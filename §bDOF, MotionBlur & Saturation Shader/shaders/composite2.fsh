#version 150
#include "/lib/recurso.glsl"

// Variables de entrada (coordenadas de textura)
varying vec2 TexCoords;

// Variables uniformes compartidas
uniform float viewWidth, viewHeight; // Dimensiones de la pantalla
uniform vec3 cameraPosition, previousCameraPosition; // Posiciones de la cámara entre cuadros
uniform mat4 gbufferPreviousProjection, gbufferProjectionInverse; // Matrices de proyección y su inversa
uniform mat4 gbufferPreviousModelView, gbufferModelViewInverse;  // Matrices de modelo/vista y su inversa
uniform sampler2D colortex0; // Textura base de color
uniform sampler2D depthtex1; // Textura que contiene los datos de profundidad

#if MOTION_BLUR == 1
// Función principal para aplicar Motion Blur
vec3 ApplyMotionBlur(vec3 baseColor, float depthValue, float noiseFactor) {
    // Motion Blur se aplica solo para píxeles más allá de cierta profundidad
    if (depthValue <= 0.60) {
        return baseColor;
    }

    // Variables iniciales para acumulación de color y peso
    float sampleCount = 0.0;
    vec3 accumulatedColor = vec3(0.0);

    // Tamaño de texel precomputado
    vec2 texelSize = 2.0 / vec2(viewWidth, viewHeight);

    // ** Optimización: Calcular posiciones una sola vez y almacenarlas en variables temporales **
    vec4 currentClipPosition = vec4(TexCoords * 2.0 - 1.0, depthValue * 2.0 - 1.0, 1.0);
    vec4 currentViewPosition = gbufferModelViewInverse * (gbufferProjectionInverse * currentClipPosition);
    currentViewPosition /= currentViewPosition.w;

    vec3 cameraMovement = cameraPosition - previousCameraPosition;

    // Calcular solo una vez las coordenadas previas en espacio de clip
    vec4 previousViewPosition = currentViewPosition + vec4(cameraMovement, 0.0);
    vec4 previousClipPosition = gbufferPreviousProjection * (gbufferPreviousModelView * previousViewPosition);
    previousClipPosition /= previousClipPosition.w;

    // ** Motion Vector calculado una vez **
    vec2 motionVector = (currentClipPosition.xy - previousClipPosition.xy) 
                        / (1.0 + length(currentClipPosition.xy - previousClipPosition.xy));
    motionVector *= MOTION_BLUR_INTENSITY * 0.02;

    // Inicialización de posición de muestreo
    vec2 samplePosition = TexCoords - motionVector * (3.5 + noiseFactor);

    // ** Bucle de muestreo optimizado **
    for (int i = 0; i < 7; ++i) {
        // Coordenadas de textura limitadas al rango válido
        vec2 clampedSample = clamp(samplePosition, texelSize, 1.0 - texelSize);

        // Acumulación directa del color
        accumulatedColor += texture2DLod(colortex0, clampedSample, 0).rgb;

        // Incrementar la posición de muestreo
        samplePosition += motionVector;
        sampleCount += 1.0;
    }

    // Retorna el promedio de colores acumulados
    return accumulatedColor / sampleCount;
}
#endif

void main() {
    // Color base
    vec3 baseColor = texture2D(colortex0, TexCoords).rgb;

    // Profundidad y factor de ruido
    float depthValue = texture2D(depthtex1, TexCoords).x;
    float noiseFactor = GenerateBayer64(gl_FragCoord.xy); // Optimizado a Bayer64

    #if MOTION_BLUR == 1
    // Aplicar Motion Blur
    baseColor = ApplyMotionBlur(baseColor, depthValue, noiseFactor);
    #endif

    // Salida final del color
    gl_FragData[0] = vec4(baseColor, 1.0);
}
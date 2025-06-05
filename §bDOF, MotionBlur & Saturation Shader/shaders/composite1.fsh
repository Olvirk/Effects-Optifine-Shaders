#version 150

#include "/lib/recurso.glsl" // Se incluye el archivo de configuración global con ajustes generales

// Variables de entrada y uniformes
varying vec2 texCoord;        // Coordenadas de textura

// Texturas de entrada
uniform sampler2D colortex0;  // Textura de color
uniform sampler2D depthtex1;  // Textura de profundidad

// Parámetros relacionados con la pantalla y la proyección
uniform float viewWidth;          // Ancho de la vista (pantalla)
uniform float viewHeight;         // Alto de la vista (pantalla)
uniform float aspectRatio;        // Relación de aspecto de la pantalla
uniform float centerDepthSmooth;  // Profundidad central para el suavizado del DOF
uniform mat4 gbufferProjection;   // Matriz de proyección utilizada para cálculos de perspectiva

// Constantes para el cálculo de muestras y los offsets del DOF
const int NUM_SAMPLES = 45;       // Número de muestras para el efecto de profundidad de campo
// Cada 'vec2' representa una muestra y tiene que tener la misma cantidad que la que establecemos en 'NUM_SAMPLES='
const vec2 dofOffsets[NUM_SAMPLES] = vec2[](
    vec2( 0.05   ,  0.28  ), vec2(-0.1903 ,  0.115 ), vec2(-0.2002 , -0.135 ),
    vec2( 0.01   , -0.22  ), vec2( 0.2107 , -0.110 ), vec2( 0.2203 ,  0.120 ),
    vec2( 0.02   ,  0.48  ), vec2(-0.22   ,  0.420 ), vec2(-0.420  ,  0.270 ),
    vec2(-0.47   ,  0.05  ), vec2(-0.420  , -0.27  ), vec2(-0.24   , -0.440 ),
    vec2( 0.03   , -0.47  ), vec2( 0.27   , -0.430 ), vec2( 0.400  , -0.18  ),
    vec2( 0.55   ,  0.03  ), vec2( 0.435  ,  0.22  ), vec2( 0.24   ,  0.430 ),
    vec2( 0.01   ,  0.73  ), vec2(-0.2397 ,  0.6988), vec2(-0.4635 ,  0.5640),
    vec2(-0.4971 ,  0.395 ), vec2(-0.7122 ,  0.1250), vec2(-0.7200 , -0.1105),
    vec2(-0.5103 , -0.370 ), vec2(-0.4780 , -0.5565), vec2(-0.2380 , -0.6810),
    vec2(-0.03   , -0.73  ), vec2( 0.2405 , -0.6900), vec2( 0.4750 , -0.5500),
    vec2( 0.5050 , -0.35  ), vec2( 0.7185 , -0.1300), vec2( 0.7250 ,  0.1150),
    vec2( 0.5100 ,  0.375 ), vec2( 0.4750 ,  0.5700), vec2( 0.2400 ,  0.6750),
    vec2( 0.00   ,  0.98  ), vec2(-0.2488 ,  0.9600), vec2(-0.4900 ,  0.865 ),
    vec2(-0.7100 ,  0.7200), vec2(-0.8700 ,  0.4950), vec2(-0.9650 ,  0.2700),
    vec2(-1.05  ,  0.02  ),  vec2(-0.9750 , -0.2500), vec2(-0.8700 , -0.4750)
);

#if DOF == 1
// Función principal que aplica el desenfoque de campo de profundidad (DOF)
vec3 depthOfField(vec3 color, float depth) {
    vec3 dof = color;  // Inicializa el color con el color original
    float handMask = float(depth < 0.6);  // Máscara para aplicar el desenfoque solo a ciertos valores de profundidad
    
    // Calcula la escala de campo de visión (FOV)
    float fovScale = gbufferProjection[1][1] / 2.0;
    
    // Cálculo del tamaño del círculo de confusión (CoC)
    float cocSize = max(abs(depth - centerDepthSmooth) * DOF_INTENSITY - 0.01, 0.0);
    cocSize = cocSize / sqrt(cocSize * cocSize + 0.1);  // Ajuste adicional para evitar tamaños de CoC demasiado grandes
    
    // Si el tamaño del CoC es mayor a 0 y pasa la máscara de profundidad, aplica el desenfoque
    if (cocSize > 0.0 && handMask < 0.5) {
        vec3 totalColor = vec3(0.0);  // Inicializa el color total como negro
        float totalWeight = 0.0;  // Inicializa el peso total como 0
        
        // Realiza el muestreo para el desenfoque, utilizando los desplazamientos definidos previamente
        for (int i = 0; i < NUM_SAMPLES; i++) {
            // Calcula el desplazamiento para cada muestra, ajustado por el tamaño del CoC y la relación de aspecto
            vec2 offset = dofOffsets[i] * cocSize * 0.015 * fovScale * vec2(1.0 / aspectRatio, 1.0);
            
            // Calcula el nivel de detalle (LOD) basado en la resolución de la pantalla y el tamaño del CoC
            float lod = log2(viewHeight * aspectRatio * cocSize * fovScale / 380.0);
            
            // Realiza la muestra de color usando la textura y las coordenadas desplazadas
            vec3 sampleColor = texture2DLod(colortex0, texCoord + offset, lod).rgb;
            float weight = 1.0 / float(NUM_SAMPLES);  // Asume un peso igual para todas las muestras
            
            // Acumula el color y el peso
            totalColor += sampleColor * weight;
            totalWeight += weight;
        }
        
        // Promedia el color acumulado para obtener el color final
        dof = totalColor / totalWeight;
    }
    
    return dof;  // Devuelve el color con el desenfoque aplicado
}
#endif

void main() {
    // Obtiene el color original de la textura de color
    vec3 color = texture2D(colortex0, texCoord).rgb;
    
    // Obtiene la profundidad del píxel desde la textura de profundidad
    float depth = texture2D(depthtex1, texCoord).r;
    
    #if DOF == 1
    // Aplica el efecto de profundidad de campo utilizando el color y la profundidad
    color = depthOfField(color, depth);
    #endif
    
    // Establece el color final para el fragmento en el framebuffer
    gl_FragData[0] = vec4(color, 1.0);  // El valor final es RGBA, con la componente alfa en 1.0 (opaco)
}

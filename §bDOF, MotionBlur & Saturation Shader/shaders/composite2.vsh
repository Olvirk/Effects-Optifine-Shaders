#version 150

// Coordenadas de textura de salida
out vec2 TexCoords;

// Entrada de posición y coordenadas de textura
void main() {
    // Calcula la posición del vértice en espacio de clip
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    // Pasa las coordenadas de textura al fragment shader
    TexCoords = gl_MultiTexCoord0.st;
}

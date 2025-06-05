const float sunPathRotation = 45.0; // [-45.0 -20.0 -10.0 0.0 10.0 20.0 45.0]

#define SATURATION 1.0 //Ajusta el nivel de saturacion [1.0 1.1 1.2 1.3 1.5 2.0 4.0 10.0 40.0 80.0]

//Profundidad de campo
#define DOF 0                       // [0 1]
#define DOF_INTENSITY 16.0          // [0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 8.0 16.0 32.0 64.0 128.0]

// Desenfoque de movimineto
#define MOTION_BLUR 0                  // Motion Blur           [0 1]
#define MOTION_BLUR_INTENSITY 1.25    // Motion Blur Intensity  [0.0 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]


#ifndef ENABLE_BAYER_PATTERNS
// Función base: Crea un patrón Bayer 2x2
float GenerateBayer2(vec2 coords) {
    // Ajusta las coordenadas al rango deseado
    coords = 0.5 * floor(coords);
    // Calcula el valor del patrón Bayer 2x2
    return fract(1.5 * fract(coords.y) + coords.x);
}
// Función para patrón Bayer 4x4, basado en Bayer 2x2
float GenerateBayer4(vec2 coords) {
    return 0.25 * GenerateBayer2(0.5 * coords) + GenerateBayer2(coords);
}
// Función para patrón Bayer 8x8, basado en Bayer 4x4
float GenerateBayer8(vec2 coords) {
    return 0.25 * GenerateBayer4(0.5 * coords) + GenerateBayer2(coords);
}
// Función para patrón Bayer 16x16, basado en Bayer 8x8
float GenerateBayer16(vec2 coords) {
    return 0.25 * GenerateBayer8(0.5 * coords) + GenerateBayer2(coords);
}
// Función para patrón Bayer 32x32, basado en Bayer 16x16
float GenerateBayer32(vec2 coords) {
    return 0.25 * GenerateBayer16(0.5 * coords) + GenerateBayer2(coords);
}
// Función para patrón Bayer 64x64, basado en Bayer 32x32
float GenerateBayer64(vec2 coords) {
    return 0.25 * GenerateBayer32(0.5 * coords) + GenerateBayer2(coords);
}
// Función para patrón Bayer 128x128, basado en Bayer 64x64
float GenerateBayer128(vec2 coords) {
    return 0.25 * GenerateBayer64(0.5 * coords) + GenerateBayer2(coords);
}
// Función para patrón Bayer 256x256, basado en Bayer 128x128
float GenerateBayer256(vec2 coords) {
    return 0.25 * GenerateBayer128(0.5 * coords) + GenerateBayer2(coords);
}
#endif
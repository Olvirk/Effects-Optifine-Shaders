#version 150

#include "/lib/recurso.glsl"

uniform sampler2D texture;
uniform sampler2D depthtex1;
uniform float viewWidth, viewHeight;
varying vec2 texcoord;



void main() {
    
    vec4 color = texture2D(texture, texcoord);

    //Caculador de iluminacion
    float iluminationColor = dot(color.rgb, vec3(0.300, 0.600, 0.120));

    //Incremento de saturacion
    vec3 grayScale = vec3(iluminationColor);
    vec3 saturated = mix(grayScale, color.rgb, SATURATION);


    gl_FragColor = vec4(saturated, color.a);

}
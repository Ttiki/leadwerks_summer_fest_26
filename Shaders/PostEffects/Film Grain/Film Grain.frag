#version 450

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"

// Uniforms
uniform float Strength = 0.1;

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 outColor;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec2 buffersize = vec2(DrawViewport.z, DrawViewport.w);

    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    outColor = texelFetch(ColorBuffer, coord, 0);
	
    outColor.rgb += vec3( rand(gl_FragCoord.xy / buffersize / 100.0 * float(CurrentTime) * outColor.rg + outColor.b) * Strength ) - Strength * 0.5;
}
#version 450

uniform float Strength = 0.5;

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    
	vec4 c = texelFetch(ColorBuffer, coord, 0);
	float l = c.r * 0.2126f + c.g * 0.7152f + c.b * 0.0722f;
	
	fragColor.rgb = mix(c.rgb, vec3(l), Strength);
	fragColor.a = c.a;
	
	//Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) fragColor.rgb += dither(DitherTexture);
}
#version 450

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
out vec4 outColor;

float contrast(float c)
{
	float a = 0.09;
	return (c - a) / (1 - 2 * a);
}

void main()
{
	outColor = textureLod(ColorBuffer, TexCoords, 0.0);

	outColor.r = contrast(outColor.r * 1.3);
	outColor.g = contrast(outColor.g + 0.05);
	outColor.b = contrast(outColor.b * 0.4 + 0.3);
	
	//Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
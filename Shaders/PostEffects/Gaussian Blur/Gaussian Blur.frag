#version 450

// Uniforms
uniform float Strength = 1.0;

// Samplers
uniform layout(binding = 0) sampler2D BlurBuffer;
uniform layout(binding = 1) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 outColor;

void main()
{
    outColor = textureLod(BlurBuffer, TexCoords, 0);
	if (Strength < 1.0)
	{
		outColor = mix(textureLod(ColorBuffer, TexCoords, 0), outColor, Strength);
	}
	
    //Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);	
}
#version 450

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

// Main function
void main()
{
	// Sample the previous pass
    fragColor = textureLod(ColorBuffer, TexCoords, 0);
    
    // Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) fragColor.rgb += dither(DitherTexture);
}
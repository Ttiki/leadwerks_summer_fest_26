#version 450

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

// Outputs
out vec4 outColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    outColor = texelFetch(ColorBuffer, coord, 0);
    outColor.r = 1.0 - clamp(outColor.r, 0.0, 1.0);
    outColor.g = 1.0 - clamp(outColor.g, 0.0, 1.0);
    outColor.b = 1.0 - clamp(outColor.b, 0.0, 1.0);
	
	//Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
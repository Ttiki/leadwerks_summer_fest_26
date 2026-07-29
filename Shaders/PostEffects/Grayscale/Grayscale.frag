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
    vec4 c = texelFetch(ColorBuffer, coord, 0);
	outColor.rgb = vec3(c.r * 0.2126f + c.g * 0.7152f + c.b * 0.0722f);
    outColor.a = c.a;
	
	//Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
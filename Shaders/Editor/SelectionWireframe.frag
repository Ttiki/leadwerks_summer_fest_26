#version 450

// Includes
#include "../Common/Materials.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"

// Samplers
layout(binding = 0) uniform sampler2D BaseColorMap;

// Inputs
in vec4 color;
flat in vec3 emissioncolor;
in vec2 texcoords;

// Outputs
out vec4 OutColor;

void main()
{
	ivec2 coord = ivec2(int(gl_FragCoord.x), int(gl_FragCoord.y));
	coord.y = DrawViewport.w - 1 - coord.y;
	OutColor = SelectionColor;
	OutColor.a = texelFetch(BaseColorMap, coord, 0).a;
	OutColor.rgb *= OutColor.a;
}


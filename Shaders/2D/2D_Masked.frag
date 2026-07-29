#version 450

// Includes
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"

// Samplers
layout(binding = 0) uniform sampler2D BaseColorMap;

// Inputs
in vec4 color;
flat in vec3 emissioncolor;
in vec2 TexCoords;

// Outputs
out vec4 outcolor;

void main()
{
    outcolor = color;
	Material material = materials[ MaterialIndex[0] ];
	outcolor *= material.diffuseColor;
	
    if ((TextureFlags & 1) != 0)
    {
        outcolor *= texture(BaseColorMap, TexCoords);
    }
	
	if (outcolor.a < material.alphacutoff) discard;
	
    if ((RenderFlags & RENDERFLAGS_TRANSPARENCY) != 0)
    {
        outcolor.rgb *= outcolor.a;
    }
}
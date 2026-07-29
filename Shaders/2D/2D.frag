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
	Material material;
	UnpackMaterial(uint(MaterialIndex[0]), material);
	outcolor *= material.diffuseColor;
	
    if ((TextureFlags & 1) != 0)
    {
        outcolor *= texture(BaseColorMap, TexCoords);
    }
	
    if ((RenderFlags & RENDERFLAGS_TRANSPARENCY) != 0)
    {
        outcolor.rgb *= outcolor.a;
    }
}
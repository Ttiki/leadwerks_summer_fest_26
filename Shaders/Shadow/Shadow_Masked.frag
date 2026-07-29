#version 450

//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"

//------------------------------------------------------
// Samplers
//------------------------------------------------------

layout(binding = 0) uniform sampler2D BaseColorMap;

//------------------------------------------------------
// Inputs
//------------------------------------------------------

in vec4 color;
in vec4 TexCoords;

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{
	Material mtl;
	UnpackMaterial(uint(MaterialIndex[0]), mtl);
	
    vec4 baseColor = color;
    if ((TextureFlags & 1) != 0) baseColor *= texture(BaseColorMap, TexCoords.xy);
    if (baseColor.a < mtl.alphacutoff) discard;
}
#version 450
#include "../Math/Math.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Entities.glsl"
#include "../Editor/Grid.glsl"
#include "../Editor/PaintBrush.glsl"

float SimpleShading(in vec3 normal)
{
	float d = dot(normal, normalize(vec3(-0.75, -1.25, 1.0)));
	if (d > 0.0) d *= 0.5;
	return abs(d) * 0.5 + 0.75;
}

layout(binding = 0) uniform sampler2D basetexture;
layout(binding = 5) uniform sampler2D basetexture2;
layout(binding = 10) uniform sampler2D basetexture3;

in flat uint EntityIndex;
in mat3 TBN;
in vec4 TexCoords;
in vec4 color;
in vec2 MaterialWeights;
in flat uint EntityFlags;
in vec4 vertexWorldPosition;

out vec4 outcolor;

void main()
{
    Material mtl;
	UnpackMaterial(MaterialIndex[0], mtl);
	
	outcolor = color * mtl.diffuseColor;
	
	if ((TextureFlags & 1) != 0) outcolor.rgb *= texture(basetexture, TexCoords.xy).rgb;
	outcolor.rgb = mix(vec3((outcolor.r + outcolor.g + outcolor.b) * 0.33333), outcolor.rgb, mtl.saturation);
	
	if (MaterialWeights[0] > 0.0 && (TextureFlags & TEXTURE_5) != 0) outcolor.rgb = mix(outcolor.rgb, texture(basetexture2, TexCoords.xy).rgb, MaterialWeights[0]);
	if (MaterialWeights[1] > 0.0 && (TextureFlags & TEXTURE_10) != 0) outcolor.rgb = mix(outcolor.rgb, texture(basetexture3, TexCoords.xy).rgb, MaterialWeights[1]);
	
	outcolor.rgb *= SimpleShading(TBN[2]);
	
	//------------------------------------------------------
    // Editor Display
    //------------------------------------------------------
    
	ShowGrid(outcolor, vertexWorldPosition.xyz, TBN[2], EntityFlags);
	ShowPaintBrush(outcolor, vertexWorldPosition.xyz);
}
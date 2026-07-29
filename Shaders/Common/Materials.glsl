#ifndef _MATERIALS_GLSL
#define _MATERIALS_GLSL

#include "StorageBufferBindings.glsl"
#include "../Math/Math.glsl"

// Material Style Flags
#define MATERIAL_ALPHABLEND 1u
#define MATERIAL_EXTRACTNORMALMAPZ 2u
#define MATERIAL_TWOSIDED 4u
#define MATERIAL_TESSELLATION 8u
#define MATERIAL_SIMPLEREFRACTION 16u
#define MATERIAL_ALBEDOALPHA 32u

// Material Texture Slots
#define TEXTURE_DIFFUSE 0
#define TEXTURE_BASE 0
#define TEXTURE_NORMAL 1
#define TEXTURE_METALLICROUGHNESS 2
#define TEXTURE_SPECULARGLOSSINESS 2
#define TEXTURE_DISPLACEMENT 3
#define TEXTURE_EMISSION 4
//#define TEXTURE_AMBIENTOCCLUSION 5
//#define TEXTURE_OPACITY 5

#define TEXTUREFLAGS_DIFFUSE 1u
#define TEXTUREFLAGS_BASECOLOR 1u
#define TEXTUREFLAGS_NORMAL 2u
#define TEXTUREFLAGS_METALLICROUGHNESS 4u
#define TEXTUREFLAGS_DISPLACEMENT 4u
#define TEXTUREFLAGS_EMISSION 16u
//#define TEXTUREFLAGS_OCCLUSION 16u
//#define TEXTUREFLAGS_OPACITY 32u

#define TEXTURE_TERRAINMASK 3
#define TEXTURE_TERRAINHEIGHT 4
#define TEXTURE_TERRAINNORMAL 5
#define TEXTURE_TERRAINMATERIAL 6
#define TEXTURE_TERRAINALPHA 7

#define TEXTURE_CLEARCOAT 7
#define TEXTURE_CLEARCOATROUGHNESS 8
#define TEXTURE_SHEEN 9
#define TEXTURE_SHEENROUGHNESS 10
#define TEXTURE_SHEENLUT 11
#define TEXTURE_CHARLIELUT 12
#define TEXTURE_DETAIL 13

struct PackedMaterial
{
	uint albedo[2];
	uint occlusion_roughness_metal_saturation;
	uint emissioncolor_alphacutoff;
	uint opticaldensity_edgesoftness;
	uint displacement;
	uint emissionscale_unused_blendsmoothing_specularweight;
	uint texturescroll;
	uint normalscale_ior;
};

struct Material
{
	vec4 diffuseColor;
	
	vec2 displacement;
	float metalness;
	float roughness;
	
	vec3 emissiveColor;
	uint flags;
	
	vec3 texturescroll;
	float alphacutoff;
	
	float saturation;
	float occlusion;	
	float opticaldensity;
	float edgesoftness;
	
	float normalscale;
	float ior;		
	float blendsmoothing;
	float specularweight;
};

layout(std430, binding = STORAGE_BUFFER_MATERIALS) readonly buffer MaterialBlock { PackedMaterial materials[]; };

void UnpackMaterial(in uint index, out Material mtl)
{
	PackedMaterial packmtl = materials[index];

	mtl.diffuseColor.rg = unpackHalf2x16(packmtl.albedo[0]);
	mtl.diffuseColor.b = unpackHalf2x16(packmtl.albedo[1]).x;
	mtl.diffuseColor.a = float(Blue(packmtl.albedo[1])) / 255.0;
	mtl.flags = Alpha(packmtl.albedo[1]);

	mtl.occlusion = float(Red(packmtl.occlusion_roughness_metal_saturation)) / 255.0;
	mtl.roughness = float(Green(packmtl.occlusion_roughness_metal_saturation)) / 255.0;
	mtl.metalness = float(Blue(packmtl.occlusion_roughness_metal_saturation)) / 255.0;
	mtl.saturation = float(Alpha(packmtl.occlusion_roughness_metal_saturation)) / 255.0;
	
	mtl.emissiveColor.r = float(Red(packmtl.emissioncolor_alphacutoff)) / 255.0;
	mtl.emissiveColor.g = float(Green(packmtl.emissioncolor_alphacutoff)) / 255.0;
	mtl.emissiveColor.b = float(Blue(packmtl.emissioncolor_alphacutoff)) / 255.0;
	mtl.alphacutoff = float(Alpha(packmtl.emissioncolor_alphacutoff)) / 255.0;
	
	vec2 v = unpackHalf2x16(packmtl.opticaldensity_edgesoftness);
	mtl.opticaldensity = v.x;
	mtl.edgesoftness = v.y;
	
	mtl.displacement = unpackHalf2x16(packmtl.displacement);
	
	float emissionscale = float(Red(packmtl.emissionscale_unused_blendsmoothing_specularweight)) / 16.0;
	mtl.emissiveColor *= emissionscale;
	
	mtl.blendsmoothing = float(Blue(packmtl.emissionscale_unused_blendsmoothing_specularweight)) / 255.0;
	mtl.specularweight = float(Alpha(packmtl.emissionscale_unused_blendsmoothing_specularweight)) / 255.0;
	
	mtl.texturescroll.xy = unpackHalf2x16(packmtl.texturescroll);
	mtl.texturescroll.z = 0.0;

	v = unpackHalf2x16(packmtl.normalscale_ior);
	mtl.normalscale = v.x;
	mtl.ior = v.y;
}

#endif

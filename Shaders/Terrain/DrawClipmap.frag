#version 450

// Includes
#include "../Common/Materials.glsl"

// Uniforms
uniform uvec4 MaterialIndex;
uniform vec3 TerrainScale;
uniform uint TextureFlags;
uniform vec3 HeightConstraints = vec3(0.0);
uniform vec3 SlopeConstraints = vec3(0.0, 15.0, 10.0);
uniform int WeightMapChannel = 0;
uniform int LayerIndex = 0;
uniform vec2 TextureScale = vec2(1.0);
uniform float TextureVerticalScale = 1.0;
uniform int TextureMappingMode = 0;
uniform vec2 TextureOffset = vec2(0.0);
uniform vec3 CameraPosition = vec3(0.0);
uniform vec2 TerrainSize;
uniform vec2 DrawClipmapArea;// = vec2(16.0);
uniform vec2 BufferSize;
uniform float LayerScale;

// Samplers
uniform layout(binding = 0) sampler2D AlbedoMap;
uniform layout(binding = 1) sampler2D NormalMap;
uniform layout(binding = 2) sampler2D PBRMap;
uniform layout(binding = 3) sampler2D DisplacementMap;
uniform layout(binding = 4) sampler2D EmissionMap;
uniform layout(binding = 5) sampler2D AlbedoMap2;
uniform layout(binding = 6) sampler2D NormalMap2;
uniform layout(binding = 7) sampler2D PBRMap2;
uniform layout(binding = 8) sampler2D DisplacementMap2;
uniform layout(binding = 9) sampler2D EmissionMap2;
uniform layout(binding = 10) sampler2D TerrainHeightMap;
uniform layout(binding = 11) sampler2D TerrainNormalMap;
uniform layout(binding = 12) sampler2D TerrainWeightMap;

// Inputs
in vec2 TexCoords;
in vec4 Position;

// Outputs
out layout(location = 0) vec4 fragColor;
out layout(location = 1) vec4 fragNormal;
out layout(location = 2) vec4 fragData;
out layout(location = 3) vec4 fragDisplacement;

vec4 terrainLookup(sampler2D tex, vec3 tc3, int mode, vec3 dirweights)
{
	vec4 c;
	switch (mode)
	{
	case 0:
		c = texture(tex, tc3.xz);
		break;
	case 1:
		c = texture(tex, tc3.xy) * dirweights.z;
		c += texture(tex, tc3.zy) * dirweights.x;
		c = c / (dirweights.x + dirweights.z);
		break;
	case 2:
		c = texture(tex, tc3.xy) * dirweights.z;
		c += texture(tex, tc3.xz) * dirweights.y;				
		c += texture(tex, tc3.zy) * dirweights.x;
		c = c / (dirweights.x + dirweights.y + dirweights.z);
		break;			
	}
	return c;
}

void main()
{
	vec2 clipmapratio = DrawClipmapArea / TerrainSize;
	vec2 clipmapbufferratio = DrawClipmapArea / BufferSize;
	
	vec2 texcoords = TexCoords * vec2(-1,1);
	texcoords = (texcoords - 0.5) * (0.5 * (DrawClipmapArea / TerrainSize)) * 2.0;
	texcoords += 0.5;
	texcoords.x += clipmapratio.x;
	vec2 texcoords2 = texcoords;
	
	texcoords += vec2(-CameraPosition.x, CameraPosition.z) / (DrawClipmapArea) * clipmapratio;
	
	texcoords2 += vec2(-CameraPosition.x, CameraPosition.z) / (DrawClipmapArea) * clipmapratio;
	
	texcoords2.x = 1.0 - mod(texcoords2.x, 1.0);
	texcoords2.y = mod(texcoords2.y, 1.0);
	
	texcoords *= TextureScale * 1.0;	
	//texcoords *= TextureScale / (DrawClipmapArea / TerrainSize * 4.0);	

	float alpha = 1.0;	
	if (LayerIndex != 0)
	{
		alpha = textureLod(TerrainWeightMap, texcoords2, 0.0)[WeightMapChannel];
		if (alpha == 0.0) discard;
	}	
	
	float height = textureLod(TerrainHeightMap, texcoords2, 0.0).r * TerrainScale.y;

	vec3 tc3;
	tc3.xz = texcoords;
	tc3.y = -height / TextureVerticalScale;
	
	vec3 tn;
	tn.xz = textureLod(TerrainNormalMap, texcoords2, 0.0).rg * 2.0 - 1.0;
	tn.y = 1.0 - min(1.0, sqrt(tn.x * tn.x + tn.z * tn.z));
	tn = normalize(tn);
	
	mat3 tbn;
	tbn[0] = vec3(1,0,0);
	tbn[1] = vec3(0,0,1);
	tbn[2] = tn;
	
	vec3 dirweights;
	dirweights.x = abs(dot(tn, vec3(1,0,0)));
	dirweights.y = abs(dot(tn, vec3(0,1,0)));
	dirweights.z = abs(dot(tn, vec3(0,0,1)));
	dirweights *= dirweights * dirweights * dirweights;
	//dirweights = normalize(dirweights * dirweights * dirweights);
	
	Material mtl;
	UnpackMaterial(uint(MaterialIndex[0]), mtl);
	
	if (LayerIndex != 0)
	{
		//--------------------------------------------------------------------
		// Slope Constraints
		//--------------------------------------------------------------------
		
		float slope = 90.0 - asin(tn.y) * 57.2957795;
		alpha *= (1.0 - clamp(SlopeConstraints.x - slope, 0.0, SlopeConstraints.z) / SlopeConstraints.z);
		alpha *= (1.0 - clamp(slope - SlopeConstraints.y, 0.0, SlopeConstraints.z) / SlopeConstraints.z);
		
		//--------------------------------------------------------------------
		// Height Constraints
		//--------------------------------------------------------------------
		
		if (!isnan(HeightConstraints.x) || !isnan(HeightConstraints.y))
		{			
			if (!isnan(HeightConstraints.x)) alpha *= 1.0 - clamp(HeightConstraints.x-height,0.0,HeightConstraints.z)/HeightConstraints.z;
			if (!isnan(HeightConstraints.y)) alpha *= 1.0 - clamp(height-HeightConstraints.y,0.0,HeightConstraints.z)/HeightConstraints.z;
		}
	
		if (alpha == 0.0) discard;
	}
	
	//--------------------------------------------------------------------
	// Albedo
	//--------------------------------------------------------------------
	
	fragColor = mtl.diffuseColor;
	if ((TextureFlags & 1u) != 0)
	{
		fragColor *= terrainLookup(AlbedoMap, tc3, TextureMappingMode, dirweights);
	}
	if (mtl.saturation != 1.0) fragColor.rgb = mix(vec3((fragColor.r + fragColor.g + fragColor.b) * 0.33333), fragColor.rgb, mtl.saturation);
	fragColor.a = alpha;
	
	//--------------------------------------------------------------------
	// Normal
	//--------------------------------------------------------------------
	
	if ((TextureFlags & 2u) != 0)
	{
		vec3 normal = texture(NormalMap, texcoords).rgb * 2.0 - 1.0;
		normal.z = 1.0 - sqrt(normal.x * normal.x + normal.y * normal.y);
		fragNormal.rgb = (tbn * normalize(normal)) * 0.5 + 0.5;
	}
	else
	{
		fragNormal.rgb = tn.xyz * 0.5 + 0.5;
		//fragNormal = vec4(0.5, 1.0, 0.5, 1.0);
	}
	fragNormal.a = alpha;
	
	//--------------------------------------------------------------------
	// Roughness / Metalness / Terrain blend
	//--------------------------------------------------------------------
	
	fragData.r = 0.0;
	fragData.g = mtl.roughness;
	if ((TextureFlags & 4u) != 0)
	{
		fragData.gb *= terrainLookup(PBRMap, tc3, TextureMappingMode, dirweights).gb;
	}
	fragData.g = 1.0;
	fragData.a = alpha;
	
	//--------------------------------------------------------------------
	// Displacement Map
	//--------------------------------------------------------------------
	
	fragDisplacement = vec4(0,0,0,alpha);
	if ((TextureFlags & 8u) != 0)
	{
		fragDisplacement.r = terrainLookup(DisplacementMap, tc3, TextureMappingMode, dirweights).r;
		fragDisplacement.r = fragDisplacement.r * mtl.displacement.x + mtl.displacement.y;
		fragDisplacement.r *= LayerScale * 2.56;
		 
		float influence = max(0.0, (fragDisplacement.r - 0.01) * 10.0);
		float maxInfluence = min(1.0, alpha * 4.0);
		alpha += clamp(influence * maxInfluence, 0.0, 1.0);
		alpha = clamp(alpha, 0.0, 1.0);
	}
	
	//--------------------------------------------------------------------
	// Emission Map
	//--------------------------------------------------------------------
	
	if ((TextureFlags & 16u) != 0)
	{
		if (mtl.emissiveColor.r > 0.0 || mtl.emissiveColor.g > 0.0 || mtl.emissiveColor.b > 0.0)
		{
			vec3 emissive = terrainLookup(EmissionMap, tc3, TextureMappingMode, dirweights).rgb;
			if (emissive.r > 0.0 || emissive.g > 0.0 || emissive.b > 0.0)
			{
				emissive *= mtl.emissiveColor;
				fragData.r = max(max(emissive.r, emissive.g), emissive.b);
				if (fragData.r > 0.0)
				{
					fragData.r = min(fragData.r, 1.0);
					fragColor.rgb = mix(fragColor.rgb, emissive.rgb / fragData.r, fragData.r);				
				}	
			}
		}
	}
	else
	{
		fragData.r = 0.0;
	}
	
	//--------------------------------------------------------------------
	// Pre-multiply Alpha
	//--------------------------------------------------------------------
	
	fragColor.a = alpha;
	fragNormal.a = alpha;
	fragData.a = alpha;
	fragDisplacement.a = alpha;
	
	if (LayerIndex != 0)
	{
		fragColor.rgb *= alpha;
		fragNormal.rgb *= alpha;
		fragData.rgb *= alpha;
		fragDisplacement.rgb *= alpha;
	}
}
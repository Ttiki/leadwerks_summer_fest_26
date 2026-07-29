#ifndef _MULTIMATERIAL
	#define _MULTIMATERIAL

// Calculate the smooth interpolation factor directly	
float CalculateBlendAlpha(in float alpha, in float smoothness)
{    
    return clamp((alpha - (0.5 - smoothness * 0.5)) / (smoothness), 0.0, 1.0);
}

#if MAX_MATERIALS > 1

void MultiMaterial2(in Material mtl, in float weight, in vec2 texcoords, in mat3 TBN, inout vec4 albedo, inout vec3 normal, inout vec4 omr, inout vec3 emissive)
{
	vec4 subalbedo = mtl.diffuseColor;
	if ((TextureFlags & TEXTURE_5) != 0)
	{
		subalbedo *= texture(BaseColorMap2, texcoords.xy, BaseTextureLodBias);
		subalbedo.rgb = mix(vec3(subalbedo.r + subalbedo.g + subalbedo.b) * 0.3333333, subalbedo.rgb, mtl.saturation);
	}
	if ((mtl.flags & MATERIAL_ALPHABLEND) != 0) weight *= subalbedo.a;
	
	if ((TextureFlags & TEXTURE_8) != 0)
	{
		weight += (texture(DisplacementMap2, texcoords).r - 0.5) * weight;
		weight = clamp(weight, 0.0f, 1.0f);
	}	
	weight = CalculateBlendAlpha(weight, mtl.blendsmoothing);
	
	if ((TextureFlags & TEXTURE_6) != 0)
	{
		vec3 n = texture(NormalMap2, texcoords.xy, TextureLodBias).rgb * 2.0 - 1.0;
		n.xy *= mtl.normalscale;
		if ((mtl.flags & MATERIAL_EXTRACTNORMALMAPZ) != 0)
		{
			n.z = sqrt(max(0.0, 1.0 - (n.x * n.x + n.y * n.y)));
		}
        n = TBN * n;
		normal = normalize(mix(normal, n, weight));
	}
	
	if ((TextureFlags & TEXTURE_7) != 0)
	{
		vec3 subomr = texture(MetallicRoughnessMap2, texcoords.xy, TextureLodBias).rgb;
		subomr.g *= mtl.roughness;
		subomr.b *= mtl.metalness;	
		subalbedo.rgb *= mix(1.0, subomr.r, mtl.occlusion );
		omr.gb = mix(omr.gb, subomr.gb, weight);	
	}
	
	if ((TextureFlags & TEXTURE_9) != 0)
	{
		vec3 subemmissive = texture(EmissionMap2, texcoords.xy, TextureLodBias).rgb;
		emissive = mix(emissive, subemmissive, weight);
	}
	
	if ((mtl.flags & MATERIAL_ALBEDOALPHA) == 0) albedo.rgb = mix(albedo.rgb, subalbedo.rgb, weight);
}

#endif

#if MAX_MATERIALS == 3

void MultiMaterial3(in Material mtl, in float weight, in vec2 texcoords, in mat3 TBN, inout vec4 albedo, inout vec3 normal, inout vec4 omr, inout vec3 emissive)
{
	vec4 subalbedo = mtl.diffuseColor;
	if ((TextureFlags & TEXTURE_10) != 0)
	{
		subalbedo *= texture(BaseColorMap3, texcoords.xy, BaseTextureLodBias);
		subalbedo.rgb = mix(vec3(subalbedo.r + subalbedo.g + subalbedo.b) * 0.3333333, subalbedo.rgb, mtl.saturation);
	}
	if ((mtl.flags & MATERIAL_ALPHABLEND) != 0) weight *= subalbedo.a;
	
	if ((TextureFlags & TEXTURE_13) != 0)
	{
		weight += (texture(DisplacementMap3, texcoords).r - 0.5) * weight;
		weight = clamp(weight, 0.0f, 1.0f);
	}	
	weight = CalculateBlendAlpha(weight, mtl.blendsmoothing);
	
	if ((TextureFlags & TEXTURE_11) != 0)
	{
		vec3 n = texture(NormalMap3, texcoords.xy, TextureLodBias).rgb * 2.0 - 1.0;
		n.xy *= mtl.normalscale;
		if ((mtl.flags & MATERIAL_EXTRACTNORMALMAPZ) != 0)
		{
			n.z = sqrt(max(0.0, 1.0 - (n.x * n.x + n.y * n.y)));
        }
		n = TBN * n;
		normal = normalize(mix(normal, n, weight));
	}
	
	if ((TextureFlags & TEXTURE_12) != 0)
	{
		vec3 subomr = texture(MetallicRoughnessMap3, texcoords.xy, TextureLodBias).rgb;
		subomr.g *= mtl.roughness;
		subomr.b *= mtl.metalness;	
		subalbedo.rgb *= mix(1.0, subomr.r, mtl.occlusion );
		omr.gb = mix(omr.gb, subomr.gb, weight);	
	}
	
	if ((TextureFlags & TEXTURE_14) != 0)
	{
		vec3 subemmissive = texture(EmissionMap3, texcoords.xy, TextureLodBias).rgb;
		emissive = mix(emissive, subemmissive, weight);
	}
	
	if ((mtl.flags & MATERIAL_ALBEDOALPHA) == 0) albedo.rgb = mix(albedo.rgb, subalbedo.rgb, weight);
}

#endif

#endif
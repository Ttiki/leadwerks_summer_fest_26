void DrawBoxLight(in int sampleindex, in vec3 albedo, in vec3 normal, in vec3 position, inout vec3 diffuse, inout vec3 specular, in float occlusion, in float roughness, in float metalness, in uint flags)
{
    vec4 color = LightColor;
    color.rgb = sRGBToLinear(color.rgb);
    
    vec3 shadowcoord = (LightMatrix * vec4(position, 1.0f)).xyz;
    shadowcoord.xy /= LightArea;
    shadowcoord.y *= -1.0f;
    shadowcoord.xy += 0.5f;
    
    if (shadowcoord.x > 1.0 || shadowcoord.x < 0.0 || shadowcoord.y > 1.0 || shadowcoord.y < 0.0 || shadowcoord.z < LightRange.x || shadowcoord.z > LightRange.y) return;

	shadowcoord.z *= 0.99;
    shadowcoord.z = (shadowcoord.z - LightRange.x) / (LightRange.y - LightRange.x);
    //shadowcoord.z -= 0.002f / ((LightRange.y - LightRange.x) / 10.0);
	
	// Calculate shadowmap bias
	float dn = dot(LightDirection, normal);	
	float shadowangle = acos(abs(dn));// angle of the light hitting the surface, in radians
	float shadowmapsize = textureSize(ShadowMap, 0).x;// resolution of the shadow map texture										
	float biasFactor = 0.005;
	float sampleBias = (1.0 - abs(dn)) * biasFactor;
	float resolutionBias = 512.0 / shadowmapsize;
	float areabias = max(LightArea.x, LightArea.y) / 1.0;
	float totalBias = sampleBias * resolutionBias * areabias;
	shadowcoord.z -= totalBias;
	
    float attenuation = 1.0;
	
	if (ShadowMode == 1)
	{
		attenuation *= shadowSample(ShadowMap, vec4(shadowcoord.x, shadowcoord.y, 0.0, shadowcoord.z), sampleindex).r;
		if (attenuation <= 0.0) return;
	}

    vec3 lightdir = LightDirection;

	if ((flags & PIXELFLAGS_TWOSIDED) != 0 && dot(lightdir, normal) > 0.0)
	{
		lightdir *= -1.0;
		attenuation *= 0.5;
	}
	
	// BSTF
    vec3 n = normal;
    vec3 v = normalize(CameraPosition - position.xyz);
	vec3 l = -lightdir; // Direction from surface point to light
	vec3 h = normalize(l + v); // Direction of the vector between l and v, called halfway vector

	float NdotL = clampedDot(n, l);
	float NdotH = clampedDot(n, h);
	float VdotH = clampedDot(v, h);
    float NdotV = clampedDot(n, v);

	if (NdotL > 0.0 || NdotV > 0.0)
	{
        float specularweight = 1.0;

        float perceptualRoughness = clamp(roughness, 0.04, 1.0);
        float alphaRoughness = perceptualRoughness * perceptualRoughness;
        vec3 f0 = vec3(0.04);
        f0 = mix(f0, albedo, metalness);
        vec3 f90 = vec3(1.0);
        vec3 c_diff = mix(albedo,  vec3(0.0), metalness);
        
        diffuse += color.rgb * attenuation * NdotL * BRDF_lambertian(f0, f90, c_diff, specularweight, VdotH);
        if ((flags & PIXELFLAGS_BACKFACING) == 0)
		{
			specular += color.rgb * attenuation * NdotL * BRDF_specularGGX(f0, f90, alphaRoughness, specularweight, VdotH, NdotL, NdotV, NdotH);
		}		
	}
}
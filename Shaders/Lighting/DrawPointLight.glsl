int getMajorAxis(in vec3 vn)
{
	vec3 v = abs(vn);
	return v.y > v.x ? ( v.z > v.y ? 2 : 1 ) : ( v.z > v.x ? 2 : 0 );
}

void DrawPointLight(in int sampleindex, in vec3 albedo, in vec3 normal, in vec3 position, inout vec3 diffuse, inout vec3 specular, in float occlusion, in float roughness, in float metalness, uint flags)
{
    vec3 lightdir = position - LightDirection;
    float length = length(lightdir);
    if (length > LightRange.y) return;
    lightdir /= length;

    vec4 color = LightColor;
    color.rgb = sRGBToLinear(color.rgb);

    //float dp = 1.0f - dot(normal, lightdir);
    //float angle = radians(90.0f * dp);

    float attenuation = 1.0 - (length / LightRange.y);
	if (LightFalloffMode == 0) attenuation = sqrt(attenuation);
	
	if (ShadowMode == 1)
	{
		vec3 shadowcoord = position - LightDirection;
		//shadowcoord = normalize(shadowcoord);
		int majoraxis = getMajorAxis(shadowcoord);
		int face = majoraxis * 2;
		if (shadowcoord[majoraxis] < 0.0) ++face;
		
		switch (face)
		{
		case 0:
			shadowcoord.xyz = shadowcoord.zyx * vec3(-1.0f, -1.0f, 1.0f);
			break;
		case 1:
			shadowcoord.xyz = shadowcoord.zyx * vec3(1.0f, -1.0f, -1.0f);
			break;
		case 2:
			shadowcoord.xyz = shadowcoord.xzy * vec3(1.0f, 1.0f, 1.0f);
			break;
		case 3:
			shadowcoord.xyz = shadowcoord.xzy * vec3(1.0f, -1.0f, -1.0f);
			break;				
		case 4:
			shadowcoord.xyz = shadowcoord.xyz * vec3(1.0f, -1.0f, 1.0f);
			break;
		case 5:
			shadowcoord.xyz = shadowcoord.xyz * vec3(-1.0f, -1.0f, -1.0f);
			break;				
		}
		
		shadowcoord.xy /= shadowcoord.z * 2.0;
		shadowcoord.xy += 0.5;
		shadowcoord.z *= 0.99;
		shadowcoord.z = PositionToDepth(shadowcoord.z, LightRange);

		// Calculate shadowmap bias
		float dn = dot(lightdir, normal);	
		float shadowangle = acos(abs(dn));// angle of the light hitting the surface, in radians
		float shadowmapsize = textureSize(ShadowMap, 0).x;// resolution of the shadow map texture										
		float biasFactor = 0.0005;
		float sampleBias = (1.0 + dn) * biasFactor;
		float resolutionBias = 512.0 / shadowmapsize;
		float totalBias = sampleBias * resolutionBias;
		shadowcoord.z -= totalBias;
		
		vec4 cubeshadowcoord;
		cubeshadowcoord.xyw = shadowcoord;
		cubeshadowcoord.z = face;
		attenuation *= shadowSample(ShadowMap, cubeshadowcoord, sampleindex).r;

		if (attenuation <= 0.0) return;
	}
	
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

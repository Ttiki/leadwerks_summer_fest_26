#include "DrawIBL.glsl"
#include "../Common/Vendor.glsl"

void DrawDirectionalLight(in int sampleindex, in vec3 albedo, in vec3 normal, in vec3 position, inout vec3 diffuse, inout vec3 specular, in float occlusion, in float roughness, in float metalness, in float specularweight, uint flags, inout vec3 indirectdiffuse, inout vec3 indirectspecular, float probealpha)
{
    vec4 color = LightColor;
    float attenuation = 0.0;

    vec3 lightdir = LightDirection;

    // Two-sided Lighting
	float maxattenuation = 1.0;
    vec3 onorm = normal;
    if ((flags & PIXELFLAGS_TWOSIDED) != 0 && (dot(lightdir, normal) > 0.0))
	{
		lightdir *= -1.0;
		maxattenuation = 0.5;
	}

    // Non-directional Lighting
    //if ((flags & PIXELFLAGS_IGNORENORMALS) != 0) normal = -lightdir; 
	
	// This strange logic is needed to eliminate discontinuity on AMD 6600 cards
	float dn = dot(normal, lightdir);
    if (dn > 0.0) maxattenuation = 0.0;
	
	color.rgb = sRGBToLinear(color.rgb);
	attenuation = maxattenuation;
	
	if (ShadowMode == 1)
	{
		float dist = length(CameraPosition - position);
		//vec3 camspacepos = (InverseCameraMatrix * vec4(position, 1.0)).xyz;
		if (dist < LightPartitionDistance[ShadowPartitions - 1])
		{
			vec4 shadowcoord;
			
			// Determine which CSM partiion to use based on Z-distance
			int layer = ShadowPartitions - 1;
			float shadowattenuation = 1.0;
			float shadowangle;
			float shadowaarea;
			float shadowmapsize = textureSize(ShadowMap, 0).x;// resolution of the shadow map texture										
			float biasFactor = 0.000025;
			float sampleBias;
			//float sampleBias = (1.0 - (abs(dn))) * biasFactor;
			float resolutionBias = 1024.0 / shadowmapsize * (shadowaarea / 2.0);
			float totalBias = sampleBias * resolutionBias;
			float shadowstrength = 1.0;
			
			for (layer = 0; layer < ShadowPartitions; ++layer)
			{
				//if (dist < LightPartitionDistance[layer])
				{
					//if (ShadowPartitions > 3 && dist < LightPartitionDistance[2]) layer = 2;
					//if (ShadowPartitions > 2 && dist < LightPartitionDistance[1]) layer = 1;
					//if (dist < LightPartitionDistance[0]) layer = 0;
					
					shadowcoord = LightMatrix[layer] * vec4(position, 1.0f);
					shadowcoord.xy /= LightArea[layer];
					shadowcoord.y *= -1.0f;
					shadowcoord.xy += 0.5f;
					shadowcoord.z = (shadowcoord.z - LightRange.x) / (LightRange.y - LightRange.x);
					
					shadowangle = acos(-dn);// angle of the light hitting the surface, in radians
					shadowaarea = LightArea[layer].x;// area the shadow map covers
					shadowmapsize = textureSize(ShadowMap, 0).x;// resolution of the shadow map texture										
					biasFactor = 0.000025;
					sampleBias = (acos(abs(dn)) / 3.14159265358979323846) * biasFactor;
					//float sampleBias = (1.0 - (abs(dn))) * biasFactor;
					resolutionBias = 1024.0 / shadowmapsize * (shadowaarea / 2.0);
					totalBias = sampleBias * resolutionBias;
					shadowcoord.z -= totalBias + 0.000001;					
					
					// Calculate shadow offset
					//shadowcoord.z -= 0.0002f / ((LightRange.y - LightRange.x) / 10.0);
					
					shadowcoord.w = shadowcoord.z;				
					shadowcoord.z = layer;
					
					float ss = mix(1.0, shadowSample(ShadowMap, shadowcoord, sampleindex), shadowstrength);
					
					if (dist < LightPartitionDistance[layer])
					{
						shadowattenuation *= ss;
						shadowstrength = 0.0;
#ifdef VENDOR_NVIDIA					
						break;
#endif
					}
				}
			}
			
			// Fade final stage out
			if (dist > LightPartitionDistance[ShadowPartitions - 2])
			{
				float faderange = (LightPartitionDistance[ShadowPartitions - 1] - LightPartitionDistance[ShadowPartitions - 2]) * 0.25;
				float fadestart = LightPartitionDistance[ShadowPartitions - 1] - faderange;
				if (dist > fadestart)
				{
					float p = clamp((dist - fadestart) / faderange, 0.0, 1.0);
					shadowattenuation = mix(shadowattenuation, 1.0, p);                
				}
			}

			attenuation *= shadowattenuation;
		}
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
	
    float perceptualRoughness = clamp(roughness, 0.04, 1.0);
    float alphaRoughness = perceptualRoughness * perceptualRoughness;
    vec3 f0 = vec3(0.04);
    f0 = mix(f0, albedo, metalness);
    vec3 f90 = vec3(1.0);
    vec3 c_diff = mix(albedo,  vec3(0.0), metalness);
    
    if (attenuation > 0.0 && (NdotL > 0.0 || NdotV > 0.0))
    {
		vec3 c = color.rgb * attenuation * NdotL * BRDF_lambertian(f0, f90, c_diff, specularweight, VdotH);		
        diffuse += c;
		if ((flags & PIXELFLAGS_BACKFACING) == 0)
        {
        	//if (dot(onorm, v) > 0.0f)// No specular if normal is facing away from camera no, that is not exactly right...
            {
				vec3 spec = BRDF_specularGGX(f0, f90, alphaRoughness, specularweight, VdotH, NdotL, NdotV, NdotH);
				spec = min(spec, vec3(1.0));
                specular += color.rgb * attenuation * NdotL * spec;
            }
        }
    }
    
    if (probealpha < 1.0 && IBLIntensity > 0.0f)
    {
        DrawIBL(indirectdiffuse, indirectspecular, 1.0 - probealpha, normal, v, perceptualRoughness, c_diff, f0, specularweight, occlusion, flags);
    }
}
void DrawIBL(inout vec3 diffuse, inout vec3 specular, in float alpha, in vec3 normal, in vec3 v, in float perceptualRoughness, in vec3 c_diff, in vec3 f0, in float specularweight, in float occlusion, in uint flags)
{
	vec3 linearfogcolor;
	if (FogColor.a > 0.0 && FogAngles.y > 0.0) linearfogcolor = sRGBToLinear(FogColor.rgb);

    // Diffuse Image-based Lighting
    if ((TextureFlags & TEXTURE_14) != 0)
    {
        vec4 ibldiffuse = vec4(0.0);    
        if (ibldiffuse.a < 1.0f && IBLIntensity > 0.0f)
        {
            ibldiffuse.rgb = sRGBToLinear(textureLod(DiffuseEnvironmentMap, normal, 0.0).rgb) * (1.0f - ibldiffuse.a) * IBLIntensity;
			/*if (FogColor.a > 0.0 && FogAngles.y > 0.0)
			{
				float slope = degrees(asin(normal.y));
				if (slope < FogAngles.y)
				{
					float fog = clamp(1.0f - ((slope - FogAngles.x) / (FogAngles.y - FogAngles.x)), 0.0f, 1.0f) * FogColor.a;
					ibldiffuse.rgb = mix(ibldiffuse.rgb, linearfogcolor, fog);
				}
			}*/
        }
        
        ibldiffuse *= occlusion;
        if (ibldiffuse.r + ibldiffuse.g + ibldiffuse.b > 0.0f)
        {
            diffuse += getIBLRadianceLambertian(Lut_GGX, ibldiffuse.rgb, normal, v, perceptualRoughness, c_diff, f0, specularweight) * alpha;
        }
    }
    
    // Specular Image-based Lighting
    if ((TextureFlags & TEXTURE_15) != 0)
    {
        //if ((flags & PIXELFLAGS_BACKFACING) == 0)// No specular for back-face lighting
        {
            vec4 iblspecular = vec4(0.0);
            if (iblspecular.a < 1.0 && IBLIntensity > 0.0)
            {
                int u_MipCount = textureQueryLevels(SpecularEnvironmentMap);
                float lod = perceptualRoughness * float(u_MipCount - 1);
                //lod = min(lod, 5.0);
				vec3 r = reflect(-v, normal);
                iblspecular.rgb = textureLod(SpecularEnvironmentMap, r, lod).rgb * (1.0f - iblspecular.a) * IBLIntensity;
				if (FogColor.a > 0.0 && FogAngles.y > 0.0)
				{
					float slope = degrees(asin(r.y));
					if (slope < FogAngles.y)
					{
						float fog = clamp(1.0f - ((slope - FogAngles.x) / (FogAngles.y - FogAngles.x)), 0.0f, 1.0f) * FogColor.a;
						fog *= 1.0 - perceptualRoughness;
						iblspecular.rgb = mix(iblspecular.rgb, linearfogcolor, fog);
					}
				}
            }
            
            //indirectlighting += iblspecular.rgb;
			
            iblspecular *= occlusion;
            if (iblspecular.r + iblspecular.g + iblspecular.b > 0.0f)
            {
                iblspecular.rgb = sRGBToLinear(iblspecular.rgb) * SkyIntensity;
				vec3 sn = normal;
                if (dot(sn, v) < 0.0f) sn *= -1.0f;
                specular += getIBLRadianceGGX(Lut_GGX, iblspecular.rgb, sn, v, perceptualRoughness, f0, specularweight) * alpha;
            }
        }
    }
}

float BoxIntersectsRay(in vec3 bounds0, in vec3 bounds1, in vec3 rpos, in vec3 dir)
{
    float t[10];
    vec3 rdir = 1.0f / dir;
    t[1] = (bounds0.x - rpos.x) * rdir.x;
    t[2] = (bounds1.x - rpos.x) * rdir.x;
    t[3] = (bounds0.y - rpos.y) * rdir.y;
    t[4] = (bounds1.y - rpos.y) * rdir.y;
    t[5] = (bounds0.z - rpos.z) * rdir.z;
    t[6] = (bounds1.z - rpos.z) * rdir.z;
    t[7] = max(max(min(t[1], t[2]), min(t[3], t[4])), min(t[5], t[6]));
    t[8] = min(min(max(t[1], t[2]), max(t[3], t[4])), max(t[5], t[6]));
    t[9] = (t[8] < 0 || t[7] > t[8]) ? -1.0f : t[7];
    return t[9];
}

void DrawProbe(in uint probeindex, in vec3 albedo, in vec3 normal, in vec3 position, inout vec3 diffuse, inout vec3 specular, in float occlusion, in float roughness, in float metalness, out float alpha, in mat4 LightMatrix, in vec4 BackgroundColor, in vec3 FadeDistance0, in vec3 FadeDistance1)
{
    vec3 gposition = position;
    alpha = 0.0;
    position = (LightMatrix * vec4(position, 1.0f)).xyz;
    vec3 shadowcoord = position;
    shadowcoord.y *= -1.0f;
    shadowcoord.xy += 0.5f;
    float extra = 0.05;
    if (shadowcoord.x > 1.0 + extra || shadowcoord.x < -extra || shadowcoord.y > 1.0 + extra || shadowcoord.y < -extra || shadowcoord.z > 0.5 + extra || shadowcoord.z < -0.5 - extra) return;
    
    alpha = 1.0;
    if (FadeDistance0.x != 0.0 && position.x < -0.5 + FadeDistance0.x) alpha *= (position.x + 0.5) / (FadeDistance0.x);
    if (FadeDistance0.y != 0.0 && position.y < -0.5 + FadeDistance0.y) alpha *= (position.y + 0.5) / (FadeDistance0.y);
    if (FadeDistance0.z != 0.0 && position.z < -0.5 + FadeDistance0.z) alpha *= (position.z + 0.5) / (FadeDistance0.z);
    if (FadeDistance1.x != 0.0 && position.x > 0.5 - FadeDistance1.x) alpha *= 1.0 - (position.x - (0.5 - FadeDistance1.x)) / FadeDistance1.x;
    if (FadeDistance1.y != 0.0 && position.y > 0.5 - FadeDistance1.y) alpha *= 1.0 - (position.y - (0.5 - FadeDistance1.y)) / FadeDistance1.y;
    if (FadeDistance1.z != 0.0 && position.z > 0.5 - FadeDistance1.z) alpha *= 1.0 - (position.z - (0.5 - FadeDistance1.z)) / FadeDistance1.z;
    
    alpha = max(alpha, 0.0);
    if (alpha == 0.0) return;

	// BSTF - Transform everything into local space
    vec3 n = normalize(mat3(LightMatrix) * normal);
    vec3 lcampos = (LightMatrix * vec4(CameraPosition, 1.0)).xyz;
    vec3 v = normalize(lcampos - position.xyz);
    float perceptualRoughness = clamp(roughness, 0.04, 1.0);
    float alphaRoughness = perceptualRoughness * perceptualRoughness;
    vec3 f0 = vec3(0.04);
    f0 = mix(f0, albedo, metalness);
    vec3 f90 = vec3(1.0);
    vec3 c_diff = mix(albedo,  vec3(0.0), metalness);
    float specularweight = 1.0;

    //-----------------------------------------------------------
    // Diffuse Reflection
    //-----------------------------------------------------------
    
    vec4 cubecoord;
    cubecoord.xyz = n;
    cubecoord.w = float(probeindex);
    vec4 ibldiffuse = textureLod(DiffuseMap, cubecoord, 0);    
    if (ibldiffuse.r > 0.0 || ibldiffuse.g > 0.0 || ibldiffuse.b > 0.0)
    {        
        ibldiffuse.rgb = sRGBToLinear(ibldiffuse.rgb);
        diffuse += getIBLRadianceLambertian(Lut_GGX, ibldiffuse.rgb, n, v, perceptualRoughness, c_diff, f0, specularweight);
    }
    
    //-----------------------------------------------------------
    // Specular Reflection
    //-----------------------------------------------------------

    int u_MipCount = textureQueryLevels(SpecularMap);
    float lod = perceptualRoughness * float(u_MipCount - 1);
    //lod = min(lod, 5.0);
    
    vec3 reflection = reflect(-v, n);
    vec3 orig = position + reflection * 2.0;
    float dist = BoxIntersectsRay(vec3(-0.5f),  vec3(0.5f), orig, -reflection);
    cubecoord.xyz = orig - reflection * dist;
    
    vec4 iblspecular = textureLod(SpecularMap, cubecoord, lod);
	alpha *= iblspecular.a;
	
    /*if (iblspecular.a < 1.0)
    {
        if ((TextureFlags & 4096) != 0)
        {
            // Blend with sky specular reflection map
            vec3 v = normalize(CameraPosition - gposition.xyz);
            reflection = reflect(-v, normal);
            iblspecular.rgb = mix(textureLod(SpecularEnvironmentMap, reflection, lod).rgb, iblspecular.rgb, iblspecular.a);
        }
        else
        {
            // Blend with background color
            iblspecular.rgb = mix(BackgroundColor.rgb, iblspecular.rgb, iblspecular.a);
        }
    }*/
    if (iblspecular.r > 0.0 || iblspecular.g > 0.0 || iblspecular.b > 0.0f)
    {
        iblspecular.rgb = sRGBToLinear(iblspecular.rgb);
        vec3 sn = n;
        //if (dot(sn, v) < 0.0f) sn *= -1.0f;
        specular += getIBLRadianceGGX(Lut_GGX, iblspecular.rgb, sn, v, perceptualRoughness, f0, specularweight);
    }
	//specular = diffuse;
}
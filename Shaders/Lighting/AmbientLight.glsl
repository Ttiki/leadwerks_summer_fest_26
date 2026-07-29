// Uniforms
//uniform vec3 AmbientLight = vec3(0.0f);
uniform vec3 LightDirection = vec3(0,0,1);
uniform vec4 LightColor = vec4(1.0f);
uniform mat4 LightProjectionMatrix[4];
//uniform vec3 CameraPosition;
//uniform mat4 CameraMatrix;
//uniform ivec4 DrawViewport;
//uniform uint TextureFlags = 0;
//uniform float IBLIntensity = 1.0;
//uniform vec4 FogColor;
//uniform vec2 FogAngles;
//uniform vec2 FogRange;
//uniform float FogDensity;
//uniform int ToneMappingMode = -1;
//uniform vec4 BackgroundColor = vec4(0.0);
//uniform vec3 SkyColor = vec3(1.0);
#ifdef MSAASAMPLES
    uniform vec2 SampleLocations[MSAASAMPLES];
#endif

// Texture Slots
#define TEXTURE_0 1u
#define TEXTURE_1 2u
#define TEXTURE_2 4u
#define TEXTURE_3 8u
#define TEXTURE_4 16u
#define TEXTURE_5 32u
#define TEXTURE_6 64u
#define TEXTURE_7 128u
#define TEXTURE_8 256u
#define TEXTURE_9 512u
#define TEXTURE_10 1024u
#define TEXTURE_11 2048u
#define TEXTURE_12 4096u
#define TEXTURE_13 8192u
#define TEXTURE_14 16384u
#define TEXTURE_15 32768u

// Samplers
#ifdef MSAASAMPLES
    layout(binding = 0) uniform sampler2DMS DepthBuffer;
    layout(binding = 1) uniform sampler2DMS ColorBuffer;
    layout(binding = 2) uniform sampler2DMS NormalRoughnessMetalBuffer;
    layout(binding = 3) uniform sampler2DMS PBRBuffer;
    layout(binding = 4) uniform sampler2DMS EmissionBuffer;
#else
    layout(binding = 0) uniform sampler2D DepthBuffer;
    layout(binding = 1) uniform sampler2D ColorBuffer;
    layout(binding = 2) uniform sampler2D NormalRoughnessMetalBuffer;
    layout(binding = 3) uniform sampler2D PBRBuffer;
#endif

layout(binding = 4) uniform sampler2D AverageLuminanceBuffer;
layout(binding = 8) uniform sampler2D PunctualLightBuffer;
layout(binding = 9) uniform sampler2D SpecularProbeBuffer;
layout(binding = 11) uniform sampler2D DitherTexture;
layout(binding = 12) uniform samplerCube BackgroundEnvironmentMap;
layout(binding = 13) uniform sampler2D Lut_GGX;
layout(binding = 14) uniform samplerCube DiffuseEnvironmentMap;
layout(binding = 15) uniform samplerCube SpecularEnvironmentMap;

// Includes
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "Light.glsl"
#include "DrawIBL.glsl"
#include "OpticalDensity.glsl"
#include "ToneMapping.glsl"
#include "../Common/Dither.glsl"

// Outputs
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outReflection;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec3 screencoord = vec3((gl_FragCoord.x ) / float(DrawViewport.z), (gl_FragCoord.y ) / float(DrawViewport.w), 0.0);
    vec3 samplecoord;
	outReflection = vec4(0.0, 0.0, 0.0, 1.0);

    vec3 diffuse = vec3(0.0);
    vec3 specular = vec3(0.0);
    vec3 emissive = vec3(0.0);
    float accumulatedroughness = 0.0;
    float accumulatedmetalness = 0.0;
    vec3 accumulatednormal = vec3(0.0);
    float accumulatedocclusion = 0.0;
    vec4 accumulatedalbedo = vec4(0.0);
    float alpha = 0.0;
    vec4 probelighting = vec4(0.0);
	float fogeffect = 0.0;
	
    // Punctual lights + probe diffuse
    if ((TextureFlags & TEXTURE_8) != 0)
    {
        probelighting = texelFetch(PunctualLightBuffer, coord, 0);
        probelighting.a = min(probelighting.a, 1.0);
    }
	
	vec4 probespecular = vec4(0);
	if ((TextureFlags & TEXTURE_9) != 0)
	{
		probespecular = texelFetch(SpecularProbeBuffer, coord, 0);
		probespecular.a = min(probespecular.a, 1.0);
		probelighting.a = probespecular.a;
	}
	
#ifdef MSAASAMPLES  
    for (int n = 0; n < MSAASAMPLES; ++n)
    {
        samplecoord.xy = screencoord.xy + SampleLocations[n];
#else
    #define n 0
        samplecoord = screencoord;
#endif
        vec4 albedo = texelFetch(ColorBuffer, coord, n);
        float depth = texelFetch(DepthBuffer, coord, n).r;
        samplecoord.z = depth;
        vec4 color = albedo;
        //vec3 position = ScreenCoordToWorldPosition(samplecoord);

        if (depth < 1.0)
        {
            alpha += albedo.a;
            vec4 occlussionroughnessmetal = texelFetch(PBRBuffer, coord, n);
            emissive += sRGBToLinear(albedo.rgb * occlussionroughnessmetal.r);            
            //emissive += sRGBToLinear(texelFetch(EmissionBuffer, coord, n).rgb);
            accumulatedalbedo += albedo;
			
			if (probelighting.a < 1.0 || FogColor.a > 0.0)
            {
				vec3 position = ScreenCoordToWorldPosition(samplecoord);
				float fogstrength = 0.0;							
				if (FogColor.a > 0.0)
				{
					float d = length(CameraPosition - position);
					//fogstrength = (d - FogRange.x) / (FogRange.y - FogRange.x);
					//fogstrength = clamp(fogstrength, 0.0, 1.0) * FogColor.a;
					fogstrength = (1.0 - transmittance(FogDensity, d)) * FogColor.a;					
				}			
				fogeffect += fogstrength;
				
				// Image-based Lighting
				if (probelighting.a < 1.0)
				{
					if ((TextureFlags & TEXTURE_14) != 0 || (TextureFlags & TEXTURE_15) != 0)
					{
						vec4 normalroughnessmetal = texelFetch(NormalRoughnessMetalBuffer, coord, n);
						vec3 normal = normalize(normalroughnessmetal.rgb * 2.0 - 1.0);
						accumulatednormal += normal;

						uint flags = uint(round(normalroughnessmetal.a * 15.0));

						float occlusion = 1.0;//occlussionroughnessmetal.r;
						float roughness = occlussionroughnessmetal.g;
						float metalness = occlussionroughnessmetal.b;

						accumulatedroughness += roughness;
						accumulatedmetalness += metalness;
						accumulatedocclusion += occlusion;
						
						vec3 v = normalize(CameraPosition - position);
						
						vec3 basecolor = sRGBToLinear(albedo.rgb);
						float specularWeight = 1.0;

						float perceptualRoughness = clamp(roughness, 0.04, 1.0);
						float alphaRoughness = perceptualRoughness * perceptualRoughness;
						vec3 f0 = vec3(0.04);
						f0 = mix(f0, basecolor.rgb, metalness);
						vec3 f90 = vec3(1.0);
						vec3 c_diff = mix(basecolor.rgb, vec3(0.0), metalness);
						
						vec3 sampdiffuse = vec3(0.0);
						vec3 sampspecular = vec3(0.0);
						
						DrawIBL(sampdiffuse, sampspecular, 1.0 - probelighting.a, normal, v, perceptualRoughness, c_diff, f0, specularWeight, occlusion, flags);
						
						diffuse += sampdiffuse * (1.0 - fogstrength);
						specular += sampspecular * (1.0 - fogstrength);
						
						/*// Diffuse Image-based Lighting
						if ((TextureFlags & TEXTURE_14) != 0)
						{
							vec4 ibldiffuse = vec4(0.0);
							//if (ibldiffuse.a < 1.0f && IBLIntensity > 0.0f)
							{
								ibldiffuse.rgb += sRGBToLinear(textureLod(DiffuseEnvironmentMap, normal, 0.0).rgb) * (1.0f - ibldiffuse.a);// * IBLIntensity;
							}
							ibldiffuse *= occlusion;
							if (ibldiffuse.r + ibldiffuse.g + ibldiffuse.b > 0.0f)
							{
								diffuse += getIBLRadianceLambertian(Lut_GGX, ibldiffuse.rgb, normal, v, perceptualRoughness, c_diff, f0, specularWeight) * (1.0 - probelighting.a);
							}
						}
						
						// Specular Image-based Lighting
						if ((TextureFlags & TEXTURE_15) != 0)
						{
							vec4 iblspecular = vec4(0.0);
							//if (iblspecular.a < 1.0 && IBLIntensity > 0.0)
							{
								int u_MipCount = textureQueryLevels(SpecularEnvironmentMap);
								float lod = perceptualRoughness * float(u_MipCount - 1);
								//lod = min(lod, 5.0);
								vec3 sky = sRGBToLinear(textureLod(SpecularEnvironmentMap, reflect(-v, normal), lod).rgb) * (1.0f - iblspecular.a);// * IBLIntensity;
								iblspecular.rgb += sky;
							}
							iblspecular *= occlusion;
							if (iblspecular.r + iblspecular.g + iblspecular.b > 0.0f)
							{
								vec3 sn = normal;
								if (dot(sn, v) < 0.0f) sn *= -1.0f;
								specular += getIBLRadianceGGX(Lut_GGX, iblspecular.rgb, sn, v, perceptualRoughness, f0, specularWeight) * (1.0 - probelighting.a);
							}                    
						}*/
					}
				}
            }
        }
#ifdef MSAASAMPLES
    }
    alpha /= float(MSAASAMPLES);
    diffuse /= float(MSAASAMPLES);
    specular /= float(MSAASAMPLES);
    emissive /= float(MSAASAMPLES);
    accumulatedroughness /= float(MSAASAMPLES);
    accumulatedocclusion /= float(MSAASAMPLES);
    accumulatedmetalness /= float(MSAASAMPLES);
    accumulatedalbedo /= float(MSAASAMPLES);
#endif
	
	vec4 linearfogcolor;
	if (FogColor.a > 0.0) linearfogcolor = sRGBToLinear(FogColor);
	
	diffuse *= 1.0 - probelighting.a;
	specular *= 1.0 - probelighting.a;
	
    outColor.rgb = (accumulatedalbedo.rgb * AmbientLight * (1.0 - fogeffect)) + (diffuse);
	outColor.rgb += emissive * (1.0 - pow(fogeffect, 3.0));// very arbitrary but it looks good
    outColor.rgb += probelighting.rgb;
    outColor.rgb += linearfogcolor.rgb * fogeffect;	
    outColor.a = accumulatedalbedo.a;
	
	outReflection = outColor;
	
	outColor.rgb += specular + probespecular.rgb;
	
    if (alpha < 1.0)
    {
        float one_minus_alpha = 1.0 - alpha;
        if ((TextureFlags & TEXTURE_12) != 0)
        {
            // Background (single texture lookup)
            screencoord.z = 1.0;
            vec3 position = ScreenCoordToWorldPosition(screencoord);
			vec3 texcoord = position - CameraPosition;
			vec3 sky = sRGBToLinear(texture(BackgroundEnvironmentMap, texcoord).rgb) * SkyIntensity;
			
			if (FogColor.a > 0.0 && FogAngles.y > 0.0)
			{
				float slope = degrees(asin(texcoord.y / length(texcoord.xyz)));
				if (slope < FogAngles.y)
				{
					float l = clamp(1.0f - ((slope - FogAngles.x) / (FogAngles.y - FogAngles.x)), 0.0f, 1.0f) * FogColor.a;
					sky.rgb = sky.rgb * (1.0 - l) + linearfogcolor.rgb * l;
				}
			}
            outColor.rgb += sky * one_minus_alpha;
        }
        else
        {
            outColor.rgb += sRGBToLinear(BackgroundColor.rgb) * one_minus_alpha;
            outColor.a = mix(outColor.a, BackgroundColor.a, one_minus_alpha);
        }
    }
	//outColor.a = 1.0;
	//outReflection.a = 1.0;
	
	if (ToneMappingMode != -1)
	{
		if ((TextureFlags & 8u) != 0)
		{		
			// Read average luminance from buffer
			float AverageLuminance = textureLod(AverageLuminanceBuffer, vec2(0.5), 0.0).r;
			
			// Compute the luminance correction factor
			float luminanceFactor = 0.214 / max(AverageLuminance, 0.0001);
			luminanceFactor = clamp(luminanceFactor, 0.1, 5.0);
			
			// Apply correction
			outColor.rgb *= luminanceFactor;
		}	
		outColor.rgb = ApplyToneMapping(outColor.rgb, ToneMappingMode);
	}
	
	if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
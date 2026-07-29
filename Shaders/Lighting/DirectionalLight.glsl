// Uniforms
//uniform vec3 AmbientLight = vec3(0.0f);
uniform int LightIndex;
//uniform mat4 CameraMatrix;
//uniform vec3 CameraPosition;
//uniform mat4 InverseCameraMatrix;
//uniform ivec4 DrawViewport;
//uniform uint TextureFlags = 0;
//uniform float IBLIntensity = 1.0;
uniform int ShadowPartitions = 3;
//#define ShadowPartitions 3
//uniform int ToneMappingMode = 0;
//uniform vec4 FogColor = vec4(0.0);
//uniform float FogDensity;
//uniform vec2 FogRange;
//uniform vec2 FogAngles;
uniform vec3 LightDirection;
uniform int ShadowMode = 1;
uniform vec4 LightColor;
//uniform vec4 BackgroundColor = vec4(0.0);
uniform mat4 LightMatrix[4];
uniform vec2 LightArea[4];
uniform vec4 LightPartitionDistance;
uniform vec2 LightRange;
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
#else
    layout(binding = 0) uniform sampler2D DepthBuffer;
    layout(binding = 1) uniform sampler2D ColorBuffer;
    layout(binding = 2) uniform sampler2D NormalRoughnessMetalBuffer;
    layout(binding = 3) uniform sampler2D PBRBuffer;
#endif

layout(binding = 4) uniform sampler2D AverageLuminanceBuffer;

// Probably don't need these...
layout(binding = 5) uniform sampler2DArray TerrainClipMap;
layout(binding = 6) uniform sampler2D TerrainHeightMap;
layout(binding = 7) uniform sampler2D TerrainNormalMap;

layout(binding = 8) uniform sampler2D PunctualLightBuffer;
layout(binding = 9) uniform sampler2D ProbeLightBuffer;
layout(binding = 10) uniform sampler2DArrayShadow ShadowMap;
layout(binding = 11) uniform sampler2D DitherTexture;
layout(binding = 12) uniform samplerCube BackgroundEnvironmentMap;
layout(binding = 13) uniform sampler2D Lut_GGX;
layout(binding = 14) uniform samplerCube DiffuseEnvironmentMap;
layout(binding = 15) uniform samplerCube SpecularEnvironmentMap;

// Includes
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Dither.glsl"
#include "Light.glsl"
#include "DrawDirectionalLight.glsl"
#include "ToneMapping.glsl"
#include "OpticalDensity.glsl"

// Outputs
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 Out_Reflection;

void main()
{
	outColor = vec4(0.0,0.0,0.0,1.0);

    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec3 screencoord = vec3(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w), 0.0);
    vec3 samplecoord;
    vec4 probelighting = vec4(0.0);
    vec3 punctuallighting = vec3(0.0);
    vec4 ssr = vec4(0.0);

    // Get probe specular lighting
    if ((TextureFlags & TEXTURE_9) != 0)
    {
        probelighting = texelFetch(ProbeLightBuffer, coord, 0);
        probelighting.a = min(probelighting.a, 1.0);
    }
	
    // Get Punctual lighting and probe diffuse
    if ((TextureFlags & TEXTURE_8) != 0) punctuallighting = texelFetch(PunctualLightBuffer, coord, 0).rgb;
	
//outColor = vec4(probelighting.a);
//return;

    float alpha = 0.0;
    vec3 diffuse = vec3(0.0);
    vec3 specular = vec3(0.0);
    vec3 background = vec3(0.0f);
    vec3 emissive = vec3(0.0);
    vec4 realcolor = vec4(0.0);
    vec3 indirectdiffuse = vec3(0.0);
    vec3 indirectspecular = vec3(0.0);
	vec4 linearfogcolor = sRGBToLinear(FogColor);
	float fogeffect = 0.0;
	
#ifdef MSAASAMPLES  
    for (int n = 0; n < MSAASAMPLES; ++n)
    {
        samplecoord.xy = screencoord.xy + SampleLocations[n];
#else
    #define n 0
        samplecoord = screencoord;
#endif
        float depth = texelFetch(DepthBuffer, coord, n).r;
        
        //screencoord.z = depth;
        //vec3 position = ScreenCoordToWorldPosition(screencoord);
        vec3 samplediffuse = vec3(0.0);
        vec3 samplespecular = vec3(0.0);
		float fogstrength = 0.0;	
		vec3 ispec = vec3(0.0);
		vec3 idiff = vec3(0.0);
				
        if (depth < 1.0)
        {    
			vec4 albedo = texelFetch(ColorBuffer, coord, n);
			realcolor += albedo;
		
            alpha += albedo.a;
            
            vec4 pbr = texelFetch(PBRBuffer, coord, n);
            
            emissive += sRGBToLinear(albedo.rgb * pbr.r); 
            //emissive += sRGBToLinear(texelFetch(EmissionBuffer, coord, n).rgb);            
            albedo.rgb = sRGBToLinear(albedo.rgb);
            
            screencoord.z = depth;
            vec3 position = ScreenCoordToWorldPosition(screencoord);
    
			if (FogColor.a > 0.0)
			{
				float d = length(CameraPosition - position);
				//fogstrength = (d - FogRange.x) / (FogRange.y - FogRange.x);				
				fogstrength = (1.0 - transmittance(FogDensity, d)) * FogColor.a;
			}
			
            vec4 normalroughnessmetal = texelFetch(NormalRoughnessMetalBuffer, coord, n);

            vec3 normal = normalize(normalroughnessmetal.rgb * 2.0 - 1.0);
            
            uint flags = uint(round(normalroughnessmetal.a * 3.0));

            float occlusion = 1.0;
            float roughness = pbr.g;
            float metalness = pbr.b;
            float specularweight = 1.0;//normalroughnessmetal.a;

            DrawDirectionalLight(n, albedo.rgb, normal, position, samplediffuse, samplespecular, occlusion, roughness, metalness, specularweight, flags, idiff, ispec, probelighting.a);
        }
		
		float one_minus_fog = 1.0 - fogstrength;
		indirectspecular += ispec * one_minus_fog;
		indirectdiffuse += idiff * one_minus_fog;
		diffuse += samplediffuse * one_minus_fog;
		specular += samplespecular * one_minus_fog;
		fogeffect += fogstrength;
		
#ifdef MSAASAMPLES
    }
	fogeffect /= float(MSAASAMPLES);
    alpha /= float(MSAASAMPLES);
    diffuse /= float(MSAASAMPLES);
    specular /= float(MSAASAMPLES);
    emissive /= float(MSAASAMPLES);
    realcolor /= float(MSAASAMPLES);
    indirectdiffuse /= float(MSAASAMPLES);
    indirectspecular /= float(MSAASAMPLES);
#endif
    outColor.rgb = ((diffuse + specular));// + emissive;
	outColor.rgb += emissive * (1.0 - pow(fogeffect, 3.0));// very arbitrary but it looks good

    outColor.a = alpha;
    
    // Mix skybox with probes
    indirectdiffuse *= 1.0 - probelighting.a;
    indirectspecular *= 1.0 - probelighting.a;

    outColor.rgb += AmbientLight * realcolor.rgb + indirectdiffuse + punctuallighting + linearfogcolor.rgb * fogeffect;
	
    // Screen-space reflection
    Out_Reflection.rgb = outColor.rgb; // Scene without probe and sky specular, but does include diffuse
    outColor.rgb += probelighting.rgb + indirectspecular;
	
    //outColor.rgb = linearTosRGB(outColor.rgb);

    if (alpha < 1.0)
    {
        float one_minus_alpha = 1.0 - alpha;
        if ((TextureFlags & TEXTURE_12) != 0)
        {
            // Background (single texture lookup)
            screencoord.z = 1.0;
            vec3 position = ScreenCoordToWorldPosition(screencoord);
			vec3 texcoord = position - CameraPosition;
            vec4 sky = sRGBToLinear(texture(BackgroundEnvironmentMap, texcoord)) * SkyIntensity;
			if (FogColor.a > 0.0 && FogAngles.y > 0.0)
			{
				float slope = degrees(asin(texcoord.y / length(texcoord.xyz)));
				if (slope < FogAngles.y)
				{
					float l = clamp(1.0f - ((slope - FogAngles.x) / (FogAngles.y - FogAngles.x)), 0.0f, 1.0f) * FogColor.a;
					l = 1.0 - pow(1.0 - l, 1.0 / 2.8);// This looks much better
                    sky.rgb = sky.rgb * (1.0 - l) + linearfogcolor.rgb * l;
				}
			}
			outColor.rgb += sky.rgb * one_minus_alpha;
        }
        else
        {
            outColor.rgb += sRGBToLinear(BackgroundColor.rgb) * one_minus_alpha;
            //outColor.a = mix(outColor.a, BackgroundColor.a, one_minus_alpha);
        }
    }
	
	//---------------------------------------------------------------
	// Tone Mapping and Auto-exposure
	//---------------------------------------------------------------
	
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
	
	// Apply dither if needed
	if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}

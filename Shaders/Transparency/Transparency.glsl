uniform ivec4 DrawViewport;
uniform vec2 CameraRange;
uniform mat4 CameraProjectionMatrix;
//uniform mat4 InverseCameraProjectionViewMatrix;
uniform vec3 CameraPosition;
uniform int ToneMapping = 0;
uniform int SSR = 0;
uniform int TransparentRoughness = 0;
uniform int ToneMappingMode = -1;
uniform float SoftFadeRange = 0.5;
uniform vec4 FogColor;
uniform vec2 FogRange;
uniform vec2 FogAngles;
uniform float FogDensity;
uniform float SSRScale = 1.0;
uniform uint TextureFlags = 0;

#ifdef MSAASAMPLES
layout(binding = 0) uniform sampler2DMS DepthBuffer;
layout(binding = 2) uniform sampler2DMS ColorBuffer;
layout(binding = 3) uniform sampler2DMS NormalBuffer;
layout(binding = 4) uniform sampler2DMS ZPositionBuffer;
layout(binding = 5) uniform sampler2DMS RoughnessThicknessBuffer;
//layout(binding = 6) uniform usampler2DMS RefractionModelBuffer;
layout(binding = 6) uniform sampler2DMS RefractionModelBuffer;
layout(binding = 9) uniform sampler2DMS BackgroundPBRBuffer;
#else
layout(binding = 0) uniform sampler2D DepthBuffer;
layout(binding = 2) uniform sampler2D ColorBuffer;
layout(binding = 3) uniform sampler2D NormalBuffer;
layout(binding = 4) uniform sampler2D ZPositionBuffer;
layout(binding = 5) uniform sampler2D RoughnessThicknessBuffer;
//layout(binding = 6) uniform usampler2D RefractionModelBuffer;
layout(binding = 6) uniform sampler2D RefractionModelBuffer;
layout(binding = 9) uniform sampler2D BackgroundPBRBuffer;
#endif

layout(binding = 8) uniform sampler2D BackgroundBuffer2;// No indirect specular reflection
layout(binding = 1) uniform sampler2D BackgroundBuffer;// Includes indirect specular reflection
layout(binding = 7) uniform sampler2D ReflectionsBuffer;
layout(binding = 10) uniform sampler2D AverageLuminanceBuffer;

// Includes
#include "../Lighting/Light.glsl"
#include "../Lighting/ToneMapping.glsl"
#include "../Lighting/OpticalDensity.glsl"

// Uniforms
uniform int MipLevels = 1;
uniform mat3 CameraNormalMatrix;

// Outputs
layout(location = 0) out vec4 OutColor;

float DepthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x) ) * depthrange.y;
}

vec3 getVolumeTransmissionRay(vec3 n, vec3 v, float thickness, float ior)
{
    // Direction of refracted light.
    vec3 refractionVector = refract(-v, normalize(n), 1.0 / ior);

    // Compute rotation-independant scaling of the model matrix.
    //vec3 modelScale;
    //modelScale.x = length(vec3(modelMatrix[0].xyz));
    //modelScale.y = length(vec3(modelMatrix[1].xyz));
    //modelScale.z = length(vec3(modelMatrix[2].xyz));

    // The thickness is specified in local space.
    return normalize(refractionVector) * thickness;// * modelScale;
}

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec2 texcoord = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));
    vec3 screencoord = vec3(texcoord, 0.0);

    float alpha = 0.0;
    vec4 background = vec4(0.0);
    vec4 background2 = vec4(0.0);// background with no specular
    vec4 foreground = vec4(0.0);
    bool anythingdrawn = false;
    float transparency = 0.0;
    vec4 roughnessthickness = vec4(0.0);
    float deltaz = 0.0;
    float transparentreflection = 0.0;
    vec2 ssrcoords = vec2(0.0);
    float ssrlod = 0.0;
	float solidbackground = 0.0;
	float backgroundroughness = 0.0;
	float refractionstrength = 0.0;
	float fogstrength = 0.0;
	float sky = 0.0;
	
#ifdef MSAASAMPLES
    for (int n = 0; n < MSAASAMPLES; ++n)
    {
#else
    #define n 0
#endif
		backgroundroughness += texelFetch(BackgroundPBRBuffer, coord, n).g;
        vec2 bgcoords = texcoord;
        float bglod = 0.0;
        float rawz = texelFetch(ZPositionBuffer, coord, n).r;
		
		bool simplerefraction = rawz < 0.0;
		rawz = abs(rawz);
		float rawdepth = texelFetch(DepthBuffer, coord, n).r;
		
		if (rawdepth < 1.0) solidbackground += 1.0;
		
		// Can't use sampleforeground.a because heat haze doesn't use color
		// Can't use normal.a because normal attachment uses 4-bit alpha
		if (rawz < 1.0)
		//if (nsample.a > 0.0)
		{
			vec4 sampleforeground = texelFetch(ColorBuffer, coord, n);
			sampleforeground.rgb = min(sampleforeground.rgb, vec3(2.0));// Prevent very bright values
			//if (sampleforeground.a > 0.0)
			
			float fogz = rawdepth;
			
			//if (rawz < 1.0)
			{
				//z = z * (CameraRange.y - CameraRange.x) + CameraRange.x;        
				float z = DepthToPosition(rawz, CameraRange);            
				float depth = DepthToPosition(rawdepth, CameraRange);
				fogz = rawdepth;
			
				if (z <= depth)
				{
					//uint flags = texelFetch(RefractionModelBuffer, coord, n).r;
					transparency += 1.0;
					
					deltaz += depth - z;
					
					anythingdrawn = true;
					
					//if (sampleforeground.a > 0.0)
					{
						roughnessthickness = texelFetch(RoughnessThicknessBuffer, coord, n);
						float ior = roughnessthickness.r * 4.0 + 1.0;
						float roughness = roughnessthickness.g;
						//float density = roughnessthickness.b * 2.0;
						float dist = depth - z;
						refractionstrength += roughnessthickness.a;
						
						//OutColor = vec4(ior);
						//return;
						vec4 nsample = texelFetch(NormalBuffer, coord, n);
						vec3 normal = normalize(nsample.rgb * 2.0 - 1.0);
						
						transparentreflection += texelFetch(RefractionModelBuffer, coord, n).r;
						
						fogz = rawz;
						
						/*if ((TRANSPARENCY_SSR & flags) != 0)
						{
							transparentreflection += 1.0;
							fogz = rawz;
						}*/
						
						/*if (density > 0.0)
						{	
							float rawdepth = texelFetch(DepthBuffer, ivec2(bgcoords.x * float(DrawViewport.x), bgcoords.y * float(DrawViewport.y)), n).r;
							float depth = DepthToPosition(rawdepth, CameraRange);
							float t = transmittance(density, dist);
							sampleforeground.a = mix(1.0, sampleforeground.a, t);
							roughness = mix(min(roughness + 0.5, 1.0), roughness, t);
						}*/
						
						// Soft edges for water and particles
						/*if (dist < SoftFadeRange && (TRANSPARENCY_SOFTEDGES & flags) != 0)
						{
							float hardness = dist / SoftFadeRange;
							hardness *= hardness; // Squared looks a lot better
							sampleforeground *= hardness;
							ior = mix(1.0, ior, hardness);
							roughness *= hardness;
							transparentreflection *= hardness;
						}*/
						
						//ior = mix(1.0, ior, roughnessthickness.a);
						
						//OutColor.rgb = vec3(ior - 1.0);
						//return;
						
						uint flags = 0;
						if (ior > 1.0)
						{
							if (simplerefraction)
							//if ((TRANSPARENCY_SIMPLEREFRACTION & flags) != 0)
							{
								// Simple refraction for water and other flat surfaces, prevents refraction edge artifacts
								bgcoords += normal.xy * 0.25 */* clamp(depth - z, 0.25, 2.0) **/ (ior - 1.0);// This could be gradually faded out on the edges for a better appearance
								ivec2 coord = ivec2(bgcoords.x * float(DrawViewport.z), bgcoords.y * float(DrawViewport.w));
								coord.x = clamp(coord.x, 0, int(DrawViewport.z));
								coord.y = clamp(coord.y, 0, int(DrawViewport.w));
								float depth = texelFetch(DepthBuffer, coord, n).r;
								depth = DepthToPosition(depth, CameraRange);
								if (depth < z) bgcoords = texcoord;
							}
							else
							{ 
								// Realistic refraction
								screencoord.z = rawz;//PositionToDepth(z, CameraRange);
								vec3 position = ScreenCoordToWorldPosition(screencoord);
								vec3 v = normalize(CameraPosition - position);
								if (dot(v, normal) < 0.0) normal *= -1.0;// Flip the normal, for backface culling (Is that alway right???)
								//thickness = 0.25;
								//vec3 transmissionRay = getVolumeTransmissionRay(normal, v, thickness, ior, u_ModelMatrix);
								vec3 transmissionRay = getVolumeTransmissionRay(normal, v, 1.0, ior);
								vec3 refractedRayExit = position + transmissionRay;                        
								
								// Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
								vec4 ndcPos = CameraProjectionMatrix * vec4(refractedRayExit, 1.0);							
								bgcoords = ndcPos.xy / ndcPos.w;
								bgcoords = (bgcoords + 1.0) * 0.5;
							}
						}
						
						//int mipcount = textureQueryLevels(BackgroundBuffer);
						bglod = roughness * float(MipLevels - 1);
					}
					foreground += sampleforeground;		
				}
			}
			
			if (FogColor.a > 0.0)
			{
				screencoord.z = fogz;
				vec3 position = ScreenCoordToWorldPosition(screencoord);
				float dist = length(position - CameraPosition);
				float fog = 1.0 - transmittance(FogDensity, dist);
				fogstrength += clamp(fog, 0.0, 1.0) * FogColor.a;
			}
        }
		else
		{
			if (rawdepth == 1.0) sky += 1.0;
		}
        background += textureLod(BackgroundBuffer, bgcoords, bglod);
        background2 += textureLod(BackgroundBuffer2, bgcoords, bglod);
        ssrlod += bglod;
        ssrcoords += bgcoords;
#ifdef MSAASAMPLES
    }
	solidbackground /= MSAASAMPLES;
	fogstrength /= float(MSAASAMPLES);
    ssrlod /= float(MSAASAMPLES);
    ssrcoords /= float(MSAASAMPLES);
    transparentreflection /= float(MSAASAMPLES);
    deltaz /= float(MSAASAMPLES);
    transparency /= float(MSAASAMPLES);
    background /= float(MSAASAMPLES);
    background2 /= float(MSAASAMPLES);
	backgroundroughness /= float(MSAASAMPLES);
    foreground /= float(MSAASAMPLES);
	refractionstrength /= float(MSAASAMPLES);
    roughnessthickness /= float(MSAASAMPLES);
	sky /= float(MSAASAMPLES);
#endif
    
    if (TransparentRoughness == 0) ssrlod = 0.0;
    
	//OutColor = vec4(refractionstrength);
	//return;
	
	// Soft edges don't account for reflective transparency, yet...
    if (SSR == 1)
    {
		float bglod = backgroundroughness * float(textureQueryLevels(ReflectionsBuffer) - 1);
        bglod -= (1.0 - SSRScale) * 2.0;
		vec4 r = textureLod(ReflectionsBuffer, texcoord, bglod);
        r.a = mix(r.a, r.a * foreground.a, transparentreflection);
		r.a *= 1.0 - fogstrength;
		r.a *= 1.0 - sky;
        /*if (transparentreflection > 0.5)
        {
            foreground.rgb = mix(foreground.rgb, r.rgb, r.a);
        }
        else
        {
            background.rgb = mix(background.rgb, background2.rgb + r.rgb, r.a);			
        }*/
        foreground.rgb = mix(foreground.rgb, r.rgb, r.a * transparentreflection);
        background.rgb = mix(background.rgb, background2.rgb + r.rgb, r.a * (1.0 - transparentreflection));
    }
	
    // Make rough glass appear more clear for closer objects
    const float roughnessrange = 0.5;
    if (deltaz < roughnessrange) roughnessthickness.r = mix(roughnessthickness.r * 0.5, roughnessthickness.r, deltaz / roughnessrange);

    //foreground.rgb = linearTosRGB(foreground.rgb);
    //background = textureLod(BackgroundBuffer, bgcoords, roughnessthickness.r * float(MipLevels - 1));
	
	//foreground.a = max(foreground.a, refractionstrength);
	
    OutColor.rgb = background.rgb * (1.0 - foreground.a) + foreground.rgb;
	
	// Auto-exposure
	if ((TextureFlags & 1024u) != 0)
	{		
		// Read average luminance from buffer
		float AverageLuminance = textureLod(AverageLuminanceBuffer, vec2(0.5), 0.0).r;
		
		// Compute the luminance correction factor
		float luminanceFactor = 0.214 / max(AverageLuminance, 0.0001);
		luminanceFactor = clamp(luminanceFactor, 0.1, 5.0);
		
		// Apply correction
		OutColor.rgb *= luminanceFactor;
	}
	
    OutColor.rgb = ApplyToneMapping(OutColor.rgb, ToneMappingMode);
	OutColor.a = mix( mix(1.0, foreground.a, transparency * (1.0 - solidbackground)) , 0.0, sky);
}
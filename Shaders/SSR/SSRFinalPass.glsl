#include "../Lighting/OpticalDensity.glsl"

// Uniforms
//uniform ivec4 DrawViewport;
//uniform int ToneMappingMode = 0;
uniform float SSRScale = 1.0;

// Outputs
layout(location = 0) out vec4 OutColor;

// Samplers
layout(binding = 0) uniform sampler2D SSRBuffer;
layout(binding = 1) uniform sampler2D BackgroundBuffer;
layout(binding = 2) uniform sampler2D BackgroundBuffer2;
#ifdef MSAASAMPLES
layout(binding = 3) uniform sampler2DMS PBRBuffer;
layout(binding = 4) uniform sampler2DMS DepthBuffer;
#else
layout(binding = 3) uniform sampler2D PBRBuffer;
layout(binding = 4) uniform sampler2D DepthBuffer;
#endif
#ifdef TRANSPARENCY
layout(binding = 6) uniform sampler2D TransparencyZPositionBuffer;
layout(binding = 7) uniform sampler2D TransparencyColorBuffer;
layout(binding = 8) uniform sampler2D TransparencyRoughnessThicknessBuffer;
layout(binding = 9) uniform usampler2D TransparencyFlagsBuffer;
#endif
layout(binding = 10) uniform sampler2D AverageLuminanceBuffer;

#include "../Lighting/Light.glsl"
#include "../Lighting/ToneMapping.glsl"
#include "../Common/Uniforms.glsl"

void main()
{
    ivec2 coord = ivec2(int(gl_FragCoord.x), int(gl_FragCoord.y));
    vec2 texcoord = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));
    
    vec4 backgroundwithnoindirect;    
    vec4 background;
    vec4 pbr;
    float roughness;
    float blendalpha = 1.0;

#ifdef TRANSPARENCY
    uint flags = texelFetch(TransparencyFlagsBuffer, coord, 0).r;
    if ((2 & flags) != 0)
    //float z = texelFetch(TransparencyZPositionBuffer, coord, 0).r;
    //if (z < 1.0)
    {
        background = textureLod(TransparencyColorBuffer, texcoord, 0);
        backgroundwithnoindirect = background;
        roughness = texelFetch(TransparencyRoughnessThicknessBuffer, coord, 0).r;
    }
    else
#endif
    {
        background = textureLod(BackgroundBuffer, texcoord, 0);
        backgroundwithnoindirect = textureLod(BackgroundBuffer2, texcoord, 0);
        roughness = texelFetch(PBRBuffer, coord, 0).g;
#ifdef TRANSPARENCY
        blendalpha *= 1.0 - textureLod(TransparencyColorBuffer, texcoord, 0).a;
#endif        
    }
    
    float lod = roughness * float(textureQueryLevels(SSRBuffer) - 1) * 1.0;
	lod -= (1.0 - SSRScale) * 2.0;
	
    vec4 reflection = textureLod(SSRBuffer, texcoord, lod);
    
    //OutColor = vec4(blendalpha);
    //return;
    reflection.a *= blendalpha;
    
	float depth = texelFetch(DepthBuffer, coord, 0).r;
	if (depth == 1.0) reflection = vec4(0.0);
	
	if (FogColor.a > 0.0)
	{
		vec3 screencoord;
		screencoord.xy = texcoord;
		screencoord.z = depth;
		vec3 position = ScreenCoordToWorldPosition(screencoord);
		float dist = length(position - CameraPosition);
		//float fog = (dist - FogRange.x) / (FogRange.y - FogRange.x);
		float fog = 1.0 - transmittance(FogDensity, dist);
		fog = clamp(fog, 0.0, 1.0);
		fog *= FogColor.a;
		reflection *= (1.0 - fog);
	}
	
    vec4 ssrbackground = backgroundwithnoindirect + reflection;
	
    OutColor = mix(background, ssrbackground, reflection.a);
	
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
}
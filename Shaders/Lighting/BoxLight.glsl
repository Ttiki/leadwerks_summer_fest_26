// Uniforms
uniform ivec4 DrawViewport;
uniform vec3 CameraPosition;
uniform int ShadowMode = 1;
uniform mat4 LightMatrix;
uniform vec4 LightColor;
uniform vec2 LightRange;
uniform vec3 LightDirection;
uniform vec2 LightArea;
uniform vec4 FogColor = vec4(0.0);
uniform float FogDensity;

#ifdef MSAASAMPLES
    uniform vec2 SampleLocations[MSAASAMPLES];
#endif

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

layout(binding = 10) uniform sampler2DArrayShadow ShadowMap;
layout(binding = 11) uniform sampler2D BaseColorMap;

// Includes
#include "../Common/Constants.glsl"
#include "Light.glsl"
#include "DrawBoxLight.glsl"
#include "OpticalDensity.glsl"

// Outputs
layout(location = 0) out vec4 outColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec3 screencoord = vec3(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w), 0.0);
    vec3 diffuse = vec3(0);
    vec3 specular = vec3(0);
    vec3 samplecoord;
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
        if (depth < 1.0f)
        {
            samplecoord.z = depth;
            vec3 position = ScreenCoordToWorldPosition(samplecoord);
            
            vec4 albedo = texelFetch(ColorBuffer, coord, n);
            albedo.rgb = sRGBToLinear(albedo.rgb);
            vec4 nsample = texelFetch(NormalRoughnessMetalBuffer, coord, n);
            vec3 normal = normalize(nsample.rgb * 2.0 - 1.0);
            vec4 pbr = texelFetch(PBRBuffer, coord, 0);
			uint flags = uint(round(nsample.a * 3.0));
			
            float occlusion = 1.0;
            float roughness = pbr.g;
            float metalness = pbr.b;
			
			float fogstrength = 0.0;							
			if (FogColor.a > 0.0)
			{
				float d = length(CameraPosition - position);
				fogstrength = (1.0 - transmittance(FogDensity, d)) * FogColor.a;					
			}			
			fogeffect += fogstrength;
			
            if (fogstrength < 1.0) DrawBoxLight(n, albedo.rgb, normal, position, diffuse, specular, occlusion, roughness, metalness, flags);
        }
#ifdef MSAASAMPLES
    }
    diffuse /= float(MSAASAMPLES);
    specular /= float(MSAASAMPLES);
	fogeffect /= float(MSAASAMPLES);
#endif
	
    outColor.rgb = (diffuse + specular) * (1.0 - fogeffect);
    outColor.a = 0.0f;
}
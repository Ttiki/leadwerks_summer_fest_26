// Uniforms
uniform ivec4 DrawViewport;
uniform vec3 CameraPosition;
uniform mat4 LightMatrix;
uniform mat4 LightPosition;
uniform vec4 LightColor;
uniform uint ProbeIndex = 0;
uniform vec3 FadeDistance[2];
uniform uint TextureFlags = 0;
uniform vec4 BackgroundColor = vec4(0.0);
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
#undef MSAASAMPLES

layout(binding = 10) uniform samplerCubeArray DiffuseMap;
layout(binding = 11) uniform samplerCubeArray SpecularMap;
layout(binding = 13) uniform sampler2D Lut_GGX;
layout(binding = 15) uniform samplerCube SpecularEnvironmentMap;

// Includes
#include "Light.glsl"
#include "DrawProbe.glsl"
#include "OpticalDensity.glsl"

// Outputs
layout(location = 0) out vec4 Out_Specular;
layout(location = 1) out vec4 Out_Diffuse;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec3 screencoord = vec3(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w), 0.0);
    vec3 diffuse = vec3(0);
    vec3 specular = vec3(0);
    vec3 samplecoord;
    float alpha = 0.0;
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
            vec4 nornalroughnessmetal = texelFetch(NormalRoughnessMetalBuffer, coord, n);
            vec3 normal = normalize(nornalroughnessmetal.rgb * 2.0 - 1.0);
            vec4 pbr = texelFetch(PBRBuffer, coord, 0);
            
            float occlusion = 1.0;
            float roughness = pbr.g;
            float metalness = pbr.b;
            float probealpha = 0.0;

			float fogstrength = 0.0;							
			if (FogColor.a > 0.0)
			{
				float d = length(CameraPosition - position);
				fogstrength = (1.0 - transmittance(FogDensity, d)) * FogColor.a;					
			}			
			fogeffect += fogstrength;

            if (fogstrength < 1.0) DrawProbe(ProbeIndex, albedo.rgb, normal, position, diffuse, specular, occlusion, roughness, metalness, probealpha, LightMatrix, BackgroundColor, FadeDistance[0], FadeDistance[1]);
			
            alpha += probealpha;
        }
#ifdef MSAASAMPLES
    }
    alpha /= float(MSAASAMPLES);
    diffuse /= float(MSAASAMPLES);
    specular /= float(MSAASAMPLES);
	fogeffect /= float(MSAASAMPLES);
#endif

	alpha *= 1.0 - fogeffect;

    Out_Specular.rgb = specular;// * alpha;
    Out_Specular.a = alpha;
    Out_Specular.a = clamp(Out_Specular.a, 0.0, 1.0);
	Out_Diffuse.rgb = diffuse;// * alpha;
    Out_Diffuse.a = alpha;
		
	Out_Diffuse.rgb *= LightColor.rgb;
	Out_Specular.rgb *= LightColor.rgb;
}
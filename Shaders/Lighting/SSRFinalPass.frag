#version 450

// Uniforms
uniform ivec4 DrawViewport;
uniform int ToneMappingMode = 0;

// Outputs
layout(location = 0) out vec4 OutColor;

#define TRANSPARENCY

// Samplers
layout(binding = 0) uniform sampler2D SSRBuffer;
layout(binding = 1) uniform sampler2D BackgroundBuffer;
layout(binding = 2) uniform sampler2D BackgroundBuffer2;
layout(binding = 3) uniform sampler2D PBRBuffer;
#ifdef TRANSPARENCY
layout(binding = 6) uniform sampler2D TransparencyZPositionBuffer;
layout(binding = 7) uniform sampler2D TransparencyColorBuffer;
layout(binding = 8) uniform sampler2D TransparencyRoughnessThicknessBuffer;
#endif

#include "Light.glsl"
#include "ToneMapping.glsl"

void main()
{
    ivec2 coord = ivec2(int(gl_FragCoord.x), int(gl_FragCoord.y));
    vec2 texcoord = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));
    
    vec4 backgroundwithnoindirect;    
    vec4 background;
    vec4 pbr;
    float roughness;
    
#ifdef TRANSPARENCY
    float z = texelFetch(TransparencyZPositionBuffer, coord, 0).r;
    if (z < 1.0)
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
    }
    
    float lod = roughness * float(textureQueryLevels(SSRBuffer) - 1) * 1.0;
    vec4 reflection = textureLod(SSRBuffer, texcoord, lod);

    vec4 ssrbackground = backgroundwithnoindirect + reflection;
    OutColor = mix(background, ssrbackground, reflection.a);
    OutColor.rgb = ApplyToneMapping(OutColor.rgb, ToneMappingMode);
}
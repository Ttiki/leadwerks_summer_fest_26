#version 450

uniform ivec4 DrawViewport;
uniform vec2 CameraRange;
uniform uint ToneMapping = 0;

#include "Light.glsl"

#ifdef MSAASAMPLES
layout(binding = 0) uniform sampler2DMS DepthBuffer;
layout(binding = 1) uniform sampler2DMD BackgroundBuffer;
layout(binding = 2) uniform sampler2DMS ColorBuffer;
layout(binding = 3) uniform sampler2DMS NormalBuffer;
layout(binding = 4) uniform sampler2DMS RoughnessThicknessBuffer;
layout(binding = 5) uniform usampler2DMS RefractionModelBuffer;
layout(binding = 6) uniform sampler2DMS ZPositionBuffer;
#else
layout(binding = 0) uniform sampler2D DepthBuffer;
layout(binding = 1) uniform sampler2D BackgroundBuffer;
layout(binding = 2) uniform sampler2D ColorBuffer;
layout(binding = 3) uniform sampler2D NormalBuffer;
layout(binding = 4) uniform sampler2D ZPositionBuffer;
layout(binding = 5) uniform sampler2D RoughnessThicknessBuffer;
layout(binding = 6) uniform usampler2D RefractionModelBuffer;
#endif

// Uniforms
uniform int MipLevels = 1;

// Outputs
layout(location = 0) out vec4 OutColor;

float DepthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x) ) * depthrange.y;
}

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec2 texcoord = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));

    bool drawtransparency = true;
    float z = texelFetch(ZPositionBuffer, coord, 0).r;
    if (z == 1.0) drawtransparency = false;
    
    if (drawtransparency)
    {
        z = DepthToPosition(z, CameraRange);
        //z = z * (CameraRange.y - CameraRange.x) + CameraRange.x;        
        float depth = texelFetch(DepthBuffer, coord, 0).r;
        depth = DepthToPosition(depth, CameraRange);
        if (z > depth) drawtransparency = false;
    }

    if (drawtransparency == false)
    {
        OutColor = texelFetch(BackgroundBuffer, coord, 0);
        OutColor.rgb = ApplyToneMapping(OutColor.rgb, ToneMapping);
        return;
    }

    vec4 foreground = texelFetch(ColorBuffer, coord, 0);
    
    vec2 bgcoords = texcoord;
    if (foreground.a > 0.0)
    {
        vec3 normal = normalize(texelFetch(NormalBuffer, coord, 0).rgb * 2.0 - 1.0);
        //bgcoords += normal.xy * 0.02;
    }

    vec2 roughnessthickness = texelFetch(RoughnessThicknessBuffer, coord, 0).rg;
    
    //int mipcount = textureQueryLevels(BackgroundBuffer);
    vec4 background = textureLod(BackgroundBuffer, bgcoords, roughnessthickness.r * float(MipLevels - 1));
    
    OutColor.rgb = background.rgb * (1.0 - foreground.a) + foreground.rgb;
    OutColor.a = foreground.a;

    OutColor.rgb = ApplyToneMapping(OutColor.rgb, ToneMapping);

    return;

    //OutColor = texelFetch(NormalBuffer, coord, 0);

    /*float depth = texelFetch(DepthBuffer, coord, 0).r;
    vec4 color = texelFetch(ColorBuffer, coord, 0);
    
    vec2 roughnessthickness = texelFetch(RoughnessThicknessBuffer, coord, 0).rg;
    uint refractionmodel = texelFetch(RefractionModelBuffer, coord, 0).r;    

    switch (refractionmodel)
    {
        case 0:// Realistic
            
            break;
        case 1:// Simple
            
            break;
    }

    vec4 background = texelFetch(BackgroundBuffer, coord, 0);
    
    OutColor.rgb = color.rgb * color.a + background.rgb * (1.0 - color.a);
    //OutColor.a = color.a;*/
}
#version 450

#ifdef MSAASAMPLES
layout(binding = 0) uniform sampler2DMS DepthBuffer;
layout(binding = 1) uniform sampler2DMS ColorBuffer;
layout(binding = 2) uniform sampler2DMS NormalBuffer;
layout(binding = 3) uniform sampler2DMS RoughnessThicknessBuffer;
layout(binding = 4) uniform usampler2DMS RefractionModelBuffer;
#else
layout(binding = 0) uniform sampler2D DepthBuffer;
layout(binding = 1) uniform sampler2D ColorBuffer;
layout(binding = 2) uniform sampler2D NormalBuffer;
layout(binding = 3) uniform sampler2D RoughnessThicknessBuffer;
layout(binding = 4) uniform usampler2D RefractionModelBuffer;
#endif
layout(binding = 5) uniform usampler2D Background;

vec4 OutColor;

void main()
{
    float depth = texelFetch(DepthBuffer, coord, 0).r;
    vec4 color = texelFetch(ColorBuffer, coord, 0);
    vec3 normal = texelFetch(NormalBuffer, coord, 0).rgb * 2.0 - 1.0;
    vec2 roughnessthickness = texelFetch(RoughnessThicknessBuffer, coord, 0).rg;
    uint refractionmodel = texelFetch(RefractionModelBuffer, coord, 0).r;    

    switch (refractionmodel)
    {
        case 0:// Realistic
            
            break;
        case 1:// Simple
            
            break;
    }

    OutColor.rgb = color.rgb * color.a + background.rgb * (1.0 - color.a);
    //OutColor.a = color.a;
}
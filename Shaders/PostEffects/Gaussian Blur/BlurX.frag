#version 450

#define BlurRadius 16

// Uniforms
uniform int TargetMipLevel = 0;
uniform ivec4 DrawViewport;

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;

//Inputs
in vec2 TexCoords;

//Output
layout(location = 0) out vec4 outColor;

void main()
{
    float ts = 1.0f / textureSize(ColorBuffer, 0).y;
    
    outColor = vec4(0.0);
    for (int n = -BlurRadius; n < BlurRadius; ++n)
    {
        outColor += textureLod(ColorBuffer, TexCoords + vec2(ts * (float(n) + 0.5), 0.0f), 0);
    }
    outColor /= float(BlurRadius * 2);
}
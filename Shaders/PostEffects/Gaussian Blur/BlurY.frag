#version 450

#define BlurRadius 16

// Uniforms
uniform ivec4 DrawViewport;

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;

//Inputs
in vec2 TexCoords;

//Output
out vec4 outColor;

void main()
{
    float ts = 1.0f / textureSize(ColorBuffer, 0).y;
    
    outColor = vec4(0.0);
    for (int n = -BlurRadius; n < BlurRadius; ++n)
    {
        outColor += textureLod(ColorBuffer, TexCoords + vec2(0.0f, ts * (float(n) + 0.5)), 0);
    }
    outColor /= float(BlurRadius * 2);
}
#version 450

#define BlurRadius 8

// Uniforms
uniform ivec4 DrawViewport;

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;
layout(binding = 1) uniform sampler2D ZBuffer;

//Inputs
in vec2 TexCoords;

//Output
layout(location = 0) out vec4 outColor;
layout(location = 1) out float outZ;

void main()
{
    float ts = 1.0f / textureSize(ColorBuffer, 0).y;
    
    outColor = vec4(0.0);
    outZ = 0.0;
    for (int n = -BlurRadius; n < BlurRadius; ++n)
    {
        outColor += textureLod(ColorBuffer, TexCoords + vec2(0.0f, ts * (float(n) + 0.5)), 0);
		outZ += textureLod(ZBuffer, TexCoords + vec2(0.0f, ts * (float(n) + 0.5)), 0).r;
    }
    outColor /= float(BlurRadius * 2);
    outZ /= float(BlurRadius * 2);
}
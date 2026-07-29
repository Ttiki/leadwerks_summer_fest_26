#version 450

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

void main()
{
    fragColor = textureLod(ColorBuffer, TexCoords, 0);
}
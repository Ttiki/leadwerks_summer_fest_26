#version 450

// Samplers
uniform layout(binding = 0) sampler2DMS ColorBuffer;
uniform layout(binding = 1) sampler2DMS DepthBuffer;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    fragColor = texelFetch(ColorBuffer, coord, 0);
	if (texelFetch(DepthBuffer, coord, 0).r == 1.0) fragColor.a = 0.0;
}
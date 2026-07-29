#version 450

#include "../Common/ColorSpace.glsl"

// Uniforms
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform float Alpha = 0.01;
uniform vec2 BufferSize;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

void main()
{
    vec3 c = sRGBToLinear(textureLod(ColorBuffer, vec2(0.5), textureQueryLevels(ColorBuffer) - 1.0).rgb);
	
	float luminance = c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722;
	luminance *= Alpha;
	
	fragColor = vec4(luminance, luminance, luminance, Alpha);
	
    //fragColor.r = 1.0;
	//fragColor.a = Alpha;
    //fragColor.rgb *= Alpha;
}
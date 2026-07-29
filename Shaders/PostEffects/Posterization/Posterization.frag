#version 450

// Uniforms
uniform int Levels = 7;

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;

// Outputs
out vec4 outColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec4 c = texelFetch(ColorBuffer, coord, 0);
	float l = c.r * 0.2126f + c.g * 0.7152f + c.b * 0.0722f;
    
	l *= Levels;
	l = int(l);
	l /= float(Levels);
	
    outColor.rgb = vec3(l);
	outColor.a = c.a;
	
	// For this effect, we can skip dithering
}
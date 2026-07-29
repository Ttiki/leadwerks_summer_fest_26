#version 450

uniform ivec4 DrawViewport;
uniform float Sharpness = 4.0;

layout(binding = 0) uniform sampler2D ColorBuffer;

layout(location = 0) out vec4 outColor;

void main()
{
    vec2 texelSize = vec2(1.0 / float(DrawViewport.z), 1.0 / float(DrawViewport.w));
    vec2 uv = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);

    //uv = uv * (0.6 + 0.4 * sin(iTime * 0.5));
    vec2 iResolution = vec2(DrawViewport.z, DrawViewport.w);

	vec4 center  = texelFetch(ColorBuffer, coord, 0);

	vec2 step = 0.5 / iResolution.xy;	
	vec3 around = texture( ColorBuffer, uv + vec2(-step.x, -step.y) ).rgb;
	around += texture( ColorBuffer, uv + vec2(step.x, -step.y) ).rgb;
	around += texture( ColorBuffer, uv + vec2(-step.x, step.y) ).rgb;
	around += texture( ColorBuffer, uv + vec2(step.x, step.y) ).rgb;	
	around /= 4.0;
	
	float edge = center.a;
	edge = min(1.0, edge * 2.0);
	
	vec3 col = center.rgb + (center.rgb - around) * Sharpness * (1.0 - edge);
    outColor = vec4(col, center.a);
}

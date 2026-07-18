#version 460
#extension GL_GOOGLE_include_directive : enable
#extension GL_ARB_separate_shader_objects : enable

#include "../Utilities/ReconstructPosition.glsl"

uniform int Samples = 8;

layout(binding = 0) uniform sampler2DMS DepthBuffer;
layout(binding = 1) uniform sampler2DMS NormalBuffer;
layout(binding = 2) uniform sampler2D ColorBuffer;

//Inputs
layout(location = 0) in vec2 texCoords;

//Outputs
layout(location = 0) out vec4 outColor;

#define MAXEFFECT 1.0f
#define MAX_DISTANCE 10.0f
#define SCALE 1.0f
#define BIAS 0.05f
#define SAMPLE_RADIUS 0.05f
#define SAMPLE_COUNT 16
#define INTENSITY 1.0f

float rand(vec2 seed)
{
	vec3 r  = fract(vec3(seed.xyx) * vec3(0.1051f, 0.11367f, 0.13789f));
    r += dot(r, r.yzx + 17.17f);
    return fract(r.z * (r.x + r.y));
}

void main()
{
	const int ss = 1;// screen scale
	vec2 uv = gl_FragCoord.xy / BufferSize * float(ss);
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y) * ss;
    vec4 subsample;
    outColor = vec4(0.0f);
    float ao, rad, sumao = 0.0f;
	outColor = vec4(1.0f);
	
	float z = texelFetch(DepthBuffer, coord, 0).r;
	if (z < 1.0f)
    {
        vec3 p = ScreenCoordToWorldPosition(vec3(gl_FragCoord.xy * float(ss) / BufferSize, z));
        vec3 n = texelFetch(NormalBuffer, coord, 0).rgb;		
		vec2 aoUV;
        float rStep = SAMPLE_RADIUS / max(10.0f, z);
		float deltaAngle = 360.0f / float(SAMPLE_COUNT);//2.4f;
		float startRotate = rand( uv * 100.0f ) * 6.28f;
		float startrad = 0.0;
		float radius;
		float rotate;
		
		for (int i = 0; i < SAMPLE_COUNT; i++)
		{
			radius = float(i + 1) * rStep;
			rotate = startRotate + float(i) * deltaAngle;			
			aoUV.x = sin(rotate);
			aoUV.y = cos(rotate);
			vec2 tcoord = aoUV * radius;			
			if (tcoord.x + uv.x < 0.0f || tcoord.x + uv.x > 1.0f || tcoord.y + uv.y < 0.0f || tcoord.y + uv.y > 1.0f) continue;			
			vec2 samplecoord = tcoord + uv;
			float samplez = texelFetch(DepthBuffer, ivec2(samplecoord.x * DrawViewport.z, samplecoord.y * DrawViewport.w), 0).r;
			vec3 diff = ScreenCoordToWorldPosition(vec3(samplecoord, samplez)) - p;
			float l = length(diff);
			vec3 v = diff / l;
			float d = l * SCALE;
			float aosamp = max(0.0f, dot(n,v) - BIAS) * (1.0f / (1.0f + d));
			aosamp *= smoothstep(MAX_DISTANCE,MAX_DISTANCE * 0.5f, l);
			ao += aosamp;
		}
		ao /= float(SAMPLE_COUNT);
        ao = clamp(ao * INTENSITY, 0.0f, 1.0f);
		ao = 1.0f - clamp(ao, 0.0f, MAXEFFECT);
		ao = min(ao * 1.1f, 1.0f);		
		outColor.rgb *= vec3(ao);    
	}
}
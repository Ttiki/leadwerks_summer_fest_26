// Uniforms
//uniform vec3 TerrainToolPosition;
//uniform vec2 ClipmapDrawPosition[8];
//uniform vec2 ClipmapArea[8];
//uniform float CameraClipmapDistance[8];
//uniform int CountClipmaps = 1;
uniform mat4 InverseCameraProjectionViewMatrix;
uniform mat4 CameraProjectionViewMatrix;

// Samplers
uniform layout(binding = 0) sampler2DArray ColorClipmap;
uniform layout(binding = 1) sampler2DArray NormalClipmap;
uniform layout(binding = 2) sampler2DArray PBRClipmap;
uniform layout(binding = 3) sampler2DArray DisplacementClipmap;
uniform layout(binding = 4) sampler2D Heightmap;
uniform layout(binding = 5) sampler2D TerrainNormalMap;
uniform layout(binding = 6) sampler2D BaseColorClipmap;
uniform layout(binding = 7) sampler2D BaseNormalClipmap;
uniform layout(binding = 8) sampler2D BasePBRClipmap;
uniform layout(binding = 9) sampler2D BaseDisplacementClipmap;
#ifdef MSAA
uniform layout(binding = 10) sampler2DMS DepthMap;
uniform layout(binding = 11) sampler2DMS TerrainBlendMap;
uniform layout(binding = 12) sampler2DMS ScreenNormalsBuffer;
#else
uniform layout(binding = 10) sampler2D DepthMap;
uniform layout(binding = 11) sampler2D TerrainBlendMap;
uniform layout(binding = 12) sampler2D ScreenNormalsBuffer;
#endif

// Includes
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Constants.glsl"
#include "../Utilities/ReconstructPosition.glsl"
#include "ClipmapSample.glsl"

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;
out vec4 fragNormal;
out vec4 fragData;

vec3 clipmapSample(in vec3 position, in vec3 pnormal, in float deltaheight, out vec3 albedo, out vec3 normal, out vec3 pbr)
{
	vec3 a0, b0, c0;
	vec3 a1, b1, c1;
	vec3 wt = abs(pnormal);
	wt *= wt * wt;
	float sum = wt.x + wt.y + wt.z;
	vec3 samplepos;
	vec3 n;
	
	clipmapSample(position, albedo, n, pbr);
	if (wt.y == 1.0 || deltaheight == 0.0)
	{
		normal = n; 
		return n;	
	}
	
	vec3 d0, d1;
	
	samplepos = position;
	samplepos.x += deltaheight;
	clipmapSample(samplepos, a0, b0, c0);	
	d0 = b0;
	b0 = b0.yxz * vec3(sign(pnormal.x), -sign(pnormal.x), 1.0);
	
	samplepos = position;
	samplepos.z += deltaheight;
	clipmapSample(samplepos, a1, b1, c1);
	d1 = b1;
	b1 = b1.xzy * vec3(1.0, -sign(pnormal.z), sign(pnormal.z));
	
	albedo = (albedo * wt.y + a0 * wt.x + a1 * wt.z) / sum;
	normal = (n * wt.y + b0 * wt.x + b1 * wt.z) / sum;
	pbr = (pbr * wt.y + c0 * wt.x + c1 * wt.z) / sum;
	n = (n * wt.y + d0 * wt.x + d1 * wt.z) / sum;
	
	//normal = normalize(normal);
	return n;
}

void main()
{
	//Debigging...
	//fragColor = vec4(1,0,1,1);
	//return;
	
	ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
	vec2 blend = texelFetch(TerrainBlendMap, coord, 0).rg;
	if (blend.x <= 0.0 && blend.y <= 0.0) discard;
	
	vec3 screencoord;
	screencoord.xy = gl_FragCoord.xy / BufferSize;	
	screencoord.z = texelFetch(DepthMap, coord, gl_SampleID).r;
	vec3 position = ScreenCoordToWorldPosition(screencoord);
	vec3 screennormal = texelFetch(ScreenNormalsBuffer, coord, gl_SampleID).rgb * 2.0 - 1.0;
	
	vec2 texcoords = (position.xz / TerrainSize) + 0.5;
	float height = texture(Heightmap, texcoords).r;
	float deltaheight = position.y - height;
	
	vec3 n = clipmapSample(position.xyz, screennormal, deltaheight, fragColor.rgb, fragNormal.rgb, fragData.rgb);
	
	fragNormal.rgb = mix(fragNormal.rgb, n, blend.y);
	
	fragNormal.rgb = fragNormal.rgb * 0.5 + 0.5;
	
	fragColor.a = blend.x;
	fragNormal.a = blend.x;
	fragData.a = blend.x;
	
	if (RenderMode == 4) fragColor.a = 0.0;
	
	fragColor.rgb *= fragColor.a;
	fragNormal.rgb *= fragNormal.a;
	fragData.rgb *= fragData.a;
}
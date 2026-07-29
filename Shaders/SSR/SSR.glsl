// Uniforms
uniform ivec4 DrawViewport;
uniform vec2 CameraRange;
uniform vec3 CameraPosition;
//uniform mat4 InverseCameraProjectionViewMatrix;
vec2 BufferSize = vec2(DrawViewport.z, DrawViewport.w);
uniform uint CurrentTime = 0u;
uniform mat3 CameraInverseNormalMatrix;
uniform int ToneMappingMode = -1;
uniform mat4 CameraMatrix;
uniform float SSRScale = 1.0;
mat4 CameraInverseMatrix = inverse(CameraMatrix);
uniform vec4 FogColor;
uniform vec2 FogAngles;
uniform vec2 FogRange;
uniform float FogDensity;
uniform int MAX_STEPS = 100;
uniform float STEP_DELTA = 1.1;
uniform float STEP_SIZE = 0.01;

//#define MAX_STEPS 100
//#define STEP_DELTA 1.1
//#define STEP_SIZE 0.01

//#define MAX_STEPS 128
//#define STEP_DELTA 1.1
//#define STEP_SIZE 0.01

//#define MAX_STEPS 256
//#define STEP_DELTA 1.05
//#define STEP_SIZE 0.005

// Outputs
layout(location = 0) out vec4 OutColor;

// Samplers
#ifdef MSAASAMPLES
    layout(binding = 0) uniform sampler2DMS DepthBuffer;
    layout(binding = 1) uniform sampler2DMS ColorBuffer;
    layout(binding = 2) uniform sampler2DMS NormalBuffer;
    layout(binding = 3) uniform sampler2DMS PBRBuffer;
    //layout(binding = 4) uniform usampler2DMS FlagsBuffer;
    layout(binding = 6) uniform sampler2DMS TransparencyZPositionBuffer;
	layout(binding = 10) uniform sampler2DMS TransparencyColorBuffer;
#else
    layout(binding = 0) uniform sampler2D DepthBuffer;
    layout(binding = 1) uniform sampler2D ColorBuffer;
    layout(binding = 2) uniform sampler2D NormalBuffer;
    layout(binding = 3) uniform sampler2D PBRBuffer;
    //layout(binding = 4) uniform usampler2D FlagsBuffer;
    //#ifdef TRANSPARENCY
    layout(binding = 6) uniform sampler2D TransparencyZPositionBuffer;
    layout(binding = 8) uniform sampler2D TransparencyRoughnessThicknessBuffer;
    //layout(binding = 9) uniform usampler2D TransparencyFlagsBuffer;
    layout(binding = 9) uniform sampler2D TransparencySSRStrengthBuffer;
	layout(binding = 11) uniform sampler2D TransparencyNormalBuffer;
	layout(binding = 10) uniform sampler2D TransparencyColorBuffer;
    //#endif
#endif

layout(binding = 5) uniform sampler2D ReflectionBuffer;
layout(binding = 7) uniform sampler2D Lut_GGX;

#include "../Lighting/Light.glsl"
#include "../Lighting/ToneMapping.glsl"
#include "../Lighting/OpticalDensity.glsl"

mat4 CameraProjectionViewMatrix = inverse(InverseCameraProjectionViewMatrix);

float DepthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x) ) * depthrange.y;// Vulkan
	//return (depthrange.x / (depth / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);// OpenGL
}

float random(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 WorldPositionToScreenCoord(in vec3 position)
{
	vec4 coord = vec4(position, 1.0f);
	coord = CameraProjectionViewMatrix * coord;
	coord.z = (coord.z + coord.w) * 0.5f;
	coord.xy = coord.xy / coord.w * 0.5f + 0.5f;  
	return coord.xyz;
}

vec3 GetFragmentWorldPosition(in sampler2D depthmap)
{
	const int samp = 0;
	vec3 pos;
	vec2 sz = textureSize(depthmap, 0);
	vec2 texcoords = gl_FragCoord.xy / BufferSize;
	float depth = texelFetch(depthmap, ivec2(texcoords * sz), samp).r;
	pos.z = depth;//DepthToPosition(depth, CameraRange);
	pos.xy = texcoords;
	return ScreenCoordToWorldPosition(pos);
}

#ifdef MSAASAMPLES
vec4 SSRTrace(in float fdepth, in vec3 texCoords, in vec3 position, in sampler2D diffusemap, in sampler2DMS depthmap, in vec3 normal, in float roughness)
#else
vec4 SSRTrace(in float fdepth, in vec3 texCoords, in vec3 position, in sampler2D diffusemap, in sampler2D depthmap, in vec3 normal, in float roughness)
#endif
{
    float visibility = 1.0;
    float ssrambiguity = 1.0f;
    int miplevels = textureQueryLevels(diffusemap);
    float lod = roughness * float(miplevels - 1);
#ifdef MSAASAMPLES
    vec2 texsize = textureSize(depthmap);
#else
    vec2 texsize = textureSize(depthmap, 0);
#endif
	vec4 linearfogcolor = sRGBToLinear(FogColor);

#ifdef GBUFFER_MSAA
    //vec3 position = GetFragmentWorldPosition(depthmap, samp);
#else
    //vec3 position = GetFragmentWorldPosition(depthmap);
    int samp = 0;
#endif
    vec3 fragposition = position;

    vec3 screencoord;
    screencoord.xy = texCoords.xy;
    float startz = texCoords.z;

    vec3 f_specular = vec3(0.0f);

    if (normal.x == 0.0f && normal.y == 0.0f && normal.z == 0.0f) return vec4(0);
	
	position += (normal * 2.6 * fdepth) * 2.0;
    //position += normal * 0.125f;
    
    /*
    normal.x += random(gl_FragCoord.xy * normal.xy * CurrentTime) * 0.1f;
    normal.y += random(gl_FragCoord.yx * normal.zy * CurrentTime * 0.1f) * 0.1f;
    normal.z += random(gl_FragCoord.xy * normal.zx * CurrentTime * 0.2f) * 0.1f;
    normal = normalize(normal);
    */

    //roughness = max(roughness, minroughness);

    //vec3 roffset;
    //roffset.x = random(gl_FragCoord.xy * normal.xy * CurrentTime);
    //roffset.y = random(gl_FragCoord.yx * normal.yz * CurrentTime);
    //roffset.z = random(gl_FragCoord.xy * normal.zy * CurrentTime);
    //normal += roffset * roughness * 5.0f;

    //normal = normalize(normal);

    vec3 surfacenormal = normal;
    vec4 color = textureLod(diffusemap, texCoords.xy, lod) * 1.0;
    //f_specular = color.rgb;

    //if (abs(normal.y) < 0.707f) return;

    vec3 viewdir = normalize(position - CameraPosition);
    normal = reflect(viewdir, normal);

#ifdef DOUBLE_FLOAT
    dvec3 v = normalize(CameraPosition - fragposition);
#else
    vec3 v = normalize(CameraPosition - fragposition);
#endif

    vec2 texelSize = 1.0f / texsize;

    float hit = 0.0f;

    float z;
    vec3 prevscreencoord = WorldPositionToScreenCoord(position);
    vec3 prevposition = position;

    float stepsize = STEP_SIZE;//
    
    vec3 cameranormal = CameraInverseNormalMatrix * normal;
    
    //outColor.rgb = cameranormal * 0.5 + 0.5;
    //return;

    //position += normal / length(cameranormal.xy);

    //Nudge the position off the surface so it doesn't self-detect
    //position += surfacenormal * 0.05f;

    //vec3 f_emissive = vec3(0);

    float speccutoff = 0.0;

    float disttravelled = 0.0f;

    //stepsize = 1.0f * texelSize.y / length(cameranormal.xy);

    float DepthTolerance = mix(0.5, 0.75, abs(cameranormal.z));

    bool transparencyhit = false;
    if (cameranormal.z < 0.0) transparencyhit = true;
	float depth;

	int countsteps = 0;
	//for (int n = 0; n < MAX_STEPS; ++n)
	while (true)
	{
		++countsteps;
		if (countsteps >= MAX_STEPS) break;
		
		disttravelled += stepsize;
#ifdef MAX_DISTANCE
		if (disttravelled >= MAX_DISTANCE) break;
#endif
		position += normal * stepsize;
		
		if (cameranormal.z < 0.0)
		{
			vec3 lposition = (CameraInverseMatrix * vec4(position, 1.0)).xyz;
			if (lposition.z < 0.0) break;
		}
		
		screencoord = WorldPositionToScreenCoord(position);
		if (screencoord.z > CameraRange.y * 0.99) break;
		
		if (screencoord.z < CameraRange.x || screencoord.x < 0.0 || screencoord.x > 1.0 || screencoord.y < 0.0 || screencoord.y > 1.0)
		{
			ssrambiguity = 0.0f;
			break;
		}
		
		ivec2 coord = ivec2(screencoord.x * texsize.x + 0.0f, screencoord.y * texsize.y + 0.0f);
		depth = texelFetch(depthmap, coord, 0).r;//textureLod(depthmap, screencoord.xy, 0).r;
		
#ifdef TRANSPARENCY
		//--------------------------------------------------
		// Test transparency
		//--------------------------------------------------
		
		float tdepth = texelFetch(TransparencyZPositionBuffer, ivec2(screencoord.x * texsize.x + 0.0f, screencoord.y * texsize.y + 0.0f), 0).r;				
		if (tdepth > 0.0 && tdepth < depth * 0.999)
		{
			tdepth = abs(tdepth);
			z = DepthToPosition(tdepth, CameraRange);
			if (screencoord.z > z)
			{
				DepthTolerance = 0.25 * z;// / SSRScale;
				
				if (screencoord.z > z - 0.01 && screencoord.z < z + DepthTolerance)
				{
					float alpha = 1.0f - length(screencoord.y - 0.5) * 6.0f;
					if (alpha > 0.5f) alpha = 1.0f;
					vec2 dCoords = smoothstep(0.2f, 0.6f, abs(vec2(0.5f) - screencoord.xy));
					alpha = clamp(1.0f - (dCoords.x + dCoords.y), 0.0f, 1.0f);
	#ifdef MAX_DISTANCE
					if (disttravelled > MAX_DISTANCE * 0.9f)
					{
						alpha *= 1.0f - float(disttravelled - MAX_DISTANCE * 0.9f) / float(MAX_DISTANCE * 0.1f);
					}
	#endif
	#ifdef MSAASAMPLES
					vec4 diffuse = texelFetch(TransparencyColorBuffer, coord, 0);
	#else
					vec4 diffuse = textureLod(TransparencyColorBuffer, screencoord.xy, lod );
	#endif
					float transparency = max(max(diffuse.r, diffuse.g), diffuse.b);
					transparency = max(transparency, diffuse.a * 0.5);
					f_specular += diffuse.rgb * alpha;
					hit += transparency * alpha;
					hit = min(hit, 1.0);
					if (hit == 1.0) break;
				}
			}		
		}
		
		//--------------------------------------------------
#endif		
		
		// If ray hits the sky and it's almost straight from the camera, exit early
		// This will eliminate reflections of overhangs past a certain distance
		if (depth == 1.0)
		{
			vec3 dir = normalize(position - CameraPosition);
			if (dot(viewdir, dir) > 0.98)
			{
			//	break;
			}
		}
		
		z = DepthToPosition(depth, CameraRange);
		if (screencoord.z > z - 0.01)
		{
			DepthTolerance = 0.25 * z;// / SSRScale;
			
			if (screencoord.z > z - 0.01 && screencoord.z < z + DepthTolerance)
			{
				float alpha = 1.0f - length(screencoord.y - 0.5) * 6.0f;
				if (alpha > 0.5f) alpha = 1.0f;
				vec2 dCoords = smoothstep(0.2f, 0.6f, abs(vec2(0.5f) - screencoord.xy));
				alpha = clamp(1.0f - (dCoords.x + dCoords.y), 0.0f, 1.0f);
#ifdef MAX_DISTANCE
				if (disttravelled > MAX_DISTANCE * 0.9f)
				{
					alpha *= 1.0f - float(disttravelled - MAX_DISTANCE * 0.9f) / float(MAX_DISTANCE * 0.1f);
				}
#endif
				vec3 diffuse = textureLod(diffusemap, screencoord.xy, lod ).rgb;
				f_specular += diffuse * alpha * visibility;
				hit += alpha;
				break;
			}
			else
			{
				/*
				// This fills in the missing data with the best guess
				float alpha = 1.0;// - min(1.0, (screencoord.z - (z + DepthTolerance)) / DepthTolerance);
				vec3 diffuse = textureLod(diffusemap, screencoord.xy, 99.0).rgb;
				f_specular += diffuse * alpha;
				hit += alpha;
				if (hit >= 1.0) break;
				*/
			}
		}
		
//#ifdef STEP_DELTA
		DepthTolerance *= STEP_DELTA;
		stepsize *= STEP_DELTA;
//#endif
#ifdef MAX_STEP_SIZE
		stepsize = min(MAX_STEP_SIZE, stepsize);
#endif
		prevscreencoord = screencoord;
		prevposition = position;
	}
    return vec4(f_specular, hit);// * ssrambiguity);// problem with transparent reflections? I don't see any artifacts when commenting this out.
}

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    //coord.x *= 2;
    //coord.y *= 2;
#ifdef MSAASAMPLES
    ivec2 ts = textureSize(DepthBuffer);
#else
    ivec2 ts = textureSize(DepthBuffer, 0);
#endif
    vec2 texturescale = vec2( float(ts.x) / float(DrawViewport.z), float(ts.y) / float(DrawViewport.w) );
    coord.x = int( round(coord.x * texturescale.x) );
    coord.y = int( round(coord.y * texturescale.y) );

    vec3 screencoord = vec3(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w), 0.0);
    //screencoord.xy *= texturescale;

    //OutColor.rgb = (textureLod(ReflectionBuffer, screencoord.xy, 1.0).rgb);
    //OutColor.a = 1.0;
    //return;

#ifdef MSAASAMPLES
    vec4 occlusionrougnessmetalness = vec4(0.0);
    int count = textureSamples(PBRBuffer);
    for (int n = 0; n < count; ++n)
    {
        occlusionrougnessmetalness += texelFetch(PBRBuffer, coord, n);                    
    }
    occlusionrougnessmetalness /= float(count);
#else
    vec4 occlusionrougnessmetalness = texelFetch(PBRBuffer, coord, 0);
#endif

    float roughness = occlusionrougnessmetalness.g;
    float metalness = occlusionrougnessmetalness.b;

    //OutColor = vec4(0, roughness, metalness, 1.0);
    //return;

    if (roughness > 0.8)
    {
        OutColor = vec4(0.0);
        return;
    }

    screencoord.z = texelFetch(DepthBuffer, coord, 0).r;
    vec3 normal;

	if (screencoord.z == 1.0)
	{
		OutColor = vec4(0.0);
		return;
	}
#ifdef MSAASAMPLES
		normal = vec3(0.0);
		count = textureSamples(NormalBuffer);
		for (int n = 0; n < count; ++n)
		{
			normal += texelFetch(NormalBuffer, coord, n).rgb;                    
		}
		normal /= float(count);
		normal = normalize(normal * 2.0 - 1.0);
#else
		normal = normalize(texelFetch(NormalBuffer, coord, 0).rgb * 2.0 - 1.0);
#endif

    vec3 position = ScreenCoordToWorldPosition(screencoord);
    
	float fdepth = (DepthToPosition(screencoord.z, CameraRange) - CameraRange.x) / (CameraRange.y - CameraRange.x);
	vec3 dir = normalize(position - CameraPosition);
	float dd = dot(normal, dir);
	fdepth *= 1.0 - dd;
	
    vec4 reflection = SSRTrace(fdepth, screencoord, position, ReflectionBuffer, DepthBuffer, normal, roughness);
    if (reflection.a == 0.0)
    {
        OutColor = vec4(0.0);
        return;
    }

	// BSTF - Transform everything into local space
    vec3 n = normal;
    vec3 v = normalize(CameraPosition - position.xyz);

#ifdef MSAASAMPLES
	vec2 texsize = textureSize(ColorBuffer);
#else
	vec2 texsize = textureSize(ColorBuffer, 0);
#endif
	float scale = texsize.x / float(DrawViewport.z);
	//coord.x = int(float(coord.x) * scale + 0.5);
//	coord.y = int(float(coord.y) * scale + 0.5);

    vec3 albedo = texelFetch(ColorBuffer, coord, 0).rgb;
    albedo = sRGBToLinear(albedo);
    
	//albedo = vec3(0.5);
	
	//OutColor.rgb = albedo.rgb;
	//OutColor.a = 1.0;
	//return;
	
	float perceptualRoughness = clamp(roughness, 0.04, 1.0);
    float alphaRoughness = perceptualRoughness * perceptualRoughness;
    vec3 f0 = vec3(0.04);
    f0 = mix(f0, albedo, metalness);
    vec3 f90 = vec3(1.0);
    vec3 c_diff = mix(albedo,  vec3(0.0), metalness);
    float specularweight = 1.0;

    vec3 sn = n;
    //if (dot(sn, v) < 0.0f) sn *= -1.0f;
    reflection.rgb = getIBLRadianceGGX(Lut_GGX, reflection.rgb, sn, v, perceptualRoughness, f0, specularweight);

    reflection.r = clamp(reflection.r, 0.0, 1.0);
    reflection.g = clamp(reflection.g, 0.0, 1.0);
    reflection.b = clamp(reflection.b, 0.0, 1.0);

    OutColor = reflection;  
    OutColor.a = reflection.a;
}
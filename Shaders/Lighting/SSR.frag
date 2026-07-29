#version 450

// Uniforms
uniform ivec4 DrawViewport;
uniform vec2 CameraRange;
uniform vec3 CameraPosition;
//uniform mat4 InverseCameraProjectionViewMatrix;
vec2 BufferSize = vec2(DrawViewport.z, DrawViewport.w);
uniform uint CurrentTime = 0u;
uniform mat3 CameraInverseNormalMatrix;
uniform int ToneMappingMode = 0;
uniform mat4 CameraMatrix;
mat4 CameraInverseMatrix = inverse(CameraMatrix);


#define MAX_STEPS 64
#define STEP_DELTA 1.1
#define STEP_SIZE 0.025
//#define MAX_STEP_SIZE 0.1
//#define MAX_DISTANCE 16.0
#define DEPTH_TOLERANCE 2.0

// Outputs
layout(location = 0) out vec4 OutColor;

// Samplers
#ifdef MSAASAMPLES
    layout(binding = 0) uniform sampler2DMS DepthBuffer;
    layout(binding = 1) uniform sampler2DMS ColorBuffer;
    layout(binding = 2) uniform sampler2DMS NormalBuffer;
    layout(binding = 3) uniform sampler2DMS PBRBuffer;
    //layout(binding = 4) uniform usampler2DMS FlagsBuffer;
#else
    layout(binding = 0) uniform sampler2D DepthBuffer;
    layout(binding = 1) uniform sampler2D ColorBuffer;
    layout(binding = 2) uniform sampler2D NormalBuffer;
    layout(binding = 3) uniform sampler2D PBRBuffer;
    //layout(binding = 4) uniform usampler2D FlagsBuffer;
#endif
layout(binding = 5) uniform sampler2D ReflectionBuffer;
layout(binding = 6) uniform sampler2D TransparencyZPositionBuffer;
layout(binding = 7) uniform sampler2D Lut_GGX;

#include "Light.glsl"
#include "ToneMapping.glsl"

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

vec4 SSRTrace_n(in vec2 texCoords, in sampler2D diffusemap, in sampler2D depthmap, in vec3 normal, in float roughness)
{
    float ssrambiguity = 1.0;

    int miplevels = textureQueryLevels(diffusemap);
    float lod = roughness * float(miplevels - 1);

    vec3 position = GetFragmentWorldPosition(depthmap);
    vec3 fragposition = position;

    vec3 screencoord;
    screencoord.xy = texCoords;

    vec3 f_specular = vec3(0.0);

    if (length(normal) == 0.0) return vec4(0.0);

    // Offset position slightly along normal to avoid self-intersection
    position += normal * 0.05;

    // Add some noise to the normal for stochastic sampling
    vec3 randOffset = vec3(
        (random(gl_FragCoord.xy + 0.0) - 0.5) * 0.01,
        (random(gl_FragCoord.xy + 1.0) - 0.5) * 0.01,
        (random(gl_FragCoord.xy + 2.0) - 0.5) * 0.01
    );
    vec3 sampleNormal = normalize(normal + randOffset);

    // Calculate reflection direction
    vec3 viewDir = normalize(position - CameraPosition);
    vec3 reflDir = reflect(viewDir, sampleNormal);

    // Convert reflection direction to screen space
    vec3 refStartPos = position;
    vec3 refDir = reflDir;

    // Initialize ray marching parameters
    float stepSize = STEP_SIZE;
    float traveled = 0.0;

    vec3 currentPos = refStartPos;
    vec3 prevScreenCoord = WorldPositionToScreenCoord(currentPos);
    float hitAlpha = 0.0;

    // Loop for ray marching
    for (int i = 0; i < MAX_STEPS; ++i)
    {
        traveled += stepSize;
#ifdef MAX_DISTANCE
        if (traveled > MAX_DISTANCE)
            break;
#endif

        currentPos += refDir * stepSize;

        vec3 screenCoord = WorldPositionToScreenCoord(currentPos);
        // Check if out of screen bounds
        if (screenCoord.z < CameraRange.x || screenCoord.x < 0.0 || screenCoord.x > 1.0 || screenCoord.y < 0.0 || screenCoord.y > 1.0)
        {
            ssrambiguity = 0.0;
            break;
        }

        // Fetch depth at current sample
        float depthSample = texelFetch(depthmap, ivec2(int(screenCoord.x * textureSize(depthmap, 0).x), int(screenCoord.y * textureSize(depthmap, 0).y)), 0).r;
        float sceneDepth = DepthToPosition(depthSample, CameraRange);

        // Check for intersection (the ray hits geometry)
        if (screenCoord.z > sceneDepth - 0.01)
        {
            // Compute hit opacity based on proximity
            float depthDiff = sceneDepth - screenCoord.z;
            float alpha = clamp(1.0 - depthDiff * 50.0, 0.0, 1.0);
            vec2 dCoords = smoothstep(vec2(0.2), vec2(0.6), abs(vec2(0.5) - screenCoord.xy));
            alpha *= clamp(1.0 - (dCoords.x + dCoords.y), 0.0, 1.0);

            // Fetch color at hit point
            vec3 hitColor = textureLod(diffusemap, screenCoord.xy, lod).rgb;
            f_specular += hitColor * alpha;
            hitAlpha += alpha;

            break; // Exit after first hit
        }

        #ifdef STEP_DELTA
        stepSize *= STEP_DELTA; // Optionally scale step size
        #else
        stepSize = STEP_SIZE * currentPos.z;
        #endif
        #ifdef MAX_STEP_SIZE
        stepSize = min(MAX_STEP_SIZE, stepSize);
        #endif
    }

    return vec4(f_specular, hitAlpha * ssrambiguity);
}

vec4 SSRTrace(in vec2 texCoords, in vec3 position, in sampler2D diffusemap, in sampler2D depthmap, in vec3 normal, in float roughness)
{
    float ssrambiguity = 1.0f;
    int miplevels = textureQueryLevels(diffusemap);
    float lod = roughness * float(miplevels - 1);

#ifdef GBUFFER_MSAA
    //vec3 position = GetFragmentWorldPosition(depthmap, samp);
#else
    //vec3 position = GetFragmentWorldPosition(depthmap);
    int samp = 0;
#endif
    vec3 fragposition = position;

    vec3 screencoord;
    screencoord.xy = texCoords;

    vec3 f_specular = vec3(0.0f);

    if (normal.x == 0.0f && normal.y == 0.0f && normal.z == 0.0f) return vec4(0);

    position += normal * 0.125f;

    normal.x += random(gl_FragCoord.xy * normal.xy * CurrentTime) * 0.1f;
    normal.y += random(gl_FragCoord.yx * normal.zy * CurrentTime * 0.1f) * 0.1f;
    normal.z += random(gl_FragCoord.xy * normal.zx * CurrentTime * 0.2f) * 0.1f;
    normal = normalize(normal);

    //roughness = max(roughness, minroughness);

    //vec3 roffset;
    //roffset.x = random(gl_FragCoord.xy * normal.xy * CurrentTime);
    //roffset.y = random(gl_FragCoord.yx * normal.yz * CurrentTime);
    //roffset.z = random(gl_FragCoord.xy * normal.zy * CurrentTime);
    //normal += roffset * roughness * 5.0f;

    //normal = normalize(normal);

    vec3 surfacenormal = normal;
    vec4 color = textureLod(diffusemap, texCoords, lod) * 1.0;
    //f_specular = color.rgb;

    //if (abs(normal.y) < 0.707f) return;

    vec3 viewdir = normalize(position - CameraPosition);
    normal = reflect(viewdir, normal);

#ifdef DOUBLE_FLOAT
    dvec3 v = normalize(CameraPosition - fragposition);
#else
    vec3 v = normalize(CameraPosition - fragposition);
#endif

    vec2 texsize = BufferSize;
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

    stepsize = 1.0f * texelSize.y / length(cameranormal.xy);

    float DepthTolerance = mix(0.5, 0.75, abs(cameranormal.z));

    //if (cameranormal.z > 0.0)
    {
        int countsteps = 0;
        //for (int n = 0; n < MAX_STEPS; ++n)
        while (true)
        {
            ++countsteps;
            
            // This should not happen...
            if (countsteps >= MAX_STEPS)
            {
                //outColor = vec4(1,0,1,1);
                break;
            }
            
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
            
            //screencoord.xy += cameranormal.xy * texelSize;
            //screencoord.z += cameranormal.z;
            //position = ScreenCoordToWorldPosition(screencoord);

            if (screencoord.z < CameraRange.x || screencoord.x < 0.0 || screencoord.x > 1.0 || screencoord.y < 0.0 || screencoord.y > 1.0)
            {
                ssrambiguity = 0.0f;
                break;
            }
//#ifdef GBUFFER_MSAA
            float depth = texelFetch(depthmap, ivec2(screencoord.x * texsize.x + 0.0f, screencoord.y * texsize.y + 0.0f), 0).r;//textureLod(depthmap, screencoord.xy, 0).r;
//#else
//            float depth = texelFetch(depthmap, ivec2(screencoord.x * texsize.x + 0.5f, screencoord.y * texsize.y + 0.5f), 0).r;//textureLod(depthmap, screencoord.xy, 0).r;
//#endif
            z = DepthToPosition(depth, CameraRange);
            //z = depthSample(texture2DSampler[DepthTextureID], screencoord.xy);
            if (screencoord.z > CameraRange.y *0.99f) break;

            if (screencoord.z > z)
            {
                //if (screencoord.z < z + cameranormal.z * stepsize * 6.0)
                DepthTolerance = mix(0.5, 0.75, abs(cameranormal.z));
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
                    //ssrambiguity = 0.0f;// - alpha;

                    float diff = (z - screencoord.z) / (stepsize * 2.0);
                    //alpha *= 1.0f - diff;

                    //vec3 nsample = normalize(textureLod(normalmap, screencoord.xy, lod).rgb);
                    //if (dot(nsample, normal) < 0.0f)
                    {
                        //float d = min(dot(-viewdir, nsample) * 100.0f, 1.0f);
                        vec3 diffuse = textureLod(diffusemap, screencoord.xy, lod).rgb;
                        f_specular += diffuse * alpha;
                        hit += alpha;
                        
                    }
                    //else
                    {
                        //ssrambiguity = 1.0f;
                    }
                }
                else
                {
                    //ssrambiguity = 0.0f;
                }
                break;

                /*float l2 = length(screencoord.xy - prevscreencoord.xy);
                int substeps = 8;//max(1, int(l2));
                position = prevposition;
                screencoord = prevscreencoord;
                float substepsize = stepsize / float(substeps);
                float tolerance = DEPTH_TOLERANCE / float(substeps);
                for (int m = 0; m < substeps; ++m)
                {
                    position += normal * substepsize;
                    screencoord = WorldPositionToScreenCoord(position);
                    //depth = textureLod(texture2DSampler[DepthTextureID], screencoord.xy, 0).r;
                    //z = DepthToPosition(depth, CameraRange);
                    z = depthSample(texture2DSampler[DepthTextureID], screencoord.xy);
                    if (screencoord.z > z and screencoord.z < z + tolerance)
                    {
                        if (depth < CameraRange.y)
                        {
                            vec2 dCoords = smoothstep(0.2, 0.6, abs(vec2(0.5, 0.5) - screencoord.xy));
                            float alpha = clamp(1.0 - (dCoords.x + dCoords.y), 0.0, 1.0);
                            color.rgb += textureLod(texture2DSampler[DiffuseTextureID], screencoord.xy, lod).rgb * alpha * specularcolor;
                            break;
                        }
                    }
                }
                break;*/
            }

#ifdef STEP_DELTA
            DepthTolerance *= STEP_DELTA;
            stepsize *= STEP_DELTA;
#endif
#ifdef MAX_STEP_SIZE
            stepsize = min(MAX_STEP_SIZE, stepsize);
#endif
            prevscreencoord = screencoord;
            prevposition = position;
        }
    }
    return vec4(f_specular, hit * ssrambiguity);
}

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    ivec2 ts = textureSize(DepthBuffer, 0);
    vec2 texturescale = vec2( float(ts.x) / float(DrawViewport.z), float(ts.y) / float(DrawViewport.w) );
    coord.x = int( round(coord.x * texturescale.x) );
    coord.y = int( round(coord.y * texturescale.y) );

    vec3 screencoord = vec3(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w), 0.0);
    screencoord.xy *= texturescale;

    //OutColor.rgb = (textureLod(ReflectionBuffer, screencoord.xy, 1.0).rgb);
    //OutColor.a = 1.0;
    //return;

    vec4 occlusionrougnessmetalness = texelFetch(PBRBuffer, coord, 0);
    float roughness = occlusionrougnessmetalness.g;
    float metalness = occlusionrougnessmetalness.b;
    
    if (roughness > 0.8)
    {
        OutColor = vec4(0.0);
        return;
    }

    screencoord.z = texelFetch(DepthBuffer, coord, 0).r;
    vec3 normal;
    
    float z = texelFetch(TransparencyZPositionBuffer, coord, 0).r;
    if (z < screencoord.z)
    {
        screencoord.z = z;
        normal = vec3(0,0,-1);
    }
    else
    {
        normal = normalize(texelFetch(NormalBuffer, coord, 0).rgb * 2.0 - 1.0);
    }

    /*if (Transparency == 1)
    {
        float depth2 = texelFetch(DepthBuffer, coord, n).r;
        if (depth2 < screencoord.z)
        {
            screencoord.z = depth2;
        }
    }*/

    if (screencoord.z == 1.0)
    {
        OutColor = vec4(0.0);
        return;
    }

    vec3 position = ScreenCoordToWorldPosition(screencoord);
    
    vec4 reflection = SSRTrace(screencoord.xy, position, ReflectionBuffer, DepthBuffer, normal, roughness);
    if (reflection.a == 0.0)
    {
        OutColor = vec4(0.0);
        return;
    }

	// BSTF - Transform everything into local space
    vec3 n = normal;
    vec3 v = normalize(CameraPosition - position.xyz);

    vec3 albedo = texelFetch(ColorBuffer, coord, 0).rgb;
    albedo = sRGBToLinear(albedo);
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
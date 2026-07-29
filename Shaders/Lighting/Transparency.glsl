uniform ivec4 DrawViewport;
uniform vec2 CameraRange;
uniform mat4 CameraProjectionMatrix;
//uniform mat4 InverseCameraProjectionViewMatrix;
uniform vec3 CameraPosition;
uniform int ToneMapping = 0;
uniform int SSR = 0;

#ifdef MSAASAMPLES
layout(binding = 0) uniform sampler2DMS DepthBuffer;
layout(binding = 2) uniform sampler2DMS ColorBuffer;
layout(binding = 3) uniform sampler2DMS NormalBuffer;
layout(binding = 4) uniform sampler2DMS ZPositionBuffer;
layout(binding = 5) uniform sampler2DMS RoughnessThicknessBuffer;
layout(binding = 6) uniform usampler2DMS RefractionModelBuffer;
#else
layout(binding = 0) uniform sampler2D DepthBuffer;
layout(binding = 2) uniform sampler2D ColorBuffer;
layout(binding = 3) uniform sampler2D NormalBuffer;
layout(binding = 4) uniform sampler2D ZPositionBuffer;
layout(binding = 5) uniform sampler2D RoughnessThicknessBuffer;
layout(binding = 6) uniform usampler2D RefractionModelBuffer;
#endif
layout(binding = 1) uniform sampler2D BackgroundBuffer;// Includes indirect specular reflection
layout(binding = 7) uniform sampler2D ReflectionsBuffer;
layout(binding = 8) uniform sampler2D BackgroundBuffer2;// No indirect specular reflection

// Includes
#include "Light.glsl"
#include "ToneMapping.glsl"

// Uniforms
uniform int MipLevels = 1;
uniform mat3 CameraNormalMatrix;

// Outputs
layout(location = 0) out vec4 OutColor;

/*
vec3 ScreenCoordToWorldPosition(in vec3 position)
{
	vec4 coord = InverseCameraProjectionViewMatrix * vec4(position.xy * 2.0f - 1.0f, position.z * 2.0f - 1.0f, 1.0f);
	return coord.xyz / coord.w;
}

float PositionToDepth(in float z, in vec2 depthrange)
{
	return (depthrange.x / (z / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);
}
*/

float DepthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x) ) * depthrange.y;
}

vec3 getVolumeTransmissionRay(vec3 n, vec3 v, float thickness, float ior, mat4 modelMatrix)
{
    // Direction of refracted light.
    vec3 refractionVector = refract(-v, normalize(n), 1.0 / ior);

    // Compute rotation-independant scaling of the model matrix.
    vec3 modelScale;
    modelScale.x = length(vec3(modelMatrix[0].xyz));
    modelScale.y = length(vec3(modelMatrix[1].xyz));
    modelScale.z = length(vec3(modelMatrix[2].xyz));

    // The thickness is specified in local space.
    return normalize(refractionVector) * thickness * modelScale;
}

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec2 texcoord = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));
    vec3 screencoord = vec3(texcoord, 0.0);

    float alpha = 0.0;
    vec4 background = vec4(0.0);
    vec4 background2 = vec4(0.0);// background with no specular
    vec4 foreground = vec4(0.0);
    bool anythingdrawn = false;
    float transparency = 0.0;
    vec2 roughnessthickness = vec2(0.0);
    float deltaz = 0.0;
    float transparentreflection = 0.0;

#ifdef MSAASAMPLES
    for (int n = 0; n < MSAASAMPLES; ++n)
    {
#else
    #define n 0
#endif
        vec2 bgcoords = texcoord;
        float bglod = 0.0;
        float rawz = texelFetch(ZPositionBuffer, coord, n).r;
        if (rawz < 1.0)
        {
            transparency += 1.0;
            //z = z * (CameraRange.y - CameraRange.x) + CameraRange.x;        
            float z = DepthToPosition(rawz, CameraRange);
            float rawdepth = texelFetch(DepthBuffer, coord, n).r;
            float depth = DepthToPosition(rawdepth, CameraRange);

            if (z <= depth)
            {
                uint flags = texelFetch(RefractionModelBuffer, coord, n).r;
                
                deltaz += depth - z;

                anythingdrawn = true;
                foreground += texelFetch(ColorBuffer, coord, n);

                if (foreground.a > 0.0)
                {
                    roughnessthickness = texelFetch(RoughnessThicknessBuffer, coord, n).rg;
                    float thickness = roughnessthickness.g;
                    
                    vec3 normal = normalize(texelFetch(NormalBuffer, coord, n).rgb * 2.0 - 1.0);
                    
                    if ((2 & flags) != 0) transparentreflection += 1.0;

                    if ((1 & flags) != 0)
                    {
                        // Simple refraction
                        //normal = CameraNormalMatrix * normal;
                        bgcoords += normal.xy * 0.025 * clamp(depth - z, 0.25, 2.0);// This could be gradually faded out on the edges for a better appearance
                        ivec2 coord = ivec2(bgcoords.x * float(DrawViewport.z), bgcoords.y * float(DrawViewport.w));
                        coord.x = clamp(coord.x, 0, int(DrawViewport.z));
                        coord.y = clamp(coord.y, 0, int(DrawViewport.w));
                        float depth = texelFetch(DepthBuffer, coord, n).r;
                        depth = DepthToPosition(depth, CameraRange);
                        if (depth < z) bgcoords = texcoord;
                    }
                    else
                    { 
                        // Realistic refraction
                        screencoord.z = rawz;//PositionToDepth(z, CameraRange);
                        vec3 position = ScreenCoordToWorldPosition(screencoord);
                        vec3 v = normalize(CameraPosition - position);
                        float ior = 1.5;
                        thickness = 0.25;
                        mat4 u_ModelMatrix = mat4(1.0f);
                        vec3 transmissionRay = getVolumeTransmissionRay(normal, v, thickness, ior, u_ModelMatrix);
                        vec3 refractedRayExit = position + transmissionRay;                        

                        // Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
                        vec4 ndcPos = CameraProjectionMatrix * vec4(refractedRayExit, 1.0);
                        bgcoords = ndcPos.xy / ndcPos.w;
                        bgcoords = (bgcoords + 1.0) * 0.5;
                    }
                    
                    //int mipcount = textureQueryLevels(BackgroundBuffer);
                    bglod = roughnessthickness.r * float(MipLevels - 1);
                }
            }            
        }
        background += textureLod(BackgroundBuffer, bgcoords, bglod);
        background2 += textureLod(BackgroundBuffer2, bgcoords, bglod);
#ifdef MSAASAMPLES
    }
    transparentreflection /= float(MSAASAMPLES);
    deltaz /= float(MSAASAMPLES);
    transparency /= float(MSAASAMPLES);
    background /= float(MSAASAMPLES);
    background2 /= float(MSAASAMPLES);
    foreground /= float(MSAASAMPLES);
    roughnessthickness /= float(MSAASAMPLES);
#endif
    
    if (SSR == 1)
    {
        vec4 r = textureLod(ReflectionsBuffer, bgcoords, bglod);        
        if (transparentreflection > 0.5)
        {        
            foreground.rgb = mix(foreground.rgb, r.rgb, r.a);
        }
        else
        {
            background.rgb = mix(background.rgb, background2.rgb + r.rgb, r.a);
        }
    }

    // Make rough glass appear more clear for closer objects
    const float roughnessrange = 0.5;
    if (deltaz < roughnessrange) roughnessthickness.r = mix(roughnessthickness.r * 0.5, roughnessthickness.r, deltaz / roughnessrange);

    //foreground.rgb = linearTosRGB(foreground.rgb);
    //background = textureLod(BackgroundBuffer, bgcoords, roughnessthickness.r * float(MipLevels - 1));
    OutColor.rgb = background.rgb * (1.0 - foreground.a) + foreground.rgb;

    //if (ToneMapping != -1)
    OutColor.rgb = ApplyToneMapping(OutColor.rgb, 0);
}
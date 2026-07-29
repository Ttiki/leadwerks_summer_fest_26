// This doesn't save very much time at all
//#define OPTIMIZELAMBERTIAN
//#define OPTIMIZESPECULAR

#include "../Common/ColorSpace.glsl"

uniform mat4 InverseCameraProjectionViewMatrix;

//---------------------------------------------------------------
// Light Structures
//---------------------------------------------------------------

/*struct DirectionalLight
{
    vec3 direction;
    uint flags;
    mat4 matrix[4];
    vec2 area[4];
    vec4 color;
    vec2 range;
    vec4 partitiondistance;
};*/

struct Light
{
    mat4 matrix;
    vec3 direction;
    uint flags;
    vec2 range;
    vec2 coneangles;
};

struct ProbeVolume
{
    mat4 matrix;
    vec3 fadedistance0;
    uint flags;
    vec3 fadedistance1;
};

//---------------------------------------------------------------
// Storage Buffers
//---------------------------------------------------------------

//#define STORAGE_BUFFER_LIGHTS 7
//layout(std430, binding = STORAGE_BUFFER_LIGHTS) readonly buffer LightBlock { Light Lights[]; };

//---------------------------------------------------------------
// Helper Functions
//---------------------------------------------------------------

float PositionToDepth(in float z, in vec2 depthrange)
{
	return (depthrange.x / (z / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);// Vulkan
	//return depthrange.x / (depthrange.y - z * (depthrange.y - depthrange.x)) * depthrange.y;// OpenGL
}

vec3 ScreenCoordToWorldPosition(in vec3 position)
{
	vec4 coord = InverseCameraProjectionViewMatrix * vec4(position.xy * 2.0f - 1.0f, position.z * 2.0f - 1.0f, 1.0f);
	return coord.xyz / coord.w;
}

float clampedDot(vec3 x, vec3 y)
{
    return clamp(dot(x, y), 0.0, 1.0);
}

//---------------------------------------------------------------
// Diffuse Lighting
//---------------------------------------------------------------

vec3 F_Schlick(vec3 f0, vec3 f90, float VdotH)
{
    return f0 + (f90 - f0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);
}

vec3 BRDF_lambertian(vec3 f0, vec3 f90, vec3 diffuseColor, float specularWeight, float VdotH)
{
    // see https://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    return (1.0 - specularWeight * F_Schlick(f0, f90, VdotH)) * (diffuseColor / 3.141592653589793);
}

//---------------------------------------------------------------
// Specular Lighting
//---------------------------------------------------------------

float V_GGX(float NdotL, float NdotV, float alphaRoughness)
{
    float alphaRoughnessSq = alphaRoughness * alphaRoughness;

    float GGXV = NdotL * sqrt(NdotV * NdotV * (1.0 - alphaRoughnessSq) + alphaRoughnessSq);
    float GGXL = NdotV * sqrt(NdotL * NdotL * (1.0 - alphaRoughnessSq) + alphaRoughnessSq);

    float GGX = GGXV + GGXL;
    if (GGX > 0.0)
    {
        return 0.5 / GGX;
    }
    return 0.0;
}

float D_GGX(float NdotH, float alphaRoughness)
{
    float alphaRoughnessSq = alphaRoughness * alphaRoughness;
    float f = (NdotH * NdotH) * (alphaRoughnessSq - 1.0) + 1.0;
    return alphaRoughnessSq / (3.141592653589793 * f * f);
}

vec3 BRDF_specularGGX(vec3 f0, vec3 f90, float alphaRoughness, float specularWeight, float VdotH, float NdotL, float NdotV, float NdotH)
{
    // prevents flickering pixels
    NdotV = clamp(NdotV, 0.0, 0.98);
    NdotL = clamp(NdotL, 0.0, 0.98);

    vec3 F = F_Schlick(f0, f90, VdotH);
    float Vis = V_GGX(NdotL, NdotV, alphaRoughness);
    float D = D_GGX(NdotH, alphaRoughness);

    return specularWeight * F * Vis * D;
}

/*
// Approximate GGX Geometry term with a simple inverse quadratic
float V_GGX_Approx(float NdotL, float NdotV, float alphaRoughness)
{
    // Use a simple form for visibility
    float gg = max(NdotL, NdotV);
    return 0.5 / (gg + alphaRoughness);
}

// Approximate GGX Distribution with a simple power law
float D_GGX_Approx(float NdotH, float alphaRoughness)
{
    return pow(NdotH, alphaRoughness * 4.0) * (1.0 / 3.14159);
}

// Approximate Schlick Fresnel with a fixed factor
vec3 F_Schlick_Fake(vec3 f0, vec3 f90, float VdotH)
{
    // Just return f0 for simplicity
    return f0;
}

vec3 BRDF_specularGGX2(vec3 f0, vec3 f90, float alphaRoughness, float specularWeight, float VdotH, float NdotL, float NdotV, float NdotH)
{
    vec3 F = F_Schlick_Fake(f0, vec3(1.0), VdotH);
    float Vis = V_GGX_Approx(NdotL, NdotV, alphaRoughness);
    float D = D_GGX_Approx(NdotH, alphaRoughness);
    return specularWeight * F * Vis * D;
}
*/

//---------------------------------------------------------------
// Diffuse Image-based Lighting
//---------------------------------------------------------------

#ifdef OPTIMIZELAMBERTIAN

vec3 getIBLRadianceLambertian(in sampler2D u_GGXLUT, in vec3 irradiance, vec3 n, vec3 v, float roughness, vec3 diffuseColor, vec3 F0, float specularWeight)
{
    // Basic diffuse scaled by irradiance
    return diffuseColor * irradiance;
}

#else

vec3 getIBLRadianceLambertian(in sampler2D u_GGXLUT, in vec3 irradiance, vec3 n, vec3 v, float roughness, vec3 diffuseColor, vec3 F0, float specularWeight)
{
    return diffuseColor * irradiance;

    float NdotV = clampedDot(n, v);
    vec2 brdfSamplePoint = clamp(vec2(NdotV, roughness), vec2(0.0f, 0.0f), vec2(1.0f, 1.0f));
    vec2 f_ab = texture(u_GGXLUT, brdfSamplePoint).rg;

    //vec3 irradiance = getDiffuseLight(u_LambertianEnvSampler, n);

    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera

    vec3 Fr = max(vec3(1.0f - roughness), F0) - F0;
    vec3 k_S = F0 + Fr * pow(1.0f - NdotV, 5.0f);
    vec3 FssEss = specularWeight * k_S * f_ab.x + f_ab.y; // <--- GGX / specular light contribution (scale it down if the specularWeight is low)

    // Multiple scattering, from Fdez-Aguera
    float Ems = (1.0f - (f_ab.x + f_ab.y));
    vec3 F_avg = specularWeight * (F0 + (1.0f - F0) / 21.0f);
    vec3 FmsEms = Ems * FssEss * F_avg / (1.0f - F_avg * Ems);
    vec3 k_D = diffuseColor * (1.0f - FssEss + FmsEms); // we use +FmsEms as indicated by the formula in the blog post (might be a typo in the implementation)

    return (FmsEms + k_D) * irradiance;
}

#endif

//---------------------------------------------------------------
// Specular Image-based Lighting
//---------------------------------------------------------------

//#define ALGOBRDF
#ifdef ALGOBRDF

// Experimental, won't work as-is
//https://community.khronos.org/t/code-that-approximates-the-ggx-lookup-table/112464

vec3 EnvDFGPolynomial(in vec3 specularColor, float roughness, float ndotv)
{
    float x = 1.0 - roughness;
    float y = ndotv;
    
    float b1 = -0.1688;
    float b2 = 1.895;
    float b3 = 0.9903;
    float b4 = -4.853;
    float b5 = 8.404;
    float b6 = -5.069;
    float bias = clamp( min( b1 * x + b2 * x * x, b3 + b4 * y + b5 * y * y + b6 * y * y * y ), 0.0, 1.0);
    
    float d0 = 0.6045;
    float d1 = 1.699;
    float d2 = -0.5228;
    float d3 = -3.603;
    float d4 = 1.404;
    float d5 = 0.1939;
    float d6 = 2.661;
    float delta = clamp( d0 + d1 * x + d2 * y + d3 * x * x + d4 * x * y + d5 * y * y + d6 * x * x * x, 0.0, 1.0);
    float scale = delta - bias;
    
    bias *= clamp( 50.0 * specularColor.y, 0.0, 1.0);
    return specularColor * scale + bias;
}
 
//https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
vec3 EnvBRDFApprox( vec3 SpecularColor, float Roughness, float NoV )
{
	const vec4 c0 = { -1, -0.0275, -0.572, 0.022 };
	const vec4 c1 = { 1, 0.0425, 1.04, -0.04 };
	vec4 r = Roughness * c0 + c1;
	float a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
	vec2 AB = vec2( -1.04, 1.04 ) * a004 + r.zw;
	return SpecularColor * AB.x + AB.y;
}

#endif

#ifdef OPTIMIZESPECULAR

vec3 getIBLRadianceGGX(
    in sampler2D u_GGXLUT, 
    in vec3 specularSample,
    in vec3 n,
    in vec3 v,
    float roughness,
    vec3 F0,
    float specularWeight
) {
    // Return scaled specular sample with a fixed darkening factor
    float brightnessFactor = 0.2; // reduce brightness significantly
    return specularWeight * specularSample * brightnessFactor;
}

#else

vec3 getIBLRadianceGGX(in sampler2D u_GGXLUT, in vec3 specularSample, vec3 n, vec3 v, float roughness, vec3 F0, float specularWeight)
{
    float NdotV = clampedDot(n, v);
#ifdef ALGOBRDF
    return EnvBRDFApprox(specularSample, roughness, NdotV) * specularWeight;
    //return EnvDFGPolynomial(specularSample, roughness, NdotV) * specularWeight;
#else
    vec3 reflection = normalize(reflect(-v, n));
    vec2 brdfSamplePoint = clamp(vec2(NdotV, roughness), vec2(0.0, 0.0), vec2(1.0, 1.0));
    vec2 f_ab = texture(u_GGXLUT, brdfSamplePoint).rg;
    //vec4 specularSample = getSpecularSample(u_GGXEnvSampler, reflection, lod);

    vec3 specularLight = specularSample.rgb;

    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera
    vec3 Fr = max(vec3(1.0 - roughness), F0) - F0;
    vec3 k_S = F0 + Fr * pow(1.0 - NdotV, 5.0);
    vec3 FssEss = k_S * f_ab.x + f_ab.y;

    return specularWeight * specularLight * FssEss;
#endif
}

#endif
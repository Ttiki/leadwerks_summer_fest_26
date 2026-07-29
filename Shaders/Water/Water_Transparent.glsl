//------------------------------------------------------
// Uniforms
//------------------------------------------------------

uniform uvec4 Probes;
uniform int CountProbes = 0;
uniform mat4 LightMatrix[4];
uniform vec3 FadeDistance[8];
uniform uvec4 ProbeIndex;
uniform float WaveNormalDistance = 100.0;
uniform float WaveNormalIterations = 16.0;

//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Uniforms.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Entities.glsl"
#include "../Lighting/OpticalDensity.glsl"

//------------------------------------------------------
// Samplers
//------------------------------------------------------

layout(binding = 0) uniform sampler2D BaseColorMap;
layout(binding = 1) uniform sampler2D NormalMap;
layout(binding = 2) uniform sampler2D MetallicRoughnessMap;
layout(binding = 3) uniform sampler2D DusplacementMap;
layout(binding = 4) uniform sampler2D EmissionMap;
layout(binding = 13) uniform sampler2D Lut_GGX;
layout(binding = 14) uniform samplerCube DiffuseEnvironmentMap;
layout(binding = 15) uniform samplerCube SpecularEnvironmentMap;
layout(binding = 12) uniform samplerCubeArray DiffuseMap;
layout(binding = 11) uniform samplerCubeArray SpecularMap;
layout(binding = 15) uniform samplerCube BFNTable;

#ifdef MSAASAMPLES
layout(binding = 10) uniform sampler2DMS DepthBuffer;
#else
layout(binding = 10) uniform sampler2D DepthBuffer;
#endif

//------------------------------------------------------
// Constants
//------------------------------------------------------

// Texture Slots
#define TEXTURE_0 1u
#define TEXTURE_1 2u
#define TEXTURE_2 4u
#define TEXTURE_3 8u
#define TEXTURE_4 16u
#define TEXTURE_5 32u
#define TEXTURE_6 64u
#define TEXTURE_7 128u
#define TEXTURE_8 256u
#define TEXTURE_9 512u
#define TEXTURE_10 1024u
#define TEXTURE_11 2048u
#define TEXTURE_12 4096u
#define TEXTURE_13 8192u
#define TEXTURE_14 16384u
#define TEXTURE_15 32768u

//------------------------------------------------------
// Inputs
//------------------------------------------------------

in vec4 color;
in vec3 normal;
in vec4 TexCoords;
in vec3 tangent;
in vec3 bitangent;
in vec4 vertexWorldPosition;
in vec3 emissioncolor;
in vec4 materialweights;
in flat uint EntityIndex;

//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Materials.glsl"
#include "../Lighting/Light.glsl"
#include "../Lighting/DrawIBL.glsl"
#include "../Lighting/DrawProbe.glsl"
#include "../Editor/RenderModes.glsl"
#include "ShoreFoam.glsl"

//------------------------------------------------------
// Outputs
//------------------------------------------------------

layout(location = 0) out vec4 Out_Albedo;
layout(location = 1) out vec4 Out_Normal;
layout(location = 2) out float Out_ZPosition;
layout(location = 3) out vec4 Out_IORRoughness;
layout(location = 4) out vec4 Out_SSRStrength;
//layout(location = 4) out uint Out_TransparencyFlags;
layout(location = 5) out vec4 Out_SSRNormal;
layout(location = 6) out vec4 Out_SSROcclusionRoughnessMetal;
layout(location = 7) out vec4 Out_SSRAlbedo;

#include "Waves.glsl"

float DepthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x) ) * depthrange.y;
}

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{
	float depth1 = texelFetch(DepthBuffer, ivec2(gl_FragCoord.x, gl_FragCoord.y), 0).r;
	depth1 = DepthToPosition(depth1, CameraRange);
	float depth2 = DepthToPosition(gl_FragCoord.z, CameraRange);
	float dz = max(depth1 - depth2, 0.0);
	
	vec4 foam = vec4(0.0);
	if (RenderMode == RENDERMODE_TEXTUREDLIGHTING || RenderMode == RENDERMODE_LIGHTING)
	{
		if ((TextureFlags & 6u) == 6u)
		{
			if (dz < 1.0) foam = calculateFoam(vec3(TexCoords.x, vertexWorldPosition.y, TexCoords.y), dz, NormalMap, MetallicRoughnessMap);
		}
	}
	
    Material material;
	UnpackMaterial(uint(MaterialIndex[0]), material);
    
    vec3 position = vertexWorldPosition.xyz;
    vec3 v = normalize(CameraPosition - position);
	
    //------------------------------------------------------
    // Normals
    //------------------------------------------------------
	
    //Out_Normal.rgb = texture(BFNTable, normalize(vec3(normal.x, -normal.y, normal.z))).rgb;
    vec3 n = normal;
    vec3 simplenormal = vec3(0.0, 0.0, 1.0);
    
    float dist = length(vertexWorldPosition.xyz - CameraPosition);
	float fogdistance = dist;
	dist /= WaveNormalDistance;
	dist = 1.0 - min(dist,1.0);
    float m = dist;
	//m *= m * m;
	float nm = abs(dot(normal, v));
	//nm = asin(nm) / radians(90.0);
	nm = sin(radians(nm * 90.0));
	m *= nm;
	vec3 surfnormal = vec3(0,0,1);
	float waveheight = 0.0;
    if (m > 0.0)
    {
        n = waveNormal(TexCoords.xy * 10.0, 0.01, 0.5 * m, WaveNormalIterations * dist, 1.0, waveheight);
		n = normalize(n);
        n = n.xzy;
		float ns = material.normalscale;
		if (ns != 1.0)
		{
			n.xy *= ns;
			n = normalize(n);			
		}
		surfnormal = n;
		//n += waveNormal(vertexWorldPosition.xz * 1.0, 0.01, 2.0 * m * 2.0, 6.0, 0.25) * 0.5;
        //n *= 0.5;
		n = tangent.xyz * n.x + bitangent * n.y + normal * n.z;
    }
    else
    {
        n = normal;
    }
	if (!gl_FrontFacing) n *= -1.0;
	//n = vec3(0.0, 1.0, 0.0);
    
	//n = normal;
	
	//n = vec3(0.0, 1.0, 0.0);
    Out_Normal.rgb = n * 0.5 + 0.5;
    Out_SSRNormal = Out_Normal;
	//Out_SSRNormal.rgb = mix(vec3(0.5,1,0.5), Out_Normal.rgb, 1.0 - min(dist / 4.0, 1.0));
    
    //------------------------------------------------------
    // Albedo
    //------------------------------------------------------
    
    vec4 baseColor = sRGBToLinear(color) * sRGBToLinear(material.diffuseColor);	
	if (RenderMode ==4) baseColor = vec4(0.18,0.18,0.18,1.0);
	
    bool hasbasecolortexture = (TextureFlags & TEXTUREFLAGS_BASECOLOR) != 0;
    if (hasbasecolortexture)
	{
		baseColor *= sRGBToLinear(texture(BaseColorMap, TexCoords.xy + surfnormal.xy * 0.05, TextureLodBias));
		//baseColor = mix(baseColor, baseColor * texture(BaseColorMap, TexCoords.xy + surfnormal.xy * 0.05, TextureLodBias), WaveHeight);
	}
    Out_Albedo = baseColor;	
	Out_Albedo += foam.r;
	
	//Out_Albedo = vec4(WaveHeight, WaveHeight, WaveHeight, 1.0);
	
#ifdef ALPHA_DISCARD
    //if (hasbasecolortexture) Out_Albedo.a *= 1.0 + max(0.0, textureQueryLod(BaseColorMap, TexCoords.xy).y) * 0.25;// Sharpen alpha
    if (Out_Albedo.a < material.alphacutoff) discard;
#else
    if (material.alphacutoff > 0.0)
    {
        // https://bgolus.medium.com/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f
        if (hasbasecolortexture) Out_Albedo.a *= 1.0 + max(0.0, textureQueryLod(BaseColorMap, TexCoords.xy).y) * 0.25;// Sharpen alpha
        Out_Albedo.a = (Out_Albedo.a - material.alphacutoff) / max(fwidth(Out_Albedo.a), 0.0001) + 0.5;        
    }
    Out_Albedo.a = 1.0 - Out_Albedo.a;
    float d = 1.0 - abs(dot(n, v));
    Out_Albedo.a *= 1.0 - d * d;
    Out_Albedo.a = 1.0 - Out_Albedo.a;
#endif
	
	//----------------------------------------------
	// Optical Density
	//----------------------------------------------
	
	if (gl_FrontFacing && material.opticaldensity > 0.0)
	{
		float t = transmittance(material.opticaldensity, dz);
		Out_Albedo.a = mix(1.0, Out_Albedo.a, t);
	}
	
	//--------------------------------------------------------
	// Soft Edges
	//--------------------------------------------------------
	
	if (dz < material.edgesoftness)
	{
		Out_Albedo.a *= dz / material.edgesoftness;
	}
	
    Out_Normal.a = Out_Albedo.a;
	Out_SSRNormal.a = Out_Albedo.a;
	Out_SSRAlbedo.rgb = linearTosRGB(Out_Albedo.rgb);
	Out_SSRAlbedo.a = Out_Albedo.a;	
	
    //------------------------------------------------------
    // Roughness / Thickness
    //------------------------------------------------------
    
    vec3 occlussionroughnessmetal = vec3(material.occlusion, material.roughness, material.metalness);
    if ((TextureFlags & TEXTUREFLAGS_METALLICROUGHNESS) != 0)
    {
        occlussionroughnessmetal *= texture(MetallicRoughnessMap, TexCoords.xy, TextureLodBias).rgb;
        occlussionroughnessmetal.r = mix(material.occlusion, occlussionroughnessmetal.r, 1.0);
    }
	
	// Make transmittance affect roughness
	//occlussionroughnessmetal.g = min(occlussionroughnessmetal.g + (1.0 - t) * 0.5, 1.0);
	
    Out_IORRoughness.r = (material.ior - 1.0) * 0.25;// Index of refraction
    Out_IORRoughness.g = occlussionroughnessmetal.g; // Roughness
    //Out_IORRoughness.b = material.opticaldensity * 0.5;
	Out_IORRoughness.a = Out_Normal.a;
	
    Out_SSROcclusionRoughnessMetal.r = 1.0;
    Out_SSROcclusionRoughnessMetal.g = occlussionroughnessmetal.g;
    Out_SSROcclusionRoughnessMetal.b = occlussionroughnessmetal.b;
    Out_SSROcclusionRoughnessMetal.a = Out_Normal.a;
	
    //------------------------------------------------------
    // Lighting
    //------------------------------------------------------
	
	if (RenderMode == RENDERMODE_TEXTUREDLIGHTING || RenderMode == RENDERMODE_LIGHTING)
	{
		baseColor.rgb = sRGBToLinear(baseColor.rgb);
		float roughness = occlussionroughnessmetal.g;
		float metalness = occlussionroughnessmetal.b;
		float perceptualRoughness = clamp(roughness, 0.04, 1.0);
		float alphaRoughness = perceptualRoughness * perceptualRoughness;
		vec3 f0 = vec3(0.04);
		f0 = mix(f0, baseColor.rgb, metalness);
		vec3 f90 = vec3(1.0);
		vec3 c_diff = mix(baseColor.rgb, vec3(0.0), metalness);

		Light probe;
		float alpha = 0.0;
		vec3 fadedistance0, fadedistance1;
		vec3 diffuse = vec3(0.0);
		vec3 specular = vec3(0.0);
		float occlusion = 1.0;
		float a;
		vec3 pdiffuse;
		vec3 pspecular;
		
		for (int k = 0; k < CountProbes; ++k)
		{
			a = 0.0;
			pdiffuse = vec3(0.0);
			pspecular = vec3(0.0);
			DrawProbe(ProbeIndex[k], baseColor.rgb, n, vertexWorldPosition.xyz, pdiffuse, pspecular, occlusion, perceptualRoughness, metalness, a, LightMatrix[k], BackgroundColor, FadeDistance[k * 2 + 0], FadeDistance[k * 2 + 1]);
			diffuse = mix(diffuse, pdiffuse * a, a);
			specular = mix(specular, pspecular * a, a);
			alpha += a;
		}
		if (alpha < 1.0)
		{
			vec3 skydiffuse = vec3(0.0);
			vec3 skyspecular = vec3(0.0);
			DrawIBL(skydiffuse, skyspecular, 1.0, n, v, perceptualRoughness, c_diff, f0, 1.0, 1.0, 0);
			diffuse += skydiffuse * (1.0 - alpha);
			specular += skyspecular * (1.0 - alpha);
		}
		Out_Albedo.rgb += (diffuse + specular) * Out_Albedo.a * 2.0;// Let's double this since there is no direct lighting
	}
	
	//------------------------------------------------------
	// Fog
	//------------------------------------------------------
	
	if (FogColor.a > 0.0)
	{
		//float fogstrength = (fogdistance - FogRange.x) / (FogRange.y - FogRange.x);
		//fogstrength = clamp(fogstrength, 0.0, 1.0) * FogColor.a;
		float fogstrength = (1.0 - transmittance(FogDensity, fogdistance)) * FogColor.a;
		Out_Albedo.rgb = mix(Out_Albedo.rgb, sRGBToLinear(FogColor.rgb), fogstrength);
	}
	
    //------------------------------------------------------
    // Render Mode
    //------------------------------------------------------
    
	if (RenderMode == RENDERMODE_TEXTURED || RenderMode == RENDERMODE_COLORED || RenderMode == RENDERMODE_COLOREDSHADED)
	{
		Out_Albedo.rgb = RenderModeColor(RenderMode, Out_Albedo.rgb, Out_Normal.rgb);
		Out_Albedo.a = 1.0;
	}
	
	//------------------------------------------------------
	// Pre-multiply alpha for blending
	//------------------------------------------------------
	
	Out_Albedo.rgb *= Out_Albedo.a;
	
    //------------------------------------------------------
    // Emission
    //------------------------------------------------------
    
    if ((TextureFlags & TEXTUREFLAGS_EMISSION) != 0)
    {
        vec3 emissive = emissioncolor * texture(EmissionMap, TexCoords.xy, TextureLodBias).rgb;
        Out_Albedo.rgb += sRGBToLinear(emissive);
    }

    //------------------------------------------------------
    // Transparency flags
    //------------------------------------------------------
    
	if ((RenderFlags & RENDERFLAGS_DEPTHMASK) != 0)
	{
		Out_SSRStrength = vec4(1.0, 1.0, 1.0, Out_Normal.a);
	}
	else
	{
		Out_SSRStrength = vec4(0.0, 0.0, 0.0, Out_Normal.a);
	}
	
    //------------------------------------------------------
    // Z-Position
    //------------------------------------------------------
    
    Out_ZPosition = -vertexWorldPosition.z;
    Out_ZPosition = (inverse(CameraMatrix) * vertexWorldPosition).z;
    Out_ZPosition = PositionToDepth(Out_ZPosition, CameraRange);
	
	// Encode the refraction model in the sign of the Z-position!
	if ((material.flags & MATERIAL_SIMPLEREFRACTION) != 0) Out_ZPosition *= -1.0;
}
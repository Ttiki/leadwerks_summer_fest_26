//------------------------------------------------------
// Uniforms
//------------------------------------------------------

uniform uvec4 Probes;
uniform int CountProbes = 0;
uniform mat4 LightMatrix[4];
uniform vec3 FadeDistance[8];
uniform uvec4 ProbeIndex;

//------------------------------------------------------
// Samplers
//------------------------------------------------------

layout(binding = 0) uniform sampler2D BaseColorMap;
layout(binding = 1) uniform sampler2D NormalMap;
layout(binding = 2) uniform sampler2D MetallicRoughnessMap;
layout(binding = 3) uniform sampler2D DusplacementMap;
layout(binding = 4) uniform sampler2D EmissionMap;
layout(binding = 5) uniform sampler2D OpacityMap;
//layout(binding = 15) uniform samplerCube BFNTable;
layout(binding = 13) uniform sampler2D Lut_GGX;
layout(binding = 14) uniform samplerCube DiffuseEnvironmentMap;
layout(binding = 15) uniform samplerCube SpecularEnvironmentMap;
layout(binding = 12) uniform samplerCubeArray DiffuseMap;
layout(binding = 11) uniform samplerCubeArray SpecularMap;

#ifdef MSAASAMPLES
layout(binding = 10) uniform sampler2DMS DepthBuffer;
#else
layout(binding = 10) uniform sampler2D DepthBuffer;
#endif

float DepthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x) ) * depthrange.y;
}

//------------------------------------------------------
// Inputs
//------------------------------------------------------

in vec4 color;
in vec4 TexCoords;
in vec4 vertexWorldPosition;
in flat uint entityflags;
flat in uint decallayers;
flat in vec3 emissioncolor;
in vec4 materialweights;
in mat3 TBN;
flat in uint EntityIndex;

//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Lighting/Light.glsl"
#include "../Lighting/DrawIBL.glsl"
#include "../Lighting/DrawProbe.glsl"
#include "../Lighting/OpticalDensity.glsl"
#include "../Editor/RenderModes.glsl"

//------------------------------------------------------
// Outputs
//------------------------------------------------------

layout(location = 0) out vec4 Out_Albedo;
layout(location = 1) out vec4 Out_Normal;
layout(location = 2) out float Out_ZPosition;
layout(location = 3) out vec4 Out_RoughnessThickness;
layout(location = 4) out vec4 Out_SSRStrength;
//layout(location = 4) out uint Out_TransparencyFlags;
layout(location = 5) out vec4 Out_SSRNormal;
layout(location = 6) out vec4 Out_SSROcclusionRoughnessThickness;
layout(location = 7) out vec4 Out_SSRAlbedo;

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{
	float transparentssr = 0.0f;
	if ((RenderFlags & RENDERFLAGS_DEPTHMASK) != 0u) transparentssr = 1.0;

	float depth1 = texelFetch(DepthBuffer, ivec2(gl_FragCoord.x, gl_FragCoord.y), 0).r;
	depth1 = DepthToPosition(depth1, CameraRange);
	float depth2 = DepthToPosition(gl_FragCoord.z, CameraRange);
	float dz = max(depth1 - depth2, 0.0);

    Material material;
	UnpackMaterial(MaterialIndex[0], material);
    
    vec3 position = vertexWorldPosition.xyz;
	vec3 dir = CameraPosition - position;
	float dist = length(dir);
    vec3 v = dir / dist;

    //------------------------------------------------------
    // Normals
    //------------------------------------------------------
	
    //Out_Normal.rgb = texture(BFNTable, normalize(vec3(normal.x, -normal.y, normal.z))).rgb;
    vec3 n = TBN[2];
    vec3 simplenormal = vec3(0.0, 0.0, 1.0);
    if ((TextureFlags & TEXTUREFLAGS_NORMAL) != 0)
    {
        simplenormal = texture(NormalMap, TexCoords.xy, TextureLodBias).rgb * 2.0 - 1.0;
        n = simplenormal;
		n.xy *= material.normalscale;
        n.z = sqrt(max(0.0, 1.0 - (n.x * n.x + n.y * n.y)));
        n = normalize(TBN * n);
    }
	if (!gl_FrontFacing) n *= -1.0;
    Out_Normal.rgb = n * 0.5 + 0.5;
    Out_SSRNormal = Out_Normal;
	
    //------------------------------------------------------
    // Albedo
    //------------------------------------------------------
    
    vec4 baseColor = sRGBToLinear(color) * sRGBToLinear(material.diffuseColor);
    bool hasbasecolortexture = (TextureFlags & TEXTUREFLAGS_BASECOLOR) != 0;
    if (hasbasecolortexture) baseColor *= texture(BaseColorMap, TexCoords.xy, TextureLodBias);
    if (material.saturation != 1.0) baseColor.rgb = mix(vec3((baseColor.r + baseColor.g + baseColor.b) * 0.33333), baseColor.rgb, material.saturation);
    Out_Albedo = baseColor;
	Out_SSRAlbedo = baseColor;
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
    //Out_Albedo.a = 1.0 - Out_Albedo.a;
    //float d = 1.0 - abs(dot(n, v));// Supports backface culling disabled mode
    //Out_Albedo.a *= 1.0 - d * d;
    //Out_Albedo.a = 1.0 - Out_Albedo.a;
#endif
    
	//--------------------------------------------------------
	// Soft Edges
	//--------------------------------------------------------
	
	float hardness = 1.0;
	if (dz < material.edgesoftness)
	{
		hardness = dz / material.edgesoftness;
	}
	
    Out_Normal.a = Out_Albedo.a;
	Out_SSRNormal.a = Out_Albedo.a;
	
	//--------------------------------------------------------------
	// Blend Modes
	//--------------------------------------------------------------
	
	switch (BlendMode)
	{
	// BLEND_ALPHA
	case 1:
		
		// Opacity map discards color but keeps normals, roughness, and thickness
		if ((material.flags & MATERIAL_ALBEDOALPHA) != 0)
		{
			Out_Albedo = vec4(0.0);
			//Out_Normal.a = texture(OpacityMap, TexCoords.xy, TextureLodBias).r;
			Out_Normal.a *= color.a * material.diffuseColor.a * hardness;
			Out_SSRStrength = vec4(transparentssr, transparentssr, transparentssr, 0.0);
		}
		else
		{
			Out_Albedo.rgb = sRGBToLinear(Out_Albedo.rgb * hardness);
			Out_Albedo.a *= hardness;
			Out_Normal.a = Out_Albedo.a;			
			Out_SSRStrength = vec4(transparentssr, transparentssr, transparentssr, Out_Normal.a);
		}
		break;
	// BLEND_LIGHTEN
	case 2:
		Out_Normal.a = max(Out_Albedo.r, max(Out_Albedo.g, Out_Albedo.b)) * hardness;
		Out_Albedo.rgb = sRGBToLinear(Out_Albedo.rgb * hardness);
		Out_Albedo.a = 0.0;
		Out_SSRStrength = vec4(transparentssr, transparentssr, transparentssr, Out_Normal.a);
		break;
	}
	
	//----------------------------------------------
	// Optical Density
	//----------------------------------------------
	
	if (gl_FrontFacing && material.opticaldensity > 0.0)
	{
		float t = transmittance(material.opticaldensity, dz);
		Out_Albedo.a = mix(1.0, Out_Albedo.a, t);
	}
	
	Out_SSRAlbedo.rgb = linearTosRGB(Out_Albedo.rgb);	
	Out_SSRAlbedo.a = Out_Albedo.a;
	
    //------------------------------------------------------
    // Roughness / Thickness
    //------------------------------------------------------
    
    vec3 occlussionroughnessmetal = vec3(material.occlusion, material.roughness, material.metalness);
    if ((TextureFlags & TEXTUREFLAGS_METALLICROUGHNESS) != 0)
    {
        occlussionroughnessmetal.rgb *= texture(MetallicRoughnessMap, TexCoords.xy, TextureLodBias).rgb;
    }
    Out_RoughnessThickness.r = (material.ior - 1.0) * 0.25 * Out_Normal.a;	
    Out_RoughnessThickness.g = occlussionroughnessmetal.g;
	Out_RoughnessThickness.a = Out_Normal.a;
	
    Out_SSROcclusionRoughnessThickness.r = occlussionroughnessmetal.r;
	Out_SSROcclusionRoughnessThickness.g = occlussionroughnessmetal.g;
    Out_SSROcclusionRoughnessThickness.b = occlussionroughnessmetal.b;
    Out_SSROcclusionRoughnessThickness.a = Out_Albedo.a;

	//------------------------------------------------------
	// Pre-multiply alpha for blending
	//------------------------------------------------------
	
	//Out_Albedo.rgb *=  Out_Albedo.a;
	
	Out_Albedo.rgb *= Out_Albedo.a;
	if ((material.flags & MATERIAL_ALBEDOALPHA) != 0u) Out_Albedo = vec4(0.0);
	
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
			diffuse += skydiffuse * (1.0 - alpha) * 2.0;
			specular += skyspecular * (1.0 - alpha) * 2.0;
		}
		Out_Albedo.rgb = (diffuse + specular) * Out_Normal.a;
	}
	else
	{
		Out_Albedo = baseColor;
	}
	
	//------------------------------------------------------
	// Fog
	//------------------------------------------------------
	
	if (FogColor.a > 0.0)
	{
		float fogstrength = (1.0 - transmittance(FogDensity, dist)) * FogColor.a;		
		//if (BlendMode == BLEND_LIGHTEN) fogstrength *= min(1.0, max(Out_Albedo.r, max(Out_Albedo.g, Out_Albedo.b)));
		Out_Albedo.rgb = mix(Out_Albedo.rgb, sRGBToLinear(FogColor.rgb), fogstrength);
	}
	
    //------------------------------------------------------
    // Emission
    //------------------------------------------------------
    
    if ((TextureFlags & TEXTUREFLAGS_EMISSION) != 0)
    {
        vec3 emissive = emissioncolor * texture(EmissionMap, TexCoords.xy, TextureLodBias).rgb;
        Out_Albedo.rgb += sRGBToLinear(emissive);
    }

    //------------------------------------------------------
    // SSR Settings
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
    
    Out_ZPosition = (inverse(CameraMatrix) * vertexWorldPosition).z;
    Out_ZPosition = PositionToDepth(Out_ZPosition, CameraRange);
	
	// Encode the refraction model in the sign of the Z-position!
	if ((material.flags & MATERIAL_SIMPLEREFRACTION) != 0) Out_ZPosition *= -1.0;
	
    //------------------------------------------------------
    // Render Mode
    //------------------------------------------------------
    
	if (RenderMode == RENDERMODE_TEXTURED || RenderMode == RENDERMODE_COLORED || RenderMode == RENDERMODE_COLOREDSHADED) Out_Albedo.rgb = RenderModeColor(RenderMode, Out_Albedo.rgb, Out_Normal.rgb * 2.0 - 1.0);
}
//------------------------------------------------------
// Samplers
//------------------------------------------------------

layout(binding = 0) uniform sampler2D BaseColorMap;
layout(binding = 1) uniform sampler2D NormalMap;
layout(binding = 2) uniform sampler2D MetallicRoughnessMap;
layout(binding = 3) uniform sampler2D DusplacementMap;
layout(binding = 4) uniform sampler2D EmissionMap;
#if MAX_MATERIALS > 1
	layout(binding = 5) uniform sampler2D BaseColorMap2;
	layout(binding = 6) uniform sampler2D NormalMap2;
	layout(binding = 7) uniform sampler2D MetallicRoughnessMap2;
	layout(binding = 8) uniform sampler2D DisplacementMap2;
	layout(binding = 9) uniform sampler2D EmissionMap2;
#endif
#if MAX_MATERIALS > 2
	layout(binding = 10) uniform sampler2D BaseColorMap3;
	layout(binding = 11) uniform sampler2D NormalMap3;
	layout(binding = 12) uniform sampler2D MetallicRoughnessMap3;
	layout(binding = 13) uniform sampler2D DisplacementMap3;
	layout(binding = 14) uniform sampler2D EmissionMap3;
#endif
layout(binding = 15) uniform sampler2D TerrainHeightmap;

//------------------------------------------------------
// Inputs
//------------------------------------------------------

in vec4 color;
in vec4 TexCoords;
in vec4 vertexWorldPosition;
in flat uint entityflags;
flat in vec3 emissioncolor;
flat in uint EntityFlags;
flat in uint EntityIndex;
in vec2 MaterialWeights;
in mat3 TBN;
in flat vec3 EntityTerrainBlending;

//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Entities.glsl"
#include "../Editor/RenderModes.glsl"
#include "../Editor/Grid.glsl"
#include "../Editor/RenderModes.glsl"
#include "../Editor/PaintBrush.glsl"
#include "MultiMaterial.glsl"
#include "../Terrain/Terrain.glsl"

//------------------------------------------------------
// Outputs
//------------------------------------------------------

out layout(location = 0) vec4 fragColor;
out layout(location = 1) vec4 fragNormal;
out layout(location = 2) vec4 fragData;
out layout(location = 3) vec2 fragBlend;

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{    
	Material material;
	UnpackMaterial(uint(MaterialIndex[0]), material);
    
    //------------------------------------------------------
    // Albedo
    //------------------------------------------------------
    
    vec4 baseColor = color * material.diffuseColor;
    bool hasbasecolortexture = (TextureFlags & TEXTUREFLAGS_BASECOLOR) != 0;
    if (hasbasecolortexture) baseColor *= texture(BaseColorMap, TexCoords.xy, BaseTextureLodBias);
	if (material.saturation != 1.0) baseColor.rgb = mix(vec3((baseColor.r + baseColor.g + baseColor.b) * 0.33333), baseColor.rgb, material.saturation);
    fragColor = baseColor;
#ifdef ALPHA_DISCARD
    if (fragColor.a < material.alphacutoff) discard;
#else
    if (material.alphacutoff > 0.0 && hasbasecolortexture == true)
    {
        // https://bgolus.medium.com/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f
		float lod = textureQueryLod(BaseColorMap, TexCoords.xy).y;
        fragColor.a *= 1.0 + max(0.0, lod) * 0.25;// Sharpen alpha
        fragColor.a = (fragColor.a - material.alphacutoff) / max(fwidth(fragColor.a), 0.0001) + 0.5;        
    }
#endif
   
    //------------------------------------------------------
    // Normals / Specular Weight
    //------------------------------------------------------
	
	vec3 n = TBN[2];
	if ((TextureFlags & TEXTURE_1) != 0)
	{
		n = texture(NormalMap, TexCoords.xy, TextureLodBias).rgb * 2.0 - 1.0;
		n.xy *= material.normalscale;
		if ((material.flags & MATERIAL_EXTRACTNORMALMAPZ) != 0)
		{
			n.z = sqrt(max(0.0, 1.0 - (n.x * n.x + n.y * n.y)));
		}
        n = normalize(TBN * n);
	}
    fragNormal.rgb = n;
    
    //------------------------------------------------------
    // Emission / Roughness / Metalness
    //------------------------------------------------------
    
    vec3 occlussionroughnessmetal = vec3(material.occlusion, material.roughness, material.metalness);
    if ((TextureFlags & TEXTUREFLAGS_METALLICROUGHNESS) != 0)
    {
        occlussionroughnessmetal *= texture(MetallicRoughnessMap, TexCoords.xy, TextureLodBias).rgb;
        occlussionroughnessmetal.r = mix(1.0, occlussionroughnessmetal.r, material.occlusion);
		fragColor.rgb *= occlussionroughnessmetal.r;
    }
    fragData.rgb = occlussionroughnessmetal;
    fragData.r = 0.0;
    fragData.a = 1.0;
    
	//------------------------------------------------------
	// Emission
	//------------------------------------------------------
	
	vec3 emissive = vec3(0.0);
    if ((TextureFlags & TEXTUREFLAGS_EMISSION) != 0)
    {
        emissive = texture(EmissionMap, TexCoords.xy, TextureLodBias).rgb;
		emissive *= material.emissiveColor;
    }
	
	//------------------------------------------------------
	// Terrain Blending
	//------------------------------------------------------
	
	fragBlend = vec2(0.0);
	if ((EntityFlags & ENTITYFLAGS_TERRAINBLEND) != 0)
	{
		fragBlend = TerrainBlend(TerrainHeightmap, vertexWorldPosition.xyz, n, EntityTerrainBlending);
	}
		
	/*float alpha = 1.0;
	float h = TerrainHeight(TerrainHeightmap, vertexWorldPosition.xyz);
	float deltay = vertexWorldPosition.y - h;
	if (EntityTerrainBlending.x > 0.0)
	{
		alpha = 1.0 - (deltay / EntityTerrainBlending.x);
		alpha = clamp(alpha, 0.0, 1.0);
		alpha = mix(alpha, alpha * n.y, EntityTerrainBlending.y);
	}
	if (deltay < EntityTerrainBlending.z)
	{
		alpha = max(alpha, 1.0 - max(deltay / EntityTerrainBlending.z, 0.0));
	}
	alpha = clamp(alpha, 0.0, 1.0);
	fragBlend = alpha;*/
		
	//------------------------------------------------------
	// Multi-material Blending
	//------------------------------------------------------
	
	Material mtl;
	
#if MAX_MATERIALS > 1
	if (MaterialWeights[0] > 0.0)
	{
		UnpackMaterial(uint(MaterialIndex[1]), mtl);
		MultiMaterial2(mtl, MaterialWeights[0], TexCoords.xy, TBN, fragColor, fragNormal.xyz, fragData, emissive);
	}
#endif
#if MAX_MATERIALS > 2
	if (MaterialWeights[1] > 0.0)
	{
		UnpackMaterial(uint(MaterialIndex[2]), mtl);
		MultiMaterial3(mtl, MaterialWeights[1], TexCoords.xy, TBN, fragColor, fragNormal.xyz, fragData, emissive);
	}
#endif
	
    //------------------------------------------------------
    // Render Mode
    //------------------------------------------------------
    
	if (RenderMode == RENDERMODE_TEXTURED || RenderMode == RENDERMODE_COLORED || RenderMode == RENDERMODE_COLOREDSHADED) fragColor.rgb = RenderModeColor(RenderMode, fragColor.rgb, fragNormal.rgb);
	
    //------------------------------------------------------
    // Finalize Output Colors
    //------------------------------------------------------
    
	if (RenderMode == RENDERMODE_LIGHTING) fragColor.rgb = vec3(0.5);
	if (emissive.r > 0.0 || emissive.g > 0.0 || emissive.b > 0.0)
	{
		emissive *= emissioncolor;
        fragData.r = max(max(emissive.r, emissive.g), emissive.b);
        if (fragData.r > 0.0)
        {
			fragData.r = min(fragData.r, 1.0);
            fragColor.rgb = mix(fragColor.rgb, emissive.rgb / fragData.r, fragData.r);
        }	
	}
	
	fragNormal.rgb = fragNormal.rgb * 0.5 + 0.5;
	
    //------------------------------------------------------
    // Pixel Flags - TODO
    //------------------------------------------------------
    
    uint flags = 0;
    if (!gl_FrontFacing) flags |= PIXELFLAGS_BACKFACING;
    if ((material.flags & MATERIAL_TWOSIDED) != 0u) flags |= PIXELFLAGS_TWOSIDED;
    fragNormal.a = float(flags) / 3.0;
	
    //------------------------------------------------------
    // Editor Display
    //------------------------------------------------------
    
	ShowGrid(fragColor, vertexWorldPosition.xyz, TBN[2], EntityFlags);
	ShowPaintBrush(fragColor, vertexWorldPosition.xyz);	
}
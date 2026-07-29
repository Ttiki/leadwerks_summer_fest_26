#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Math/Plane.glsl"
#include "../PBR/Multimaterial.glsl"
#include "PNQuad.glsl"
#include "PNTriangle.glsl"

//----------------------------------------------------------------
// Patch Layout
//----------------------------------------------------------------

//#if PATCH_VERTICES == 2
//layout(isolines, fractional_odd_spacing, ccw) in;
//#endif

#if PATCH_VERTICES == 3
layout(triangles, fractional_odd_spacing, ccw) in;
#endif

#if PATCH_VERTICES == 4
layout(quads, fractional_odd_spacing, ccw) in;
#endif

//----------------------------------------------------------------
// Texture Samplers
//----------------------------------------------------------------

uniform layout(binding = 3) sampler2D DisplacementMap;
uniform layout(binding = 8) sampler2D DisplacementMap2;
uniform layout(binding = 13) sampler2D DisplacementMap3;

//----------------------------------------------------------------
// Inputs
//----------------------------------------------------------------

in float tess_Displacement[];
in vec4 tess_texCoords[];
in mat3 tess_TBN[]; 
in vec2 tess_MaterialWeights[];
in vec4 tess_vertexWorldPosition[];
in vec4 tess_color[];
#ifdef WRITE_COLOR
flat in vec3 tess_emissioncolor[];
in patch vec3 tess_EntityTerrainBlending;
#endif
in patch int tess_Coplanar;
in patch uint tess_EntityIndex;
in patch uint tess_EntityFlags;

//----------------------------------------------------------------
// Outputs
//----------------------------------------------------------------

flat out uint EntityIndex;
out flat uint EntityFlags;
out vec4 TexCoords;
out mat3 TBN;
out vec2 MaterialWeights;
out vec4 vertexWorldPosition;
out vec4 color;
#ifdef WRITE_COLOR
flat out vec3 EntityTerrainBlending;
flat out vec3 emissioncolor;
#endif

void main()
{
	EntityIndex = tess_EntityIndex;
	EntityFlags = tess_EntityFlags;	
#ifdef WRITE_COLOR
	EntityTerrainBlending = tess_EntityTerrainBlending;
	emissioncolor = tess_emissioncolor[0];
#endif
	
#if PATCH_VERTICES == 3
	vec3 tessCoord = gl_TessCoord;
	float vertexDisplacement = tess_Displacement[0] * gl_TessCoord.x + tess_Displacement[1] * gl_TessCoord.y + tess_Displacement[2] * gl_TessCoord.z;
	TexCoords = tess_texCoords[0] * gl_TessCoord.x + tess_texCoords[1] * gl_TessCoord.y + tess_texCoords[2] * gl_TessCoord.z;
	TBN = tess_TBN[0] * gl_TessCoord.x + tess_TBN[1] * gl_TessCoord.y + tess_TBN[2] * gl_TessCoord.z;
	//Displacement = tess_Displacement[0] * gl_TessCoord.x + tess_Displacement[1] * gl_TessCoord.y + tess_Displacement[2] * gl_TessCoord.z;
	MaterialWeights = tess_MaterialWeights[0] * gl_TessCoord.x + tess_MaterialWeights[1] * gl_TessCoord.y + tess_MaterialWeights[2] * gl_TessCoord.z;
	color = tess_color[0] * gl_TessCoord.x + tess_color[1] * gl_TessCoord.y + tess_color[2] * gl_TessCoord.z;
	
#ifdef PNTRIANGLES
	if (tess_Coplanar == 0)
	{
		vertexWorldPosition.xyz = PNTriangle(tess_vertexWorldPosition[0].xyz, tess_vertexWorldPosition[1].xyz, tess_vertexWorldPosition[2].xyz, tess_TBN[0][2], tess_TBN[1][2], tess_TBN[2][2], gl_TessCoord.xyz, true, true, true);
	}
	else
#endif
	{
		vertexWorldPosition = tess_vertexWorldPosition[0] * gl_TessCoord.x + tess_vertexWorldPosition[1] * gl_TessCoord.y + tess_vertexWorldPosition[2] * gl_TessCoord.z;
	}
#endif

#if PATCH_VERTICES == 4
	
	const vec2 tessCoord = gl_TessCoord.xy;
	float vertexDisplacement = mix(mix(tess_Displacement[0], tess_Displacement[3], tessCoord.x), mix(tess_Displacement[1], tess_Displacement[2], tessCoord.x), tessCoord.y);
 	TexCoords = mix(mix(tess_texCoords[0], tess_texCoords[3], tessCoord.x), mix(tess_texCoords[1], tess_texCoords[2], tessCoord.x), tessCoord.y);
	//Displacement = mix(mix(tess_Displacement[0], tess_Displacement[3], tessCoord.x), mix(tess_Displacement[1], tess_Displacement[2], tessCoord.x), tessCoord.y);
	MaterialWeights = mix(mix(tess_MaterialWeights[0], tess_MaterialWeights[3], tessCoord.x), mix(tess_MaterialWeights[1], tess_MaterialWeights[2], tessCoord.x), tessCoord.y);
	TBN[0] = mix(mix(tess_TBN[0][0], tess_TBN[3][0], tessCoord.x), mix(tess_TBN[1][0], tess_TBN[2][0], tessCoord.x), tessCoord.y);
	TBN[1] = mix(mix(tess_TBN[0][1], tess_TBN[3][1], tessCoord.x), mix(tess_TBN[1][1], tess_TBN[2][1], tessCoord.x), tessCoord.y);
	TBN[2] = mix(mix(tess_TBN[0][2], tess_TBN[3][2], tessCoord.x), mix(tess_TBN[1][2], tess_TBN[2][2], tessCoord.x), tessCoord.y);
	color = mix(mix(tess_color[0], tess_color[3], tessCoord.x), mix(tess_color[1], tess_color[2], tessCoord.x), tessCoord.y);	
	
#ifdef PNQUADS
	if (tess_Coplanar == 0)
	{
		vertexWorldPosition.xyz = PNQuad(tess_vertexWorldPosition[0].xyz, tess_vertexWorldPosition[1].xyz, tess_vertexWorldPosition[2].xyz, tess_vertexWorldPosition[3].xyz,
		tess_TBN[2][0], tess_TBN[2][1], tess_TBN[2][2], tess_TBN[3][2], gl_TessCoord.xy);
	}
	else
#endif
	{
		vertexWorldPosition = mix(mix(tess_vertexWorldPosition[0], tess_vertexWorldPosition[3], tessCoord.x), mix(tess_vertexWorldPosition[1], tess_vertexWorldPosition[2], tessCoord.x), gl_TessCoord.y);
	}
	
#endif
	
// Edge testing:
//#define DEBUG_EDGES
#ifdef DEBUG_EDGES
#ifdef WRITE_COLOR
	#if PATCH_VERTICES == 4
if (gl_TessCoord.x == 0.0f || gl_TessCoord.x == 1.0f)
{
	color = vec4(1,0,0,1);
}
if (gl_TessCoord.y == 0.0f || gl_TessCoord.y == 1.0f)
{
	color = vec4(0,1,0,1);
}
	#endif
	#if PATCH_VERTICES == 3
if (gl_TessCoord.x == 0.0f)
{
//	if (tess_normal2[1] != vec3(0.0f) && tess_normal2[2] != vec3(0.0f))
	color = vec4(1,0,0,1);
}
if (gl_TessCoord.y == 0.0f)
{
	color = vec4(0,1,0,1);
}
if (gl_TessCoord.z == 0.0f)
{
	color = vec4(0,0,1,1);
}
	#endif
#endif
#endif
	
	//Standard displacement mapping
	Material material;
	float h = 0.0;
	float displacement = 0.0;
	float wt;
	
	if ((TextureFlags & TEXTURE_3) != 0 && MaterialIndex[0] != 0)
	{
		UnpackMaterial(uint(MaterialIndex[0]), material);
		if ((material.flags & MATERIAL_TESSELLATION) != 0)
		{
			displacement = textureLod(DisplacementMap, TexCoords.xy, 0.0).r;
			h = displacement * material.displacement.x + material.displacement.y;	
		}
	}
	
	if ((TextureFlags & TEXTURE_8) != 0 && MaterialIndex[1] != 0)
	{
		UnpackMaterial(uint(MaterialIndex[1]), material);
		if ((material.flags & MATERIAL_TESSELLATION) != 0)
		{
			wt = MaterialWeights[0];
			displacement = textureLod(DisplacementMap2, TexCoords.xy, 0.0).r;
			displacement = (displacement * material.displacement.x + material.displacement.y);
			h = mix(h, displacement, wt);
		}
	}
	
	if ((TextureFlags & TEXTURE_13) != 0 && MaterialIndex[2] != 0)
	{
		UnpackMaterial(uint(MaterialIndex[2]), material);
		if ((material.flags & MATERIAL_TESSELLATION) != 0)
		{
			wt = MaterialWeights[1];
			displacement = textureLod(DisplacementMap3, TexCoords.xy, 0.0).r;
			displacement = (displacement * material.displacement.x + material.displacement.y);
			h = mix(h, displacement, wt);
		}
	}
	
	vertexWorldPosition.xyz += normalize(TBN[2]) * (h * vertexDisplacement);
	
	vertexWorldPosition.w = 1.0f;
	gl_Position = CameraProjectionMatrix * vertexWorldPosition;
}
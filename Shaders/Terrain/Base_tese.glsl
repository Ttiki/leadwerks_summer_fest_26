
uniform layout(binding = 0) sampler2DArray ColorClipmap;
uniform layout(binding = 1) sampler2DArray NormalClipmap;
uniform layout(binding = 2) sampler2DArray PBRClipmap;
uniform layout(binding = 3) sampler2DArray DisplacementClipmap;
uniform layout(binding = 4) sampler2D heightmap;
uniform layout(binding = 15) sampler2D Heightmap;
uniform layout(binding = 5) sampler2D TerrainNormalMap;
uniform layout(binding = 6) sampler2D BaseColorClipmap;
uniform layout(binding = 7) sampler2D BaseNormalClipmap;
uniform layout(binding = 8) sampler2D BasePBRClipmap;
uniform layout(binding = 9) sampler2D BaseDisplacementClipmap;

#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Math/Plane.glsl"
#include "../PBR/Multimaterial.glsl"
#include "BicubicSample.glsl"
#include "ClipmapSample.glsl"

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

//in patch int tess_Coplanar;
//in patch uint tess_EntityIndex;
//in patch uint tess_EntityFlags;
in vec4 tess_TexCoords[];
in vec3 tess_Normal[];
//in mat3 tess_TBN[]; 
//in vec2 tess_MaterialWeights[];
in vec4 tess_Position[];
//in float tess_Displacement[];
#ifdef WRITE_COLOR
//in vec4 tess_color[];
//flat in vec3 tess_emissioncolor[];
#endif

//----------------------------------------------------------------
// Outputs
//----------------------------------------------------------------

//flat out uint EntityIndex;
//out flat uint EntityFlags;
out vec4 TexCoords;
//out mat3 TBN;
//out vec2 MaterialWeights;
out vec4 Position;
//out float Displacement;
#ifdef WRITE_COLOR
//out vec4 color;
//flat out vec3 emissioncolor;
#endif

#include "../Tessellation/PNQuad.glsl";

void main()
{
	//EntityIndex = tess_EntityIndex;
	//EntityFlags = tess_EntityFlags;	
#ifdef WRITE_COLOR
	//emissioncolor = tess_emissioncolor[0];
#endif
	
#if PATCH_VERTICES == 3
	vec3 tessCoord = gl_TessCoord;
	float vertexDisplacement = tess_Displacement[0] * gl_TessCoord.x + tess_Displacement[1] * gl_TessCoord.y + tess_Displacement[2] * gl_TessCoord.z;
	TexCoords = tess_TexCoords[0] * gl_TessCoord.x + tess_TexCoords[1] * gl_TessCoord.y + tess_TexCoords[2] * gl_TessCoord.z;
	//TBN = tess_TBN[0] * gl_TessCoord.x + tess_TBN[1] * gl_TessCoord.y + tess_TBN[2] * gl_TessCoord.z;
	Displacement = tess_Displacement[0] * gl_TessCoord.x + tess_Displacement[1] * gl_TessCoord.y + tess_Displacement[2] * gl_TessCoord.z;
	MaterialWeights = tess_MaterialWeights[0] * gl_TessCoord.x + tess_MaterialWeights[1] * gl_TessCoord.y + tess_MaterialWeights[2] * gl_TessCoord.z;
	#ifdef WRITE_COLOR
	emissioncolor = tess_emissioncolor[0];
	color = tess_color[0] * gl_TessCoord.x + tess_color[1] * gl_TessCoord.y + tess_color[2] * gl_TessCoord.z;
	#endif
	
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
	//float vertexDisplacement = mix(mix(tess_Displacement[0], tess_Displacement[3], tessCoord.x), mix(tess_Displacement[1], tess_Displacement[2], tessCoord.x), tessCoord.y);
 	TexCoords = mix(mix(tess_TexCoords[0], tess_TexCoords[3], tessCoord.x), mix(tess_TexCoords[1], tess_TexCoords[2], tessCoord.x), tessCoord.y);
	//Displacement = mix(mix(tess_Displacement[0], tess_Displacement[3], tessCoord.x), mix(tess_Displacement[1], tess_Displacement[2], tessCoord.x), tessCoord.y);
	//MaterialWeights = mix(mix(tess_MaterialWeights[0], tess_MaterialWeights[3], tessCoord.x), mix(tess_MaterialWeights[1], tess_MaterialWeights[2], tessCoord.x), tessCoord.y);
	//TBN[0] = mix(mix(tess_TBN[0][0], tess_TBN[3][0], tessCoord.x), mix(tess_TBN[1][0], tess_TBN[2][0], tessCoord.x), tessCoord.y);
	//TBN[1] = mix(mix(tess_TBN[0][1], tess_TBN[3][1], tessCoord.x), mix(tess_TBN[1][1], tess_TBN[2][1], tessCoord.x), tessCoord.y);
	//TBN[2] = mix(mix(tess_TBN[0][2], tess_TBN[3][2], tessCoord.x), mix(tess_TBN[1][2], tess_TBN[2][2], tessCoord.x), tessCoord.y);
	#ifdef WRITE_COLOR
	//color = mix(mix(tess_color[0], tess_color[3], tessCoord.x), mix(tess_color[1], tess_color[2], tessCoord.x), tessCoord.y);	
	#endif
	
	//------------------------
	
	//Position.xyz = PNQuad(tess_Position[0].xyz, tess_Position[1].xyz, tess_Position[2].xyz, tess_Position[3].xyz, tess_Normal[0], tess_Normal[1], tess_Normal[2], tess_Normal[3], gl_TessCoord.xy);
	Position = mix(mix(tess_Position[0], tess_Position[3], tessCoord.x), mix(tess_Position[1], tess_Position[2], tessCoord.x), gl_TessCoord.y);
	
#endif
	
	//Position.y += texture(heightmap, TexCoords.xy).r * TerrainScale.y;
	Position.y += (textureBicubic(heightmap, TexCoords.xy).r + texture(heightmap, TexCoords.xy).r) * 0.5 * TerrainScale.y;
	
	Position.w = 1.0;
	
	float displacement;
	clipmapSample(Position.xyz, displacement);
	
	vec4 gposition = Position;
	
	vec3 normal;
	normal.xz = texture(TerrainNormalMap, TexCoords.xy).rg * 2.0 - 1.0;
	normal.y = 1.0 - min(1.0, sqrt(normal.x * normal.x + normal.z * normal.z));
	normal = normalize(normal);
	gposition.xyz += normal * displacement * 1.0;
	
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

	vec3 prevpos = Position.xyz;
	float displacementdistance = 0.0f;

	//Standard displacement mapping
	/*Material material;
	float h = 0.0f;
	float displacement;
	float wt;
	
	if ((TextureFlags & TEXTURE_3) != 0 && MaterialIndex[0] != 0)
	{
		material = materials[ MaterialIndex[0] ];
		if ((material.flags & MATERIAL_TESSELLATION) != 0)
		{
			displacement = textureLod(DisplacementMap, TexCoords.xy, 0.0).r * Displacement;
			h = displacement * material.displacement.x + material.displacement.y;				
		}
	}
	
	if ((TextureFlags & TEXTURE_8) != 0 && MaterialIndex[1] != 0)
	{
		material = materials[ MaterialIndex[1] ];
		if ((material.flags & MATERIAL_TESSELLATION) != 0)
		{
			wt = MaterialWeights[0];
			displacement = textureLod(DisplacementMap2, texCoords.xy, 0.0).r;
			displacement = (displacement * material.displacement.x + material.displacement.y) * Displacement;
			h = mix(h, displacement, wt);
		}
	}
	
	if ((TextureFlags & TEXTURE_13) != 0 && MaterialIndex[2] != 0)
	{
		material = materials[ MaterialIndex[2] ];
		if ((material.flags & MATERIAL_TESSELLATION) != 0)
		{
			wt = MaterialWeights[1];
			displacement = textureLod(DisplacementMap3, texCoords.xy, 0.0).r;
			displacement = (displacement * material.displacement.x + material.displacement.y) * Displacement;
			h = mix(h, displacement, wt);
		}
	}*/
	
	//vertexWorldPosition.xyz += normalize(TBN[2]) * h * vertexDisplacement;
	Position.w = 1.0f;
	
	gl_Position = CameraProjectionMatrix * gposition;
}
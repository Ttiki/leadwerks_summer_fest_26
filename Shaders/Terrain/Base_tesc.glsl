//----------------------------------------------------------------
// Includes
//----------------------------------------------------------------

#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Common/StorageBufferBindings.glsl"
#include "../Math/Plane.glsl"
#include "../Math/Math.glsl"
#include "../PBR/MultiMaterial.glsl"

//----------------------------------------------------------------
// Patch Layout
//----------------------------------------------------------------

layout (vertices = PATCH_VERTICES) out;

//----------------------------------------------------------------
// Inputs
//----------------------------------------------------------------

//flat in uint EntityIndex[];
//in flat uint EntityFlags[];
in vec4 TexCoords[];
//in mat3 TBN[];
in vec4 vPosition[];
in vec4 Position[];
in vec3 Normal[];
//in vec2 MaterialWeights[];
//in float Displacement[];
#ifdef WRITE_COLOR
//in vec4 color[];
//flat in vec3 emissioncolor[];
#endif

//----------------------------------------------------------------
// Outputs
//----------------------------------------------------------------

out vec4 tess_TexCoords[];
//out flat uint tess_EntityFlags[];
//out mat3 tess_TBN[];
out vec4 tess_Position[];
//out vec2 tess_MaterialWeights[];
//out patch uint tess_EntityIndex;
out patch int tess_Coplanar;
out float tess_Displacement[];
out vec3 tess_Normal[];
#ifdef WRITE_COLOR
//out vec4 tess_color[];
//flat out vec3 tess_emissioncolor[];
#endif

/*
#if PATCH_VERTICES == 3
bool DisplacementInUse(in vec2 materialweights0, in vec2 materialweights1, in vec2 materialweights2)
#endif
#if PATCH_VERTICES == 4
bool DisplacementInUse(in vec2 materialweights0, in vec2 materialweights1, in vec2 materialweights2, in vec2 materialweights3)
#endif
{
	Material material;
	
	if ((TextureFlags & TEXTURE_3) != 0 && MaterialIndex[0] != 0)
	{
		material = materials[ MaterialIndex[0] ];
		if ((material.flags & MATERIAL_TESSELLATION) != 0) return true;
	}
	
	if ((TextureFlags & TEXTURE_8) != 0 && MaterialIndex[1] != 0)
	{
#if PATCH_VERTICES == 3
		if (materialweights0[0] > 0.0 || materialweights1[0] > 0.0 || materialweights2[0] > 0.0)
#endif
#if PATCH_VERTICES == 4
		if (materialweights0[0] > 0.0 || materialweights1[0] > 0.0 || materialweights2[0] > 0.0 || materialweights3[0] > 0.0)
#endif
		{
			material = materials[ MaterialIndex[1] ];
			if ((material.flags & MATERIAL_TESSELLATION) != 0) return true;
		}
	}
	
	if ((TextureFlags & TEXTURE_13) != 0 && MaterialIndex[2] != 0)
	{
#if PATCH_VERTICES == 3
		if (materialweights0[1] > 0.0 || materialweights1[1] > 0.0 || materialweights2[1] > 0.0)
#endif
#if PATCH_VERTICES == 4
		if (materialweights0[1] > 0.0 || materialweights1[1] > 0.0 || materialweights2[1] > 0.0 || materialweights3[1] > 0.0)
#endif
		{
			material = materials[ MaterialIndex[2] ];
			if ((material.flags & MATERIAL_TESSELLATION) != 0) return true;
		}
	}
	
	return false;
}
*/

//----------------------------------------------------------------
// Main Function
//----------------------------------------------------------------

void main()
{
	vec4 TessLevelOuter = vec4(1);
	vec2 TessLevelInner = vec2(2);

	if (gl_InvocationID == 0)
	{
		float polygonsize = CameraTessellation;
		const float tessfactor = 0.35f * float(BufferSize.y) * CameraZoom / CameraTessellation;
		float edgelength0, edgelength1, edgelength2, edgelength3, edgedistance0, edgedistance1, edgedistance2, edgedistance3;

		//------------------------------------------------------------
		// Test for coplanar patches
		//------------------------------------------------------------
		
		tess_Coplanar = 0;
		
		/*tess_Coplanar = 1;
		vec3 sum = vec3(0.0);
		for (int n = 0; n < PATCH_VERTICES; ++n)
		{
			sum += normalize(TBN[n][2]);
		}
		sum /= float(PATCH_VERTICES);
		for (int n = 0; n < PATCH_VERTICES; ++n)
		{
			if (dot(TBN[n][2], sum) < 0.98)
			{
				tess_Coplanar = 0;
				break;
			}
		}*/
		
		if (CameraProjectionMode == 1)// ortho
		{
			float tessfactor = 1.0 * CameraZoom / CameraTessellation;
			
			vec4 A = CameraProjectionMatrix * Position[0];
			vec4 B = CameraProjectionMatrix * Position[1];
			vec4 C = CameraProjectionMatrix * Position[2];
			vec4 D = CameraProjectionMatrix * Position[3];
			
			edgelength0 = length(A.xy - B.xy);
			edgelength1 = length(D.xy - A.xy);
			edgelength2 = length(C.xy - D.xy);
			edgelength3 = length(B.xy - C.xy);
 
			TessLevelOuter[0] = max(1.0f, tessfactor * edgelength0);
			TessLevelOuter[1] = max(1.0f, tessfactor * edgelength1);
			TessLevelOuter[2] = max(1.0f, tessfactor * edgelength2);
			TessLevelOuter[3] = max(1.0f, tessfactor * edgelength3);
		}
		else
		{
			edgelength0 = length(Position[0].xyz - Position[1].xyz);
			edgelength1 = length(Position[3].xyz - Position[0].xyz);
			edgelength2 = length(Position[2].xyz - Position[3].xyz);
			edgelength3 = length(Position[1].xyz - Position[2].xyz);

			edgedistance0 = length((Position[0].xyz + Position[1].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance1 = length((Position[3].xyz + Position[0].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance2 = length((Position[2].xyz + Position[3].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance3 = length((Position[1].xyz + Position[2].xyz) * 0.5f - CameraPosition.xyz);

			TessLevelOuter[0] = max(1.0f, ((tessfactor * edgelength0) / edgedistance0)) * 1.0;
			TessLevelOuter[1] = max(1.0f, ((tessfactor * edgelength1) / edgedistance1)) * 1.0;
			TessLevelOuter[2] = max(1.0f, ((tessfactor * edgelength2) / edgedistance2)) * 1.0;
			TessLevelOuter[3] = max(1.0f, ((tessfactor * edgelength3) / edgedistance3)) * 1.0;			
		}

		TessLevelInner[0] = max(TessLevelOuter[3], TessLevelOuter[1]);
		TessLevelInner[1] = max(TessLevelOuter[0], TessLevelOuter[2]);

		gl_TessLevelOuter[0] = TessLevelOuter[0];
		gl_TessLevelOuter[1] = TessLevelOuter[1];
		gl_TessLevelOuter[2] = TessLevelOuter[2];
		gl_TessLevelOuter[3] = TessLevelOuter[3];
		gl_TessLevelInner[0] = TessLevelInner[0];
		gl_TessLevelInner[1] = TessLevelInner[1];

		/*
		gl_TessLevelOuter[0] = 1.0;
		gl_TessLevelOuter[1] = 1.0;
		gl_TessLevelOuter[2] = 1.0;
		gl_TessLevelOuter[3] = 1.0;
		gl_TessLevelInner[0] = 1.0;
		gl_TessLevelInner[1] = 1.0;
		*/
		
		//-------------------------------------------------------------------------------------------------------
		// Check for the presence of a displacement map and disable inner subdivision if not found
		//-------------------------------------------------------------------------------------------------------
		/*
	#if PATCH_VERTICES == 3
		if (tess_Coplanar == 1 && DisplacementInUse(MaterialWeights[0], MaterialWeights[1], MaterialWeights[2]) == false)
	#endif
	#if PATCH_VERTICES == 4
		if (tess_Coplanar == 1 && DisplacementInUse(MaterialWeights[0], MaterialWeights[1], MaterialWeights[2], MaterialWeights[3]) == false)
	#endif
		{
			gl_TessLevelInner[0] = 1;
			gl_TessLevelInner[1] = 1;
		}
		*/
	}
	
	//tess_EntityIndex = EntityIndex[gl_InvocationID];
	//tess_EntityFlags[gl_InvocationID] = EntityFlags[gl_InvocationID];
	//tess_TBN[gl_InvocationID] = TBN[gl_InvocationID];
	tess_Normal[gl_InvocationID] = Normal[gl_InvocationID];
	tess_TexCoords[gl_InvocationID] = TexCoords[gl_InvocationID];
	tess_Position[gl_InvocationID] = vPosition[gl_InvocationID];
	//tess_MaterialWeights[gl_InvocationID] = MaterialWeights[gl_InvocationID];
	//tess_EntityIndex = EntityIndex[gl_InvocationID];
	//tess_Displacement[gl_InvocationID] = Displacement[gl_InvocationID];
#ifdef WRITE_COLOR
	//tess_color[gl_InvocationID] = color[gl_InvocationID];
	//tess_emissioncolor[gl_InvocationID] = emissioncolor[gl_InvocationID];
#endif
	
	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}
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

in float _Displacement[];
in vec4 TexCoords[];
in mat3 TBN[];
in vec4 vertexWorldPosition[];
in vec2 MaterialWeights[];
in vec4 color[];
#ifdef WRITE_COLOR
in flat vec3 EntityTerrainBlending[];
flat in vec3 emissioncolor[];
#endif
in flat uint EntityIndex[];
in flat uint EntityFlags[];
 
//----------------------------------------------------------------
// Outputs
//----------------------------------------------------------------

out float tess_Displacement[];
out vec4 tess_texCoords[];
out patch uint tess_EntityFlags;
out mat3 tess_TBN[];
out vec4 tess_vertexWorldPosition[];
out vec2 tess_MaterialWeights[];
out patch uint tess_EntityIndex;
out patch int tess_Coplanar;
out vec4 tess_color[];
#ifdef WRITE_COLOR
out patch vec3 tess_EntityTerrainBlending;
flat out vec3 tess_emissioncolor[];
#endif
 
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
		UnpackMaterial(MaterialIndex[0], material);
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
			UnpackMaterial(MaterialIndex[1], material);
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
			UnpackMaterial(MaterialIndex[2], material);
			if ((material.flags & MATERIAL_TESSELLATION) != 0) return true;
		}
	}
	
	return false;
}

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
		
		tess_Coplanar = 1;
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
		}
		
#if PATCH_VERTICES == 3

		if (CameraProjectionMode == 1)// ortho
		{
			const float tessfactor = 0.2f * CameraZoom / CameraTessellation;

			vec4 A = InverseCameraMatrix * vertexWorldPosition[0];
			vec4 B = InverseCameraMatrix * vertexWorldPosition[1];
			vec4 C = InverseCameraMatrix * vertexWorldPosition[2];

			edgelength0 = length(A.xy - B.xy);
			edgelength1 = length(B.xy - C.xy);
			edgelength2 = length(C.xy - A.xy);
			
			TessLevelOuter[2] = max(1.0f, ((tessfactor * edgelength0) ));
			TessLevelOuter[0] = max(1.0f, ((tessfactor * edgelength1) ));
			TessLevelOuter[1] = max(1.0f, ((tessfactor * edgelength2) ));			
		}
		else
		{
			edgelength0 = length(vertexWorldPosition[0].xyz - vertexWorldPosition[1].xyz);
			edgelength1 = length(vertexWorldPosition[1].xyz - vertexWorldPosition[2].xyz);
			edgelength2 = length(vertexWorldPosition[2].xyz - vertexWorldPosition[0].xyz);
			
			edgedistance0 = length((vertexWorldPosition[0].xyz + vertexWorldPosition[1].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance1 = length((vertexWorldPosition[1].xyz + vertexWorldPosition[2].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance2 = length((vertexWorldPosition[2].xyz + vertexWorldPosition[0].xyz) * 0.5f - CameraPosition.xyz);

			TessLevelOuter[2] = max(1.0f, ((tessfactor * edgelength0) / edgedistance0));
			TessLevelOuter[0] = max(1.0f, ((tessfactor * edgelength1) / edgedistance1));
			TessLevelOuter[1] = max(1.0f, ((tessfactor * edgelength2) / edgedistance2));
		}

		TessLevelInner[0] = (TessLevelOuter[0] + TessLevelOuter[1] + TessLevelOuter[2]) * 0.33333f;

#endif

#if PATCH_VERTICES == 4

		if (CameraProjectionMode == 1)// ortho
		{
			const float tessfactor = 0.2f * CameraZoom / CameraTessellation;

			vec4 A = InverseCameraMatrix * vertexWorldPosition[0];
			vec4 B = InverseCameraMatrix * vertexWorldPosition[1];
			vec4 C = InverseCameraMatrix * vertexWorldPosition[2];
			vec4 D = InverseCameraMatrix * vertexWorldPosition[3];
			
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
			edgelength0 = length(vertexWorldPosition[0].xyz - vertexWorldPosition[1].xyz);
			edgelength1 = length(vertexWorldPosition[3].xyz - vertexWorldPosition[0].xyz);
			edgelength2 = length(vertexWorldPosition[2].xyz - vertexWorldPosition[3].xyz);
			edgelength3 = length(vertexWorldPosition[1].xyz - vertexWorldPosition[2].xyz);

			edgedistance0 = length((vertexWorldPosition[0].xyz + vertexWorldPosition[1].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance1 = length((vertexWorldPosition[3].xyz + vertexWorldPosition[0].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance2 = length((vertexWorldPosition[2].xyz + vertexWorldPosition[3].xyz) * 0.5f - CameraPosition.xyz);
			edgedistance3 = length((vertexWorldPosition[1].xyz + vertexWorldPosition[2].xyz) * 0.5f - CameraPosition.xyz);

			TessLevelOuter[0] = max(1.0f, ((tessfactor * edgelength0) / edgedistance0));
			TessLevelOuter[1] = max(1.0f, ((tessfactor * edgelength1) / edgedistance1));
			TessLevelOuter[2] = max(1.0f, ((tessfactor * edgelength2) / edgedistance2));
			TessLevelOuter[3] = max(1.0f, ((tessfactor * edgelength3) / edgedistance3));			
		}

		TessLevelInner[0] = max(TessLevelOuter[3], TessLevelOuter[1]);
		TessLevelInner[1] = max(TessLevelOuter[0], TessLevelOuter[2]);
#endif

		gl_TessLevelOuter[0] = TessLevelOuter[0];
		gl_TessLevelOuter[1] = TessLevelOuter[1];
		gl_TessLevelOuter[2] = TessLevelOuter[2];
		gl_TessLevelOuter[3] = TessLevelOuter[3];
		gl_TessLevelInner[0] = TessLevelInner[0];
		gl_TessLevelInner[1] = TessLevelInner[1];
		
		//-------------------------------------------------------------------------------------------------------
		// Check for the presence of a displacement map and disable inner subdivision if not found
		//-------------------------------------------------------------------------------------------------------
		
	#if PATCH_VERTICES == 3
		if (tess_Coplanar == 1 && DisplacementInUse(MaterialWeights[0], MaterialWeights[1], MaterialWeights[2]) == false)
	#endif
	#if PATCH_VERTICES == 4
		if (tess_Coplanar == 1 && DisplacementInUse(MaterialWeights[0], MaterialWeights[1], MaterialWeights[2], MaterialWeights[3]) == false)
	#endif
		{
			gl_TessLevelInner[0] = 1.0;
			gl_TessLevelInner[1] = 1.0;
		}
	}
	
	tess_EntityIndex = EntityIndex[gl_InvocationID];
	tess_EntityFlags = EntityFlags[gl_InvocationID];
	tess_TBN[gl_InvocationID] = TBN[gl_InvocationID];
	tess_texCoords[gl_InvocationID] = TexCoords[gl_InvocationID];
	tess_vertexWorldPosition[gl_InvocationID] = vertexWorldPosition[gl_InvocationID];
	tess_MaterialWeights[gl_InvocationID] = MaterialWeights[gl_InvocationID];
	tess_EntityIndex = EntityIndex[gl_InvocationID];
	tess_Displacement[gl_InvocationID] = _Displacement[gl_InvocationID];
	tess_color[gl_InvocationID] = color[gl_InvocationID];
#ifdef WRITE_COLOR
	tess_EntityTerrainBlending = EntityTerrainBlending[gl_InvocationID];
	tess_emissioncolor[gl_InvocationID] = emissioncolor[gl_InvocationID];
#endif
	
	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}
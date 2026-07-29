// Includes
#include "../Common/Vertex.glsl"
#include "../Common/Entities.glsl"
#include "../Common/VertexSkinning.glsl"

// Uniforms
//uniform mat4 CameraProjectionMatrix;

out vec4 color;
out vec4 TexCoords;
out float _Displacement;

void main()
{    
	_Displacement = VertexDisplacement;
	
    mat4 mat;
	uint skeletonID;
	
    UnpackEntity(EntityID, mat, color, skeletonID);
    TexCoords.xy = VertexTexCoords;
	
	vec4 position = vec4(VertexPosition, 1.0);
	
	vec3 scale = vec3(length(mat[0].xyz), length(mat[1].xyz), length(mat[2].xyz));
	_Displacement *= (scale.x + scale.y + scale.z) * 0.333333;
	
	//----------------------------------------------------------------
	// Vertex Skinning
	//----------------------------------------------------------------

	if ((RenderFlags & RENDERFLAGS_MESHSKINNING) != 0u)	
	{
		float sumweights = 0.0;
		vec4 animposition = vec4(0.0);
		mat4 animmatrix = mat4(0.0);
		for (int n = 0; n < 4; ++n)
		{
			if (VertexBoneWeights[n] == 0.0) break;
			animmatrix = GetBoneMatrix(skeletonID, VertexBoneIndices[n], RenderTween);			
			animposition += animmatrix * position * VertexBoneWeights[n];
			sumweights += VertexBoneWeights[n];
		}
		if (sumweights > 0.0) position.xyz = animposition.xyz / sumweights;
	}
	
	//----------------------------------------------------------------
	
	//----------------------------------------------------------------
	
	position = mat * position;
	
	// User-defined mesh effect
#ifdef USERMESHEFFECT
	mat3 tbn;
	tbn[2] = VertexNormal;
	ApplyUserMeshEffect(mat, position.xyz, tbn[2], texCoords, color);
#endif
	
	gl_Position = CameraProjectionMatrix * position;
}
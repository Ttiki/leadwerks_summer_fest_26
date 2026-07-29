// Includes
#include "../Common/StorageBufferBindings.glsl"
#include "../Common/Entities.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Vertex.glsl"
#include "../Common/VertexSkinning.glsl"
 
// Outputs
out float _Displacement;
out vec4 vertexWorldPosition;
out vec4 vertexCameraPosition;
out vec4 TexCoords;
out vec3 emissioncolor;
out vec4 color;
out mat3 TBN;
out vec2 MaterialWeights;
flat out vec3 EntityTerrainBlending;
flat out uint EntityFlags;
flat out uint EntityIndex;

void main()
{
	_Displacement = VertexDisplacement;
	
    UnpackedEntity entity = UnpackEntity(EntityID);
    mat4 mat = entity.matrix;    
	EntityFlags = entity.flags;
    EntityIndex = EntityID;
	EntityTerrainBlending = entity.terrainblend;
	
	MaterialWeights[0] = VertexMaterialWeights[ MaterialSlots[0] ];
	MaterialWeights[1] = VertexMaterialWeights[ MaterialSlots[1] ];

	emissioncolor = entity.emission;

    TexCoords.xy = VertexTexCoords;
	TexCoords.zw = VertexLightmapCoords;
	TexCoords.xy *= entity.texturescale;
    TexCoords.xy += entity.textureoffset;
    
	Material material;
	UnpackMaterial(uint(MaterialIndex[0]), material);
	
	TexCoords.xyz += material.texturescroll.xyz * (float(CurrentTime) / 1000.0);	
	
    mat3 nmat;
	vec3 scale;
	scale.x = length(mat[0].xyz);
	scale.y = length(mat[1].xyz);
	scale.z = length(mat[2].xyz);
	nmat[0] = mat[0].xyz / scale.x;
	nmat[1] = mat[1].xyz / scale.y;
	nmat[2] = mat[2].xyz / scale.z;
    TBN[0] = nmat * VertexTangent;
    TBN[1] = nmat * VertexBitangent;
    TBN[2] = nmat * VertexNormal;
	
	//_Displacement *= (scale.x + scale.y + scale.z) * 0.333333;
	
	color = VertexColor;
	
	vec4 position = vec4(VertexPosition, 1.0);
	
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
			animmatrix = GetBoneMatrix(entity.skeletonID, VertexBoneIndices[n], RenderTween);			
			animposition += animmatrix * position * VertexBoneWeights[n];
			sumweights += VertexBoneWeights[n];
		}
		if (sumweights > 0.0) position.xyz = animposition.xyz / sumweights;
	}
	
	//----------------------------------------------------------------
	
	//----------------------------------------------------------------
	
    vertexWorldPosition = mat * position;
	
	// User-defined mesh effect
#ifdef USERMESHEFFECT
	ApplyUserMeshEffect(mat, vertexWorldPosition.xyz, TBN[2], TexCoords, color);
#endif
	
	color *= entity.color;
	
    //vertexCameraPosition = InverseCameraMatrix * vertexWorldPosition;
	gl_Position = CameraProjectionMatrix * vertexWorldPosition;
}
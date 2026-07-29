// Includes
#include "../Common/Uniforms.glsl"
#include "../Common/Vertex.glsl"
#include "../Common/Entities.glsl"
#include "../Common/Materials.glsl"

// Outputs
out vec4 TexCoords;
out vec4 color;
out flat float AlphaCutoff;
out vec4 vertexWorldPosition;
out vec2 MaterialWeights;
out mat3 TBN;
out uint EntityIndex;
out uint EntityFlags;
out float _Displacement;

void main()
{
	EntityIndex = EntityID;
	EntityFlags = 0;
	_Displacement = VertexDisplacement;

    UnpackedEntity entity;
	UnpackEntity(EntityID, entity);
	
	mat4 mat = entity.matrix;
	uint skeletonID = entity.skeletonID;
	
	vec3 scale = vec3(length(mat[0].xyz), length(mat[1].xyz), length(mat[2].xyz));
	_Displacement *= (scale.x + scale.y + scale.z) * 0.333333;

	color = entity.color * VertexColor;
	
    Material material;
	UnpackMaterial(MaterialIndex[0], material);
	
    color *= material.diffuseColor;
    AlphaCutoff = material.alphacutoff;
    TexCoords.xy = VertexTexCoords;
    TexCoords.zw = VertexLightmapCoords;

	MaterialWeights = VertexMaterialWeights;
	TBN[0] = VertexTangent;
	TBN[1] = VertexBitangent;
	TBN[2] = VertexNormal;
	
	mat3 nmat;
	nmat[0] = normalize(mat[0].xyz);
	nmat[1] = normalize(mat[1].xyz);
	nmat[2] = normalize(mat[2].xyz);
	
	TBN *= nmat;
	
    vertexWorldPosition = mat * vec4(VertexPosition, 1.0);

	// User-defined mesh effect
#ifdef USERMESHEFFECT
	ApplyUserMeshEffect(mat, vertexWorldPosition.xyz, TBN[2], TexCoords, color);
#endif
	
	gl_Position = CameraProjectionMatrix * vertexWorldPosition;
}
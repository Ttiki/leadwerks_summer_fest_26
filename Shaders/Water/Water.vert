#version 450

// Includes
#include "../Common/Vertex.glsl"
#include "../Common/Entities.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Uniforms.glsl"
#include "Waves.glsl"

// Uniforms
uniform int WaveIterations = 16;
uniform float WaveDistance = 16.0;

// Outputs
out vec4 vertexWorldPosition;
out vec4 vertexCameraPosition;
out vec4 TexCoords;
out vec3 normal;
out vec3 tangent;
out vec3 bitangent;
out vec3 emissioncolor;
out vec4 color;
out flat uint EntityIndex;

void main()
{
	Material material;
	UnpackMaterial(uint(MaterialIndex[0]), material);
	
    UnpackedEntity entity = UnpackEntity(EntityID);
    mat4 mat = entity.matrix;
    color = entity.color;
    emissioncolor = entity.emission;

	EntityIndex = EntityID;
	//EntityFlags = entity.flags;

    TexCoords.xy = VertexTexCoords;
    TexCoords.xy *= entity.texturescale;
    TexCoords.xy += entity.textureoffset;
	TexCoords.xyz -= material.texturescroll.xyz * (float(CurrentTime) / 1000.0);
	
    mat3 nmat;
	nmat[0] = normalize(mat[0].xyz);
	nmat[1] = normalize(mat[1].xyz);
	nmat[2] = normalize(mat[2].xyz);	
    tangent = nmat * VertexTangent;
    bitangent = nmat * VertexBitangent;
    normal = nmat * VertexNormal;
	
    vertexWorldPosition = mat * vec4(VertexPosition, 1.0);
	
	if (material.displacement.x > 0.0)
	{
		float dist = length(vertexWorldPosition.xyz - CameraPosition);
		float m = 1.0 - dist / WaveDistance;
		if (m > 0.0)
		{
			float w = getwaves(TexCoords.xy * 10.0, max(3.0, WaveIterations * m), 1.0);
			//float w = map(vertexWorldPosition.xyz * 10.0 * vec3(1,0,1));
			//w += getwaves(vertexWorldPosition.xz * 1.0, 6.0, 0.25) * 0.5;
			//w += getwaves(vertexWorldPosition.xz * 0.5, 6.0, 0.25) * 1.0;
			//w /= 2.5;
			//WaveHeight = w * m;//(w * 0.5 - 1.0) * m;
			
			// Multipliers are experimentally determined
			w *= m * material.displacement.x * VertexDisplacement * 2.9;
			w += m * material.displacement.y * VertexDisplacement * 2.5;
			
			vertexWorldPosition.xyz += normal * w;
			//normal = waveNormal(vertexWorldPosition.xz * 10.0, 0.01, 0.5 * m);// Per-vertex normals look terrible!
		}
    }
	
	gl_Position = CameraProjectionMatrix * vertexWorldPosition;
}
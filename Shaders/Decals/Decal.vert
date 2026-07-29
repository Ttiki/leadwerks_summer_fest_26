#version 450

// Includes
#include "../Common/Vertex.glsl"
#include "../Common/Entities.glsl"

// Uniforms
uniform uint LightIndex;
uniform mat4 LightMatrix;
uniform vec2 LightRange;
uniform vec2 LightArea;
uniform uint EntityIndex = 0u;

out vec4 color;
out vec3 emissioncolor;
out mat3 NormalMatrix;
out vec2 TexturePosition;
out vec2 TextureScale;
out mat3 InverseNormalMatrix;

void main()
{
	UnpackedEntity entity = UnpackEntity(EntityIndex);
	emissioncolor = entity.emission;
	
	NormalMatrix = mat3(entity.matrix);
	NormalMatrix[0] = normalize(NormalMatrix[0]);
	NormalMatrix[1] = normalize(NormalMatrix[1]);
	NormalMatrix[2] = normalize(NormalMatrix[2]);
	InverseNormalMatrix = inverse(NormalMatrix);
	
	TexturePosition = entity.textureoffset;
	TextureScale = entity.texturescale;
	
    color = entity.color;
    vec3 position = VertexPosition;
    position.xy *= LightArea.xy;
    if (position.z > 0.0f)
    {
        position.z = LightRange.y;
    }
    else
    {
        position.z = LightRange.x;       
    }
    gl_Position = CameraProjectionMatrix * (inverse(LightMatrix) * vec4(position, 1.0f));
}
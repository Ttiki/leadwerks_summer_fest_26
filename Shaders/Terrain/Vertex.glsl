// Includes
#include "../Common/StorageBufferBindings.glsl"
#include "../Common/Entities.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Vertex.glsl"

// Samplers
uniform layout(binding = 15) sampler2D Heightmap;
uniform layout(binding = 5) sampler2D TerrainNormalmap;

// Outputs
out vec4 Position;
out vec4 vPosition;
out vec4 TexCoords;
out vec3 Normal;

void main()
{
    UnpackedEntity entity = UnpackEntity(EntityID);
    mat4 mat = entity.matrix;
    
	TexCoords.zw = VertexLightmapCoords;
	
	//vertexWorldPosition.xz = VertexPosition.xz + mat[3].xz;
	Position = mat * vec4(VertexPosition, 1.0);
	Position.w = 1.0;
	Position.xz = clamp(Position.xz, -TerrainSize * 0.5, TerrainSize * 0.5);
	
	TexCoords.xy = (Position.xz / vec2(TerrainSize)) + 0.5;
	
	ivec2 coord;
	coord.x = int(TexCoords.x * TerrainResolution.x + 0.5);
	coord.y = int(TexCoords.y * TerrainResolution.y + 0.5);	
	coord = min(coord, TerrainResolution - 1);
	
	TexCoords.x = (float(coord.x) + 0.5) / float(TerrainResolution.x );
	TexCoords.y = (float(coord.y) + 0.5) / float(TerrainResolution.y );
	//TexCoords.xy = (Position.xz + TerrainSize * 0.5) / (TerrainResolution.xy - 0.5);
	
	vPosition = Position;
	
	//Position.y += textureLod(Heightmap, TexCoords.xy, 0).r * TerrainScale.y;
	Position.y += texelFetch(Heightmap, coord, 0).r * TerrainScale.y;
	
	Normal.xz = texelFetch(TerrainNormalmap, coord, 0).rg;
	Normal.y = 1.0 - min(1.0, sqrt(Normal.x * Normal.x + Normal.z * Normal.z));
	Normal = normalize(Normal);
	
	gl_Position = CameraProjectionMatrix * Position;
}
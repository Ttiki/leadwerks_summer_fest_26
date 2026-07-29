// Includes
#include "../Common/Materials.glsl"
#include "../Common/Vertex.glsl"
#include "../Common/Entities.glsl"

// Outputs
out float CameraAngle;
out vec4 Position;
out vec4 vertexWorldPosition;
out vec4 TexCoords;
out mat3 TBN;
out vec4 color;
out uint EntityFlags;
out uint EntityIndex;
out vec3 emissioncolor;
out vec2 MaterialWeights;
out vec3 EntityTerrainBlending;

void main()
{
    vec4 p;
    p.xyz = VertexPosition.xyz;
    p.w = 1.0f;
		
	UnpackedEntity entity;
	UnpackEntity(EntityID, entity);
    
	mat4 mat = entity.matrix;    
	EntityFlags = entity.flags;
    EntityIndex = EntityID;
	color = entity.color;
	emissioncolor = entity.emission;
	MaterialWeights = vec2(0.0);
	EntityTerrainBlending = vec3(0.0);
	
    vec4 relcampos = inverse(mat) * vec4(CameraPosition, 1.0f);
    vec2 d = -normalize(relcampos.xz);

    CameraAngle = mod(degrees(atan(d.x, d.y)), 360.0f);
    
    mat3 rotationmat;
    rotationmat[2].xyz = vec3(d.x, 0, d.y);
    rotationmat[1].xyz = vec3(0,1,0);
    rotationmat[0].xyz = cross(rotationmat[2].xyz, rotationmat[1].xyz);
    p.xyz = rotationmat * p.xyz;
    
    p = mat * p;
    Position = p;
	
    TexCoords.xy = VertexTexCoords;
    TexCoords.zw = VertexLightmapCoords;
	
	color = vec4(1.0f);
	
	mat3 nmat;	
	nmat[0] = normalize(entity.matrix[0].xyz);
	nmat[1] = normalize(entity.matrix[1].xyz);
	nmat[2] = normalize(entity.matrix[2].xyz);	
	//TBN[0] = normalize(nmat * VertexTangent);
	//TBN[1] = normalize(nmat * VertexBitangent);
	//TBN[2] = normalize(nmat * VertexNormal);	
	TBN = nmat;
	
	vertexWorldPosition = Position;
    gl_Position = CameraProjectionMatrix * p;
}
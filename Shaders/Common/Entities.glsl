#ifndef _ENTITIES
    #define _ENTITIES

#include "StorageBufferBindings.glsl"
#include "../Math/Math.glsl"

#define ENTITYFLAGS_TERRAINBLEND 1
#define ENTITYFLAGS_SELECTED 2
#define ENTITYFLAGS_SHOWGRID 64

struct PackedEntity
{
    // ix iy iz rg
    // jx jy jz b,a|TerrainNormalBlend
    // kscale emission.rgbx skeletonAndTerrainBlend texoffset.xy
    // tx ty tz texscale.xy
    mat4 matrix;
    vec4 data;
};

// 128 bytes
struct UnpackedEntity
{
    mat4 matrix;
    vec4 color;
    vec3 emission;
    vec2 textureoffset;
    vec2 texturescale;
    vec3 terrainblend;
    uint skeletonID;
    uint flags;
};

//layout(std430, binding = STORAGE_BUFFER_DRAW_INDEXES) readonly buffer InstanceIDBlock { uint instanceID[]; };
//layout(std140, binding = STORAGE_BUFFER_DRAW_INDEXES) uniform InstanceIDBlock { uvec4 instanceID[ MAX_UNIFORM_BLOCK_SIZE / 16 ]; };
layout(std430, binding = STORAGE_BUFFER_MATRICES) readonly buffer EntityMatrixBlock { PackedEntity entityMatrix[]; };

void UnpackEntity(in uint index, out UnpackedEntity entity)
{
    uint u;
    uvec2 u2;

    PackedEntity pack = entityMatrix[index];
    entity.matrix = pack.matrix;

    // Unpack color
    entity.color.rg = unpackHalf2x16(floatBitsToUint(pack.matrix[0][3]));
    u = floatBitsToUint(pack.matrix[1][3]);
    entity.color.b = unpackHalf2x16(u).x;
    entity.color.a = float(Blue(u)) / 255.0;
    entity.terrainblend.y = float(Alpha(u)) / 255.0;
	
    // Unpack emission
    u = floatBitsToUint(pack.matrix[2][1]);
    entity.emission.r = float(Red(u));
    entity.emission.g = float(Green(u));
    entity.emission.b = float(Blue(u));
    entity.emission /= 255.0;
    entity.flags = Alpha(u);

    // Unpack texture mapping properties
    //u2 = unpackUshort2x16(floatBitsToUint(pack.matrix[2][3]));
    //entity.textureoffset.x = float(u2.x) / 65535.0;
    //entity.textureoffset.y = float(u2.y) / 65535.0;
    entity.textureoffset = unpackHalf2x16(floatBitsToUint(pack.matrix[2][3]));
	entity.texturescale = unpackHalf2x16(floatBitsToUint(pack.matrix[3][3]));
    entity.textureoffset = pack.data.xy;
    
	entity.terrainblend.xy = unpackHalf2x16(floatBitsToUint(pack.data.z));
	entity.terrainblend.z = unpackHalf2x16(floatBitsToUint(pack.data.w)).x;
	
    // Unpack skeleton ID and two bytes leftever...
    u = floatBitsToUint(pack.matrix[2][2]);
    u2 = unpackUshort2x16(u);
    entity.skeletonID = u2.x;
    
    // Reconstruct third matrix row
    entity.matrix[2].xyz = cross(entity.matrix[0].xyz, entity.matrix[1].xyz) * entity.matrix[2][0];
    
    // Restore right-hand column
    entity.matrix[0][3] = 0.0; entity.matrix[1][3] = 0.0; entity.matrix[2][3] = 0.0; entity.matrix[3][3] = 1.0;
}

UnpackedEntity UnpackEntity(in uint index)
{
	UnpackedEntity entity;
	UnpackEntity(index, entity);
	return entity;
}

/*
void UnpackEntity(in uint index, out mat4 matrix, out vec4 color)
{
    PackedEntity pack = entityMatrix[index];
    matrix = pack.matrix;

    // Unpack color
    color.rg = unpackHalf2x16(floatBitsToUint(matrix[0][3]));
    uint u = floatBitsToUint(pack.matrix[1][3]);
    color.b = unpackHalf2x16(u).x;
    color.a = float(Blue(u)) / 255.0;
    
    // Reconstruct third matrix row
    matrix[2].xyz = cross(matrix[0].xyz, matrix[1].xyz) * matrix[2][0];
    
    // Restore right-hand column
    matrix[0][3] = 0.0; matrix[1][3] = 0.0; matrix[2][3] = 0.0; matrix[3][3] = 1.0;
}
*/

void UnpackEntity(in uint index, out mat4 matrix, out vec4 color, out uint skeletonID)
{
    PackedEntity pack = entityMatrix[index];
    matrix = pack.matrix;

    // Unpack color
    color.rg = unpackHalf2x16(floatBitsToUint(matrix[0][3]));
    uint u = floatBitsToUint(pack.matrix[1][3]);
    color.b = unpackHalf2x16(u).x;
    color.a = float(Blue(u)) / 255.0;
    
    // Reconstruct third matrix row
    matrix[2].xyz = cross(matrix[0].xyz, matrix[1].xyz) * matrix[2][0];
    
    // Restore right-hand column
    matrix[0][3] = 0.0; matrix[1][3] = 0.0; matrix[2][3] = 0.0; matrix[3][3] = 1.0;
	
	// Unpack skeleton ID and two bytes leftever...
    u = floatBitsToUint(pack.matrix[2][2]);
    uvec2 u2 = unpackUshort2x16(u);
    skeletonID = u2.x;
}

#endif

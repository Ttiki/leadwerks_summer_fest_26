#ifndef _VERTEXLAYOUT
    #define _VERTEXLAYOUT

#include "../Math/Quaternion.glsl"
#include "../Math/Math.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Constants.glsl"
#include "../Common/StorageBufferBindings.glsl"

layout(location = 0) in vec3 VertexPosition;
layout(location = 1) in vec2 VertexTexCoords;
layout(location = 2) in vec2 VertexLightmapCoords;
layout(location = 3) in vec4 VertexQTangent;
layout(location = 4) in uvec4 VertexBoneIndices;
layout(location = 5) in vec4 VertexBoneWeights;

// Fourth bone weight could be calculated as follows, which would free up one extra byte
//vec4 VertexBoneWeights = vec4(VertexBoneWeights_.x, VertexBoneWeights_.y, VertexBoneWeights_.z, max(0.0, 1.0 - (VertexBoneWeights_.x + VertexBoneWeights_.y + VertexBoneWeights_.z)));
vec4 VertexColor = (RenderFlags & RENDERFLAGS_MESHSKINNING) == 0u ? VertexBoneWeights : vec4(1.0);
vec2 VertexMaterialWeights = (RenderFlags & RENDERFLAGS_MESHSKINNING) == 0u ? vec2(float(VertexBoneIndices.x) / 255.0, float(VertexBoneIndices.y) / 255.0) : vec2(0.0);

float UnpackVertexDisplacement()
{
	uint a = VertexBoneIndices.z;
	uint b = VertexBoneIndices.w;
	uint i = (b << 8) | a;
	return unpackHalf2x16(i).x;
}

float VertexDisplacement = (RenderFlags & RENDERFLAGS_MESHSKINNING) == 0u ? unpackHalf2x16((VertexBoneIndices.w << 8) | VertexBoneIndices.z).x : 0.0;

vec3 UnpackVertexNormal(out vec3 tangent, out vec3 bitangent)
{
	vec3 normal;
	const float xx = VertexQTangent.x * VertexQTangent.x;
	const float yy = VertexQTangent.y * VertexQTangent.y;
	const float zz = VertexQTangent.z * VertexQTangent.z;
	const float xy = VertexQTangent.x * VertexQTangent.y;
	const float xz = VertexQTangent.x * VertexQTangent.z;
	const float yz = VertexQTangent.y * VertexQTangent.z;
	const float wx = VertexQTangent.w * VertexQTangent.x;
	const float wy = VertexQTangent.w * VertexQTangent.y;
	const float wz = VertexQTangent.w * VertexQTangent.z;
	tangent.x = 1.0f - 2.0f * (yy + zz);	tangent.y = 2.0f * (xy - wz);	tangent.z = 2.0f * (xz + wy);
	normal.x = 2.0f * (xz - wy);		    normal.y = 2.0f * (yz + wx);	normal.z = 1.0f - 2.0f * (xx + yy);
    bitangent = -cross(normal, tangent);
    if (VertexQTangent.w < 0.0f) bitangent *= -1.0f;
	return normal;
}

vec3 VertexTangent;
vec3 VertexBitangent;
#if __GLSLANG__
vec3 VertexNormal;
#else
vec3 VertexNormal = UnpackVertexNormal(VertexTangent, VertexBitangent);
#endif

//-----------------------------------------------
// Instance information
//-----------------------------------------------

layout(std140, binding = STORAGE_BUFFER_DRAW_INDEXES) uniform InstanceIDBlock { uvec4 instanceID[ MAX_UNIFORM_BLOCK_SIZE / 16 ]; };

uniform uint BaseInstance = 0;

uint ExtractInstanceEntityID()
{
	uint InstanceIndex = BaseInstance + gl_InstanceID;
	uint i = (InstanceIndex / 2u) % 4;
	uvec2 ids = unpackUshort2x16( instanceID[ InstanceIndex / 8u ][i] );
	return ids[InstanceIndex % 2u];	
}

#if __GLSLANG__
uint EntityID = 0u;
#else
uint EntityID = ExtractInstanceEntityID();
#endif

#endif
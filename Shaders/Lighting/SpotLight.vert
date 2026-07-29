#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shader_draw_parameters : enable

// Includes
#include "../Common/Vertex.glsl"
#include "Light.glsl"

// Uniforms
uniform uint LightIndex;
uniform mat4 LightMatrix;
uniform vec2 LightRange;
uniform vec2 lightconeangles;

// x: Cosine outer light angle
// y: Cosine inner light angle
// z: Tangent outer light angle
uniform vec3 LightConeAngles;

void main()
{
    vec3 position = VertexPosition;
    position.xy *= LightRange.y * LightConeAngles.z;
    if (position.z > 0.5f) position.z = LightRange.y;
    gl_Position = CameraProjectionMatrix * (inverse(LightMatrix) * vec4(position, 1.0f));
}
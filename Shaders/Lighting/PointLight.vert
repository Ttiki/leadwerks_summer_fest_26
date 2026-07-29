#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shader_draw_parameters : enable

// Includes
#include "../Common/Vertex.glsl"
#include "Light.glsl"

// Uniforms
uniform uint LightIndex;
uniform vec2 LightRange;
uniform mat4 LightMatrix;

void main()
{
    vec3 position = VertexPosition * LightRange.y;
    gl_Position = CameraProjectionMatrix * (vec4(position - LightMatrix[3].xyz, 1.0f));
}

#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shader_draw_parameters : enable

// Includes
#include "../Common/Vertex.glsl"
#include "Light.glsl"

// Uniforms
uniform uint LightIndex;
uniform mat4 LightMatrix2;

void main()
{
    vec3 position = VertexPosition;
    gl_Position = CameraProjectionMatrix * LightMatrix2 * vec4(position, 1.0f);
}
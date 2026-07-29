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
uniform vec2 LightArea;

void main()
{
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
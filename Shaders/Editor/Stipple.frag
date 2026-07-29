#version 450

#include "../Common/Materials.glsl"
#include "../Common/Uniforms.glsl"

// Inputs
in vec4 color;

// Outputs
out vec4 outColor;

void main()
{
    Material mtl;
	UnpackMaterial(MaterialIndex[0], mtl);
    outColor = mtl.diffuseColor * color;
    if ((int(gl_FragCoord.x / 8.0f) % 2) == (int(gl_FragCoord.y / 8.0f) % 2)) discard;
}

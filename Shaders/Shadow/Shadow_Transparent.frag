#version 450

//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Materials.glsl"

//------------------------------------------------------
// Uniforms
//------------------------------------------------------

uniform uint TextureFlags = 0;
uniform float TextureLodBias = 0.0f;
uniform uvec4 MaterialIndex = uvec4(0);
uniform ivec2 CoordOffset = ivec2(0);

//------------------------------------------------------
// Samplers
//------------------------------------------------------

layout(binding = 0) uniform sampler2D BaseColorMap;

//------------------------------------------------------
// Inputs
//------------------------------------------------------

in flat float AlphaCutoff;
in vec4 TexCoords;
in vec4 color;

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{
    vec4 VertexColor = color;
    Material material;
	UnpackMaterial(uint(MaterialIndex[0]), material);

    int ix = int(gl_FragCoord.x) + CoordOffset.x;
    int iy = int(gl_FragCoord.y);// + CoordOffset.y;
    ix = ix % 2;
    iy = iy % 2;
    
    vec4 baseColor = VertexColor * material.diffuseColor;

    if ((TextureFlags & 1) != 0) baseColor *= texture(BaseColorMap, TexCoords.xy, 0.0);
    
    //if (ix == iy) discard;
    //return;

    if (baseColor.a > 0.999) return;
    if (baseColor.a < 0.001) discard;
    
    //if (ix == iy) discard;


    if (baseColor.a < 0.33333)
    {
        if (ix != 0 || iy != 0) discard;
    }
    else if (baseColor.a < 0.66667)
    {
        if (ix == iy) discard;
    }
    else
    {
        if (ix == 0 && iy == 0) discard;
    }
}
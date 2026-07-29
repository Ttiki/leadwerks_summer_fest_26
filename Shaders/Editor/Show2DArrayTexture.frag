#version 450

#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Utilities/DepthFunctions.glsl"

uniform layout(binding = 0) sampler2DArray texture0;

in vec4 color;
in vec4 TexCoords;

out vec4 outColor;

void main()
{    
    Material mtl;
	UnpackMaterial(MaterialIndex[0], mtl);
	
    vec4 basecolor = mtl.diffuseColor * color;

    outColor = basecolor;
    vec3 tc = TexCoords.xyz;
    tc.z = mtl.emissiveColor.g;
    outColor *= textureLod(texture0, tc, mtl.emissiveColor.r);
    if ((RenderFlags & RENDERFLAGS_TRANSPARENCY) != 0) outColor.rgb *= outColor.a;
}
#version 450
#extension GL_ARB_separate_shader_objects : enable
//#extension GL_EXT_multiview : enable
//#extension GL_ARB_bindless_texture : enable

#include "../Common/Uniforms.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Materials.glsl"
#include "../Utilities/DepthFunctions.glsl"

uniform layout(binding = 0) sampler3D tex;

in vec4 color;
in vec4 TexCoords;

out vec4 outColor;

void main()
{    
    Material mtl;
	UnpackMaterial(MaterialIndex[0], mtl);
	
    vec4 basecolor = mtl.diffuseColor * color;

    outColor = color;
    
    vec3 tc = TexCoords.xyz;
    tc.z = mtl.emissiveColor.g;
	outColor *= textureLod(tex, tc, mtl.emissiveColor.r);  
    if ((RenderFlags & RENDERFLAGS_TRANSPARENCY) != 0) outColor.rgb *= outColor.a;
}
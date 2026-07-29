#version 450
#extension GL_ARB_separate_shader_objects : enable
//#extension GL_EXT_multiview : enable
//#extension GL_ARB_bindless_texture : enable

//#include "../Base/Fragment.glsl"
#include "../Utilities/DepthFunctions.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Constants.glsl"

uniform layout(binding = 0) sampler2D tex;

out vec4 outColor;
in vec4 TexCoords;

in vec4 color;

void main()
{    
    Material mtl;
	UnpackMaterial(MaterialIndex[0], mtl);
	
    vec4 basecolor = mtl.diffuseColor * color;

    outColor = basecolor;
    
    // Base texture color
    //if (mtl.textureHandle[0] != uvec2(0)) outColor[0] *= textureLod(sampler2D(mtl.textureHandle[0]), TexCoords.xy, mtl.emissiveColor.r);
	
	int lod = int(mtl.emissiveColor.r);
	if (lod == 0)
	{
		outColor *= textureLod(tex, TexCoords.xy, mtl.emissiveColor.r);
	}
	else
	{
		vec2 sz = textureSize(tex, int(mtl.emissiveColor.r)).xy;
		outColor *= texelFetch(tex, ivec2(TexCoords.x * sz.x, TexCoords.y * sz.y), lod);
	}

    if ((RenderFlags & RENDERFLAGS_TRANSPARENCY) != 0u)
	{
		outColor.rgb *= outColor.a;
	}	
}
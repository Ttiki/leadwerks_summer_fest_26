#version 450
#extension GL_ARB_separate_shader_objects : enable
//#extension GL_EXT_multiview : enable
//#extension GL_ARB_bindless_texture : enable

#include "../Common/Uniforms.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Materials.glsl"
#include "../Utilities/DepthFunctions.glsl"

vec4 sampleCubemapLike2DTexture(in samplerCube tex, in vec2 texcoords, in int miplevel, in int face) {
    // Convert 2D texture coordinates to a direction vector
    vec3 direction;

    // Determine the direction based on the specified face
    if (face == 0) { // Positive X
        direction = vec3(1.0, texcoords.y * 2.0 - 1.0, -texcoords.x * 2.0 + 1.0);
    } else if (face == 1) { // Negative X
        direction = vec3(-1.0, texcoords.y * 2.0 - 1.0, texcoords.x * 2.0 - 1.0);
    } else if (face == 2) { // Positive Y
        direction = vec3(texcoords.x * 2.0 - 1.0, 1.0, texcoords.y * 2.0 - 1.0);
    } else if (face == 3) { // Negative Y
        direction = vec3(texcoords.x * 2.0 - 1.0, -1.0, texcoords.y * 2.0 - 1.0);
    } else if (face == 4) { // Positive Z
        direction = vec3(texcoords.x * 2.0 - 1.0, texcoords.y * 2.0 - 1.0, 1.0);
    } else if (face == 5) { // Negative Z
        direction = vec3(-texcoords.x * 2.0 + 1.0, texcoords.y * 2.0 - 1.0, -1.0);
    } else {
        // Invalid face index, return a default color (e.g., transparent)
        return vec4(0.0, 0.0, 0.0, 0.0);
    }

    direction.y *= -1.0f;

    // Sample the cubemap texture using the direction vector
    return textureLod(tex, normalize(direction), miplevel);
}

in vec4 color;
in vec4 TexCoords;

out vec4 outColor;

uniform layout(binding = 0) samplerCube tex;

void main()
{    
    Material mtl;
	UnpackMaterial(MaterialIndex[0], mtl);
	
    vec4 basecolor = mtl.diffuseColor * color;

    outColor = basecolor;
    
    // Base texture color
    outColor *= sampleCubemapLike2DTexture(tex, TexCoords.xy, int(mtl.emissiveColor.r), int(mtl.emissiveColor.g) );
    if ((RenderFlags & RENDERFLAGS_TRANSPARENCY) != 0) outColor.rgb *= outColor.a;
	
}
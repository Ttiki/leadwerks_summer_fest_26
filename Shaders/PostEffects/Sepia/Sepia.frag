#version 450

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 outColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec4 color = texelFetch(ColorBuffer, coord, 0);
    
    // Apply sepia tone
    float r = color.r;
    float g = color.g;
    float b = color.b;
    
    float sepiaR = dot(vec3(r, g, b), vec3(0.393, 0.769, 0.189));
    float sepiaG = dot(vec3(r, g, b), vec3(0.349, 0.686, 0.168));
    float sepiaB = dot(vec3(r, g, b), vec3(0.272, 0.534, 0.131));
    
    vec3 sepiaColor = vec3(sepiaR, sepiaG, sepiaB);
    
    // Clamp to [0, 1]
    sepiaColor = clamp(sepiaColor, 0.0, 1.0);
    
    outColor = vec4(sepiaColor, color.a);
    
    // Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
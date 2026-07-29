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
    vec2 offset = vec2(1.0 / 1920.0, 1.0 / 1080.0); // Adjust based on your resolution

    // Offset for chromatic aberration
    vec2 redOffset = vec2(-0.005, 0.0);
    vec2 greenOffset = vec2(0.0, 0.0);
    vec2 blueOffset = vec2(0.005, 0.0);

    // Fetch each color channel with offset
    float r = texture(ColorBuffer, TexCoords + redOffset).r;
    float g = texture(ColorBuffer, TexCoords + greenOffset).g;
    float b = texture(ColorBuffer, TexCoords + blueOffset).b;

    vec4 color = vec4(r, g, b, 1.0);

    // Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0)
        color.rgb += dither(DitherTexture);

    outColor = color;
}
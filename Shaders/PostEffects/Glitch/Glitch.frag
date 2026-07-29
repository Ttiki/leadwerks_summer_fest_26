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

// Pseudo-random function for variability
float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec2 uv = TexCoords;
    float time = CurrentTime;

    // Generate a sporadic glitch trigger
    float glitchProbability = 0.02; // 2% chance per frame
    float glitchTrigger = rand(vec2(floor(time * 10.0))) > (1.0 - glitchProbability) ? 1.0 : 0.0;

    // For more sporadic glitches, combine multiple triggers
    float sporadicGlitch = 0.0;
    if (glitchTrigger > 0.5)
    {
        // Random horizontal offset
        float maxOffset = 0.05;
        float offsetAmount = rand(vec2(glitchTrigger, time)) * maxOffset;

        // Apply red and blue channel shifts
        vec4 color;
        color.r = texture(ColorBuffer, uv + vec2(offsetAmount, 0.0)).r;
        color.g = texture(ColorBuffer, uv).g;
        color.b = texture(ColorBuffer, uv - vec2(offsetAmount, 0.0)).b;

        // Add vertical noise lines
        float line = step(0.5, sin(uv.y * 100.0 + time * 20.0)) * 0.2;
        color.rgb += line;

        sporadicGlitch = 1.0;
        outColor = color;
    }
    else
    {
        // No glitch, fetch normally
        outColor = texelFetch(ColorBuffer, ivec2(gl_FragCoord.xy), 0);
    }

    // Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0)
        outColor.rgb += dither(DitherTexture);
}
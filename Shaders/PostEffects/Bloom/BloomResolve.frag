#version 450

// This is Klepto2's much improved bloom shader. Big thanks to you!
// https://www.ultraengine.com/community/topic/66624-kl_effects-reworked-posteffects-for-ultraengine/

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Math/Math.glsl"
#include "../../Common/Dither.glsl"
#include "ToneMapping.glsl"

//Inputs
in vec2 TexCoords;

//Outputs
out vec4 outColor;

// Uniforms
layout(binding = 0) uniform sampler2D ColorBuffer;
layout(binding = 1) uniform sampler2D BloomBuffer;
layout(binding = 15) uniform sampler2D DitherTexture;
uniform float Threshold = 0.5f;
uniform float Exposure = 1.0f;

void main()
{
    vec2 tc = gl_FragCoord.xy / textureSize(ColorBuffer, 0).xy;
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);

    vec3 bloom = (textureLod(BloomBuffer, tc, 0).rgb);
    vec4 background = (texelFetch(ColorBuffer, coord, 0));

    //bloom = sRGBToLinear(bloom);
   // background = sRGBToLinear(background);

    float wt = 0.75f;

    float brightness = max(max(bloom.r, bloom.g), bloom.b);
    //if (brightness < sRGBToLinear(0.5f))
    if (brightness < 0.5f)
    {
        wt = wt * (brightness * 2.0f);
    }

    outColor = background;
    outColor.rgb = mix(outColor.rgb, bloom, wt);

    outColor.r = max(outColor.r, background.r);
    outColor.g = max(outColor.g, background.g);
    outColor.b = max(outColor.b, background.b);

    //outColor.rgb = linearTosRGB(outColor.rgb);

    //Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0)
    {
        outColor.rgb += dither(DitherTexture);
    }
}
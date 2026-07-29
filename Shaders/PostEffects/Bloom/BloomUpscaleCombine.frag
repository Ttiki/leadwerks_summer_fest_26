#version 450

// This is Klepto2's much improved bloom shader. Big thanks to you!
// https://www.ultraengine.com/community/topic/66624-kl_effects-reworked-posteffects-for-ultraengine/

//Inputs
in vec2 TexCoords;

//Output
out vec4 outColor;

// Uniforms
layout(binding = 0) uniform sampler2D DownBuffer;
layout(binding = 1) uniform sampler2D AddBuffer;

uniform ivec4 DrawViewport;

#include "../../Math/Math.glsl"
#include "ToneMapping.glsl"

// 9-tap bilinear upsampler (tent filter)
vec4 UpsampleTent(sampler2D tex, vec2 uv, vec2 texelSize, vec4 sampleScale)
{
    vec4 d = texelSize.xyxy * vec4(1.0, 1.0, -1.0, 0.0) * sampleScale;

    vec4 s;
    s =  (texture(tex, uv - d.xy));
    s += (texture(tex, uv - d.wy)) * 2.0;
    s += (texture(tex, uv - d.zy));
         
    s += (texture(tex, uv + d.zw)) * 2.0;
    s += (texture(tex, uv       )) * 4.0;
    s += (texture(tex, uv + d.xw)) * 2.0;
         
    s += (texture(tex, uv + d.zy));
    s += (texture(tex, uv + d.wy)) * 2.0;
    s += (texture(tex, uv + d.xy));

    return s * (1.0 / 16.0);
}

void main()
{
    vec2 tc = TexCoords;
    vec2 ts = vec2(1.0f) / vec2(DrawViewport.zw);//textureSize(DownBuffer, 0).xy;

    outColor = (UpsampleTent(DownBuffer, tc, ts, vec4(1)));
    outColor += (texture(AddBuffer,tc));
    outColor.rgb = (outColor.rgb);
}
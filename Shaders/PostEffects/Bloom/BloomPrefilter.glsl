// This is Klepto2's much improved bloom shader. Big thanks to you!
// https://www.ultraengine.com/community/topic/66624-kl_effects-reworked-posteffects-for-ultraengine/

// Includes
#include "../../Math/Math.glsl"
#include "../../Common/Dither.glsl"
#include "ToneMapping.glsl"

// Uniforms
layout(binding = 0) uniform sampler2D ColorBuffer;
#ifdef MSAA
layout(binding = 1) uniform sampler2DMS DepthBuffer;
#else
layout(binding = 1) uniform sampler2D DepthBuffer;
#endif

//Inputs
in vec2 TexCoords;

//Outputs
out vec4 outColor;

uniform float Threshold = 0.5f;
uniform float SoftThreshold = 0.5f;
uniform ivec4 DrawViewport;

float Max3(float a, float b, float c)
{
    return max(max(a, b), c);
}

vec4 DownsampleBox13Tap(sampler2D tex, vec2 uv, vec2 texelSize)
{
	// Make sure you use textureLod here, not texture()
	// Previous buffer can have unused mipmaps
	
    vec4 A = (textureLod(tex, uv + texelSize * vec2(-1.0, -1.0), 0.0));
    vec4 B = (textureLod(tex, uv + texelSize * vec2( 0.0, -1.0), 0.0));
    vec4 C = (textureLod(tex, uv + texelSize * vec2( 1.0, -1.0), 0.0));
    vec4 D = (textureLod(tex, uv + texelSize * vec2(-0.5, -0.5), 0.0));
    vec4 E = (textureLod(tex, uv + texelSize * vec2( 0.5, -0.5), 0.0));
    vec4 F = (textureLod(tex, uv + texelSize * vec2(-1.0,  0.0), 0.0));
    vec4 G = (textureLod(tex, uv                               , 0.0));
    vec4 H = (textureLod(tex, uv + texelSize * vec2( 1.0,  0.0), 0.0));
    vec4 I = (textureLod(tex, uv + texelSize * vec2(-0.5,  0.5), 0.0));
    vec4 J = (textureLod(tex, uv + texelSize * vec2( 0.5,  0.5), 0.0));
    vec4 K = (textureLod(tex, uv + texelSize * vec2(-1.0,  1.0), 0.0));
    vec4 L = (textureLod(tex, uv + texelSize * vec2( 0.0,  1.0), 0.0));
    vec4 M = (textureLod(tex, uv + texelSize * vec2( 1.0,  1.0), 0.0));

    vec2 div = (1.0 / 4.0) * vec2(0.5, 0.125);

    vec4 o = (D + E + I + J) * div.x;
    o += (A + B + G + F) * div.y;
    o += (B + C + H + G) * div.y;
    o += (F + G + L + K) * div.y;
    o += (G + H + M + L) * div.y;

    return o;
}

vec4 Prefilter (vec4 c) {
	float brightness = max(c.r, max(c.g, c.b));
	float knee = Threshold * SoftThreshold;
	float soft = brightness - Threshold + knee;
	soft = clamp(soft, 0.0, 2.0 * knee);
	soft = soft * soft / (4.0 * knee + 0.00001);
	float contribution = max(soft, brightness - Threshold);
	contribution /= max(brightness, 0.00001);
	return c * contribution;
}
	
void main()
{
#ifdef MSAA
	vec2 sz = textureSize(DepthBuffer).xy;
#else
    vec2 sz = textureSize(DepthBuffer, 0).xy;
#endif
    vec2 tc = TexCoords;
    //ivec2 coord = ivec2(TexCoords.x * sz.x, TexCoords.y * sz.y);

    vec4 background = vec4(0.0); //(texelFetch(ColorBuffer, coord, 0));
	//float z = texelFetch(DepthBuffer, ivec2(tc * sz.xy* 2.0),0 ).r;
	
	background = DownsampleBox13Tap(ColorBuffer, tc, 1.0 / vec2(DrawViewport.zw));
	outColor = Prefilter(background);
	
    if (isnan(outColor.r) || isnan(outColor.g) || isnan(outColor.b) || isnan(outColor.a)) outColor = vec4(0,0,0,1);
}
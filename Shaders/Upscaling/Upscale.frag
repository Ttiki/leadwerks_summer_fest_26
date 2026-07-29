#version 450

uniform ivec4 DrawViewport; // xy: viewport origin, zw: viewport size (full resolution)
layout(binding = 0) uniform sampler2D ColorBuffer;

in vec2 TexCoords;

layout(location = 0) out vec4 outColor;

// Constants for FXAA
const float FXAA_REDUCE_MIN = (1.0/16.0);
const float FXAA_REDUCE_MUL = (1.0/8.0);
const float FXAA_SPAN_MAX = 16.0;

// Gaussian weights for sampling along the edge (more samples for smoother blend)
const int NUM_SAMPLES = 9;
const float weights[NUM_SAMPLES] = float[](0.05, 0.1, 0.15, 0.2, 0.5, 0.2, 0.15, 0.1, 0.05);
const float offsets[NUM_SAMPLES] = float[](-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0);

vec3 rgb2luma(vec3 rgb) {
    // Use standard luminance weights for perceptual accuracy
    return vec3(0.2126, 0.7152, 0.0722) * rgb;
}

// Limiting the brightness helps prevent specular artifacts
vec3 texColor(vec2 uv) {
    return min(textureLod(ColorBuffer, uv, 0.0).rgb, vec3(1.0));
}

#define FXAA_SPAN_MAX 32.0
#define FXAA_REDUCE_MUL   (1.0/FXAA_SPAN_MAX)
#define FXAA_REDUCE_MIN   (1.0/128.0)
#define FXAA_SUBPIX_SHIFT (1.0/4.0)

vec3 FxaaPixelShader( vec4 uv, sampler2D tex) {
    
    vec2 sz = textureSize(tex,0);
    vec2 rcpFrame = 1.0f / vec2(sz.x, sz.y);

    vec3 rgbNW = textureLod(tex, uv.zw, 0.0).xyz;
    vec3 rgbNE = textureLod(tex, uv.zw + vec2(1,0)*rcpFrame.xy, 0.0).xyz;
    vec3 rgbSW = textureLod(tex, uv.zw + vec2(0,1)*rcpFrame.xy, 0.0).xyz;
    vec3 rgbSE = textureLod(tex, uv.zw + vec2(1,1)*rcpFrame.xy, 0.0).xyz;
    vec3 rgbM  = textureLod(tex, uv.xy, 0.0).xyz;

    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);

    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

    float dirReduce = max(
        (lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
        FXAA_REDUCE_MIN);
    float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
    
    dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
          max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
          dir * rcpDirMin)) * rcpFrame.xy;

    vec3 rgbA = (1.0/2.0) * (
        textureLod(tex, uv.xy + dir * (1.0/3.0 - 0.5), 0.0).xyz +
        textureLod(tex, uv.xy + dir * (2.0/3.0 - 0.5), 0.0).xyz);
    vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
        textureLod(tex, uv.xy + dir * (0.0/3.0 - 0.5), 0.0).xyz +
        textureLod(tex, uv.xy + dir * (3.0/3.0 - 0.5), 0.0).xyz);
    
    float lumaB = dot(rgbB, luma);

    if((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
    
    return rgbB; 
}

void main()
{
    vec2 uv = vec2(gl_FragCoord.x / float(DrawViewport.z),
                   gl_FragCoord.y / float(DrawViewport.w));

    // Adjust texel size based on resolution
    vec2 texelSize = 1.0 / vec2(DrawViewport.z, DrawViewport.w);
    
    // Sample neighboring pixels
    vec3 rgbNW = texColor(uv + vec2(-texelSize.x, -texelSize.y));
    vec3 rgbNE = texColor(uv + vec2( texelSize.x, -texelSize.y));
    vec3 rgbSW = texColor(uv + vec2(-texelSize.x,  texelSize.y));
    vec3 rgbSE = texColor(uv + vec2( texelSize.x,  texelSize.y));
    vec3 rgbM  = texColor(uv);

    // Calculate luminance
    float lumaNW = dot(rgb2luma(rgbNW), vec3(0.2126, 0.7152, 0.0722));
    float lumaNE = dot(rgb2luma(rgbNE), vec3(0.2126, 0.7152, 0.0722));
    float lumaSW = dot(rgb2luma(rgbSW), vec3(0.2126, 0.7152, 0.0722));
    float lumaSE = dot(rgb2luma(rgbSE), vec3(0.2126, 0.7152, 0.0722));
    float lumaM  = dot(rgb2luma(rgbM),  vec3(0.2126, 0.7152, 0.0722));

    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    float lumaRange = lumaMax - lumaMin;

    // Early exit if no significant edge
    if (lumaRange < 0.02)
    {
        outColor = vec4(rgbM, 0.0);
        return;
    }
    
	vec3 smoothedColor = FxaaPixelShader( vec4(TexCoords, TexCoords), ColorBuffer); 
	
	float edgeStrength = clamp(lumaRange / 0.1, 0.0, 1.0);
    outColor.rgb = smoothedColor;//mix(rgbM, smoothedColor, 1.0); // soften edges	
	outColor.a = lumaRange;
	
	/*
    // Compute edge direction
    float dirX = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    float dirY =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    vec2 dir = vec2(dirX, dirY);

    // Normalize direction
    float lumaAvg = (lumaNW + lumaNE + lumaSW + lumaSE) * 0.25;
    float dirReduce = max(lumaAvg * FXAA_REDUCE_MUL, FXAA_REDUCE_MIN);
    float rcpDir = 1.0 / (max(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = clamp(dir * rcpDir, vec2(-FXAA_SPAN_MAX), vec2(FXAA_SPAN_MAX));

    // Sample along the edge with multiple points
    vec3 colorSum = vec3(0.0);
    float weightSum = 0.0;

    for (int i = 0; i < NUM_SAMPLES; ++i)
    {
        float offset = offsets[i];
        float weight = weights[i];
        vec2 offsetUv = uv + dir * texelSize * offset;
        vec3 sampleColor = texColor(offsetUv);
        colorSum += sampleColor * weight;
        weightSum += weight;
    }

    vec3 smoothedColor = colorSum / weightSum;

    // Optional: blend the original color with the smoothed color based on edge strength
    float edgeStrength = clamp(lumaRange / 0.1, 0.0, 1.0);
    vec3 finalColor = mix(rgbM, smoothedColor, edgeStrength * 0.75); // soften edges

    outColor = vec4(finalColor, lumaRange);
	*/
    //outColor = vec4(lumaRange,lumaRange,lumaRange,0.0);
}
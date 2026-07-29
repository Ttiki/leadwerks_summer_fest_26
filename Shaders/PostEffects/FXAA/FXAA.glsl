// Inputs
in vec2 TexCoords;

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

#ifdef MSAASAMPLES
	uniform layout(binding = 1) sampler2DMS DepthBuffer;
	uniform layout(binding = 2) sampler2DMS NormalBuffer;
#else
	uniform layout(binding = 1) sampler2D DepthBuffer;
	uniform layout(binding = 2) sampler2D NormalBuffer;
#endif

// Outputs
out vec4 outColor;

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"
#include "../../Common/DepthFunctions.glsl"

// Created by Reinder Nijhoff 2016
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// @reindernijhoff
//
// https://www.shadertoy.com/view/ls3GWS
//
// car model is made by Eiffie
// shader 'Shiny Toy': https://www.shadertoy.com/view/ldsGWB
//
// demonstrating post process FXAA applied to my shader 'Tokyo': 
// https://www.shadertoy.com/view/Xtf3zn
//
// FXAA code from: http://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/
//

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
#ifdef MSAASAMPLES
	vec2 depthbuffersz = textureSize(DepthBuffer);
#else
	vec2 depthbuffersz = textureSize(DepthBuffer, 0);
#endif
	ivec2 coord = ivec2(TexCoords.x * depthbuffersz.x, TexCoords.y * depthbuffersz.y);
	vec2 uv = TexCoords;

    // Adjust texel size based on resolution
    vec2 texelSize = vec2(1.0) / vec2(DrawViewport.z, DrawViewport.w);
    
    // Sample neighboring pixels
    float lumaNW = DepthToPosition(texelFetch(DepthBuffer, coord + ivec2(-1, -1), 0).r, CameraRange);
    float lumaNE = DepthToPosition(texelFetch(DepthBuffer, coord + ivec2( 1, -1), 0).r, CameraRange);
    float lumaSW = DepthToPosition(texelFetch(DepthBuffer, coord + ivec2(-1,  1), 0).r, CameraRange);
    float lumaSE = DepthToPosition(texelFetch(DepthBuffer, coord + ivec2( 1,  1), 0).r, CameraRange);

	float depth = texelFetch(DepthBuffer, coord, 0).r;
    float lumaM  = DepthToPosition(depth, CameraRange);
	float z = (lumaM - CameraRange.x) / (CameraRange.y - CameraRange.x);
	
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    float lumaRange = lumaMax - lumaMin;
	
	if (lumaRange == 0.0)
    {
		coord = ivec2(TexCoords.x * BufferSize.x, TexCoords.y * BufferSize.y);
        outColor = texelFetch(ColorBuffer, coord, 0);
        return;
    }
	
	vec3 normal = texelFetch(NormalBuffer, coord, 0).rgb * 2.0 - 1.0;
	normal = inverse(CameraNormalMatrix) * normal;
	float NT = 1.0 - abs(normal.z);
	
    // Early exit if no significant edge
    if (lumaRange < (20.0 + NT * 1000.0) * z)
    {
		coord = ivec2(TexCoords.x * BufferSize.x, TexCoords.y * BufferSize.y);
        outColor = texelFetch(ColorBuffer, coord, 0);
        return;
    }
	
	//Show Edges:
	//outColor = vec4(1.0);
	//return;
	
	vec2 tc = TexCoords;
    outColor.rgb = FxaaPixelShader( vec4(tc, tc), ColorBuffer); 
    outColor.a = 1.0f;
	
    //Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
#version 450

layout(binding = 0) uniform sampler2D prevpass;
layout(binding = 1) uniform sampler2D aobuffer;
layout(binding = 15) uniform sampler2D DitherTexture;

#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

//Inputs
in vec2 TexCoords;

//Output
layout(location = 0) out vec4 outColor;

//   GLfloat sigma = 11.0f, threshold = .180f, slider = 0.f; //running
//    // GLfloat sigma = 7.0f, threshold = .180f, slider = 0.f; //running
//    GLfloat kSigma = 2.f;

float uSigma = 1.0f;
float uThreshold = 1.0f;
float uKSigma = 1.0f;
vec2 wSize = BufferSize;

#define INV_SQRT_OF_2PI 0.39894228040143267793994605993439  // 1.0/SQRT_OF_2PI
#define INV_PI 0.31830988618379067153776752674503
//  smartDeNoise - parameters
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//  sampler2D tex     - sampler image / texture
//  vec2 uv           - actual fragment coord
//  float sigma  >  0 - sigma Standard Deviation
//  float kSigma >= 0 - sigma coefficient 
//      kSigma * sigma  -->  radius of the circular kernel
//  float threshold   - edge sharpening threshold 

vec4 smartDeNoise(sampler2D tex, vec2 uv, float sigma, float kSigma, float threshold)
{
    float radius = round(kSigma*sigma);
    float radQ = radius * radius;

    float invSigmaQx2 = .5 / (sigma * sigma);      // 1.0 / (sigma^2 * 2.0)
    float invSigmaQx2PI = INV_PI * invSigmaQx2;    // // 1/(2 * PI * sigma^2)

    float invThresholdSqx2 = .5 / (threshold * threshold);     // 1.0 / (sigma^2 * 2.0),
    float invThresholdSqrt2PI = INV_SQRT_OF_2PI / threshold;   // 1.0 / (sqrt(2*PI) * sigma)

    vec4 centrPx = texture(tex,uv); 
    //ivec2 ic = ivec2(uv * textureSize(texture2DSampler[NormalTextureID], 0));
    //vec3 centernormal = texelFetch(texture2DSampler[NormalTextureID], ic, 0).rgb;
    //if (centernormal.x == 0.0f && centernormal.y == 0.0f && centernormal.z == 0.0f) return centrPx;
    //float centerdepth = texelFetch(texture2DSampler[DepthTextureID], ic, 0).r;
    //centerdepth = DepthToPosition(centerdepth, CameraRange);

    float zBuff = 0.0;
    vec4 aBuff = vec4(0.0);
    vec2 size = vec2(textureSize(tex, 0));

    float weight;
	
    vec2 d;
	int x, y;
    for (x = -1; x <= 1; x++) {
		d.x = x;
        //float pt = sqrt(radQ-d.x*d.x);       // pt = yRadius: have circular trend
        //for (d.y=-pt; d.y <= pt; d.y++) {
        for (y=-1; y <= 1; y++)
		{  
			d.y = y;
			
            float blurFactor = exp( -dot(d , d) * invSigmaQx2 ) * invSigmaQx2PI;
            
            vec2 tc = uv+d / size;

            //float sampledepth = textureLod(texture2DSampler[DepthTextureID], tc, 0.0f).r;
            //if (sampledepth >= 1.0f) continue;
			//weight=1;
            //vec3 samplenormal = textureLod(texture2DSampler[NormalTextureID], tc, 0.0f).rgb;
            //if (samplenormal.x == 0.0f && samplenormal.y == 0.0f && samplenormal.z == 0.0f) continue;
            //weight = dot(centernormal, samplenormal);
            //if (weight <= 0.0f) continue;

            //sampledepth = DepthToPosition(sampledepth, CameraRange);
            //float diff = abs(centerdepth - sampledepth);
            //if (diff > 1.0f) weight *= max(0.0f, 1.0f - (diff - 1.0f) / 1.0f);

            vec4 walkPx =  texture(tex, tc);
            vec4 dC = walkPx-centrPx;
            float deltaFactor = exp( -dot(dC, dC) * invThresholdSqx2) * invThresholdSqrt2PI * blurFactor;

            zBuff += deltaFactor;
            aBuff += deltaFactor * walkPx;
        }
    }
    if (zBuff <= 0.0f) return centrPx;
    return aBuff/zBuff;
}

void main()
{
    vec2 texcoord = TexCoords;
    vec4 color = textureLod(prevpass, TexCoords, 0);
	
	//float ao = texture(aobuffer,texcoord).r;
    float ao = smartDeNoise(aobuffer, texcoord, uSigma, uKSigma, uThreshold).r;
    
    outColor = color * vec4(ao, ao, ao, 1.0);
	
	//Makes AO darker in dark areas
	float luminance = max(color.r, max(color.g, color.b));
	ao = 1.0f - ao;
	ao = mix(ao * 2.0f, 0.0, luminance);
	ao = 1.0f - ao;
	ao = clamp(ao, 0.0f, 1.0f);
	
	outColor = vec4(color.rgb * ao, color.a);
	//outColor = vec4(color);// for debugging
	//outColor = vec4(ao);// for debugging
	
	//Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
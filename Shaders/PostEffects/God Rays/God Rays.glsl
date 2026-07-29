uniform mat4 CameraProjectionViewMatrix;

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;
#ifdef MSAA
uniform layout(binding = 1) sampler2DMS DepthBuffer;
#else
uniform layout(binding = 1) sampler2D DepthBuffer;
#endif

// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"

// Additional uniforms for godrays
uniform float Exposure = 0.035; // Controls the intensity of the rays
uniform int NumSamples = 60; // Number of samples for the rays
uniform float Density = 0.96; // Density of the rays
uniform float Weight = 0.4; // Weight of each sample
//uniform float Decay = 0.97; // Decay factor for the rays
uniform float StepSize = 4.0;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 HSLToRGB( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0f+vec3(0.0f,4.0f,2.0f),6.0f)-3.0f)-1.0f, 0.0f, 1.0f );
    return c.z + c.y * (rgb-0.5f)*(1.0f-abs(2.0f*c.z-1.0f));
}

vec3 RGBToHSL( in vec3 c ){
  float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = c.r;
	float g = c.g;
	float b = c.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );

	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;
        
        //s = l < .05 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) ); Original
		s = l < .0 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
        
		if ( r == cMax ) {
			h = ( g - b ) / cDelta;
		} else if ( g == cMax ) {
			h = 2.0 + ( b - r ) / cDelta;
		} else {
			h = 4.0 + ( r - g ) / cDelta;
		}

		if ( h < 0.0) {
			h += 6.0;
		}
		h = h / 6.0;
	}
	return vec3( h, s, l );
}

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

void main()
{
	float aspect = BufferSize.y / BufferSize.x;
	
#ifdef MSAA
	const vec2 sz = textureSize(DepthBuffer);
#else
	const vec2 sz = textureSize(DepthBuffer, 0);
#endif	
	
    fragColor = textureLod(ColorBuffer, TexCoords, 0);
	
	vec4 sunClipSpace = CameraProjectionViewMatrix * vec4(CameraPosition - SunDirection * 1000.0, 1.0);
	vec3 SunScreenPos;
	SunScreenPos.xy = (sunClipSpace.xy / sunClipSpace.w);
	SunScreenPos.xy = SunScreenPos.xy * 0.5 + 0.5;
	ivec2 coord;
	vec3 suncolor = vec3(0.0);
	
	//if (SunScreenPos.z > 0.0)
	{
		// Calculate vector from current pixel to sun's screen position
		vec2 deltaTex = TexCoords - SunScreenPos.xy;
		
		if (sunClipSpace.z < 0.0) deltaTex.xy *= -1.0;

		deltaTex.y *= aspect;
		
		// Just for testing...
		//float sundist = length(deltaTex);
		//if (sundist < 0.01)
		//{
		//	suncolor = SunColor.rgb * (1.0 - sundist / 0.01);
		//}
		
		float dist = length(deltaTex);
		vec2 tstep = deltaTex / float(NumSamples);
		tstep = normalize(tstep) * (vec2(1.0) / BufferSize) * StepSize;
		float steplength = length(tstep);
		
		// Initialize illumination sum
		vec3 illumination = vec3(0.0);

		// Accumulate light along the ray towards the sun
		vec2 sampleCoord = TexCoords;
		float illuminationDecay = 1.0;

		sampleCoord -= tstep * rand(TexCoords);

		for (int i = 0; i < NumSamples; ++i)
		{
			dist -= steplength;
			if (dist <= 0.0) break;
			sampleCoord -= tstep;
			
			if (sampleCoord.x < 0.0 || sampleCoord.y < 0.0 || sampleCoord.x > 1.0 || sampleCoord.y > 1.0) break;
			
			coord.x = int(sampleCoord.x * sz.x + 0.5);
			coord.y = int(sampleCoord.y * sz.y + 0.5);
			
			float depth = texelFetch(DepthBuffer, coord, 0).r;
			//float depth = textureLod(DepthBuffer, sampleCoord, 0).r;
			if (depth < 1.0) continue;
			
			vec4 sampleColor = textureLod(ColorBuffer, sampleCoord, 0);
			
			// Accumulate based on brightness threshold or brightness
			float brightness = dot(sampleColor.rgb, vec3(0.299, 0.587, 0.114));
			
			illuminationDecay = (1.0 - (float(i) / float(NumSamples)));
			
			illumination += SunColor.rgb * sampleColor.rgb * brightness * Weight * illuminationDecay;
		}
		
		vec3 godrays = illumination * Exposure;

		// This reduces rays "going into the ground" when you face away from the sun
		coord.x = int(TexCoords.x * sz.x + 0.5);
		coord.y = int(TexCoords.y * sz.y + 0.5);		
		float depth = texelFetch(DepthBuffer, coord, 0).r;
		if (depth < 1.0) godrays *= max(dot(CameraNormalMatrix[2], -SunDirection), 0.0);
		
		// Mix the original scene with the godrays
		fragColor.rgb += godrays + suncolor;
	}
	
    // Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0)
        fragColor.rgb += dither(DitherTexture);
}
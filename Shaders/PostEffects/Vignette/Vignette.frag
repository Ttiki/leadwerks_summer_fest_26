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

// Uniforms
uniform float noiseamount = 0.5;                          //Amount of noise                                                       //
uniform vec2 lensRadius 	= vec2(0.65*1.5, 0.05);              //Radius and feathering of vignette                     //
uniform vec3 nvcol 	= vec3(1.1, 4.0, 1.1);          //Change these values for nightvision color

// Outputs
out vec4 outColor;

void main() 
{	
	//Nightvision
	vec4 texcolor = textureLod(ColorBuffer, TexCoords, 0.0);

	//vignette
	float dist = distance(TexCoords.xy, vec2(0.5,0.5));
	float vigfin = smoothstep(lensRadius.x, lensRadius.y, dist);

	//Render
	outColor = texcolor * vec4(vigfin,vigfin,vigfin, 1.0);
	
	//Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) outColor.rgb += dither(DitherTexture);
}
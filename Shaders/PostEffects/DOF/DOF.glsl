// Includes
#include "../../Common/Constants.glsl"
#include "../../Common/Uniforms.glsl"
#include "../../Common/Dither.glsl"
#include "../../Common/DepthFunctions.glsl"

// Uniforms
uniform float Strength = 1.0;

// Samplers
uniform layout(binding = 0) sampler2D BlurBuffer;
uniform layout(binding = 1) sampler2D BlurDepthBuffer;
uniform layout(binding = 2) sampler2D ColorBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 fragColor;

void main()
{
	//float z = texelFetch(DepthBuffer, coord, 0).r;
	//z = DepthToPosition(z, CameraRange);

	float dof = min(textureLod(BlurDepthBuffer, TexCoords, 0.0).r * 2.0, 1.0) * Strength;

	fragColor = textureLod(ColorBuffer, TexCoords, 0);
	
	// Visualize the DOF strength
	//fragColor = vec4(dof);
	//return;
	
	if (dof > 0.0)
	{
		vec4 blur = textureLod(BlurBuffer, TexCoords, 0);
		fragColor.rgb = mix(fragColor.rgb, blur.rgb, dof);
	}
	
    //Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) fragColor.rgb += dither(DitherTexture);	
}
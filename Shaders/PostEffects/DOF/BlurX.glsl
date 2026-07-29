#include "../../Common/DepthFunctions.glsl"

#define BlurRadius 8

// Uniforms
uniform ivec4 DrawViewport;
uniform vec2 CameraRange;
uniform vec2 FadeIn = vec2(0, 3);
uniform vec2 FadeOut = vec2(10000.0, 10000.0);

// Samplers
layout(binding = 0) uniform sampler2D ColorBuffer;
#ifdef MSAA
layout(binding = 1) uniform sampler2DMS DepthBuffer;
#else
layout(binding = 1) uniform sampler2D DepthBuffer;
#endif

//Inputs
in vec2 TexCoords;

//Output
layout(location = 0) out vec4 outColor;
layout(location = 1) out float outZ;

void main()
{
    float ts = 1.0f / textureSize(ColorBuffer, 0).y;
	
#ifdef MSAA
	vec2 ds = textureSize(DepthBuffer);
#else
	vec2 ds = textureSize(DepthBuffer, 0);
#endif
    float dts = 1.0f / ds.y;
    vec2 uv;
	
	ivec2 coord;
    outColor = vec4(0.0);
    outZ = 0.0;
    for (int n = -BlurRadius; n < BlurRadius; ++n)
    {
		uv = TexCoords + vec2(ts * (float(n) + 0.5), 0.0);
        outColor += textureLod(ColorBuffer, uv, 0);
		
		coord = ivec2(uv.x * ds.x, uv.y * ds.y);
		coord.x = max(coord.x, 0);
		coord.y = max(coord.y, 0);
		coord.x = min(coord.x, int(ds.x - 1));
		coord.y = min(coord.y, int(ds.y - 1));
		
		float z = DepthToPosition(texelFetch(DepthBuffer, coord, 0).r, CameraRange);
		
		float dof = 0.0f;
		if (z < FadeIn.y)
		{
			dof = 1.0f - ((z - FadeIn.x) / (FadeIn.y - FadeIn.x));
		}
		else if (z > FadeOut.x)
		{
			dof = (z - FadeOut.x) / (FadeOut.y - FadeOut.x);
		}
		dof = clamp(dof, 0.0f, 1.0f);

		outZ = max(outZ, dof);
		//outZ += dof;		
    }
    outColor /= float(BlurRadius * 2);
    //outZ /= float(BlurRadius * 2);
}
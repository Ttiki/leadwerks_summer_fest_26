#version 450

// Includes
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Constants.glsl"

// Samplers
layout(binding = 0) uniform sampler2D BaseColorMap;

// Inputs
in vec4 color;
flat in vec3 emissioncolor;
in vec2 TexCoords;

// Outputs
layout(location = 0) out vec4 outColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, DrawViewport.w - gl_FragCoord.y);
    vec2 BufferSize = vec2(DrawViewport.z, DrawViewport.w);
    vec4 c = texture(BaseColorMap, TexCoords);
	//outColor = c;
	//return;
	
    outColor = vec4(0.0f);
    float totalwt = 0.0f;
    const int m = int(2.0 * DisplayScale + 0.5);
	
    int count = 1;
    for (int n = 0; n < count; ++n)
    {
        bool done = false;
        float depth = texelFetch(BaseColorMap, coord, n).a;

        //Handle selected objects
        if (depth > 0.0)
        {
            vec2 pixelsize = vec2(1.0f) / BufferSize;

            if (coord.x < m || coord.x > DrawViewport.z - 1 - m || coord.y < m || coord.y > DrawViewport.w - 1 - m)
            {
                outColor = SelectionColor;
                totalwt = 1.0f;
                continue;
            }

            for (int x = -m; x <= m; ++x)
            {
                for (int y = -m; y <= m; ++y)
                {
                    if (x == 0 && y == 0) continue;
                    if (abs(x) == m && abs(y) == m) continue;
                    //float l = length(vec2(x, y));
                    //float wt = 1.0 - l / float(m);
                    float wt = 1.0;
					if (abs(x) > 2 || abs(y) > 2) wt = 0.5;
					/*if (l > float(m))
                    {
                        wt = 1.0f - (l - float(m));
                        if (wt <= 0.0f) continue;
                    }*/
                    float neighbor = texelFetch(BaseColorMap, coord + ivec2(x, y), n).a;
                    if (neighbor == 0.0f)
                    {
                        outColor += SelectionColor * wt;
                        totalwt += wt;
                        if (totalwt >= 1.0f)
                        {      
                            outColor = SelectionColor;
                            totalwt = 1.0f;       
                            done = true;
                            break;
                        }
                    }
                }                
                if (done) break;
            }
        }
		else
		{
			discard;
		}
    }
	
    if (totalwt > 0.0f) outColor /= totalwt;
	
    outColor.rgb = color.rgb;
    
	Material material;
	UnpackMaterial(MaterialIndex[0], material);
	
	outColor *= material.diffuseColor;
	outColor.rgb *= outColor.a;
}


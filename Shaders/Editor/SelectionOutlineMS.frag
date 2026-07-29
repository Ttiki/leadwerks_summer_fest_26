#version 450

// Includes
#include "../Common/Materials.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"

// Samplers
layout(binding = 0) uniform sampler2D BaseColorMap;

// Inputs
layout(location = 0) in vec4 color;
layout(location = 1) flat in vec3 emissioncolor;
layout(location = 2) in vec2 texcoords;

// Outputs
layout(location = 0) out vec4 outColor;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, DrawViewport.w - gl_FragCoord.y);
    vec2 BufferSize = vec2(DrawViewport.z, DrawViewport.w);
    vec4 c = texture(BaseColorMap, texcoords);

    outColor = vec4(0.0f);
    float totalwt = 0.0f;
    const int m = 2;

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
                    float l = length(vec2(x, y));
                    float wt = 1.0f;
					if (abs(x) == m && abs(y) == m) wt = 0.5;
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
    }

    if (totalwt > 0.0f) outColor /= totalwt;
    
    outColor.rgb *= outColor.a;
}


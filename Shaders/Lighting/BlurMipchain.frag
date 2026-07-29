#version 450

uniform int MipLevel = 0;

layout(binding = 0) uniform sampler2D ColorBuffer;

// Outputs
layout(location = 0) out vec4 OutColor;

//#define BLUR3x3_ZTEST
#define BLUR3x3
//#define BLUR4x4

void main()
{
    vec2 texSize = vec2(textureSize(ColorBuffer, MipLevel + 1));
    vec2 texCoord = gl_FragCoord.xy / texSize;
    vec2 pixelsize = vec2(1.0) / (texSize * 1.0);
    
#ifdef BLUR3x3_ZTEST
    int weights = 1;
    OutColor = textureLod(ColorBuffer, texCoord, MipLevel);

    vec2 tc = texCoord + vec2(-pixelsize.x, pixelsize.y);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }
    tc = texCoord + vec2(0.0, pixelsize.y);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }
    tc = texCoord + vec2(pixelsize.x, pixelsize.y);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }

    tc = texCoord + vec2(-pixelsize.x, 0.0);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }
    tc = texCoord + vec2(pixelsize.x, 0.0);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }

    tc = texCoord + vec2(-pixelsize.x, -pixelsize.y);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }
    tc = texCoord + vec2(0.0, -pixelsize.y);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }
    tc = texCoord + vec2(pixelsize.x, -pixelsize.y);
    if (textureLod(ZPositionBuffer, tc, 0).r < 1.0)
    {
        OutColor += textureLod(ColorBuffer, tc, MipLevel);
        ++weights;
    }

    OutColor /= float(weights);

#endif

#ifdef BLUR3x3
    /*
    // Center
    OutColor = textureLod(ColorBuffer, texCoord, MipLevel) * 0.25;

    // Vertical and Horizontal neighbors
    OutColor += textureLod(ColorBuffer, texCoord + vec2(0.0, pixelsize.y), MipLevel) * 0.125;
    OutColor += textureLod(ColorBuffer, texCoord + vec2(0.0, -pixelsize.y), MipLevel) * 0.125;
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, 0.0), MipLevel) * 0.125;
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, 0.0), MipLevel) * 0.125;

    // Diagonals
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, pixelsize.y), MipLevel) * 0.0625;
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, pixelsize.y), MipLevel) * 0.0625;
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, -pixelsize.y), MipLevel) * 0.0625;
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, -pixelsize.y), MipLevel) * 0.0625; 
    */
    
    // Center
    OutColor = textureLod(ColorBuffer, texCoord, MipLevel);

    // Vertical and Horizontal neighbors
    OutColor += textureLod(ColorBuffer, texCoord + vec2(0.0, pixelsize.y), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(0.0, -pixelsize.y), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, 0.0), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, 0.0), MipLevel);

    // Diagonals
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, pixelsize.y), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, pixelsize.y), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, -pixelsize.y), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, -pixelsize.y), MipLevel); 

    OutColor *= 0.1111111;

#endif

#ifdef BLUR4x4
    OutColor =  textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 1.5, pixelsize.y * 1.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 0.5, pixelsize.y * 1.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 0.5, pixelsize.y * 1.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 1.5, pixelsize.y * 1.5), MipLevel);

    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 1.5, pixelsize.y * 0.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 0.5, pixelsize.y * 0.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 0.5, pixelsize.y * 0.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 1.5, pixelsize.y * 0.5), MipLevel);

    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 1.5, -pixelsize.y * 0.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 0.5, -pixelsize.y * 0.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 0.5, -pixelsize.y * 0.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 1.5, -pixelsize.y * 0.5), MipLevel);

    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 1.5, -pixelsize.y * 1.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x * 0.5, -pixelsize.y * 1.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 0.5, -pixelsize.y * 1.5), MipLevel);
    OutColor += textureLod(ColorBuffer, texCoord + vec2(pixelsize.x * 1.5, -pixelsize.y * 1.5), MipLevel);

    OutColor *= 0.0625;
#endif
    
    // This prevents specular reflections from creating large light areas
    OutColor.r = clamp(OutColor.r, 0.0, 1.0);
    OutColor.g = clamp(OutColor.g, 0.0, 1.0);
    OutColor.b = clamp(OutColor.b, 0.0, 1.0);
}
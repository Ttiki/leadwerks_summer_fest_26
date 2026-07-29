#version 450

uniform int MipLevel = 0;

layout(binding = 0) uniform sampler2D ColorBuffer;
layout(binding = 1) uniform sampler2D DepthBuffer;
layout(binding = 2) uniform sampler2D ZPositionBuffer;
layout(binding = 3) uniform sampler2D Color2Buffer;

// Outputs
layout(location = 0) out vec4 OutColor;
layout(location = 1) out vec4 OutColor2;

void main()
{
    vec2 texSize = vec2(textureSize(ColorBuffer, MipLevel + 1));
    vec2 texCoord = gl_FragCoord.xy / texSize;
    vec2 pixelsize = vec2(1.0) / (texSize * 1.0);
    ivec2 coord = ivec2(gl_FragCoord.x * 2, gl_FragCoord.y * 2);

    OutColor = vec4(0.0);
    OutColor2 = vec4(0.0);

    int ErrorMipLevel = MipLevel + 2;

    if (MipLevel == 0)
    {
        float z = texelFetch(ZPositionBuffer, coord, 0).r;
        float depth;
        float wt = 0.0;

        // Center        
        depth = texelFetch(DepthBuffer, coord, 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord, MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        else
        {
            OutColor = textureLod(ColorBuffer, texCoord, ErrorMipLevel);
            OutColor2 = textureLod(Color2Buffer, texCoord, ErrorMipLevel);
            OutColor.a = 0.0;
            OutColor2.a = 0.0;
            return;
        }
        
        depth = texelFetch(DepthBuffer, coord + ivec2(-1,-1), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(-1,-1), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        depth = texelFetch(DepthBuffer, coord + ivec2(-1,0), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(-1,0), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        depth = texelFetch(DepthBuffer, coord + ivec2(-1,1), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(-1,1), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }

        depth = texelFetch(DepthBuffer, coord + ivec2(1,-1), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(1,-1), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        depth = texelFetch(DepthBuffer, coord + ivec2(1,0), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(1,0), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        depth = texelFetch(DepthBuffer, coord + ivec2(1,1), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(1,1), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }

        depth = texelFetch(DepthBuffer, coord + ivec2(0,1), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(0,1), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        depth = texelFetch(DepthBuffer, coord + ivec2(0,-1), 0).r;
        if (depth >= z)
        {
            OutColor += texelFetch(ColorBuffer, coord + ivec2(0,-1), MipLevel);
            OutColor2 += texelFetch(Color2Buffer, coord, MipLevel);
            wt += 1.0;
        }
        
        OutColor /= wt;
        OutColor2 /= wt;
        OutColor.a = 1.0;
    }
    else
    {
        //const float alphatolerance = 0.0;

        // Center
        vec4 c = textureLod(ColorBuffer, texCoord, MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord, MipLevel) * c.a;
        //OutColor += c;

        // Vertical and Horizontal neighbors
        c = textureLod(ColorBuffer, texCoord + vec2(0.0, pixelsize.y), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(0.0, pixelsize.y), MipLevel) * c.a;
        //OutColor += c;

        c = textureLod(ColorBuffer, texCoord + vec2(0.0, -pixelsize.y), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(0.0, -pixelsize.y), MipLevel) * c.a;
        //OutColor += c;

        c = textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, 0.0), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(pixelsize.x, 0.0), MipLevel) * c.a;
        //OutColor += c;

        c = textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, 0.0), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(-pixelsize.x, 0.0), MipLevel) * c.a;
        //OutColor += c;

        // Diagonals
        c = textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, pixelsize.y), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(pixelsize.x, pixelsize.y), MipLevel) * c.a;
        //OutColor += c;

        c = textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, pixelsize.y), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(-pixelsize.x, pixelsize.y), MipLevel) * c.a;
        //OutColor += c;

        c = textureLod(ColorBuffer, texCoord + vec2(pixelsize.x, -pixelsize.y), MipLevel);
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(pixelsize.x, -pixelsize.y), MipLevel) * c.a;
        //OutColor += c;

        c = textureLod(ColorBuffer, texCoord + vec2(-pixelsize.x, -pixelsize.y), MipLevel); 
        //if (c.a < alphatolerance) c.a = 0.0;
        OutColor.rgb += c.rgb * c.a;
        OutColor.a += c.a;
        if (c.a > 0.0) OutColor2 += textureLod(Color2Buffer, texCoord + vec2(-pixelsize.x, -pixelsize.y), MipLevel) * c.a;
        //OutColor += c;
        
        if (OutColor.a > 0.0)
        {
            OutColor.rgb /= OutColor.a;
            OutColor2.rgb /= OutColor.a;
            OutColor.a *= 0.1111111;            
        }
        else
        {
            OutColor = textureLod(ColorBuffer, texCoord, ErrorMipLevel);
            OutColor2 = textureLod(Color2Buffer, texCoord, ErrorMipLevel);
            OutColor.a = 0.0;
        }        
    }
    OutColor2.a = OutColor.a;

    // This prevents specular reflections from creating large light areas
    OutColor.r = clamp(OutColor.r, 0.0, 1.0);
    OutColor.g = clamp(OutColor.g, 0.0, 1.0);
    OutColor.b = clamp(OutColor.b, 0.0, 1.0);
    OutColor2.r = clamp(OutColor2.r, 0.0, 1.0);
    OutColor2.g = clamp(OutColor2.g, 0.0, 1.0);
    OutColor2.b = clamp(OutColor2.b, 0.0, 1.0);    
}
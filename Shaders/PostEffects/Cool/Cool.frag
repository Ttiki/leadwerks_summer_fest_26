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

// Outputs
out vec4 outColor;

// Uniform for temperature adjustment
// Range: -1.0 (cool) to +1.0 (warm), 0.0 = neutral
uniform float Temperature = -0.05;

vec3 applyWarmCool(vec3 color, float temp)
{
    // Define tint colors for warm and cool
    vec3 warmTint = vec3(1.0, 0.5, 0.0); // warm tint (orange)
    vec3 coolTint = vec3(0.0, 0.5, 1.0); // cool tint (blue)
    
    // Blend toward warm or cool tint based on temperature
    if (temp > 0.0)
    {
        color = mix(color, warmTint, temp);
    }
    else
    {
        color = mix(color, coolTint, -temp);
    }
    return color;
}

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec4 color = texelFetch(ColorBuffer, coord, 0);
    
    // Apply warm/cool tint
    color.rgb = applyWarmCool(color.rgb, clamp(Temperature, -1.0, 1.0));
    
    // Dither final pass
    if ((RenderFlags & RENDERFLAGS_FINALPASS) != 0) 
        color.rgb += dither(DitherTexture);
        
    outColor = color;
}
#version 450

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;
uniform layout(binding = 1) sampler2D NormalBuffer;
uniform layout(binding = 15) sampler2D DitherTexture;

// Inputs
in vec2 TexCoords;

// Outputs
out vec4 outColor;

// Pseudo-random function
float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Helper to compute luminance
float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

void main()
{
    vec2 uv = TexCoords;
    vec2 texSize = vec2(textureSize(ColorBuffer, 0));
    vec2 offset = 1.0 / texSize;

    // Fetch neighboring pixels for edge detection
    float centerLum = luminance(texture(ColorBuffer, uv).rgb);
    float rightLum = luminance(texture(ColorBuffer, uv + vec2(offset.x, 0.0)).rgb);
    float leftLum = luminance(texture(ColorBuffer, uv - vec2(offset.x, 0.0)).rgb);
    float upLum = luminance(texture(ColorBuffer, uv + vec2(0.0, offset.y)).rgb);
    float downLum = luminance(texture(ColorBuffer, uv - vec2(0.0, offset.y)).rgb);

    // Calculate gradient magnitude for edges
    float dx = rightLum - leftLum;
    float dy = upLum - downLum;
    float edgeStrength = length(vec2(dx, dy)) * 4.0;

    // Sample normal and convert to [-1,1]
    vec3 normal = texture(NormalBuffer, uv).rgb * 2.0 - 1.0;

    // Use normal to modulate edge detection, e.g., surface orientation
    float normalInfluence = abs(normal.z); // or dot(normal, vec3(0,0,1))
    float edge = smoothstep(0.1, 0.3, edgeStrength * normalInfluence);

    // Add some randomness/noise for hand-drawn effect
    float noise = (rand(uv + float(gl_FragCoord.x + gl_FragCoord.y)) - 0.5) * 0.1;

    // Final sketch color: black lines on white background
    vec3 sketchColor = vec3(0.0); // black lines
    vec4 finalColor = mix(vec4(1.0), vec4(sketchColor, 1.0), edge + noise);

    // Optional: you can add more modulation based on the normal if desired
    // e.g., darken or lighten based on normal.z or other components

    outColor = finalColor;
}
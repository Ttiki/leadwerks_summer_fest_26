#version 450

// Samplers
uniform layout(binding = 0) sampler2D ColorBuffer;

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

    // Use normal to modulate edge detection, e.g., surface orientation
    float edge = smoothstep(0.1, 0.3, edgeStrength);

    // Fetch original color
    vec3 color = texture(ColorBuffer, uv).rgb;
	
    // Quantize color for cartoon effect (posterization)
    int levels = 5; // Number of color levels
	color = RGBToHSL(color);
    vec3 posterizedColor = color;
	posterizedColor.b = floor(color.b * float(levels) + 0.5) / float(levels);
	posterizedColor = HSLToRGB(posterizedColor);
	
    // Mix posterized color with edge detection to emphasize edges
    vec4 colorWithEdges = vec4(posterizedColor, 1.0);

    // Overlay black outlines where edges are strong
    vec4 outlineColor = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 finalColor = mix(colorWithEdges, outlineColor, edge * 0.75);

    outColor = finalColor;
}
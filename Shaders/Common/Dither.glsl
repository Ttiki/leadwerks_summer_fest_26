#ifndef _DITHER
	#define _DITHER

float dither(in sampler2D dithermap)
{
	// Uncomment this to see banding
	//return 0.0;
	
	float d = textureLod(dithermap, gl_FragCoord.xy / 8.0, 0.0).r;
	d -= (31.5 / 255.0);
	d /= 16.0 - (1.0 / 128.0);
	return d;
}

#endif
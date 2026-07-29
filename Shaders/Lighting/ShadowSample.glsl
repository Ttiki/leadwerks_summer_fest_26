/*float shadowSample(in sampler2DShadow shadowmap, in vec3 shadowcoord, in int sampleindex)
{
#if SHADOWKERNELSIZE == 1
	return texture(shadowmap, shadowcoord);
#endif
#if SHADOWKERNELSIZE == 2
    float sz = 0.5 / float(textureSize(shadowmap, 0).x);
	
	float f = textureLod(shadowmap, shadowcoord + vec3(sz, sz, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz, sz, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz, -sz, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(sz, -sz, 0.0), 0.0);
	return f * 0.25f;
#endif
#if SHADOWKERNELSIZE == 3
    float sz = 1.0 / float(textureSize(shadowmap, 0).x);
	
	float f = texture(shadowmap, shadowcoord + 	vec3(sz, 	sz,		0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(-sz, 	sz, 	0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(sz, 	-sz, 	0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(-sz, 	-sz, 	0.0));
	//if (f == 0.0 || f == 4.0f) return f * 0.25f;// if all corners are the same we can probably quit here
	f += texture(shadowmap, shadowcoord + 		vec3(sz, 	0.0, 	0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(-sz, 	0.0, 	0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(0.0,	sz, 	0.0));
	f += texture(shadowmap, shadowcoord);
	f += texture(shadowmap, shadowcoord + 		vec3(0.0,	-sz, 	0.0));
	return f * 0.1111111;
#endif
#if SHADOWKERNELSIZE == 4
    float sz = 1.0 / float(textureSize(shadowmap, 0).x);

	float f = textureLod(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 1.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 1.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 1.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 1.5, 0.0), 0.0);

	f += textureLod(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 0.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 0.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 0.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 0.5, 0.0), 0.0);

	f += textureLod(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 0.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 0.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 0.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 0.5, 0.0), 0.0);

	f += textureLod(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 1.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 1.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 1.5, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 1.5, 0.0), 0.0);

	return f * 0.0625;
#endif
#if SHADOWKERNELSIZE == 5
    float f = texture(shadowmap, shadowcoord + vec3(-2.0 * sz, -2.0 * sz, 0.0));

    f += texture(shadowmap, shadowcoord + vec3(-1.0 * sz, -2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(0.0, -2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(1.0 * sz, -2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(2.0 * sz, -2.0 * sz, 0.0));

    f += texture(shadowmap, shadowcoord + vec3(-2.0 * sz, -1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(-1.0 * sz, -1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(0.0, -1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(1.0 * sz, -1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(2.0 * sz, -1.0 * sz, 0.0));

    f += texture(shadowmap, shadowcoord + vec3(-2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(-1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(0.0, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(2.0 * sz, 0.0, 0.0));

    f += texture(shadowmap, shadowcoord + vec3(-2.0 * sz, 1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(-1.0 * sz, 1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(0.0, 1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(1.0 * sz, 1.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(2.0 * sz, 1.0 * sz, 0.0));

    f += texture(shadowmap, shadowcoord + vec3(-2.0 * sz, 2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(-1.0 * sz, 2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(0.0, 2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(1.0 * sz, 2.0 * sz, 0.0));
    f += texture(shadowmap, shadowcoord + vec3(2.0 * sz, 2.0 * sz, 0.0));

    return f * 0.04;
#endif
}*/

float shadowSample(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord, in int sampleindex)
{
#if SHADOWKERNELSIZE == 1
	return texture(shadowmap, shadowcoord);
#endif
#if SHADOWKERNELSIZE == 2
	float sz = 0.5 / float(textureSize(shadowmap, 0).x);

	float f = texture(shadowmap, shadowcoord + vec4(sz, sz, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz, sz, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0));
	return f * 0.25f;
#endif
#if SHADOWKERNELSIZE == 3
    /*{
	float sz = 1.0 / float(textureSize(shadowmap, 0).x);
	float f = texture(shadowmap, shadowcoord);
	f += texture(shadowmap, shadowcoord + 	vec4(sz, 	sz,		0.0, 0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec4(-sz, 	sz, 	0.0, 0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec4(sz, 	-sz, 	0.0, 0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec4(-sz, 	-sz, 	0.0, 0.0));// * 0.7071f;
	//if (f == 0.0 || f == 4.0f) return f * 0.25f;// if all corners are the same we can probably quit here
	f += texture(shadowmap, shadowcoord + 		vec4(sz, 	0.0, 	0.0, 0.0));
	f += texture(shadowmap, shadowcoord + 		vec4(-sz, 	0.0, 	0.0, 0.0));
	f += texture(shadowmap, shadowcoord + 		vec4(0.0,	sz, 	0.0, 0.0));
	f += texture(shadowmap, shadowcoord + 		vec4(0.0,	-sz, 	0.0, 0.0));
	return f * 0.1111111;
	}*/
	
	/*
	float sz = 1.0 / float(textureSize(shadowmap, 0).x);
	vec2 offsets[9] = vec2[](
		vec2(-sz,  sz),
		vec2( 0.0,  sz),
		vec2( sz,  sz),
		vec2(-sz,  0.0),
		vec2( 0.0,  0.0),
		vec2( sz,  0.0),
		vec2(-sz, -sz),
		vec2( 0.0, -sz),
		vec2( sz, -sz)
	);

	// Corresponding weights for a simple kernel (can be adjusted)
	float weights[9] = float[](
		1.0, 2.0, 1.0,
		2.0, 4.0, 2.0,
		1.0, 2.0, 1.0
	);

	float totalWeight = 16.0; // sum of weights

	float shadowSum = 0.0;
	float weightSum = 0.0;
	vec4 offsetCoord;
	float w,s;
	
	for (int i = 0; i < 9; ++i) {
		offsetCoord = shadowcoord;
		offsetCoord.xy += offsets[i].xy;
		s = texture(shadowmap, offsetCoord).r;
		w = weights[i];
		shadowSum += s * w;
		weightSum += w;
	}

	return shadowSum / totalWeight;
	*/
	
	const float sz = 1.0 / float(textureSize(shadowmap, 0).x);
	
	// Corresponding weights
	const float w0 = 1.0;
	const float w1 = 2.0;
	const float w2 = 1.0;
	const float w3 = 2.0;
	const float w4 = 4.0;
	const float w5 = 2.0;
	const float w6 = 1.0;
	const float w7 = 2.0;
	const float w8 = 1.0;

	float s0 = texture(shadowmap, shadowcoord + vec4(-sz,  sz, 0.0, 0.0)).r;
	float s1 = texture(shadowmap, shadowcoord + vec4(0.0,  sz, 0.0, 0.0)).r;
	float s2 = texture(shadowmap, shadowcoord + vec4(sz,  sz, 0.0, 0.0)).r;
	float s3 = texture(shadowmap, shadowcoord + vec4(-sz,  0.0, 0.0, 0.0)).r;
	float s4 = texture(shadowmap, shadowcoord + vec4(0.0,  0.0, 0.0, 0.0)).r;
	float s5 = texture(shadowmap, shadowcoord + vec4(sz,  0.0, 0.0, 0.0)).r;
	float s6 = texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0)).r;
	float s7 = texture(shadowmap, shadowcoord + vec4(0.0, -sz, 0.0, 0.0)).r;
	float s8 = texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0)).r;

	float shadowSum = s0 * w0 + s1 * w1 + s2 * w2 + s3 * w3 + s4 * w4 + s5 * w5 + s6 * w6 + s7 * w7 + s8 * w8;
	return shadowSum / 16.0;
	
#endif
#if SHADOWKERNELSIZE == 4
    float sz = 1.0 / float(textureSize(shadowmap, 0).x);

	float f = texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 1.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 1.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 1.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 1.5, 0.0, 0.0));

	f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 0.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 0.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 0.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 0.5, 0.0, 0.0));

	f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 0.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 0.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 0.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 0.5, 0.0, 0.0));

	f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 1.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 1.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 1.5, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 1.5, 0.0, 0.0));

	return f * 0.0625;
#endif
#if SHADOWKERNELSIZE == 5
    float sz = 1.0 / float(textureSize(shadowmap, 0).x);

    float f = texture(shadowmap, shadowcoord + vec4(-2.0 * sz, -2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(-1.0 * sz, -2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(0.0, -2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(1.0 * sz, -2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(2.0 * sz, -2.0 * sz, 0.0, 0.0));

    f += texture(shadowmap, shadowcoord + vec4(-2.0 * sz, -1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(-1.0 * sz, -1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(0.0, -1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(1.0 * sz, -1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(2.0 * sz, -1.0 * sz, 0.0, 0.0));

    f += texture(shadowmap, shadowcoord + vec4(-2.0 * sz, 0.0, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(-1.0 * sz, 0.0, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(0.0, 0.0, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(1.0 * sz, 0.0, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(2.0 * sz, 0.0, 0.0, 0.0));

    f += texture(shadowmap, shadowcoord + vec4(-2.0 * sz, 1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(-1.0 * sz, 1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(0.0, 1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(1.0 * sz, 1.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(2.0 * sz, 1.0 * sz, 0.0, 0.0));

    f += texture(shadowmap, shadowcoord + vec4(-2.0 * sz, 2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(-1.0 * sz, 2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(0.0, 2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(1.0 * sz, 2.0 * sz, 0.0, 0.0));
    f += texture(shadowmap, shadowcoord + vec4(2.0 * sz, 2.0 * sz, 0.0, 0.0));

    return f * 0.04;
#endif
}
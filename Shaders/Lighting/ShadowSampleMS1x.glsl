float shadowSample(in sampler2DShadow shadowmap, in vec3 shadowcoord, in int sampleindex)
{
    float sz = 1.0 / float(textureSize(shadowmap, 0).x);
#if SHADOWKERNELSIZE == 1
	return texture(shadowmap, shadowcoord);
#endif
#if SHADOWKERNELSIZE == 2
	float f = textureLod(shadowmap, shadowcoord + vec3(sz, sz, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz, sz, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(-sz, -sz, 0.0), 0.0);
	f += textureLod(shadowmap, shadowcoord + vec3(sz, -sz, 0.0), 0.0);
	return f * 0.25f;
#endif
#if SHADOWKERNELSIZE == 3
	float f = texture(shadowmap, shadowcoord + 	vec3(sz, 	sz,		0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec3(-sz, 	sz, 	0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec3(sz, 	-sz, 	0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec3(-sz, 	-sz, 	0.0));// * 0.7071f;
	//if (f == 0.0 || f == 4.0f) return f * 0.25f;// if all corners are the same we can probably quit here
	f += texture(shadowmap, shadowcoord + 		vec3(sz, 	0.0, 	0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(-sz, 	0.0, 	0.0));
	f += texture(shadowmap, shadowcoord + 		vec3(0.0,	sz, 	0.0));
	f += texture(shadowmap, shadowcoord);
	f += texture(shadowmap, shadowcoord + 		vec3(0.0,	-sz, 	0.0));
	return f * 0.1111111;
#endif
#if SHADOWKERNELSIZE == 4
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
}

float shadowSample(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord, in int sampleindex)
{
    float sz = 1.0 / float(textureSize(shadowmap, 0).x);
#if SHADOWKERNELSIZE == 1
	return texture(shadowmap, shadowcoord);
#endif
#if SHADOWKERNELSIZE == 2
	float f = texture(shadowmap, shadowcoord + vec4(sz, sz, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz, sz, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
	f += texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0));
	return f * 0.25f;
#endif
#if SHADOWKERNELSIZE == 3
	float f = texture(shadowmap, shadowcoord + 	vec4(sz, 	sz,		0.0, 0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec4(-sz, 	sz, 	0.0, 0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec4(sz, 	-sz, 	0.0, 0.0));// * 0.7071f;
	f += texture(shadowmap, shadowcoord + 		vec4(-sz, 	-sz, 	0.0, 0.0));// * 0.7071f;
	//if (f == 0.0 || f == 4.0f) return f * 0.25f;// if all corners are the same we can probably quit here
	f += texture(shadowmap, shadowcoord + 		vec4(sz, 	0.0, 	0.0, 0.0));
	f += texture(shadowmap, shadowcoord + 		vec4(-sz, 	0.0, 	0.0, 0.0));
	f += texture(shadowmap, shadowcoord + 		vec4(0.0,	sz, 	0.0, 0.0));
	f += texture(shadowmap, shadowcoord);
	f += texture(shadowmap, shadowcoord + 		vec4(0.0,	-sz, 	0.0, 0.0));
	return f * 0.1111111;
    //return f * 0.127740023f;
#endif
#if SHADOWKERNELSIZE == 4
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
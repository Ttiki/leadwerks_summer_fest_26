#if SHADOWKERNELSIZE == 1

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		return texture(shadowmap, shadowcoord);
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		return texture(shadowmap, shadowcoord);
	}

#endif

#if SHADOWKERNELSIZE == 2

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(sz, sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
		return f * 0.5f;
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(-sz, sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0));
		return f * 0.5f;
	}

#endif

#if SHADOWKERNELSIZE == 3
	
	const float w0 = 1.0;
	const float w1 = 2.0;
	const float w2 = 1.0;
	const float w3 = 2.0;
	const float w4 = 4.0 * 0.5;
	const float w5 = 2.0;
	const float w6 = 1.0;
	const float w7 = 2.0;
	const float w8 = 1.0;
	
	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float s4 = texture(shadowmap, shadowcoord);
		float s6 = texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
		float s8 = texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0));
		float s2 = texture(shadowmap, shadowcoord + vec4(sz, sz, 0.0, 0.0));
		float s0 = texture(shadowmap, shadowcoord + vec4(-sz, sz, 0.0, 0.0));
		return (s4 * w4 + s6 * w6 + s8 * w8 + s2 * w2 + s0 * w0) / (w4 + w6 + w8 + w2 + w0) * 0.75;
	}
	
	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float s4 = texture(shadowmap, shadowcoord);
		float s6 = texture(shadowmap, shadowcoord + vec4(0.0, -sz, 0.0, 0.0));
		float s1 = texture(shadowmap, shadowcoord + vec4(0.0, sz, 0.0, 0.0));
		float s3 = texture(shadowmap, shadowcoord + vec4(-sz, 0.0, 0.0, 0.0));
		float s5 = texture(shadowmap, shadowcoord + vec4(sz, 0.0, 0.0, 0.0));
		return (s4 * w4 + s6 * w6 + s1 * w1 + s3 * w3 + s5 * w5) / (w4 + w6 + w1 + w3 + w5) * 1.25;
	}
	
#endif

#if SHADOWKERNELSIZE == 4

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);

		float f = texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 1.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 1.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 1.5, 0.0, 0.0));

		//f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 0.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 0.5, 0.0, 0.0));

		f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 0.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 0.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 0.5, 0.0, 0.0));

		//f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 1.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 1.5, 0.0, 0.0));

		return f * 0.125;
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);

		//float f = texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 1.5, 0.0, 0.0));
		float f = texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 1.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 1.5, 0.0, 0.0));

		f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 0.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 0.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 0.5, 0.0, 0.0));

		//f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 0.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 0.5, 0.0, 0.0));

		f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 1.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 1.5, 0.0, 0.0));
		//f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 1.5, 0.0, 0.0));

		return f * 0.125;
	}

#endif

/*float shadowSample(in sampler2DShadow shadowmap, in vec3 shadowcoord, in int sampleindex)	
{
	switch (sampleindex)
	{
	case 0:
		return shadowSample0(shadowmap, shadowcoord);
		break;
	case 1:
		return shadowSample1(shadowmap, shadowcoord);
		break;
	}
	return 0.0;
}*/

float shadowSample(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord, in int sampleindex)	
{
	switch (sampleindex)
	{
	case 0:
		return shadowSample0(shadowmap, shadowcoord);
		break;
	case 1:
		return shadowSample1(shadowmap, shadowcoord);
		break;
	}
	return 0.0;
}
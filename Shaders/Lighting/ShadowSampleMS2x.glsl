#if SHADOWKERNELSIZE == 1

	float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		return texture(shadowmap, shadowcoord);
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		return texture(shadowmap, shadowcoord);
	}

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

	float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		float f = textureLod(shadowmap, shadowcoord + vec3(sz, sz, 0.0), 0.0);
		f += textureLod(shadowmap, shadowcoord + vec3(-sz, -sz, 0.0), 0.0);
		return f * 0.5f;
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		float f = textureLod(shadowmap, shadowcoord + vec3(-sz, sz, 0.0), 0.0);
		f += textureLod(shadowmap, shadowcoord + vec3(sz, -sz, 0.0), 0.0);
		return f * 0.5f;
	}

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

	float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec3(-sz, -sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz, -sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz, sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz, sz, 0.0));
		return f * 0.2;
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec3(0.0, -sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(0.0, sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz, 0.0, 0.0));
		return f * 0.2;
	}

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz, sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz, sz, 0.0, 0.0));
		return f * 0.2;
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec4(0.0, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(0.0, sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz, 0.0, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz, 0.0, 0.0, 0.0));
		return f * 0.2;
	}

#endif

#if SHADOWKERNELSIZE == 4

float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);

		float f = texture(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 1.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 1.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 1.5, 0.0));

		//f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 0.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 0.5, 0.0));

		f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 0.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 0.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 0.5, 0.0));

		//f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 1.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 1.5, 0.0));

		return f * 0.125;
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);

		//float f = texture(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 1.5, 0.0));
		float f = texture(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 1.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 1.5, 0.0));

		f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 0.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 0.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 0.5, 0.0));

		//f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 0.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 0.5, 0.0));

		f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 1.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 1.5, 0.0));
		//f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 1.5, 0.0));

		return f * 0.125;
	}

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

float shadowSample(in sampler2DShadow shadowmap, in vec3 shadowcoord, in int sampleindex)	
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
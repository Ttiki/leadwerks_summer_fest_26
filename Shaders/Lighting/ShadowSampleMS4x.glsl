#if SHADOWKERNELSIZE == 1

	float shadowSample(in sampler2DShadow shadowmap, in vec3 shadowcoord, in int sampleindex)
	{
		return texture(shadowmap, shadowcoord);
	}
	
	float shadowSample(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord, in int sampleindex)
	{
		return texture(shadowmap, shadowcoord);
	}

#endif

#if SHADOWKERNELSIZE == 2

	float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec3(sz, sz, 0.0));
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec3(-sz, sz, 0.0));
	}

	float shadowSample2(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec3(sz, -sz, 0.0));
	}

	float shadowSample3(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec3(-sz, -sz, 0.0));
	}

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec4(sz, sz, 0.0, 0.0));
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec4(-sz, sz, 0.0, 0.0));
	}

	float shadowSample2(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec4(sz, -sz, 0.0, 0.0));
	}

	float shadowSample3(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.5 / float(textureSize(shadowmap, 0).x);
		return texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
	}

#endif

#if SHADOWKERNELSIZE == 3

	float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec3(-sz, 0, 0.0));
		f += texture(shadowmap, shadowcoord + vec3( sz, 0, 0.0));
		return f * 0.33333333;
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec3(0.0, -sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(0.0,  sz, 0.0));
		return f * 0.33333333;
	}

	float shadowSample2(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec3(-sz, -sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3( sz,  sz, 0.0));
		return f * 0.33333333;
	}

	float shadowSample3(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec3(-sz,  sz, 0.0));
		f += texture(shadowmap, shadowcoord + vec3( sz, -sz, 0.0));
		return f * 0.33333333;
	}

	/*float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec4(-sz, 0, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4( sz, 0, 0.0, 0.0));
		return f * 0.33333333;
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec4(0.0, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(0.0,  sz, 0.0, 0.0));
		return f * 0.33333333;
	}

	float shadowSample2(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4( sz,  sz, 0.0, 0.0));
		return f * 0.33333333;
	}

	float shadowSample3(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord);
		f += texture(shadowmap, shadowcoord + vec4(-sz,  sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4( sz, -sz, 0.0, 0.0));
		return f * 0.33333333;
	}*/

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.88888 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(-sz, 0, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4( sz, 0, 0.0, 0.0));
		return f * 0.5;
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.88888 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(0.0, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(0.0,  sz, 0.0, 0.0));
		return f * 0.5;
	}

	float shadowSample2(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.88888 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(-sz, -sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4( sz,  sz, 0.0, 0.0));
		return f * 0.5;
	}

	float shadowSample3(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 0.88888 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(-sz,  sz, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4( sz, -sz, 0.0, 0.0));
		return f * 0.5;
	}

#endif

#if SHADOWKERNELSIZE == 4

	float shadowSample0(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, -sz * 1.5, 0.0));
		return f * 0.25;
	}

	float shadowSample1(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 1.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(-sz * 0.5, sz * 1.5, 0.0));
		return f * 0.25;
	}

	float shadowSample2(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, -sz * 1.5, 0.0));
		return f * 0.25;
	}

	float shadowSample3(in sampler2DShadow shadowmap, in vec3 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 1.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 1.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 0.5, 0.0));
		f += texture(shadowmap, shadowcoord + vec3(sz * 0.5, sz * 1.5, 0.0));
		return f * 0.25;
	}

	float shadowSample0(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, -sz * 1.5, 0.0, 0.0));
		return f * 0.25;
	}

	float shadowSample1(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 1.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(-sz * 0.5, sz * 1.5, 0.0, 0.0));
		return f * 0.25;
	}

	float shadowSample2(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, -sz * 1.5, 0.0, 0.0));
		return f * 0.25;
	}

	float shadowSample3(in sampler2DArrayShadow shadowmap, in vec4 shadowcoord)
	{
		float sz = 1.0 / float(textureSize(shadowmap, 0).x);
		float f = texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 1.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 1.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 0.5, 0.0, 0.0));
		f += texture(shadowmap, shadowcoord + vec4(sz * 0.5, sz * 1.5, 0.0, 0.0));
		return f * 0.25;
	}

#endif

#if SHADOWKERNELSIZE > 1

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
	case 2:
		return shadowSample2(shadowmap, shadowcoord);
		break;
	case 3:
		return shadowSample3(shadowmap, shadowcoord);
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
	case 2:
		return shadowSample2(shadowmap, shadowcoord);
		break;
	case 3:
		return shadowSample3(shadowmap, shadowcoord);
		break;		
	}
	return 0.0;
}

#endif
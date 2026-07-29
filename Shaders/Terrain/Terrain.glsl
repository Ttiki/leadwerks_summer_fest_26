float TerrainHeight(in sampler2D heightmap, in vec3 position)
{
	vec2 texcoords = (position.xz / TerrainSize) + 0.5;
	texcoords.x += 0.5 / float(TerrainResolution.x);
	texcoords.y += 0.5 / float(TerrainResolution.y);
	return textureLod(heightmap, texcoords, 0.0).r;
}

vec2 TerrainBlend(in sampler2D heightmap, in vec3 position, in vec3 normal, in vec3 blendparameters)
{
	vec2 blend;
	blend.y = 0.0;
	float alpha = 1.0;
	float h = TerrainHeight(heightmap, position);
	float deltay = position.y - h;
	if (blendparameters.x > 0.0)
	{
		alpha = 1.0 - (deltay / blendparameters.x);
		alpha = clamp(alpha, 0.0, 1.0);
	}
	alpha = mix(alpha, alpha * max(normal.y, 0.0), blendparameters.y);
	if (deltay < blendparameters.z)
	{
		blend.y = 1.0 - max(deltay / blendparameters.z, 0.0);
		alpha = max(alpha, blend.y);		
	}
	blend.x = clamp(alpha, 0.0, 1.0);
	return blend;
}

// The strange logic in this shader is necessary to prevent texture discontinuities on some cards
void clipmapSample(in vec3 position, out vec3 albedo, out vec3 normal, out vec3 pbr)
{
	vec2 texcoords = (position.xz / TerrainSize) + 0.5;

	float clipdistance;
	vec3 cliptexcoords;
	vec3 c = vec3(0.0);
	
	float useclipmap = 0.0;
	float dontuseclipmap = 1.0;
	
	for (int n = 0; n < CountClipmaps; ++n)
	{
		clipdistance = length(position.xyz - CameraPosition);
		clipdistance = max(clipdistance, length(position.xz - ClipmapDrawPosition[n]));
		cliptexcoords.xy = texcoords.xy;
		cliptexcoords.z = n;
		cliptexcoords.xy = (cliptexcoords.xy - 0.5) * (TerrainSize / ClipmapArea[n]) + 0.5;
		cliptexcoords.xy += vec2(-ClipmapDrawPosition[n].x, -ClipmapDrawPosition[n].y) / (ClipmapArea[n]);
		if (clipdistance < ClipmapArea[n].x * 0.5)
		{
			useclipmap = 1.0;
			dontuseclipmap = 0.0;
			c[n % 3] = 1.0;
			break;
		}
	}
	albedo = vec3(0.0);
	normal = vec3(0.0);
	pbr = vec3(0.0);
	if (useclipmap > 0.0)
	{
		albedo += texture(ColorClipmap, cliptexcoords).rgb * useclipmap;
		normal += (texture(NormalClipmap, cliptexcoords).rgb * 2.0 - 1.0) * useclipmap;		
		pbr += texture(PBRClipmap, cliptexcoords).rgb * useclipmap;
	}
	{
		albedo += texture(BaseColorClipmap, texcoords.xy).rgb * dontuseclipmap;		
		normal += (texture(BaseNormalClipmap, texcoords.xy).rgb * 2.0 - 1.0) * dontuseclipmap;		
		pbr += texture(BasePBRClipmap, texcoords.xy).rgb * dontuseclipmap;
	}
	normal = normalize(normal);
}

void clipmapSample(in vec3 position, out float displacement)
{
	vec2 texcoords = (position.xz / TerrainSize) + 0.5;

	float clipdistance;
	vec3 cliptexcoords;
	vec3 c = vec3(0.0);
	
	bool useclipmap = false;
	for (int n = 0; n < CountClipmaps; ++n)
	{
		clipdistance = length(position.xyz - CameraPosition);
		clipdistance = max(clipdistance, length(position.xz - ClipmapDrawPosition[n]));
		if (clipdistance < ClipmapArea[n].x * 0.5)
		{
			cliptexcoords.xy = texcoords.xy;
			cliptexcoords.z = n;
			cliptexcoords.xy = (cliptexcoords.xy - 0.5) * (TerrainSize / ClipmapArea[n]) + 0.5;
			cliptexcoords.xy += vec2(-ClipmapDrawPosition[n].x, -ClipmapDrawPosition[n].y) / (ClipmapArea[n]);
			useclipmap = true;
			c[n % 3] = 1.0;
			break;
		}
	}
	if (useclipmap)
	{
		displacement = texture(DisplacementClipmap, cliptexcoords).r;
	}
	else
	{
		displacement = texture(BaseDisplacementClipmap, texcoords.xy).r;
	}
}

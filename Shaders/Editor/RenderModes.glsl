uniform vec4 ColorShadedMin = vec4(0.0, 0.45, 0.45, 1.0);
uniform vec4 ColorShadedMax = vec4(0.0, 0.75, 0.75, 1.0);

float SimpleShading(in vec3 normal)
{
	float d = dot(normal, normalize(vec3(-0.75, -1.25, 1.0)));
	if (d > 0.0) d *= 0.75;
	return abs(d) * 0.5 + 0.65;
}

vec3 RenderModeColor(in uint rendermode, in vec3 albedo, in vec3 normal)
{
	vec3 c;
	switch (rendermode)
	{
	case RENDERMODE_TEXTURED:
		c = albedo * SimpleShading(normal);
		break;
	case RENDERMODE_COLORED:
		c.r = ColorShadedMin.r + random(vec2(EntityIndex, EntityIndex * EntityIndex)) * (ColorShadedMax.r - ColorShadedMin.r);
		c.g = ColorShadedMin.g + random(vec2(EntityIndex, EntityIndex / EntityIndex)) * (ColorShadedMax.g - ColorShadedMin.g);
		c.b = ColorShadedMin.b + random(vec2(EntityIndex, EntityIndex + EntityIndex)) * (ColorShadedMax.b - ColorShadedMin.b);
		break;
	case RENDERMODE_COLOREDSHADED:
		c.r = ColorShadedMin.r + random(vec2(EntityIndex, EntityIndex * EntityIndex)) * (ColorShadedMax.r - ColorShadedMin.r);
		c.g = ColorShadedMin.g + random(vec2(EntityIndex, EntityIndex / EntityIndex)) * (ColorShadedMax.g - ColorShadedMin.g);
		c.b = ColorShadedMin.b + random(vec2(EntityIndex, EntityIndex + EntityIndex)) * (ColorShadedMax.b - ColorShadedMin.b);
		c *= SimpleShading(normal);
		break;
	}
	return c;
}

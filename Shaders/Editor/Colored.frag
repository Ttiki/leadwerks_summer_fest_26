#version 450
#include "../Math/Math.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Entities.glsl"

uniform vec4 ColorShadedMin = vec4(0.0, 0.45, 0.45, 1.0);
uniform vec4 ColorShadedMax = vec4(0.0, 0.75, 0.75, 1.0);

in flat uint EntityIndex;
in flat uint EntityFlags;

out vec4 outcolor;

void main()
{
	outcolor.r = ColorShadedMin.r + random(vec2(EntityIndex, EntityIndex * EntityIndex)) * (ColorShadedMax.r - ColorShadedMin.r);
	outcolor.g = ColorShadedMin.g + random(vec2(EntityIndex, EntityIndex / EntityIndex)) * (ColorShadedMax.g - ColorShadedMin.g);
	outcolor.b = ColorShadedMin.b + random(vec2(EntityIndex, EntityIndex + EntityIndex)) * (ColorShadedMax.b - ColorShadedMin.b);
	outcolor.a = 1.0;
	
	if ((EntityFlags & ENTITYFLAGS_SELECTED) != 0) outcolor = SelectionColor;
}
#version 450
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Math/Math.glsl"
#include "../Common/Entities.glsl"
#include "../Editor/Grid.glsl"
#include "../Editor/PaintBrush.glsl"

float SimpleShading(in vec3 normal)
{
	float d = dot(normal, normalize(vec3(-0.75, -1.25, 1.0)));
	if (d > 0.0) d *= 0.75;
	return abs(d) * 0.5 + 0.65;
}

uniform vec4 ColorShadedMin = vec4(0.0, 0.45, 0.45, 1.0);
uniform vec4 ColorShadedMax = vec4(0.0, 0.75, 0.75, 1.0);

in flat uint EntityIndex;
in mat3 TBN;
in vec4 vertexWorldPosition;
in flat uint EntityFlags;

out vec4 outcolor;

void main()
{
	outcolor.r = ColorShadedMin.r + random(vec2(EntityIndex, EntityIndex * EntityIndex)) * (ColorShadedMax.r - ColorShadedMin.r);
	outcolor.g = ColorShadedMin.g + random(vec2(EntityIndex, EntityIndex / EntityIndex)) * (ColorShadedMax.g - ColorShadedMin.g);
	outcolor.b = ColorShadedMin.b + random(vec2(EntityIndex, EntityIndex + EntityIndex)) * (ColorShadedMax.b - ColorShadedMin.b);
	outcolor.a = 1.0;
	outcolor.rgb *= SimpleShading(TBN[2]);
	
	//------------------------------------------------------
    // Editor Display
    //------------------------------------------------------
    
	ShowGrid(outcolor, vertexWorldPosition.xyz, TBN[2], EntityFlags);
	ShowPaintBrush(outcolor, vertexWorldPosition.xyz);	
}
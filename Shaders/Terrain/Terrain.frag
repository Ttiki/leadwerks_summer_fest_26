#version 450

// Samplers
uniform layout(binding = 0) sampler2DArray ColorClipmap;
uniform layout(binding = 1) sampler2DArray NormalClipmap;
uniform layout(binding = 2) sampler2DArray PBRClipmap;
uniform layout(binding = 3) sampler2DArray DisplacementClipmap;
uniform layout(binding = 5) sampler2D TerrainNormalMap;
uniform layout(binding = 6) sampler2D BaseColorClipmap;
uniform layout(binding = 7) sampler2D BaseNormalClipmap;
uniform layout(binding = 8) sampler2D BasePBRClipmap;
uniform layout(binding = 9) sampler2D BaseDisplacementClipmap;
uniform layout(binding = 15) sampler2D Heightmap;

// Inputs
in vec4 TexCoords;
in vec4 Position;
int EntityIndex = 10;

// Includes
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Common/Constants.glsl"
#include "ClipmapSample.glsl"
#include "../Editor/RenderModes.glsl"

// Outputs
out layout(location = 0) vec4 fragColor;
out layout(location = 1) vec4 fragNormal;
out layout(location = 2) vec4 fragData;
out layout(location = 3) vec2 fragBlend;

void main()
{
	clipmapSample(Position.xyz, fragColor.rgb, fragNormal.rgb, fragData.rgb);
	
	if (RenderMode == 4) fragColor = vec4(0.5, 0.5, 0.5, 1.0);
	//fragColor.rgb = fragNormal.rgb;
	fragNormal.rgb = fragNormal.rgb * 0.5 + 0.5;	
	fragNormal.a = 0.0;
	fragBlend = vec2(0.0);
	
	//----------------------------------------------------------------
	// Display editor gizmo    
	//----------------------------------------------------------------

    if (TerrainToolRadius.x > 0.0)
    {
        const float thickness = 0.25;
        float d = length(Position.xyz - TerrainToolPosition);
        if (d < TerrainToolRadius.x)
        {
            if (d > TerrainToolRadius.x - thickness)
            {
                fragColor = vec4(1,1,1,1);
				fragData.r = 1.0;
            }
            else if (d < TerrainToolRadius.y && d > TerrainToolRadius.y - thickness)
            {
                fragColor = vec4(1,1,0.5,1);
				fragData.r = 1.0;
            }
        }
    }
	
	//----------------------------------------------------------------
	// Render modes   
	//----------------------------------------------------------------
	
	if (RenderMode == RENDERMODE_TEXTURED || RenderMode == RENDERMODE_COLORED || RenderMode == RENDERMODE_COLOREDSHADED) fragColor.rgb = RenderModeColor(RenderMode, fragColor.rgb, fragNormal.rgb);
	
	//fragColor = texture(TerrainNormalMap, TexCoords.xy);
}
// Inputs
in vec4 color;
in vec4 TexCoords;
in vec4 vertexWorldPosition;
flat in uint EntityFlags;
flat in uint EntityIndex;

// Includes
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Entities.glsl"
#include "../Common/Materials.glsl"
#include "../Common/DepthFunctions.glsl"
#include "../Editor/Grid.glsl"
#include "../Editor/RenderModes.glsl"

// Samplers
layout(binding = 0) uniform sampler2D texture0;

// Uniforms
uint materialID = MaterialIndex[0];

// Outputs
layout(location = 0) out vec4 Out_Albedo;
layout(location = 1) out vec4 Out_Normal;
layout(location = 2) out vec4 Out_PBR;

void main()
{    
	Material mtl;
	UnpackMaterial(uint(MaterialIndex[0]), mtl);
	
    vec4 basecolor = mtl.diffuseColor * color;

    Out_Albedo = basecolor;

    if ((EntityFlags & 2u) != 0u) Out_Albedo = SelectionColor;
    	
	Out_Normal = vec4(0.5,0.5,0.5, 0.0);
	
	Out_PBR = vec4(1.0, 1.0, 0.0, 1.0);
	
    // Base texture color
    if ((TextureFlags & 1u) != 0) Out_Albedo *= texture(texture0, TexCoords.xy, BaseTextureLodBias);
	
#ifdef ALPHAMASK
	if (Out_Albedo.a < mtl.alphacutoff) discard;
#endif

    //Camera distance fog
    //if ((entityflags & ENTITYFLAGS_NOFOG) == 0) ApplyDistanceFog(outColor.rgb, vertexWorldPosition.xyz, CameraPosition);
	
    //------------------------------------------------------
    // Render Mode
    //------------------------------------------------------
    
	if (RenderMode == RENDERMODE_TEXTURED || RenderMode == RENDERMODE_COLORED || RenderMode == RENDERMODE_COLOREDSHADED) Out_Albedo.rgb = RenderModeColor(RenderMode, Out_Albedo.rgb, Out_Normal.rgb);		
}
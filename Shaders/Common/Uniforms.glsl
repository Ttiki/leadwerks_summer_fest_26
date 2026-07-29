#ifndef _UNIFORMS
	#define _UNIFORMS
	
//------------------------------------------------
// Camera Settings
//------------------------------------------------

uniform mat4 CameraMatrix;
uniform mat3 CameraNormalMatrix;
uniform mat4 CameraProjectionMatrix;
uniform mat4 InverseCameraMatrix;
uniform mat3 InverseCameraNormalMatrix;
uniform mat4 InverseCameraProjectionMatrix;
uniform vec3 CameraPosition;
uniform vec2 CameraRange;
uniform float CameraZoom = 1.0;
uniform int CameraProjectionMode = 1;
uniform vec3 ViewPosition;

//------------------------------------------------
// Render Settings
//------------------------------------------------

uniform uvec4 MaterialIndex = uvec4(0);
uniform uint TextureFlags = 0;
uniform float TextureLodBias = 0.0;
uniform float BaseTextureLodBias = 0.0;
//uniform float AlphaCutoff = 0.0;
uniform vec4 SelectionColor = vec4(243.0f / 255.0f, 151.0f / 255.0f, 46.0f / 255.0f, 1.0f);
uniform float DisplayScale = 1.0;
uniform vec3 AmbientLight = vec3(0.0);
uniform float IBLIntensity = 1.0;
uniform vec3 SkyColor = vec3(1.0);
uniform vec4 BackgroundColor = vec4(0.0);
uniform uint BlendMode = 0;
uniform uint RenderFlags = 0;
uniform float RenderTween = 1.0;
uniform ivec4 DrawViewport;
vec2 BufferSize = vec2(DrawViewport.z, DrawViewport.w);
uniform int ToneMappingMode = -1;
uniform float CameraTessellation = 0.0;
uniform int RenderMode;
uniform vec3 SunDirection = vec3(-0.577, -0.577, 0.577);
uniform vec4 SunColor = vec4(0.0);
uniform float SkyIntensity = 1.0;
uniform ivec2 MaterialSlots = ivec2(0, 1);
uniform int MSAASamples = 0;

//------------------------------------------------
// Terrain
//------------------------------------------------

uniform vec2 TerrainSize;
uniform vec3 TerrainScale;
uniform ivec2 TerrainResolution;
uniform vec2 TerrainToolRadius;
uniform vec3 TerrainToolPosition;
uniform vec2 ClipmapDrawPosition[8];
uniform vec2 ClipmapArea[8];
uniform float CameraClipmapDistance[8];
uniform int CountClipmaps = 1;

//------------------------------------------------
// Fog Settings
//------------------------------------------------

uniform vec4 FogColor = vec4(0.0);
uniform vec2 FogRange = vec2(0.0);
uniform vec2 FogAngles = vec2(0.0, 15.0);
uniform float FogDensity = 0.0;

//------------------------------------------------
// Miscellaenous
//------------------------------------------------

uniform uint CurrentTime = 0;
uniform int PassIndex = 0;

#endif
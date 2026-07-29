#version 450
//#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
//#extension GL_ARB_bindless_texture : enable

//#include "../Base/Fragment.glsl"
#include "../Utilities/PackSelectionState.glsl"
#include "../Utilities/DepthFunctions.glsl"
#include "../Base/Materials.glsl"

in vec4 color;
in vec4 vertexWorldPosition;


layout(location = 0) out vec4 Out_Albedo;
layout(location = 1) out vec4 Out_Normal;
layout(location = 2) out vec4 Out_PBR;


uniform int MajorGridLines = 8;
uniform int MinorGridLines = 1;
uniform vec2 CameraRange = vec2(0.1, 1000);
uniform float CameraZoom;
uniform vec3 CameraPosition;
uniform ivec4 DrawViewport;
uniform uint materialID = 0;
vec2 BufferSize = vec2(DrawViewport.x, DrawViewport.w);

float filterWidth2(vec2 uv)
{
     vec2 dx = dFdx(uv), dy = dFdy(uv);
    return dot(dx, dx) + dot(dy, dy) + .0001;
}

// still not happy with how it fades out too soon,
// but at least it's basically working.  Better than the others.
float gridSmooth(vec2 p, in float gridThickness)
{
    vec2 q = p;
    q += .5;
    q -= floor(q);
    q = (gridThickness + 1.) * .5 - abs(q - .5);
    float w = 12.*filterWidth2(p);
    float s = sqrt(gridThickness);
    return smoothstep(.5-w*s,.5+w, max(q.x, q.y));
}

//https://www.shadertoy.com/view/wl3Sz2
float gridAASimple(vec2 p, in float gridThickness)
{
    vec2 f = fract(p);
    float g = min(min(f.x, 1.-f.x), min(f.y, 1.-f.y)) * 2. - gridThickness
    , x = step(g, 0.) //gridUnfiltered(p)
    , w = fwidth(p.x) + fwidth(p.y)
    , r = 20.* float(BufferSize.y)
    , l = r*abs(g) / (1. + 1.*r*w) // can try different functions, divisor controls fade rate with distance
    // up close, should blend toward 0.5, but
    // far away should blend toward gridThickness, maybe sqrt'd?
    , s = sqrt(gridThickness) //gridThickness*gridThickness //gridThickness //
    , t = mix(.5, s, min(w, 1.));
    return mix(t, x, clamp(l, 0., 1.));
}

//https://www.shadertoy.com/view/wl3Sz2
float gridAAOrigin(vec2 p, in float gridThickness)
{
    const float tolerance = 0.5f;

    vec2 f = fract(p);

    if (abs(p.x) > tolerance) f.x = 0.5f;
    if (abs(p.y) > tolerance) f.y = 0.5f;
    if (f.x == 0.5f && f.y == 0.5f) return 0.0f;

    float g = min(min(f.x, 1.-f.x), min(f.y, 1.-f.y)) * 2. - gridThickness
    , x = step(g, 0.) //gridUnfiltered(p)
    , w = fwidth(p.x) + fwidth(p.y)
    , r = 20.* float(BufferSize.y)
    , l = r*abs(g) / (1. + 1.*r*w) // can try different functions, divisor controls fade rate with distance
    // up close, should blend toward 0.5, but
    // far away should blend toward gridThickness, maybe sqrt'd?
    , s = sqrt(gridThickness) //gridThickness*gridThickness //gridThickness //
    , t = mix(.5, s, min(w, 1.));
    return mix(t, x, clamp(l, 0., 1.));
}

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{
    //Material material = materials[ MaterialIndex[0] ];
    
    //------------------------------------------------------
    // Albedo
    //------------------------------------------------------
    
    Out_Albedo = vec4(0,1,0,1);
	
    //------------------------------------------------------
    // Normals / Pixel flags
    //------------------------------------------------------
	
    Out_Normal = vec4(0.5,0.5,0.5,0.0);
    
    //------------------------------------------------------
    // Occlusion / Roughness / Metalness / Emission
    //------------------------------------------------------
    
    Out_PBR = vec4(1.0, 1.0, 0.0, 1.0);
}
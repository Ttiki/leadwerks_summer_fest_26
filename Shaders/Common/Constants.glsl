#ifndef _CONSTANTS
    #define _CONSTANTS
	
    //----------------------------------------------------------
    // Render Flags
    //----------------------------------------------------------

    #define RENDERFLAGS_DEPTHMASK 1
    #define RENDERFLAGS_WIREFRAME 2
    #define RENDERFLAGS_FINALPASS 4
	#define RENDERFLAGS_MESHSKINNING 8
	#define RENDERFLAGS_EXTRACTNORMALZ 16
	#define RENDERFLAGS_TRANSPARENCY 2048
    #define RENDERFLAGS_RENDERTOTEXTURE 4096
	
    //----------------------------------------------------------
    // Render Modes
    //----------------------------------------------------------

    #define RENDERMODE_COLORED 0u
    #define RENDERMODE_COLOREDSHADED 1u
    #define RENDERMODE_TEXTURED 2u
    #define RENDERMODE_TEXTUREDLIGHTING 3u
    #define RENDERMODE_LIGHTING 4u
	
    //----------------------------------------------------------
    // Blend Modes
    //----------------------------------------------------------

	#define BLEND_SOLID 0
	#define BLEND_ALPHA 1
	#define BLEND_MASK 2
	
    //----------------------------------------------------------
    // Texture Slots
    //----------------------------------------------------------

    #define TEXTURE_0 1u
    #define TEXTURE_1 2u
    #define TEXTURE_2 4u
    #define TEXTURE_3 8u
    #define TEXTURE_4 16u
    #define TEXTURE_5 32u
    #define TEXTURE_6 64u
    #define TEXTURE_7 128u
    #define TEXTURE_8 256u
    #define TEXTURE_9 512u
    #define TEXTURE_10 1024u
    #define TEXTURE_11 2048u
    #define TEXTURE_12 4096u
    #define TEXTURE_13 8192u
    #define TEXTURE_14 16384u
    #define TEXTURE_15 32768u
    
    #define TEXTURE_BASE 0
    #define TEXTURE_ALBEDO 0
    #define TEXTURE_DIFFUSE 0
    #define TEXTURE_NORMAL 1
    #define TEXTURE_METALLICROUGHNESS 2
    #define TEXTURE_DISPLACEMENT 3
    #define TEXTURE_EMISSION 4
    #define TEXTURE_OPACITY 5

    //----------------------------------------------------------
    // GBuffer Flags
    //----------------------------------------------------------

    #define PIXELFLAGS_TWOSIDED 1u
    #define PIXELFLAGS_BACKFACING 2u

    //----------------------------------------------------------
    // Transparency Buffer Flags
    //----------------------------------------------------------

    #define TRANSPARENCY_SIMPLEREFRACTION 1
    #define TRANSPARENCY_SSR 2
    #define TRANSPARENCY_SOFTEDGES 4
	#define TRANSPARENCY_DRAW 8

    //----------------------------------------------------------
	// Texture Slots
    //----------------------------------------------------------

	#define TEXTURE_0 1u
	#define TEXTURE_1 2u
	#define TEXTURE_2 4u
	#define TEXTURE_3 8u
	#define TEXTURE_4 16u
	#define TEXTURE_5 32u
	#define TEXTURE_6 64u
	#define TEXTURE_7 128u
	#define TEXTURE_8 256u
	#define TEXTURE_9 512u
	#define TEXTURE_10 1024u
	#define TEXTURE_11 2048u
	#define TEXTURE_12 4096u
	#define TEXTURE_13 8192u
	#define TEXTURE_14 16384u
	#define TEXTURE_15 32768u

#endif

#version 450
#extension GL_ARB_shader_draw_parameters : enable
#extension GL_GOOGLE_include_directive : enable
//#extension GL_EXT_multiview : enable

#define WRITE_COLOR
#define TESSELLATION
#define TEXTURE_ANIMATION
#define VERTEX_SKINNING

#include "../Base/base_vert.glsl"
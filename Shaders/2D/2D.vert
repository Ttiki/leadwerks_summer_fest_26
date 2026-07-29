#version 450
#include "../Common/Vertex.glsl"

// Inputs
uniform mat4 matrix;
uniform vec4 clipregion = vec4(0);

// Outputs
out vec4 color;
flat out vec3 emissioncolor;
out vec2 TexCoords;

void main()
{ 
    int flip = 0;
    if ((RenderFlags & RENDERFLAGS_RENDERTOTEXTURE) != 0) flip = 1;
    
    vec2 BufferSize = vec2(float(DrawViewport.z), float(DrawViewport.w));
    vec2 pixeloffset = vec2(0.5f, -0.5f);

    vec4 pos = vec4(VertexPosition, 1.0);
    
    if (flip == 1) pixeloffset.y *= 1.0f;

    mat4 m = matrix;
    m[0][3] = 0.0f; m[1][3] = 0.0f; m[2][3] = 0.0f; m[3][3] = 1.0f;

    color.r = matrix[0][3];
    color.g = matrix[1][3];
    color.b = matrix[2][3];
    color.a = matrix[3][3];
	
    pos = m * pos;

    pos.xy += pixeloffset;
    
    if (flip == 1) pos.y = BufferSize.y + 1.0f - pos.y;

    pos.y -= BufferSize.y;

    pos.xy /= BufferSize;

	mat4 orthomatrix = mat4(0.0f);
	orthomatrix[0][0] = 2.0f;
	orthomatrix[1][1] = 2.0f;
	orthomatrix[2][2] = -1.0f;
	orthomatrix[3][0] = -1.0f;
	orthomatrix[3][1] = -1.0f;
	orthomatrix[3][3] = 1.0f;
	orthomatrix[1] *= -1.0f;

    TexCoords = VertexTexCoords.xy;

    gl_Position = orthomatrix * pos;

    vec2 clippos = (m * vec4(VertexPosition, 1.0)).xy;

    gl_ClipDistance[0] = (clippos.x - clipregion.x) / BufferSize.x;
    gl_ClipDistance[1] = (clippos.y - clipregion.y) / BufferSize.y;
    gl_ClipDistance[2] = -(clippos.x - (clipregion.x + clipregion.z)) / BufferSize.x;
    gl_ClipDistance[3] = -(clippos.y - (clipregion.y + clipregion.w)) / BufferSize.y;
}
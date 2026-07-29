#version 450
#include "../Common/Vertex.glsl"

out vec2 TexCoords;

void main()
{
	vec4 pos = vec4(VertexPosition, 1.0);
	
	TexCoords = VertexTexCoords;
	
	mat4 orthomatrix = mat4(0.0f);
	orthomatrix[0][0] = 2.0f;
	orthomatrix[1][1] = 2.0f;
	orthomatrix[2][2] = -1.0f;
	orthomatrix[3][0] = -1.0f;
	orthomatrix[3][1] = -1.0f;
	orthomatrix[3][3] = 1.0f;
	
	gl_Position = orthomatrix * pos;
}
#version 450

// Samplers
layout(binding = 0) uniform sampler2DMS ColorBuffer;

// Outputs
layout(location = 0) out vec4 Out_Color;

void main()
{
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec2 texcoord = vec2(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w));
    
}
#include "../Common/Uniforms.glsl"

void ApplyUserMeshEffect(in mat4 mat, inout vec3 position, inout vec3 normal, inout vec4 texcoords, inout vec4 color)
{
	if (color.a > 0.0)
	{
		float seed = CurrentTime * 0.0015;//mod(CurrentTime * 0.0015f, 360.0f);
		seed += mat[3].x * 33.0f + mat[3].y * 67.8f + mat[3].z * 123.5f;
		seed += position.x + position.y + position.z;
		position.xyz += normal * color.a * 0.05 * (sin(seed)+0.25 * cos(seed * 5.2 + 3.2 ));
		
		// Experimental version, only for trees...
		
		/*
		// Sway parameters
		float swayAmplitude = 0.001 * color.a; // adjust for sway range
		float swaySpeed = 0.0005; // adjust for sway speed
		float angle = swayAmplitude * (sin(CurrentTime * swaySpeed + position.x + position.z) + 0.5 * cos(CurrentTime * swaySpeed * 2.0 + position.x * position.z));
		
		// Create rotation matrix around Y axis
		float cosAngle = cos(angle);
		float sinAngle = sin(angle);
		mat4 swayRotation = mat4(
			vec4(cosAngle, 0.0, -sinAngle, 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(sinAngle, 0.0, cosAngle, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0)
		);
		
		// Apply rotation around origin
		vec4 pos4 = vec4(position, 1.0);
		pos4 = swayRotation * pos4;
		position = pos4.xyz;
		*/
	}
	color.a = 1.0;
}
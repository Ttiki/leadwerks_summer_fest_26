// Includes
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"
#include "../Common/Materials.glsl"
#include "../Lighting/Light.glsl"
#include "../Math/Math.glsl"

// Inputs
in mat3 TBN;
in vec4 TexCoords; 
in vec4 vertexWorldPosition;
flat in float CameraAngle;
in vec4 color;

// Samplers
uniform layout(binding = 0) sampler2DArray AlbedoMap;
uniform layout(binding = 1) sampler2DArray NormalMap;
uniform layout(binding = 2) sampler2DArray MetalRoughnessMap;

// Outputs
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragNormal;
layout(location = 2) out vec4 fragData;

void main()
{
	Material mtl;
	UnpackMaterial(uint(MaterialIndex[0]), mtl);

	//--------------------------------------------
	// Determine which face to use
	//--------------------------------------------
	
	float d = random(gl_FragCoord.xy);
	const int sides = 32;
	float w0, w1, m;
	float w = CameraAngle / 360.0f * float(sides);
	w0 = int(w);
	w1 = w0 + 1;
	w0 = mod(w0, float(sides));
	w1 = mod(w1, float(sides));
	m = mod(w, 1.0f);
	w = w1;
	if (d > m) w = w0;
	
	//--------------------------------------------
    // Albedo
	//--------------------------------------------
	
	bool hasbasecolortexture = (TextureFlags & TEXTURE_0) != 0;
	fragColor = color;
	if (hasbasecolortexture) fragColor = texture(AlbedoMap, vec3(TexCoords.xy, w));
	
#ifdef ALPHAMASK
	if (fragColor.a < mtl.alphacutoff) discard;
#else
	if (mtl.alphacutoff > 0.0 && hasbasecolortexture == true)
    {
        // https://bgolus.medium.com/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f
		float lod = textureQueryLod(AlbedoMap, TexCoords.xy).y;
		fragColor.a *= 1.0 + max(0.0, lod) * 0.25;// Sharpen alpha
		fragColor.a = (fragColor.a - mtl.alphacutoff) / max(fwidth(fragColor.a), 0.0001) + 0.5;        
    }
#endif
	
	//--------------------------------------------
    // Normal
	//--------------------------------------------
	
	fragNormal.rgb = TBN[2];
	fragNormal.a = 0.0;
	if ((TextureFlags & TEXTURE_1) != 0)
	{
		vec3 n = texture(NormalMap, vec3(TexCoords.xy, w)).rgb * 2.0 - 1.0;
		fragNormal.rgb = normalize(TBN * n);
	}
	fragNormal.rgb = fragNormal.rgb * 0.5 + 0.5;
	
    uint flags = 0;
    if (!gl_FrontFacing) flags |= PIXELFLAGS_BACKFACING;
    if ((mtl.flags & MATERIAL_TWOSIDED) != 0u) flags |= PIXELFLAGS_TWOSIDED;
    fragNormal.a = float(flags) / 3.0;
	
	//--------------------------------------------
    // Metal / roughness
	//--------------------------------------------
	
	fragData = vec4(0.0, 1.0, 0.0, 0.0);
	if ((TextureFlags & TEXTURE_2) != 0)
	{
		fragData.rgb = texture(MetalRoughnessMap, vec3(TexCoords.xy, w)).rgb;
	}
}
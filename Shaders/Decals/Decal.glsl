//------------------------------------------------------
// Includes
//------------------------------------------------------

#include "../Common/Materials.glsl"
#include "../Common/Constants.glsl"
#include "../Common/Uniforms.glsl"

//------------------------------------------------------
// Uniforms
//------------------------------------------------------

//uniform uint TextureFlags = 0;
//uniform float TextureLodBias = 0.0f;
//uniform uvec4 MaterialIndex = uvec4(0);
//uniform float AlphaCutoff = 0.0;
//uniform vec3 CameraPosition;
//uniform ivec4 DrawViewport;
//uniform vec2 CameraRange;
uniform mat4 InverseCameraProjectionViewMatrix;
uniform mat4 EntityMatrix;

//------------------------------------------------------
// Samplers
//------------------------------------------------------

#ifdef MSAASAMPLES
layout(binding = 0) uniform sampler2DMS DepthBuffer;
layout(binding = 1) uniform sampler2DMS NormalBuffer;
#else
layout(binding = 0) uniform sampler2D DepthBuffer;
layout(binding = 1) uniform sampler2D NormalBuffer;
#endif

layout(binding = 2) uniform sampler2D BaseColorTexture;
layout(binding = 3) uniform sampler2D NormalTexture;
layout(binding = 4) uniform sampler2D PBRTexture;
layout(binding = 5) uniform sampler2D DisplacementTexture;
layout(binding = 6) uniform sampler2D EmissionTexture;
layout(binding = 7) uniform sampler2D OpacityTexture;

//------------------------------------------------------
// Inputs
//------------------------------------------------------

in vec4 color;
in vec3 emissioncolor;
in mat3 NormalMatrix;
in mat3 InverseNormalMatrix;
in vec2 TexturePosition;
in vec2 TextureScale;

//------------------------------------------------------
// Outputs
//------------------------------------------------------

layout(location = 0) out vec4 Out_Albedo;
layout(location = 1) out vec4 Out_Normal;
layout(location = 2) out vec4 Out_PBR;

//------------------------------------------------------
// Functions
//------------------------------------------------------

vec3 ScreenCoordToWorldPosition(in vec3 position)
{
	vec4 coord = InverseCameraProjectionViewMatrix * vec4(position.xy * 2.0f - 1.0f, position.z * 2.0f - 1.0f, 1.0f);
	return coord.xyz / coord.w;
}

/*int getMajorAxis(in vec3 vn)
{
	vec3 v = abs(vn);
	return v.y > v.x ? ( v.z > v.y ? 2 : 1 ) : ( v.z > v.x ? 2 : 0 );
}*/

vec4 TrilinearTexture(in sampler2D tex, in vec3 position, in float bias, in int axis, in vec3 surfnormal)
{
	vec3 d3;
	d3[0] = dot(surfnormal, NormalMatrix[0].xyz);
	d3[1] = dot(surfnormal, NormalMatrix[1].xyz);
	d3[2] = dot(surfnormal, NormalMatrix[2].xyz);	
#if defined(TRILINEARMAPPING) || defined(BILINEARMAPPING)
	vec4 c = vec4(0.0);
	vec3 weights = vec3(0.0);

	// This approach prevents black lines from forming on edges
	weights[axis] = 1.0;
	
	vec2 tc = vec2(position.z + 0.5, 1.0 - (position.y + 0.5));	
	if (d3[0] < 0.0) tc.x = 1.0 - tc.x;
	tc *= TextureScale;
	c += texture(tex, tc, bias) * weights[0];
	
#ifdef TRILINEARMAPPING
	tc = vec2(position.x + 0.5, 1.0 - (position.z + 0.5));
	if (d3[1] < 0.0) tc.x = 1.0 - tc.x;
	tc *= TextureScale;
	c += texture(tex, tc, bias) * weights[1];
	
#endif
	
	tc = vec2(position.x + 0.5, 1.0 - (position.y + 0.5));	
	if (dot(surfnormal, NormalMatrix[2].xyz) > 0.0) tc.x = 1.0 - tc.x;	
	tc *= TextureScale;
	
	c += texture(tex, tc, bias) * weights[2];	
	
	return c;
#else
    vec2 tc = vec2(position.x + 0.5, 1.0 - (position.y + 0.5));
	if (d3[2] > 0.0) tc.x = 1.0 - tc.x;
    tc *= TextureScale;
    return texture(tex, tc, bias);
#endif
}

vec3 TrilinearNormal(in sampler2D tex, in vec3 position, in float bias, in int axis, in vec3 surfnormal)
{
	vec3 d3;
	d3[0] = dot(surfnormal, NormalMatrix[0].xyz);
	d3[1] = dot(surfnormal, NormalMatrix[1].xyz);
	d3[2] = dot(surfnormal, NormalMatrix[2].xyz);	
	vec3 nrm;
#if defined(TRILINEARMAPPING) || defined(BILINEARMAPPING)
	vec3 c = vec3(0.0);
	vec3 weights = vec3(0.0);

	// This approach prevents black lines from forming on edges
	weights[axis] = 1.0;
	
	vec2 tc = vec2(position.z + 0.5, 1.0 - (position.y + 0.5));	
	if (d3[0] < 0.0) tc.x = 1.0 - tc.x;
	tc *= TextureScale;
	//c += texture(tex, tc, bias).rgb * weights[0];
	
	nrm = texture(tex, tc, bias).rgb * 2.0 - 1.0;
	nrm.z = sqrt(max(0.0f, 1.0f - (nrm.x * nrm.x + nrm.y * nrm.y)));
	if (d3[0] < 0.0) nrm.xz *= -1.0;	
	nrm = NormalMatrix * nrm.zyx;	
	c += nrm * weights[0];
	
#ifdef TRILINEARMAPPING
	tc = vec2(position.x + 0.5, 1.0 - (position.z + 0.5));
	if (d3[1] < 0.0) tc.x = 1.0 - tc.x;
	tc *= TextureScale;
	//c += texture(tex, tc, bias).rgb * weights[1];
	
	nrm = texture(tex, tc, bias).rgb * 2.0 - 1.0;
	nrm.z = sqrt(max(0.0f, 1.0f - (nrm.x * nrm.x + nrm.y * nrm.y)));
	if (d3[1] < 0.0) nrm.xz *= -1.0;	
	nrm = NormalMatrix * nrm.xzy;
	c += nrm * weights[1];
	
#endif
	
	tc = vec2(position.x + 0.5, 1.0 - (position.y + 0.5));
	if (d3[2] > 0.0) tc.x = 1.0 - tc.x;
	tc *= TextureScale;
	
	nrm = texture(tex, tc, bias).rgb * 2.0 - 1.0;
	nrm.z = sqrt(max(0.0f, 1.0f - (nrm.x * nrm.x + nrm.y * nrm.y)));
	nrm.x *= -1.0;
	if (d3[2] < 0.0) nrm.xz *= -1.0;
	nrm = NormalMatrix * nrm;
	c += nrm * weights[2];
	
	return normalize(c);
#else
    vec2 tc = vec2(position.x + 0.5, 1.0 - (position.y + 0.5));
	if (d3[2] > 0.0) tc.x = 1.0 - tc.x;
    tc *= TextureScale;
	
    vec3 c = texture(tex, tc, bias).rgb * 2.0 - 1.0;
	c.z = sqrt(max(0.0f, 1.0f - (c.x * c.x + c.y * c.y)));
	c.x *= -1.0;
	if (d3[2] < 0.0) c.xz *= -1.0;
	c = NormalMatrix * c;
	return normalize(c);
#endif
}

//------------------------------------------------------
// Main Loop
//------------------------------------------------------

void main()
{
    Material material;
	UnpackMaterial(MaterialIndex[0], material);
	
    ivec2 coord = ivec2(gl_FragCoord.x, gl_FragCoord.y);
    vec3 screencoord = vec3(gl_FragCoord.x / float(DrawViewport.z), gl_FragCoord.y / float(DrawViewport.w), 0.0);
    screencoord.z =  texelFetch(DepthBuffer, coord, gl_SampleID).r;
    vec3 position = ScreenCoordToWorldPosition(screencoord);
    position = (EntityMatrix * vec4(position, 1.0)).xyz;
	
    // Early exit if out of volume
    if (abs(position.x) > 0.5 || abs(position.y) > 0.5 || abs(position.z) > 0.5)
    {
        Out_Albedo = vec4(0.0);
        Out_Normal = vec4(0.0);
        Out_PBR = vec4(0.0);
		discard;
    }
	
    vec2 texcoord;
	int axis;
    vec3 normal = normalize(texelFetch(NormalBuffer, coord, gl_SampleID).rgb * 2.0 - 1.0);    
#if defined(TRILINEARMAPPING) || defined(BILINEARMAPPING)
	axis = getMajorAxis(InverseNormalMatrix * normal);
#endif
    texcoord += 0.5;
    //texcoord.y *= -1.0;
	texcoord.y = 1.0 - texcoord.y;
	
    //------------------------------------------------------
    // Albedo
    //------------------------------------------------------
	
	float alpha = 0.0;
	Out_Albedo = material.diffuseColor * color;
	if ((TextureFlags & TEXTUREFLAGS_BASECOLOR) != 0)
    {
		Out_Albedo *= TrilinearTexture(BaseColorTexture, position, BaseTextureLodBias, axis, normal);
		Out_Albedo.rgb = mix(vec3((Out_Albedo.r + Out_Albedo.g + Out_Albedo.b) * 0.333333), Out_Albedo.rgb, material.saturation);
		
		// Alpha discard
		if (MSAASamples > 1)
		{
			if (material.alphacutoff > 0.0)
			{
				if (Out_Albedo.a < material.alphacutoff)
				{
					// https://bgolus.medium.com/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f
					//float lod = textureQueryLod(BaseColorTexture, TexCoords.xy).y;
					//fragColor.a *= 1.0 + max(0.0, lod) * 0.25;// Sharpen alpha
					//fragColor.a = (fragColor.a - material.alphacutoff) / max(fwidth(fragColor.a), 0.0001) + 0.5;
					Out_Albedo.a = 0.0;
				}
				else
				{
					Out_Albedo.a = 1.0;
				}
			}
		}
		else
		{
			if (material.alphacutoff > 0.0 && Out_Albedo.a < material.alphacutoff) discard;
		}
		
		alpha = Out_Albedo.a;		
	}
	
    //------------------------------------------------------
    // Opacity map discards color but allows normal and PBR blending
    //------------------------------------------------------
    
	if ((material.flags & MATERIAL_ALBEDOALPHA) != 0) Out_Albedo = vec4(0.0);
	
    //------------------------------------------------------
    // Normal
    //------------------------------------------------------
	
    if ((TextureFlags & TEXTUREFLAGS_NORMAL) != 0)
    {
	
        Out_Normal.xyz = TrilinearNormal(NormalTexture, position, TextureLodBias, axis, normal);
        //Out_Normal.xyz = NormalMatrix * Out_Normal.xyz;
		//Out_Normal.xy *= material.normalscale;
		//Out_Normal.z = -sqrt(max(0.0f, 1.0f - (Out_Normal.x * Out_Normal.x + Out_Normal.y * Out_Normal.y)));
        //Out_Normal.rgb = normalize(NormalMatrix * Out_Normal.rgb) * 0.5 + 0.5;
        Out_Normal.rgb = Out_Normal.rgb * 0.5 + 0.5;
		Out_Normal.a = alpha;
    }
    else
    {	
        Out_Normal.a = 0.0;
    }
	
    //------------------------------------------------------
    // Occlusion / Roughness / Metalness
    //------------------------------------------------------
    
    vec3 occlussionroughnessmetal = vec3(material.occlusion, material.roughness, material.metalness);
    if ((TextureFlags & TEXTUREFLAGS_METALLICROUGHNESS) != 0)
    {
        occlussionroughnessmetal *= TrilinearTexture(PBRTexture, position, TextureLodBias, axis, normal).rgb;
        occlussionroughnessmetal.r = mix(material.occlusion, occlussionroughnessmetal.r, 1.0);
		Out_PBR.rgb = occlussionroughnessmetal;
		Out_PBR.r = 0.0;
		Out_PBR.a = alpha;
    }
	else
	{
		Out_PBR = vec4(0.0);
	}
    
    //------------------------------------------------------
    // Emission
    //------------------------------------------------------
    
    if ((TextureFlags & TEXTUREFLAGS_EMISSION) != 0)
    {
		vec4 e = TrilinearTexture(EmissionTexture, position, TextureLodBias, axis, normal);
		e.rgb *= e.a;
        vec3 emissive = material.emissiveColor * emissioncolor * e.rgb;
        Out_PBR.r = max(max(emissive.r, emissive.g), emissive.b);
        if (Out_PBR.r > 0.0)
        {
            Out_PBR.r = min(1.0, Out_PBR.r);
            Out_Albedo.rgb = mix(Out_Albedo.rgb, emissive.rgb / Out_PBR.r, Out_PBR.r);			
			Out_Albedo.a = Out_PBR.r;
        }
    }
	
	if (RenderMode == RENDERMODE_LIGHTING) Out_Albedo.rgb = vec3(0.5);
	
	switch (BlendMode)
	{
	case BLEND_ALPHA:
		Out_Albedo.rgb *= Out_Albedo.a;
		Out_Normal.rgb *= Out_Normal.a;
		Out_PBR.rgb *= Out_PBR.a;
		break;
	}
}
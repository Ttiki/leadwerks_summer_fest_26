//#include "DrawElementsIndirectCommand.glsl"

#define MESHLAYER_ALIGN_CENTER 0
#define MESHLAYER_ALIGN_VERTEX 1
#define MESHLAYER_ALIGN_ROTATE 2

//Uniforms
uniform ivec2 resolution;
uniform vec2 spacing = vec2(2.0f);
uniform uint offset = 0;
uniform vec3 terrainscale = vec3(1.0f);
uniform int SublayerAlignment = 0;
uniform uint SublayerFlags = 0;
uniform vec3 SublayerTerrainBlending;
uniform int TerrainTessellation = 0;

//Samplers
uniform layout(binding = 14) sampler2D normalmap;
uniform layout(binding = 15) sampler2D elevationmap;

//layout(std430, binding = 8) buffer IndirectDrawBlock { DrawElementsIndirectCommand drawcommands[]; };
layout(std430, binding = 9) buffer DrawInstancesIDBlock { uint instanceids[]; };
layout(std430, binding = 11) buffer MeshLayerNoiseBlock { mat4 meshlayeroffsets[]; };

#include "../Common/Constants.glsl"
#include "../Common/Vertex.glsl"
#include "../Common/Materials.glsl"
#include "../Terrain/BicubicSample.glsl"

// Outputs
out vec4 vertexWorldPosition;
out vec4 vertexCameraPosition;
out vec4 TexCoords;
out vec3 emissioncolor;
out vec4 color;
out mat3 TBN;
flat out uint EntityFlags;
flat out uint EntityIndex;
out vec2 MaterialWeights;
out float Displacement;
out vec3 EntityTerrainBlending;
out float CameraAngle;

void main()
{
    color = VertexColor;
    
    vec4 p;
    p.xyz = VertexPosition.xyz;
    p.w = 1.0f;
	
	int id = int(instanceids[BaseInstance + gl_InstanceID]);

    int y = id / resolution.x;
    int x = id - resolution.x * y;

    int noiseid = (y % 16) * 16 + (x % 16);
    mat4 noise = meshlayeroffsets[noiseid];
	//noise = mat4(1.0);
	
    uint alignment = uint(SublayerAlignment);//drawcommands[/*gl_DrawID +*/ offset].alignment;

    vec2 texcoord = vec2(0.0f);
#ifdef WRITE_COLOR
    emissioncolor = vec3(1.0f);
#endif
#ifdef IMPOSTER

    vec3 center;
    center.xz = vec2(x, y) * spacing;

    center.xz -= textureSize(elevationmap, 0) * 0.5f;
    center.xz += noise[3].xz;  
    texcoord = center.xz / textureSize(elevationmap, 0);    
    center.y = textureLod(elevationmap, texcoord, 0).r;
	center.y += textureBicubic(elevationmap, texcoord).r;
	center.y *= 0.5;
	center.y *= terrainscale.y;
	
    mat4 mat = noise;
    mat[0][3] = 0.0f; mat[1][3] = 0.0f; mat[2][3] = 0.0f; mat[3][3] = 1.0f;
    mat[3].xyz = center;

	mat4 mm = mat;
	mm[3][1] = 0.0;
    vec4 relcampos = inverse(mm) * vec4(CameraPosition.x, 0.0, CameraPosition.z, 1.0f);
	//vec4 relcampos = inverse(mat) * vec4(CameraPosition, 1.0f);
    vec2 d = -relcampos.xz;

    CameraAngle = mod(degrees(atan(d.x, d.y)), 360.0f);
    
    mat3 rotationmat;
    d = normalize(d);
    rotationmat[2].xyz = vec3(d.x, 0, d.y);
    rotationmat[1].xyz = vec3(0.0f, 1.0f, 0.0f);
    rotationmat[0].xyz = cross(rotationmat[2].xyz, rotationmat[1].xyz);

    p.xyz = rotationmat * p.xyz;
    
#endif

    if (alignment == MESHLAYER_ALIGN_ROTATE || alignment == MESHLAYER_ALIGN_CENTER)
    {
        vec2 center = vec2(x, y) * spacing;
        center += noise[3].xz;
        ivec2 ts = textureSize(elevationmap, 0);
        vec2 fts = vec2(ts.x, ts.y);    
        texcoord = (center + 0.5f) / fts;
       
        if (alignment == MESHLAYER_ALIGN_ROTATE)
        {
            vec2 ntexcoord = texcoord;

            vec3 n;
            n.xz = textureLod(normalmap, ntexcoord, 0).rg * 2.0f - 1.0f;
            n.y = sqrt(max(0.0f, 1.0f - (n.x * n.x + n.z * n.z)));

            mat3 base;
            
            vec3 i, j, k;

            j = normalize(n);
            i = -normalize(cross(j, vec3(0,1,0)));
            k = normalize(cross(i, j));

            if (j.y > 0.5f)
            {
                //color = vec4(1,0,0,1);                
                float yaw = atan(n.x, n.z);
                float pitch = acos(n.y);
                vec4 q = RotationToQuat(pitch, yaw);
                float d = degrees(asin((j.y - 0.5f) * 2.0f)) / 90.0f;
                q = Slerp(q, vec4(0.0f, 0.0f, 0.0f, 1.0f), d);
                mat3 m = QuatToMat3(q);
                i = m[0];
                j = m[1];
                k = m[2];
            }
            
            base[0].xyz = i;
            base[1].xyz = j;
            base[2].xyz = k;

            base *= mat3(noise);
            noise[0].xyz = base[0];
            noise[1].xyz = base[1];
            noise[2].xyz = base[2];
        }
    }
	
    noise[0][3] = 0.0f; noise[1][3] = 0.0f; noise[2][3] = 0.0f; noise[3][3] = 1.0f;
    p = noise * p;

    if (alignment == MESHLAYER_ALIGN_VERTEX)
    {
        texcoord = (vec2(x, y) * spacing + p.xz + 0.5f) / textureSize(elevationmap, 0);

#ifndef DEPTHRENDER
        /*vec3 n;
        n.xz = textureLod(normalmap, texcoord, 0).rg * 2.0f - 1.0f;
        n.y = sqrt(max(0.0f, 1.0f - (n.x * n.x + n.z * n.z)));
        normal = n;*/
#endif
    }
	
    p.xz -= textureSize(elevationmap, 0) * 0.5f;
    p.xz += vec2(x, y) * spacing;
	
	float h = textureLod(elevationmap, texcoord, 0).r;
	if (TerrainTessellation == 1)
	{
		h += textureBicubic(elevationmap, texcoord).r;
		h *= 0.5;
	}
	h *= terrainscale.y;
    p.y += h;
	
    vertexWorldPosition = p;
    EntityFlags = SublayerFlags;
	EntityTerrainBlending = SublayerTerrainBlending;

#ifdef WRITE_COLOR
    
    TexCoords.xy = VertexTexCoords.xy;
	TexCoords.zw = VertexLightmapCoords.xy;
	
    //materialIndex[0] = drawcommands[gl_DrawID + offset].materialID;
    //materialIndex[1] = 0;
    //materialIndex[2] = 0;
    //materialIndex[3] = 0;

    //materialweights = vec4(1,0,0,0);

    #ifndef DEPTHRENDER
    
    //if (alignment != MESHLAYER_ALIGN_VERTEX)
    {
        //ExtractVertexNormalTangentBitangent(normal, tangent, bitangent);
        //mat3 nmat = mat3(noise);
        
		mat3 nmat = mat3(noise);
		
        TBN[0] = normalize(nmat * VertexTangent);
        TBN[1] = normalize(nmat * VertexBitangent);
        TBN[2] = normalize(nmat * VertexNormal);
    }

    #endif

#endif
	
	// User-defined mesh effect
#ifdef USERMESHEFFECT
	ApplyUserMeshEffect(noise, p.xyz, TBN[2], TexCoords, color);
#endif	
	
    gl_Position = CameraProjectionMatrix * p;
	//gl_Position = vec4(0.0);

#ifdef IMPOSTER

    TBN[0] = normalize(noise[0].xyz);
    TBN[1] = normalize(noise[1].xyz);
    TBN[2] = normalize(noise[2].xyz);

#endif

}
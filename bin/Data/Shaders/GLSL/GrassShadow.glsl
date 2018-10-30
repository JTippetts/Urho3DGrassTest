#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"

#ifdef VSM_SHADOW
    varying vec4 vTexCoord;
#else
    varying vec2 vTexCoord;
#endif
varying vec4 vWorldPos;
uniform vec4 cHeightData;  // terrain width, terrain height, spacing.x, spacing.y
uniform sampler2D sHeightMap1;
uniform sampler2D sCoverMap2;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);

	// Convert world coords to UV coords
	float tu=worldPos.x / cHeightData.z;
	float tv=worldPos.z / cHeightData.z;

	vec2 htuv=vec2((tu/cHeightData.x)+0.5, 1.0-((tv/cHeightData.y)+0.5));
	vec4 htt=textureLod(sHeightMap1, htuv, 0.0);
	vec4 cov=textureLod(sCoverMap2, htuv, 0.0);

	float vx=cov.r*2.0-1.0;
	float vz=cov.b*2.0-1.0;
	worldPos.x=worldPos.x+vx*cHeightData.w*0.5;
	worldPos.z=worldPos.z+vz*cHeightData.w*0.5;
	float htscale=cHeightData.w*255.0;
	float ht=htt.r*htscale + htt.g*cHeightData.w;

	float dx=worldPos.x - cCameraPos.x;
	float dz=worldPos.z - cCameraPos.z;
	float dist=sqrt(dx*dx+dz*dz);
	dist=(dist-30.0)/(0.7*30.0-30.0);
	dist=clamp(dist,0.0,1.0);
	dist=1.0;
	worldPos.y=worldPos.y*dist*cov.g + ht;

    gl_Position = GetClipPos(worldPos);
	vWorldPos = vec4(worldPos, GetDepth(gl_Position));
    #ifdef VSM_SHADOW
        vTexCoord = vec4(GetTexCoord(iTexCoord), gl_Position.z, gl_Position.w);
    #else
        vTexCoord = GetTexCoord(iTexCoord);
    #endif
}

void PS()
{
    float tu=vWorldPos.x / cHeightData.z;
	float tv=vWorldPos.z / cHeightData.z;
	//vec2 htuv=vec2(worldPos.x/(cHeightData.x)+0.5, 1.0-(worldPos.z/(cHeightData.y)+0.5));
	vec2 htuv=vec2((tu/cHeightData.x)+0.5, 1.0-((tv/cHeightData.y)+0.5));
	vec4 htt=texture2D(sHeightMap1, htuv);

	//htuv=vec2(floor(tu)/cHeightData.x+0.5, 1.0-(floor(tv)/cHeightData.y+0.5));
	vec4 cov=texture2D(sCoverMap2, htuv);
	float u=vTexCoord.x*0.25+floor(cov.a*4.0)*0.25;

    // Get material diffuse albedo
	vec4 diffInput = texture2D(sDiffMap, vec2(u,vTexCoord.y));

	//diffInput=cov;

	if (diffInput.a < 0.5) discard;

    #ifdef VSM_SHADOW
        float depth = vTexCoord.z / vTexCoord.w * 0.5 + 0.5;
        gl_FragColor = vec4(depth, depth * depth, 1.0, 1.0);
    #else
        gl_FragColor = vec4(1.0);
    #endif
}

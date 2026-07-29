#define EXT_MULT 130.0

const float timeScaling = 0.0001;
const float BubbleSpeed = 0.05;
const float foamSpeed = 1.0;
const float shorelineDepth = 1.0;
const float leadingEdgeFalloff = 1.0;// This already gets faded out if soft edges are enabled
const float foamSize = 16.0f;
const float BubbleScale = 4.0;

//vec2 waterTransparency = vec2(0.95,4.5); 
//vec2 _FoamRanges = vec2(.3, .45);

//vec3 horizontalExtinction = normalize(vec3(7.0,75.0,130.0)) * EXT_MULT;
//vec3 surfaceColor=vec3(0.078, 0.296, 0.245);
//vec3 depthColor=vec3(0.07f, 0.15f, 0.2f);

#define saturate(x) clamp(x,0.0,1.0)

vec4 calculateFoam(vec3 InPosW, float waterDepth, sampler2D foamMaskSampler, sampler2D foamBubbleSampler )
{
   vec4 resultColor = vec4(vec3(0.0f), 0.0f);
   vec2 InTex = InPosW.xz;
   /* Shoreline */
   float timeOffset = CurrentTime * timeScaling * foamSpeed;
   
   vec2 scaledprojectedUV = InPosW.xz * foamSize;
   float channelA = texture(foamMaskSampler, scaledprojectedUV - vec2(timeOffset, cos(InTex.x))).r;
   float channelB = texture(foamMaskSampler, scaledprojectedUV * 0.5 + vec2(sin(InTex.y), timeOffset)).b;

   float mask = (channelA + channelB) * 0.95;
   mask = pow(mask, 2);
   mask = clamp(mask, 0.0f, 1.0f);

   float shorelineDepth = shorelineDepth;

   float leading = 1.0f;
 
   if (waterDepth < shorelineDepth * leadingEdgeFalloff)
   {
      leading = waterDepth / (shorelineDepth * leadingEdgeFalloff);
      resultColor.a = leading;
      mask *= leading;
   }

   // Calculate linear falloff value
   float falloff = 1.0f - (waterDepth / shorelineDepth);

   // Color the foam, blend based on alpha
   float bubbleA = texture(foamBubbleSampler, (InTex - vec2(timeOffset, cos(InTex.x)) * BubbleSpeed) * BubbleScale).r;
   float bubbleB = texture(foamBubbleSampler, (InTex + vec2(sin(InTex.y), timeOffset) * BubbleSpeed) * BubbleScale).r;
   bubbleA = saturate(15.0*(bubbleA-0.8));
   bubbleB = saturate(15.0*(bubbleB-0.8));
   
   float foam_bubbles = (bubbleA + bubbleB) * 0.5;//saturate(5.0*(((bubbleA + bubbleB) * 0.95)-0.8));
   vec3 foamColor = vec3(foam_bubbles);//vec3(0.9);
   vec3 edge = foamColor.rgb * falloff;

   // Subtract mask value from foam gradient, then add the foam value to the final pixel color
   resultColor.rgb = clamp(edge - vec3(mask), 0.0, 1.0);
 
   //resultColor.rgb = vec3(foam_bubbles);
   return resultColor * 0.5;
}

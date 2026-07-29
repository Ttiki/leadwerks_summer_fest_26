//---------------------------------------------------------------
// Tone Mapping
//---------------------------------------------------------------

float sRGBToLinear(float rgb)
{
	bool cutoff = rgb < 0.04045;
    float higher = pow((rgb + (0.055))/(1.055), (2.4));
    float lower = rgb/(12.92);
    return mix(higher, lower, cutoff);
}

vec3 sRGBToLinear(vec3 rgb)
{
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  //return mix(pow((rgb + 0.055) * (1.0 / 1.055), vec3(2.4)),
  //           rgb * (1.0/12.92),
  //           lessThanEqual(rgb, vec3(0.04045)));

    bvec3 cutoff = lessThan(rgb, vec3(0.04045));
    vec3 higher = pow((rgb + vec3(0.055))/vec3(1.055), vec3(2.4));
    vec3 lower = rgb/vec3(12.92);
    return mix(higher, lower, cutoff);
}

vec4 sRGBToLinear(vec4 c)
{
	c.rgb = sRGBToLinear(c.rgb);
	return c;
}

vec3 linearTosRGB(vec3 rgb)
{
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  //return mix(1.055 * pow(rgb, vec3(1.0 / 2.4)) - 0.055,
  //           rgb * 12.92,
  //           lessThanEqual(rgb, vec3(0.0031308)));

    bvec3 cutoff = lessThan(rgb, vec3(0.0031308));
    vec3 higher = vec3(1.055)*pow(rgb, vec3(1.0/2.4)) - vec3(0.055);
    vec3 lower = rgb * vec3(12.92);
    return mix(higher, lower, cutoff);
}

float linearTosRGB(float rgb)
{
/*  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return mix(1.055 * pow(rgb, (1.0 / 2.4)) - 0.055,
             rgb * 12.92,
             rgb <= 0.0031308);*/
    
    bool cutoff = rgb <= 0.0031308;
    float higher = (1.055)*pow(rgb, (1.0/2.4)) - (0.055);
    float lower = rgb * (12.92);
    return mix(higher, lower, cutoff);
}
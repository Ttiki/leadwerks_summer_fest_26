uniform float WaveAngle = 0.0;
uniform float WaveSpeed = 1.0;

#define DRAG_MULT 0.38 // changes how much waves pull on the water
#define WATER_DEPTH 1.0 // how deep is the water
#define CAMERA_HEIGHT 2.5 // how high the camera should be
#define ITERATIONS_RAYMARCH 16 // waves iterations of raymarching
#define ITERATIONS_NORMAL 16 // waves iterations when calculating normals

// Calculates wave value and its derivative, 
// for the wave direction, position in space, wave frequency and time
vec2 wavedx(vec2 position, vec2 direction, float frequency, float timeshift) {
  float x = dot(direction, position) * frequency + timeshift;
  float wave = exp(sin(x) - 1.0);
  float dx = wave * cos(x);
  return vec2(wave, -dx);
}

// Calculates waves by summing octaves of various waves with various parameters
float getwaves(vec2 position, float fiterations, float speed) {
  float wavePhaseShift = length(position) * 0.1; // this is to avoid every octave having exactly the same phase everywhere
  float iter = 0.0; // this will help generating well distributed wave directions
  float frequency = 1.0; // frequency of the wave, this will change every iteration
  float timeMultiplier = WaveSpeed * speed * 2.0 / 1000.0; // time multiplier for the wave, this will change every iteration
  float weight = 1.0;// weight in final sum for the wave, this will change every iteration
  float sumOfValues = 0.0; // will store final sum of values
  float sumOfWeights = 0.0; // will store final sum of weights
  int iterations = int(ceil(fiterations));
  float lastweight = fiterations / float(iterations);

  for(int i=0; i < iterations; i++) {
    // generate some wave direction that looks kind of random
    vec2 p = vec2(sin(iter + WaveAngle), cos(iter + WaveAngle));
    
    // calculate wave data
    vec2 res = wavedx(position, p, frequency, float(CurrentTime) * timeMultiplier + wavePhaseShift);

    // shift position around according to wave drag and derivative of the wave
    position += p * res.y * weight * DRAG_MULT;

    if (i == iterations - 1) weight *= lastweight;

    // add the results to sums
    sumOfValues += res.x * weight;
    sumOfWeights += weight;

    // modify next octave ;
    //if (i > 2)// This prevents any distinct flow since there are three large opposing waves
    {
      weight = mix(weight, 0.0, 0.2);
      frequency *= 1.18;
      timeMultiplier *= 1.07;
    }

    // add some kind of random value to make next wave look random too
    iter += 1232.399963;
  }
  // calculate and return
  return sumOfValues / sumOfWeights;
}

// 3-in-1 waves is faster for normals
// Calculates waves by summing octaves of various waves with various parameters
vec3 getwaves(vec2 position0,vec2 position1, vec2 position2, float  fiterations, in float speed) {
  vec3 wavePhaseShift;
  wavePhaseShift[0] = length(position0) * 0.1; // this is to avoid every octave having exactly the same phase everywhere
  wavePhaseShift[1] = length(position1) * 0.1; // this is to avoid every octave having exactly the same phase everywhere
  wavePhaseShift[2] = length(position2) * 0.1; // this is to avoid every octave having exactly the same phase everywhere
  float iter = 0.0; // this will help generating well distributed wave directions
  float frequency = 1.0; // frequency of the wave, this will change every iteration
  float timeMultiplier = WaveSpeed * speed * 2.0 / 1000.0; // time multiplier for the wave, this will change every iteration
  float weight = 1.0;// weight in final sum for the wave, this will change every iteration
  vec3 sumOfValues = vec3(0.0); // will store final sum of values
  float sumOfWeights = 0.0; // will store final sum of weights
  int iterations = int(ceil(fiterations));
  float lastweight = fiterations / float(iterations);

  for(int i=0; i < iterations; i++) {
    // generate some wave direction that looks kind of random
    vec2 p = vec2(sin(iter + WaveAngle), cos(iter + WaveAngle));
    
    // calculate wave data
    float tm = float(CurrentTime) * timeMultiplier;
    vec2 res0 = wavedx(position0, p, frequency, tm + wavePhaseShift[0]);
    vec2 res1 = wavedx(position1, p, frequency, tm + wavePhaseShift[1]);
    vec2 res2 = wavedx(position2, p, frequency, tm + wavePhaseShift[2]);

    // shift position around according to wave drag and derivative of the wave
    position0 += p * res0.y * weight * DRAG_MULT;
    position1 += p * res1.y * weight * DRAG_MULT;
    position2 += p * res2.y * weight * DRAG_MULT;

    if (i == iterations - 1) weight *= lastweight;

    // add the results to sums
    sumOfValues[0] += res0.x * weight;
    sumOfValues[1] += res1.x * weight;
    sumOfValues[2] += res2.x * weight;
    sumOfWeights += weight;
  
    // modify next octave ;
    weight = mix(weight, 0.0, 0.2);
    frequency *= 1.18;
    timeMultiplier *= 1.07;

    // add some kind of random value to make next wave look random too
    iter += 1232.399963;
  }
  // calculate and return
  return sumOfValues / sumOfWeights;
}

/*
// Original function
// Calculate normal at point by calculating the height at the pos and 2 additional points very close to pos
vec3 waveNormal_(vec2 pos, float e, float depth, float iterations) {
  vec2 ex = vec2(e, 0);
  float H = getwaves(pos.xy, iterations) * depth;
  vec3 a = vec3(pos.x, H, pos.y);
  return normalize(
    cross(
      a - vec3(pos.x - e, getwaves(pos.xy - ex.xy, iterations) * depth, pos.y), 
      a - vec3(pos.x, getwaves(pos.xy + ex.yx, 3.0) * depth, pos.y + e)
    )
  );
}
*/

// 3-in-1 waves is faster
// Calculate normal at point by calculating the height at the pos and 2 additional points very close to pos
vec3 waveNormal(vec2 pos, float e, float depth, float iterations, in float speed, out float waveheight) {
  vec2 ex = vec2(e, 0);
  vec3 H = getwaves(pos.xy, pos.xy - ex.xy, pos.xy + ex.yx, iterations, speed) * depth;
  vec3 a = vec3(pos.x, H[0], pos.y);
  waveheight = H[0] / depth;
  return normalize(
    cross(
      a - vec3(pos.x - e, H[1], pos.y), 
      a - vec3(pos.x, H[2], pos.y + e)
    )
  );
}

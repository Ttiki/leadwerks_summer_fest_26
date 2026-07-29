#ifndef _OPTICALDENSITY
	#define _OPTICALDENSITY
	
float log10(float x)
{
    return log(x) / log(10.0);
}

// Inverse of the Beer-Lambert Law
float transmittance(float opticalDensity, float pathLength)
{
    // Assuming opticalDensity corresponds to referencePath
    float scaledOD = opticalDensity * (pathLength);
    return pow(10.0, -scaledOD);
}

#endif
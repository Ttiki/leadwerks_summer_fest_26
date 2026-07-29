#ifdef GL_AMD_shader_ballot
    #define VENDOR_AMD
#endif

#ifdef GL_INTEL_fragment_shader_ordering
    #define VENDOR_INTEL
#endif

#ifdef __GLSL_CG_DATA_TYPES
	#define VENDOR_NVIDIA
#endif
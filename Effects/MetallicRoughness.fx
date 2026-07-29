{
    "posteffect":
    {
        "subpasses":
        [
            {
                "samplers" : ["METALLICROUGHNESS"],
                "shader" : "Shaders/PostEffects/Albedo/Albedo.frag",
        		"multisampleshader" : "Shaders/PostEffects/Albedo/Albedo_MS.frag"
            }
        ]
    }
}
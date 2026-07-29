{
    "posteffect":
    {
        "subpasses":
        [
            {    
                "samplers": ["PREVPASS", "DEPTH", "NORMAL"],
                "shader": "Shaders/PostEffects/FXAA/FXAA.frag",
				"multisampleshader": "Shaders/PostEffects/FXAA/FXAA_MS.frag"
            }
        ]
    }
}
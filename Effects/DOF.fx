{
    "posteffect":
    {
        "textures":
        [
            {
                "size": [0.5, 0.5],
                "format": 122
            },
            {
                "size": [0.25, 0.25],
                "format": 122
            },
            {
                "size": [0.5, 0.5],
                "format": 9
            },
            {
                "size": [0.25, 0.25],
                "format": 9
            }			
        ],
        "subpasses":
        [
            {
                "colorattachments": [0, 2],
                "samplers": ["PREVPASS", "DEPTH"],
                "shader": "Shaders/PostEffects/DOF/BlurX.frag",
				"multisampleshader": "Shaders/PostEffects/DOF/BlurX_MS.frag"
            },
            {
                "colorattachments": [1, 3],
                "samplers": [0, 2],
                "shader": "Shaders/PostEffects/DOF/BlurY.frag"
            },
            {
                "samplers": [1, 3, "PREVPASS"],
                "shader": "Shaders/PostEffects/DOF/DOF.frag",
				"multisampleshader": "Shaders/PostEffects/DOF/DOF_MS.frag"
            }                   
        ]
    }
}
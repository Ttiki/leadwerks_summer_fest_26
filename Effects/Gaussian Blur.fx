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
            }
        ],
        "subpasses":
        [
            {
                "colorattachments": [0],
                "samplers": ["PREVPASS"],
                "shader": "Shaders/PostEffects/Gaussian Blur/BlurX.frag"
            },
            {
                "colorattachments": [1],
                "samplers": [0],
                "shader": "Shaders/PostEffects/Gaussian Blur/BlurY.frag"
            },
            {
                "samplers": [1, "PREVPASS"],
                "shader": "Shaders/PostEffects/Gaussian Blur/Gaussian Blur.frag"
            }                   
        ]
    }
}
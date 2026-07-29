{
    "posteffect":
    {
        "textures":
        [
        {
            "size": [1.0, 1.0],
            "format" : 9
        }
        ] ,
        "subpasses":
        [
            {
                "colorattachments": [0],
                "samplers" : ["DEPTH", "NORMAL", "PREVPASS"],
                "shader" : "Shaders/PostEffects/SSAO/SSAO.frag",
			          "multisampleshader" : "Shaders/PostEffects/SSAO/SSAO_MS.frag"
            },
            {
                "samplers" : ["PREVPASS", 0],
                "shader" :  "Shaders/PostEffects/SSAO/SSAOResolve.frag"
            }
        ]
    }
}
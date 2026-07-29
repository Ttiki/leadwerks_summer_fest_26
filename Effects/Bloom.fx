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
                "size": [0.125, 0.125],
                "format" : 122
            },
            {
                "size": [0.0625, 0.0625],
                "format" : 122
            },
            {
                "size": [0.03125, 0.03125],
                "format" : 122
            },
             {
                "size": [0.015625, 0.015625],
                "format" : 122
            },
            {
                "size": [0.03125, 0.03125],
                "format" : 122
            },
            {
                "size": [0.0625, 0.0625],
                "format" : 122
            },
            {
                "size": [0.125, 0.125],
                "format" : 122
            },
            {
                "size": [0.25, 0.25],
                "format": 122
            },
            {
                "size": [0.5, 0.5],
                "format": 122
            }
        ],
        "subpasses":
        [
            {
                "colorattachments": [0],
                "samplers": [ "PREVPASS", "DEPTH" ],
                "shader": "Shaders/PostEffects/Bloom/BloomPrefilter.frag",
				"multisampleshader": "Shaders/PostEffects/Bloom/BloomPrefilter_MS.frag"
            },
            {
                "colorattachments": [1],
                "samplers": [ 0 ],
                "shader": "Shaders/PostEffects/Bloom/BloomDownSample.frag"
            },
            {
                "colorattachments": [2] ,
                "samplers" : [ 1 ],
                "shader" : "Shaders/PostEffects/Bloom/BloomDownSample.frag"
            },
            {
                "colorattachments": [3],
                "samplers" : [2],
                "shader" : "Shaders/PostEffects/Bloom/BloomDownSample.frag"
            },
            {
                "colorattachments": [4],
                "samplers" : [3],
                "shader" : "Shaders/PostEffects/Bloom/BloomDownSample.frag"
            },
            {
                "colorattachments": [5],
                "samplers" : [4],
                "shader" : "Shaders/PostEffects/Bloom/BloomDownSample.frag"
            },
            {
                "colorattachments": [6],
                "samplers" : [4,5],
                "shader" : "Shaders/PostEffects/Bloom/BloomUpscaleCombine.frag"
            },
            {
                "colorattachments": [7],
                "samplers" : [4,6],
                "shader" : "Shaders/PostEffects/Bloom/BloomUpscaleCombine.frag"
            },
            {
                "colorattachments": [8],
                "samplers" : [3,7],
                "shader" : "Shaders/PostEffects/Bloom/BloomUpscaleCombine.frag"
            },
            {
                "colorattachments": [9],
                "samplers" : [2,8],
                "shader" : "Shaders/PostEffects/Bloom/BloomUpscaleCombine.frag"
            },
            {
                "colorattachments": [10],
                "samplers" : [1,9],
                "shader" : "Shaders/PostEffects/Bloom/BloomUpscaleCombine.frag"
            },
            {
                "samplers": ["PREVPASS", "DEPTH", 10],
                "shader": "Shaders/PostEffects/Bloom/BloomFinalPass.frag",
				"multisampleshader": "Shaders/PostEffects/Bloom/BloomFinalPass_MS.frag"
            }                      
        ]
    }
}
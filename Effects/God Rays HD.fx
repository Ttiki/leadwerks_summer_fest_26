{
    "posteffect":
    {
        "textures":
        [
            {
                "size": [1.0, 1.0],
                "format": 122
            }
        ],	
        "subpasses":
        [
            {    
                "samplers": ["PREVPASS", "DEPTH"],
				"colorattachments": [0],
                "shader": "Shaders/PostEffects/God Rays/God Rays.frag",
				"multisampleshader": "Shaders/PostEffects/God Rays/God Rays MS.frag"
            },
			{    
                "samplers": [ 0 ],
                "shader": "Shaders/PostEffects/God Rays/God Rays Resolve.frag"
            }			
        ]
    }
}
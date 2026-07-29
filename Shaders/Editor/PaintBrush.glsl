#ifndef _SHOWPAINTBRUSH
	#define _SHOWPAINTBRUSH

uniform vec4 PaintBrushPosition = vec4(0.0);
uniform vec4 PaintBrushColor = vec4(0,1,0,1);

void ShowPaintBrush(inout vec4 color, in vec3 position)
{
    //Display paint brush guide
    if (PaintBrushPosition.w > 0.0)
    {
        float d = length(position - PaintBrushPosition.xyz);
        if (d < PaintBrushPosition.w)
        {
            d /= PaintBrushPosition.w;
            d = (1.0f - d) * 0.25;
            if (d < 0.02) d = 1.0;
            color = mix(color,  PaintBrushColor, d);
        }
    }
}

#endif
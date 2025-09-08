#version 140
in  mediump vec2 var_texcoord0;
in  mediump vec4 var_color;
out mediump vec4 out_fragColor;

uniform lowp sampler2D texture_sampler;

uniform uniforms {
	uniform mediump vec4 g_row0;       // (m00, m01, tx, _)
uniform mediump vec4 g_row1;       // (m10, m11, ty, _)
uniform mediump vec4 gradient_stop0;  // premultiplied цвет в P0
uniform mediump vec4 gradient_stop1;  // premultiplied цвет в P1
uniform mediump vec4 gradient_pos;    // x = позиция P0, y = позиция P1
uniform mediump vec4 uv_rect;         // (центр.x, центр.y, w, h) в UV атласа
uniform mediump vec4 figma_size;      // (ширина, высота, _, _) в пикселях Figma
};


void main()
{
    // 1) Атласные UV → локальные 0..1 UV спрайта
    mediump vec2 centerUV = uv_rect.xy;
    mediump vec2 sizeUV   = uv_rect.zw;
    mediump vec2 uv_min   = centerUV - sizeUV * 0.5;
    mediump vec2 uv01     = (var_texcoord0 - uv_min) / sizeUV;
    uv01 = clamp(uv01, 0.0, 1.0);

    // 2) Локальные UV → пиксели Figma
    mediump vec2 uvPx = uv01 * figma_size.xy;

    // 3) Центрируем относительно середины спрайта
    mediump vec2 halfPx = figma_size.xy * 0.5;
    mediump vec2 posPx  = uvPx - halfPx;

    // 4) Дирекция градиента (первый столбец матрицы Figma) в пикселях
    mediump vec2 rawDirPx = vec2(
        g_row0.x * figma_size.x,
        g_row0.y * figma_size.y
    );
    mediump vec2 dir = normalize(rawDirPx);

    // 5) Проекция на ось градиента и нормализация по границам спрайта
    mediump float proj    = dot(posPx, dir);
    mediump float minP    = dot(-halfPx, dir);
    mediump float maxP    = dot( halfPx, dir);
    mediump float t       = clamp((proj - minP) / (maxP - minP), 0.0, 1.0);

    // 6) Смешиваем стопы и маскируем по альфе спрайта
    mediump vec4 color = mix(gradient_stop1, gradient_stop0, t);
    mediump float maskA = texture(texture_sampler, var_texcoord0).a;
    out_fragColor = color * maskA * var_color;
}


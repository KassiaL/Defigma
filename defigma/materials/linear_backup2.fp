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
    highp vec2 uvPx   = uv01 * figma_size.xy;
    highp vec2 halfPx = figma_size.xy * 0.5;

    // 3) Центрируем и ПЕРЕВОРАЧИВАЕМ Y (Figma: вниз, GL: вверх)
    highp vec2 posPx = vec2(uvPx.x - halfPx.x, -(uvPx.y - halfPx.y));

    // 4) Направление градиента — первый столбец матрицы. Тоже переворачиваем Y.
    highp vec2 rawDirPx = vec2(
        g_row0.x * figma_size.x,
       -g_row1.x * figma_size.y
    );
    highp vec2 dir = normalize(rawDirPx);

    // 5) Проекция точки и нормализация по настоящим границам (через 4 угла)
    highp vec2 c1 = vec2(-halfPx.x,  halfPx.y);  // после переворота Y
    highp vec2 c2 = vec2( halfPx.x,  halfPx.y);
    highp vec2 c3 = vec2(-halfPx.x, -halfPx.y);
    highp vec2 c4 = vec2( halfPx.x, -halfPx.y);

    highp float p1 = dot(c1, dir);
    highp float p2 = dot(c2, dir);
    highp float p3 = dot(c3, dir);
    highp float p4 = dot(c4, dir);

    highp float minP = min(min(p1, p2), min(p3, p4));
    highp float maxP = max(max(p1, p2), max(p3, p4));

    highp float proj = dot(posPx, dir);
    highp float t    = clamp((proj - minP) / (maxP - minP), 0.0, 1.0);

    // 6) Учитываем реальные позиции стопов из Figma
    highp float range = max(gradient_pos.y - gradient_pos.x, 1e-6);
    highp float t01   = clamp((t - gradient_pos.x) / range, 0.0, 1.0);

    // 7) Смешиваем в НЕинвертированном порядке
    mediump vec4 color = mix(gradient_stop0, gradient_stop1, t01);

    // 8) Маска альфой текстуры
    mediump float maskA = texture(texture_sampler, var_texcoord0).a;
    out_fragColor = color * maskA * var_color;
}


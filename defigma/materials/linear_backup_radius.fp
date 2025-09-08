#version 140
in  mediump vec2 var_texcoord0;
in  mediump vec4 var_color;
out mediump vec4 out_fragColor;

uniform uniforms {
	uniform mediump vec4 grad_data;  // premultiplied цвет в P0
uniform mediump vec4 gradient_stop0;  // premultiplied цвет в P0
uniform mediump vec4 gradient_stop1;  // premultiplied цвет в P1
uniform mediump vec4 uv_rect;         // (центр.x, центр.y, w, h) в UV атласа
};

mediump float calc_corner_alpha(vec2 center, vec2 vec_xy, float _r, float fade_width) {
        mediump float dist = distance(vec_xy, center);
        return (1.0 - smoothstep(_r - fade_width, _r + fade_width, dist));
    }

void main()
{
    // 1) Атласные UV → локальные 0..1 UV спрайта
    mediump vec2 centerUV = uv_rect.xy;
    mediump vec2 sizeUV   = uv_rect.zw;
    mediump vec2 uv_min   = centerUV - sizeUV * 0.5;
    mediump vec2 uv01     = (var_texcoord0 - uv_min) / sizeUV;
    uv01 = clamp(uv01, 0.0, 1.0);

    mediump float _r = grad_data.y;
	mediump float width = grad_data.z;
	mediump float height = grad_data.w;
	mediump float x = uv01.x * width;
	mediump float y = uv01.y * height;

	mediump float corner_alpha = 1.0;
	mediump vec2 vec_xy = vec2(x, y);
	mediump float fade_width = max(0.3 * _r, 2.0);
	
	if (x < _r && y < _r)
{
if ((x - _r) * (x - _r) + (y - _r) * (y - _r) > _r * _r)
  corner_alpha = calc_corner_alpha(vec2(_r, _r), vec_xy, _r, fade_width);
}

if (x < _r && y > (height - _r))
                {
                    if ((x - _r) * (x - _r) + (y - (height - _r)) * (y - (height - _r)) > _r * _r)
                        corner_alpha = calc_corner_alpha(vec2(width - _r, _r), vec_xy, _r, fade_width);
                }
 
                                 
                if (x > (width - _r) && y < _r)
                {
                    if ((x - (width - _r)) * (x - (width - _r)) + (y - _r) * (y - _r) > _r * _r)
                        corner_alpha = calc_corner_alpha(vec2(_r, height - _r), vec_xy, _r, fade_width);
                }
 
                                 
                if (x > (width - _r) && y > (height - _r))
                {
                    if ((x - (width - _r)) * (x - (width - _r)) + (y - (height - _r)) * (y - (height - _r)) > _r * _r)
                        corner_alpha = calc_corner_alpha(vec2(width - _r, height - _r), vec_xy, _r, fade_width);
                }
    
    // 2) Рассчет направления градиента
    mediump float rad = grad_data.x;
    mediump vec2 dir = vec2(cos(rad), sin(rad));
    
    // 3) Нормализованная проекция на направление
    mediump vec2 centered = uv01 - vec2(0.5);
    mediump float t = dot(centered, dir);
    
    // 4) Автоматическая нормализация в [0, 1]
    mediump float max_t = 0.5 * (abs(dir.x) + abs(dir.y));
    mediump float t_normalized = clamp((t + max_t) / (2.0 * max_t), 0.0, 1.0);

    mediump vec4 color = mix(gradient_stop0, gradient_stop1, t_normalized);
    // out_fragColor = (color * var_color) * corner_alpha;
	out_fragColor = vec4(1.0, 1.0, 1.0, 1.0) * corner_alpha;
}
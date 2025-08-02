#version 140
in  mediump vec2 var_texcoord0;
in  mediump vec4 var_color;

in  mediump vec2 v_normalizedPos;

out mediump vec4 out_fragColor;
uniform lowp sampler2D texture_sampler;

uniform uniforms {
	uniform mediump vec4 grad_data;
uniform mediump vec4 gradient_stop0;
uniform mediump vec4 gradient_stop1;
};

void main()
{
    // mediump float rad = grad_data.x;
    // mediump vec2 dir = vec2(cos(rad), sin(rad));
    
    // mediump vec2 centered = v_normalizedPos - vec2(0.5);
    // mediump float t = dot(centered, dir);
    
    // mediump float max_t = 0.5 * (abs(dir.x) + abs(dir.y));
    // mediump float t_normalized = clamp((t + max_t) / (2.0 * max_t), 0.0, 1.0);

    // mediump vec4 color = mix(gradient_stop0, gradient_stop1, t_normalized);
	// color.xyz *= color.w;
	// mediump float maskA = texture(texture_sampler, var_texcoord0).a;
    // out_fragColor = color * var_color * maskA;
	mediump vec2 start = grad_data.xy; // Стартовая точка
    mediump vec2 end = grad_data.zw;   // Конечная точка
    
    // Вычисляем вектор направления и его длину
    mediump vec2 dir_vec = end - start;
    mediump float length_dir = length(dir_vec);
    
    mediump vec4 color;
    if (length_dir < 0.0001) {
        // Защита от нулевой длины - используем стартовый цвет
        color = gradient_stop0;
    } else {
        mediump vec2 dir = normalize(dir_vec);
        mediump vec2 rel = v_normalizedPos - start;  // Вектор от старта к текущей точке
        
        // Проекция вектора rel на направление градиента
        mediump float t = dot(rel, dir);
        
        // Нормализация проекции на отрезок [0, 1]
        mediump float t_normalized = clamp(t / length_dir, 0.0, 1.0);
        
        // Интерполяция цвета с автоматическим переходом в крайние цвета за пределами
        color = mix(gradient_stop0, gradient_stop1, t_normalized);
    }
    
    // Умножение на альфа-канал (premultiplied alpha)
    color.xyz *= color.w;
    
    // Учет маски и цвета вершины
    mediump float maskA = texture(texture_sampler, var_texcoord0).a;
    out_fragColor = color * var_color * maskA;
}
shader_type canvas_item;

uniform float radius = 0.5;  // 圆的半径
uniform float smoothness = 0.01;  // 边缘平滑度

void fragment() {
    // 计算UV坐标相对于中心点(0.5, 0.5)的位置
    vec2 uv = UV - 0.5;

    // 计算到中心的距离
    float dist = length(uv);

    // 创建圆形，使用smoothstep实现平滑边缘
    float circle = 1.0 - smoothstep(radius - smoothness, radius + smoothness, dist);

    // 计算角度（atan2返回-PI到PI的值）
    float angle = atan(uv.y, uv.x);

    // 创建黑白分界，不使用平滑过渡
    float division = step(0.0, angle);

    // 组合圆形和黑白分界
    vec3 color = mix(vec3(0.0), vec3(1.0), division);

    // 应用透明度控制
    COLOR = vec4(color, circle);
}
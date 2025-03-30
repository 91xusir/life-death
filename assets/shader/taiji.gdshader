shader_type canvas_item;

uniform float radius = 0.5;  // 太极图半径
uniform float smoothness = 0.01;  // 边缘平滑度
uniform float rotation_speed = 0.5;  // 旋转速度

void fragment() {
    // 计算UV坐标相对于中心点(0.5, 0.5)的位置
    vec2 uv = UV - 0.5;

    // 计算到中心的距离
    float dist = length(uv);

    // 创建圆形，使用smoothstep实现平滑边缘
    float circle = 1.0 - smoothstep(radius - smoothness, radius + smoothness, dist);

    // 计算旋转角度
    float time_rotation = TIME * rotation_speed;

    // 旋转UV坐标
    float s = sin(time_rotation);
    float c = cos(time_rotation);
    vec2 rotated_uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );

    // 计算角度（atan2返回-PI到PI的值）
    float angle = atan(rotated_uv.y, rotated_uv.x);

    // 创建黑白分界
    float division = step(0.0, angle);

    // 创建太极内部的两个小圆
    float inner_radius = radius * 0.5;
    float small_circle1 = 1.0 - smoothstep(inner_radius - smoothness, inner_radius + smoothness,
                                         length(rotated_uv - vec2(inner_radius, 0.0)));
    float small_circle2 = 1.0 - smoothstep(inner_radius - smoothness, inner_radius + smoothness,
                                         length(rotated_uv - vec2(-inner_radius, 0.0)));

    // 组合太极图案
    float taiji = division;
    taiji = mix(taiji, 0.0, small_circle1);  // 黑色部分中的白色小圆
    taiji = mix(taiji, 1.0, small_circle2);  // 白色部分中的黑色小圆

    // 组合颜色
    vec3 color = mix(vec3(0.0), vec3(1.0), taiji);

    // 应用圆形遮罩
    COLOR = vec4(color * circle, circle);
}
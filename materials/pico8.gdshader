shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D palette_texture : hint_default_black;
uniform int palette_size : hint_range(2, 64) = 16;
uniform float solid_modifier : hint_range(0.1, 1.0) = 0.6;
uniform float max_distance : hint_range(0.1, 1.0) = 0.6;
uniform float gamma : hint_range(0.0, 10.0) = 1.0;

vec3[2] find_closest_colors(vec3 target) {
    float min_distance = 1e10;
    vec3 closest_color_1 = vec3(0.0);
    vec3 closest_color_2 = vec3(0.0);

    for (int i = 0; i < palette_size; i++) {
        vec3 color_i = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;
        for (int j = i; j < palette_size; j++) {
            vec3 color_j = texelFetch(palette_texture, ivec2(j, 0), 0).rgb;
            if (distance(color_i, color_j) > max_distance) {
                continue;
            }

            vec3 mid_color = (color_i + color_j) * 0.5;
            float modifier = i == j ? solid_modifier : 1.0;
            float d = distance(target, mid_color) * modifier;

            if (d < min_distance) {
                min_distance = d;
                closest_color_1 = color_i;
                closest_color_2 = color_j;
            }
        }
    }

    return vec3[2](closest_color_1, closest_color_2);
}

float bayer_dither(vec2 position) {
    const mat4 bayer_matrix = mat4(
        vec4(0,  8,  2, 10),
        vec4(12, 4, 14,  6),
        vec4(3, 11,  1,  9),
        vec4(15, 7, 13,  5)
    ) / 16.0;

    ivec2 pos = ivec2(mod(position, 4.0));
    return bayer_matrix[pos.x][pos.y];
}

void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
    // Apply gamma correction
    c = pow(c, vec3(1.0 / gamma));

    vec3[2] result = find_closest_colors(c);
    vec3 color1 = result[0];
    vec3 color2 = result[1];
    float dither = bayer_dither(FRAGCOORD.xy);
    COLOR.rgb = (dither < 0.5) ? color1 : color2;
}
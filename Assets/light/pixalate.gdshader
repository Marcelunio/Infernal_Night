
shader_type canvas_item;

uniform float pixel_size = 4;

void fragment() {
    // Snap lighting and shadows to pixel grid.

	COLOR.rgb=vec3(SHADOW_VERTEX,0);
}
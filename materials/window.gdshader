shader_type spatial;
render_mode cull_front, unshaded;

uniform sampler2D paralax_texture : filter_linear_mipmap;
uniform float cylinder_radius = 10.0; // Distance to the "virtual" cylinder
uniform float vertical_scale = 1.0; // Scale the vertical mapping

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Calculate view direction in world space
	vec3 view_dir = normalize(world_position - CAMERA_POSITION_WORLD);
	
	// Convert to cylindrical coordinates
	// Horizontal angle (azimuth) - this becomes our U coordinate
	float u = atan(view_dir.x, view_dir.z) / (2.0 * PI) + 0.5;
	
	// Vertical mapping - you can choose one of these approaches:
	
	// Option 1: Direct Y mapping (simple)
	float v = view_dir.y * vertical_scale + 0.5;
	
	// Option 2: Vertical angle mapping (more perspective-correct)
	// float v = atan(view_dir.y, length(view_dir.xz)) / PI + 0.5;
	
	// Clamp V to avoid stretching at extreme angles
	v = clamp(v, 0.0, 1.0);
	
	vec2 uv = vec2(u, v);
	vec4 tx = textureLod(paralax_texture, uv, 0.0);
	
	ALBEDO = tx.rgb;
	// ALPHA = tx.a;
}
shader_type canvas_item;

void fragment() {
	float lines = step(0.96, fract(UV.y * 45.0 + TIME * 8.0));

	float noise = fract(
		sin(
			dot(
				floor(UV * vec2(180.0, 45.0)),
				vec2(12.9898, 78.233)
			)
		) * 43758.5453
	);

	float static_signal = lines * noise;

	COLOR = vec4(0.85, 0.85, 0.85, static_signal * 0.22);
}
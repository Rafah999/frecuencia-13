class_name F13Overlay
extends Control

# Capa atmosférica reutilizable para Frecuencia 13.
#
# Layer.AMBIENT   -> va DEBAJO de la interfaz: viñeta radial sutil,
#                    líneas de barrido fijas y una banda de interferencia
#                    breve y ocasional.
#
# Layer.INTERFERENCE -> va ENCIMA de toda la interfaz: de vez en cuando
#                    "rompe" la pantalla entera (desplazamiento de filas +
#                    aberración cromática + grano), afectando a todo.
#
# Nunca hay parpadeo constante: las interferencias son breves y espaciadas.
# No captura el ratón ni ejecuta procesos por frame.

enum Layer { AMBIENT, INTERFERENCE }

const VIGNETTE_CODE := """
shader_type canvas_item;
void fragment() {
	vec2 uv = UV - vec2(0.5);
	float d = length(uv * vec2(1.15, 1.0));
	float v = smoothstep(0.30, 0.95, d);
	COLOR = vec4(0.0, 0.0, 0.0, v * 0.55);
}
"""

const SCANLINE_CODE := """
shader_type canvas_item;
void fragment() {
	float line = step(0.5, fract(UV.y * 120.0));
	COLOR = vec4(0.06, 0.028, 0.020, line * 0.12);
}
"""

const INTERFERENCE_CODE := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float strength : hint_range(0.0, 1.0) = 0.0;

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec4 out_color = vec4(0.0, 0.0, 0.0, 0.0);
	if (strength >= 0.001) {
		float band = floor(SCREEN_UV.y * 48.0);
		float r = hash(band + floor(TIME * 30.0) * 7.0);
		float shift = (r - 0.5) * 0.12 * strength;

		vec2 uv = vec2(clamp(SCREEN_UV.x + shift, 0.0, 1.0), SCREEN_UV.y);
		float ca = 0.006 * strength;
		float rr = texture(screen_tex, vec2(clamp(uv.x + ca, 0.0, 1.0), uv.y)).r;
		float gg = texture(screen_tex, uv).g;
		float bb = texture(screen_tex, vec2(clamp(uv.x - ca, 0.0, 1.0), uv.y)).b;
		vec3 col = vec3(rr, gg, bb);

		float grain = hash(
			dot(floor(SCREEN_UV * vec2(320.0, 180.0)), vec2(12.9898, 78.233))
			+ floor(TIME * 40.0)
		);
		col += (grain - 0.5) * 0.25 * strength;

		out_color = vec4(col, 1.0);
	}
	COLOR = out_color;
}
"""

var _layer: int = Layer.AMBIENT
var _glitch: ColorRect
var _interference_material: ShaderMaterial
var _timer: Timer
var _rng := RandomNumberGenerator.new()

# Configuración por instancia (ajustar ANTES de add_child).
var interval_range := Vector2(5.0, 12.0)  # segundos entre interferencias
var strength_scale := 1.0                 # 0..1, intensidad de cada interferencia


func _init(layer: int = Layer.AMBIENT) -> void:
	_layer = layer
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.randomize()

	if _layer == Layer.INTERFERENCE:
		_build_interference()
	else:
		_build_ambient()

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func _build_ambient() -> void:
	_add_shader_rect(VIGNETTE_CODE)
	_add_shader_rect(SCANLINE_CODE)

	_glitch = ColorRect.new()
	_glitch.color = Color(0.86, 0.44, 0.32, 0.0)
	_glitch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glitch.anchor_left = 0.0
	_glitch.anchor_right = 1.0
	_glitch.anchor_top = 0.0
	_glitch.anchor_bottom = 0.0
	_glitch.offset_left = 0.0
	_glitch.offset_right = 0.0
	_glitch.offset_top = 0.0
	_glitch.offset_bottom = 3.0
	add_child(_glitch)


func _build_interference() -> void:
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = INTERFERENCE_CODE
	_interference_material = ShaderMaterial.new()
	_interference_material.shader = shader
	_interference_material.set_shader_parameter("strength", 0.0)
	rect.material = _interference_material
	add_child(rect)


func _add_shader_rect(code: String) -> ColorRect:
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = code
	var mat := ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)
	return rect


func _ready() -> void:
	_schedule()


func _schedule() -> void:
	if not is_inside_tree():
		return
	_timer.start(_rng.randf_range(interval_range.x, interval_range.y))


func _on_timeout() -> void:
	trigger()
	_schedule()


# Dispara una interferencia de inmediato (p. ej. al interactuar con la UI).
func trigger() -> void:
	if _layer == Layer.INTERFERENCE:
		_play_screen_glitch()
	else:
		_play_band_glitch()


func _set_strength(value: float) -> void:
	if _interference_material != null:
		_interference_material.set_shader_parameter("strength", value)


func _play_screen_glitch() -> void:
	if not is_inside_tree() or _interference_material == null:
		return
	var peak: float = clampf(strength_scale, 0.0, 1.0)
	var t := create_tween()
	t.tween_method(_set_strength, 0.0, peak, 0.05)
	t.tween_interval(0.04)
	t.tween_method(_set_strength, peak, 0.0, 0.14)


func _play_band_glitch() -> void:
	if not is_inside_tree() or _glitch == null:
		return

	var view_height: float = size.y if size.y > 0.0 else 360.0
	var y: float = _rng.randf_range(0.0, max(view_height - 8.0, 1.0))
	var alpha: float = 0.16 * clampf(strength_scale, 0.0, 2.0)

	_glitch.offset_top = y
	_glitch.offset_bottom = y + 3.0
	_glitch.color.a = 0.0

	var sweep := create_tween()
	sweep.set_parallel(true)
	sweep.tween_property(_glitch, "color:a", alpha, 0.04)
	sweep.tween_property(_glitch, "offset_top", y + 7.0, 0.16)
	sweep.tween_property(_glitch, "offset_bottom", y + 10.0, 0.16)

	var fade := create_tween()
	fade.tween_interval(0.10)
	fade.tween_property(_glitch, "color:a", 0.0, 0.08)

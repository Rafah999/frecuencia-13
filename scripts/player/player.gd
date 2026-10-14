extends CharacterBody2D

const ANIM_PREFIX_IDLE := "idle_"
const ANIM_PREFIX_WALK := "walk_"

@export var speed: float = 120.0

# Altura visible objetivo del protagonista (en píxeles de pantalla), igual para
# todas las direcciones. El "scale" de cada animación se calcula a partir de
# esto, de modo que todas las vistas se vean del mismo tamaño.
@export var character_height: float = 55.0

# Velocidad (en fotogramas por segundo) de las animaciones de caminar.
# Ajustable desde el inspector sin tocar el recurso SpriteFrames.
@export var walk_fps: float = 8.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Desplazamiento por textura para anclar los pies y centrar el contenido.
var _texture_offsets: Dictionary = {}

# Escala calculada por animación para igualar la altura visible.
var _animation_scales: Dictionary = {}

# Dirección a la que mira el protagonista. Por defecto, la izquierda.
var _facing: Vector2 = Vector2.LEFT


func _ready() -> void:
	_setup_alignment()
	_update_animation()


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# =====================================================
	# MOVIMIENTO
	# =====================================================

	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0

	if Input.is_action_pressed("move_right"):
		direction.x += 1.0

	if Input.is_action_pressed("move_up"):
		direction.y -= 1.0

	if Input.is_action_pressed("move_down"):
		direction.y += 1.0

	# Evitar mayor velocidad en diagonal
	if direction.length() > 0.0:
		direction = direction.normalized()

	# El personaje mira hacia donde se mueve y conserva la última dirección
	# al detenerse (W = arriba/espalda, S = abajo/frente, A = izquierda, D = derecha).
	if direction != Vector2.ZERO:
		_facing = _dominant_direction(direction)

	velocity = direction * speed

	move_and_slide()

	_update_animation()

	# =====================================================
	# INTERACCIÓN
	# =====================================================

	if Input.is_action_just_pressed("interact"):
		intentar_interactuar()


# =====================================================
# DIRECCIÓN
# =====================================================

func _dominant_direction(direction: Vector2) -> Vector2:
	# En diagonal se prioriza el eje horizontal, como es habitual en 2D.
	if absf(direction.x) >= absf(direction.y):
		return Vector2.LEFT if direction.x < 0.0 else Vector2.RIGHT

	return Vector2.UP if direction.y < 0.0 else Vector2.DOWN


func _facing_name() -> String:
	if _facing.x < 0.0:
		return "left"
	if _facing.x > 0.0:
		return "right"
	return "up" if _facing.y < 0.0 else "down"


# =====================================================
# ANIMACIÓN SEGÚN LA DIRECCIÓN
# =====================================================
#
# Al moverse se reproduce "walk_<dirección>" si existe; al detenerse se vuelve
# a "idle_<dirección>". Por ahora solo existe "walk_right"; el resto de
# direcciones siguen usando su reposo hasta que se añadan sus caminatas.

func _update_animation() -> void:
	if sprite.sprite_frames == null:
		return

	var suffix := _facing_name()
	var moving := velocity.length() > 0.5
	var animation := ANIM_PREFIX_IDLE + suffix

	if moving:
		var walk := ANIM_PREFIX_WALK + suffix
		if sprite.sprite_frames.has_animation(walk):
			animation = walk

	_apply_animation(StringName(animation))


func _apply_animation(animation: StringName) -> void:
	if sprite.sprite_frames == null:
		return

	if not sprite.sprite_frames.has_animation(animation):
		return

	if sprite.animation == animation and sprite.is_playing():
		return

	if _animation_scales.has(animation):
		sprite.scale = _animation_scales[animation]

	sprite.play(animation)
	_apply_frame_offset()


# =====================================================
# ALINEACIÓN Y MISMO TAMAÑO ENTRE DIRECCIONES
# =====================================================
#
# SpriteFrames no permite escala ni desplazamiento distintos por fotograma, así
# que ambos se calculan a partir del recuadro real de contenido de cada textura
# (Image.get_used_rect) y se aplican con AnimatedSprite2D.scale y
# AnimatedSprite2D.offset. Las imágenes originales no se modifican y la
# colisión del personaje no se altera.
#
# Nota sobre el encuadre horizontal: los fotogramas de reposo están exportados
# centrados al contenido, por eso se anclan por el centro de su propia caja
# (fotograma a fotograma). Los de caminar, en cambio, están exportados sobre un
# lienzo común (los pies caen siempre en el mismo píxel), así que se anclan a un
# punto horizontal FIJO de ese lienzo: centrar cada fotograma por su caja haría
# que el balanceo de brazos y piernas arrastrara también al cuerpo.

func _setup_alignment() -> void:
	if sprite.sprite_frames == null:
		return

	# Las animaciones de caminar usan la velocidad exportada (walk_fps).
	for animation_name in sprite.sprite_frames.get_animation_names():
		if String(animation_name).begins_with(ANIM_PREFIX_WALK):
			sprite.sprite_frames.set_animation_speed(animation_name, walk_fps)

	var target := _get_feet_target()
	var offsets: Dictionary = {}
	var scales: Dictionary = {}

	for animation_name in sprite.sprite_frames.get_animation_names():
		var frame_count := sprite.sprite_frames.get_frame_count(animation_name)
		var textures: Array[Texture2D] = []
		var max_height := 0.0
		var center_sum := 0.0
		var center_count := 0
		var is_walk := String(animation_name).begins_with(ANIM_PREFIX_WALK)

		for frame_index in range(frame_count):
			var texture := sprite.sprite_frames.get_frame_texture(
				animation_name,
				frame_index
			)

			if texture == null or textures.has(texture):
				continue

			textures.append(texture)

			var image := texture.get_image()

			if image == null:
				continue

			var used := image.get_used_rect()
			max_height = maxf(
				max_height,
				float(used.size.y)
			)
			center_sum += used.position.x + used.size.x * 0.5
			center_count += 1

		# Escala uniforme para que la altura visible sea "character_height".
		var animation_scale := Vector2.ONE

		if max_height > 0.0:
			animation_scale = Vector2.ONE * (character_height / max_height)

		scales[animation_name] = animation_scale

		var fixed_anchor_x := -1.0
		if is_walk and center_count > 0:
			fixed_anchor_x = center_sum / float(center_count)

		for texture in textures:
			offsets[texture] = _compute_frame_offset(
				texture,
				target,
				animation_scale,
				fixed_anchor_x
			)

	_animation_scales = scales
	_texture_offsets = offsets
	sprite.frame_changed.connect(_apply_frame_offset)


func _apply_frame_offset() -> void:
	if sprite.sprite_frames == null:
		return

	var texture := sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)

	if texture != null and _texture_offsets.has(texture):
		sprite.offset = _texture_offsets[texture]


func _get_feet_target() -> Vector2:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D

	if collision != null and collision.shape is RectangleShape2D:
		var shape := collision.shape as RectangleShape2D
		return collision.position + Vector2(0.0, shape.size.y * 0.5)

	return Vector2.ZERO


func _compute_frame_offset(
	texture: Texture2D,
	target: Vector2,
	scale: Vector2,
	anchor_x: float = -1.0
) -> Vector2:
	var image := texture.get_image()

	if image == null:
		return Vector2.ZERO

	var size := texture.get_size()
	var used := image.get_used_rect()

	# Punto de anclaje: centro horizontal y base (pies) del contenido.
	# Para animaciones "walk_*" usamos un anchor_x fijo para evitar el
	# tambaleo causado por el balanceo de brazos/piernas.
	var center_x := used.position.x + used.size.x * 0.5
	if anchor_x >= 0.0:
		center_x = anchor_x

	var anchor := Vector2(
		center_x,
		used.position.y + used.size.y
	)

	var safe_scale := Vector2(
		scale.x if not is_zero_approx(scale.x) else 1.0,
		scale.y if not is_zero_approx(scale.y) else 1.0
	)

	return Vector2(
		target.x / safe_scale.x - (anchor.x - size.x * 0.5),
		target.y / safe_scale.y - (anchor.y - size.y * 0.5)
	)


func intentar_interactuar() -> void:

	var objetos = $InteractionArea.get_overlapping_areas()

	for objeto in objetos:

		if objeto.has_method("interact"):
			objeto.interact()
			return

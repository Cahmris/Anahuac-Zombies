extends CharacterBody2D

# Customizable speed parameters visible in your Xodot Inspector panel
@export var MAX_SPEED: float = 300.0
@export var ACCELERATION: float = 1500.0
@export var FRICTION: float = 2000.0

func _physics_process(delta: float) -> void:
	# 1. Gather directional input vectors from your Input Map
	var input_direction := Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_top")
	input_direction = input_direction.normalized()

	# 2. Smoothly interpolate velocity using acceleration and friction values
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# 3. Apply physics-safe motion handling (handles collisions automatically)
	move_and_slide()

	# 4. Face toward the touch target or drag position on your iPhone screen
	var target_position := get_global_mouse_position()
	if global_position.distance_to(target_position) > 10.0:
		look_at(target_position)


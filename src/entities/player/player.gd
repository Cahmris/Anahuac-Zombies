extends CharacterBody2D

## Base configuration parameters for the Anahuac Zombies prototype loop
@export_category("Movement Attributes")
@export var movement_speed: float = 300.0
@export var acceleration: float = 0.25 # Handles responsive slide/skate feel on mobile surfaces

# Reference node locations for vector mapping
@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_aim_rotation()

## Calculates responsive, normalized 2D movement grids
func handle_movement(_delta: float) -> void:
	# Extract input directions from mapped engine hooks
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Normalize vector to prevent running faster diagonally (Essential Game Feel rule)
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	
	# Apply fluid velocity calculations using engine lerp operations
	var target_velocity: Vector2 = input_vector * movement_speed
	velocity = velocity.lerp(target_velocity, acceleration)
	
	# Integrated Godot physics engine movement loop
	# Reads obstacles natively to keep you from phasing through airport ticket counters
	move_and_slide()

## Handles look target orientation across both mouse position grids and touch layers
func handle_aim_rotation() -> void:
	# Because 'Emulate Mouse From Touch' is checked ON in your project settings,
	# this function natively captures where your right thumb touches/drags on an iPhone screen.
	var target_aim_position: Vector2 = get_global_mouse_position()
	
	# Smoothly calculate look vector boundaries
	if global_position.distance_to(target_aim_position) > 10.0:
		look_at(target_aim_position)

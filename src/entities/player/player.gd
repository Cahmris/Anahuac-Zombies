extends CharacterBody2D

## Base configuration parameters for the Anahuac Zombies prototype loop
@export_category("Movement Attributes")
@export var movement_speed: float = 300.0
@export var acceleration: float = 0.25 # Handles responsive slide/skate feel on mobile surfaces

@export_category("Combat Attributes")
@export var active_weapon: String = "pistol" # Types: "pistol", "shotgun", "machete"

## Mastery System Variables
var distance_traveled_accumulator: float = 0.0
var step_threshold: float = 5000.0 # Pixels/units moved before speed increments

# Dictionary tracking skill usage counts, current mastery levels, and milestones
var weapon_mastery: Dictionary = {
	"pistol": {"use_count": 0, "level": 1, "threshold": 100},
	"shotgun": {"use_count": 0, "level": 1, "threshold": 50},
	"machete": {"use_count": 0, "level": 1, "threshold": 75}
}

# Reference node locations for vector mapping
@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Muzzle

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_aim_rotation()
	handle_weapon_inputs()

## Calculates responsive, normalized 2D movement grids and tracks step distance
func handle_movement(delta: float) -> void:
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
	
	# Mastery step calculation: track distance run this frame
	if velocity.length() > 0:
		distance_traveled_accumulator += velocity.length() * delta
		if distance_traveled_accumulator >= step_threshold:
			upgrade_movement()
	
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

## Catch mouse clicks or screen presses to handle attacks
func handle_weapon_inputs() -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if active_weapon == "machete":
			swing_melee_weapon()
		else:
			fire_ranged_weapon()

func fire_ranged_weapon() -> void:
	print("Fired ranged weapon: ", active_weapon)
	# Track the shot for specific weapon type proficiency
	record_weapon_use(active_weapon)
	# Bullet spawning / Object pool hooks will go here next

func swing_melee_weapon() -> void:
	print("Swung melee weapon: machete")
	# Track the swing for melee proficiency
	record_weapon_use("machete")
	# Collision damage check hooks will go here next

## --- ORGANIC PROFICIENCY PROGRESSION UPGRADES ---

## Triggered automatically when the user moves enough units
func upgrade_movement() -> void:
	distance_traveled_accumulator = 0.0
	movement_speed += 15.0 # Permanently increase velocity attributes
	step_threshold *= 1.25 # Scale the milestone difficulty up progressively
	print("ATHLETICS UPGRADED! New Speed: ", movement_speed)

## Increments the action count and tracks thresholds
func record_weapon_use(weapon_id: String) -> void:
	if weapon_mastery.has(weapon_id):
		weapon_mastery[weapon_id]["use_count"] += 1
		var current_data = weapon_mastery[weapon_id]
		
		if current_data["use_count"] >= current_data["threshold"]:
			level_up_weapon(weapon_id)

## Upgrades the matching weapon and resets milestones
func level_up_weapon(weapon_id: String) -> void:
	var current_data = weapon_mastery[weapon_id]
	current_data["level"] += 1
	current_data["use_count"] = 0
	current_data["threshold"] = int(current_data["threshold"] * 1.5) # Increase threshold requirement for next level
	
	print(weapon_id.to_upper(), " UPGRADED TO LEVEL ", current_data["level"], "!")
	
	# Apply actual mathematical modifiers to gun parameters on level up
	match weapon_id:
		"pistol":
			# Handled downstream when building firing speed counters
			pass
		"shotgun":
			# Handled downstream to add dynamic pellet projectile values
			pass
		"machete":
			# Handled downstream to widen or quicken attack arc hitboxes
			pass

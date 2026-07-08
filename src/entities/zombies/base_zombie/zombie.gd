extends CharacterBody2D

@export_category("Zombie Attributes")
@export var speed: float = 150.0
@export var target_player: CharacterBody2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var state_chart: StateChart = $StateChart

func _ready() -> void:
	# Find the player in the scene dynamically if not manually assigned
	if not target_player:
		target_player = get_tree().get_first_node_in_group("Player")
	
	# Set up navigation parameters
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

func _physics_process(_delta: float) -> void:
	# Only execute path calculation if we have a valid player target
	if target_player:
		nav_agent.target_position = target_player.global_position

# Called by the State Chart when the 'Chasing' state is active
func _on_chasing_state_physics_processing(_delta):
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
		
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_path_pos)
	
	velocity = direction * speed
	move_and_slide()
	
	# Rotate zombie to look at the direction it is moving
	if velocity.length() > 0:
		rotation = velocity.angle()

# Visual AI State Transitions
func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body == target_player:
		state_chart.send_event("player_detected")

func _on_detection_radius_body_exited(body: Node2D) -> void:
	if body == target_player:
		state_chart.send_event("player_lost")

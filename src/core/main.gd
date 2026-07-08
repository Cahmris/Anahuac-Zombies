extends Node2D

@export_category("Game Settings")
# Drag and drop your zombie.tscn file into this slot in the Godot Editor Inspector
@export var zombie_scene: PackedScene 

@onready var player = $Player

# Wave Management Variables
var current_wave: int = 1
var zombies_to_spawn: int = 5
var zombies_alive: int = 0
var score: int = 0

func _ready() -> void:
	# Randomize the seed so spawns are different every time you play
	randomize() 
	print("Anahuac Zombies Prototype Started!")
	start_wave()

func start_wave() -> void:
	print("Starting Wave: ", current_wave)
	zombies_to_spawn = current_wave * 5 # E.g., Wave 1 spawns 5, Wave 2 spawns 10
	
	# Spawn zombies one by one using a timer or loop
	for i in range(zombies_to_spawn):
		spawn_zombie()
		
func spawn_zombie() -> void:
	# 1. Create a new instance of the zombie
	var new_zombie = zombie_scene.instantiate()
	
	# 2. Pick a random spawn point slightly off-screen or far from the player
	# (For now, we'll just spawn them in a random circle around the player)
	var spawn_radius = 800.0
	var random_angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	
	new_zombie.global_position = spawn_pos
	
	# 3. Add the zombie to the world
	add_child(new_zombie)
	zombies_alive += 1
	
	# 4. Connect a signal to know when this zombie dies (you'll need to emit "died" from zombie.gd later)
	# new_zombie.connect("died", Callable(self, "_on_zombie_died"))

# This function will be called when a zombie is killed
func _on_zombie_died() -> void:
	zombies_alive -= 1
	score += 100
	print("Zombie killed! Score: ", score, " | Remaining: ", zombies_alive)
	
	# Check if the wave is over
	if zombies_alive <= 0:
		current_wave += 1
		# Add a slight delay before the next wave starts
		await get_tree().create_timer(3.0).timeout 
		start_wave()

# Listen for the Escape/Start button to pause or quit
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

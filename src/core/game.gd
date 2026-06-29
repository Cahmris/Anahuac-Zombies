extends Node2D

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var player: CharacterBody2D = $Entities/Player

func _ready() -> void:
	# Center the player on our mock terminal playground at spawn
	player.global_position = Vector2(960, 540)
	print("Anahuac Zombies: Core world framework compiled successfully.")

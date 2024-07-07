# scripts/voxel_world.gd

extends Node3D

const CHUNK_SIZE = 16
const CHUNK_COUNT = 4

@onready var chunk_scene = preload("res://scenes/voxel_chunk.tscn")

func _ready():
	generate_world()

func generate_world():
	for x in range(CHUNK_COUNT):
		for y in range(CHUNK_COUNT):
			for z in range(CHUNK_COUNT):
				var chunk = chunk_scene.instantiate()  # Use instantiate() in Godot 4.x
				chunk.transform.origin = Vector3(x * CHUNK_SIZE, y * CHUNK_SIZE, z * CHUNK_SIZE)
				add_child(chunk)

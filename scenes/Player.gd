# scripts/player.gd

extends CharacterBody3D

@export var move_speed = 5.0
@export var mouse_sensitivity = 0.1

var last_mouse_position = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	handle_mouse_input(delta)
	handle_movement_input(delta)

func handle_mouse_input(delta):
	var mouse_delta = Input.get_last_mouse_velocity()
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var rotation_x = deg_to_rad(-mouse_delta.y * mouse_sensitivity)
		var rotation_y = deg_to_rad(-mouse_delta.x * mouse_sensitivity)
		rotate_x(rotation_x)
		$Camera3D.rotate_y(rotation_y)

func handle_movement_input(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()

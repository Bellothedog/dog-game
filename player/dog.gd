extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 2.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 6.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _mesh: Node3D = %"dawg-simplified"
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	# NOTE: For joystick support, use Input.get_axis() w/ controller joystick mappings
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity


func _physics_process(delta: float) -> void:
	# Vertical rotation
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, 
	-PI / 6.0, PI / 3.0)
	
	# Horizontal rotation
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("left", "right", "forward", "backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	# Apply gravity
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta
	
	# Test if dog is on floor and jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_impulse
	
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_mesh.global_rotation.y = lerp_angle(_mesh.global_rotation.y, target_angle, rotation_speed * delta)
	
	if velocity.length() > 0.0:
		if velocity.y > 0.0:
			play_anim("Jump")
		else:
			play_anim("Walk")
	else:
		play_anim("Idle")

func play_anim(anim: String) -> void:
	if _animation_player.current_animation != anim:
		_animation_player.play(anim)

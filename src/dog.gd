extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 20.0
@export var acceleration := 5.0 
@export var rotation_speed := 10.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var mouse_captured := true

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _model: Node3D = %board

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		mouse_captured = not mouse_captured
	if mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	# Limit rotation to -30° to 60°
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	# Stop rotation after mouse movement
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	
	# Calculate target rotation angle
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	# Smoothly turn towards target
	_model.global_rotation.y = lerp_angle(_model.rotation.y, target_angle, rotation_speed * delta)

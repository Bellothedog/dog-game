extends CharacterBody3D


@onready var pivot: Node3D = $CamOrigin
@export var speed = 10.0
@export var jump_velocity = 2.0
@export var mouse_sensitivity = 0.5
@export var acceleration = 5.0
@export var turn_speed = 2.0

var camera_input_direction := Vector2.ZERO
var current_turn_speed : float

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	# rotate camera
	pivot.rotation.x += camera_input_direction.y * delta
	pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(30))
	pivot.rotation.y -= camera_input_direction.x * delta
	pivot.rotation.y = clamp(pivot.rotation.y, deg_to_rad(-90), deg_to_rad(90))
	
	# stop movement after mouse input
	camera_input_direction = Vector2.ZERO
	
	# apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	var raw_input := Input.get_vector("left", "right", "up", "down")
	
	var up := self.global_basis.y
	var turn_direction := up * raw_input.x
	current_turn_speed = move_toward(current_turn_speed, turn_speed, delta)
	if turn_direction:
		rotate_y((-raw_input.x * current_turn_speed) * delta)
		#rotation = turn_direction * current_turn_speed
	
	var forward := self.global_basis.z
	var move_direction := forward * raw_input.y
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	velocity = velocity.move_toward(move_direction * speed, acceleration * delta)
	
	move_and_slide()

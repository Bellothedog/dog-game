extends CharacterBody3D


@onready var pivot: Node3D = $CamOrigin
@export var speed = 5.0
@export var jump_velocity = 10
@export var mouse_sensitivity = 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pivot.rotate_x(deg_to_rad(-event.relative.x * mouse_sensitivity))
		pivot.rotate_y(deg_to_rad(-event.relative.y * mouse_sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		pivot.rotation.y = clamp(pivot.rotation.y, deg_to_rad(-45), deg_to_rad(45))

func _physics_process(delta: float) -> void:
	# apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

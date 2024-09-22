extends CharacterBody3D


@export var SPEED := 5.0
@export var JUMP_VELOCITY := 4.5
@export var SPRING_ARM_ADJUSTMENT := 2.0

@onready var pivot = $CameraOrigin
@onready var mouse_sensitivity = 0.5
@onready var spring_arm_3d = $CameraOrigin/SpringArm3D
@onready var save_pivot = pivot.rotation
@onready var shoot_timer = $ShootTimer
@onready var laser = $Rifle/laser
@onready var animation_player = $AnimationPlayer

var anim_rand

@onready var rifle = $Rifle

#bullets
var bullet = preload("res://player/bullet.tscn")
var bullet_instance
var rng = RandomNumberGenerator.new()
var spring_arm_length = 2.0
var free_look = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rng.randomize()

func _input(event):
	if Input.is_action_just_pressed("free_look"):
			free_look = true
			save_pivot = pivot.rotation
	if Input.is_action_just_released("free_look"):
			free_look = false
			pivot.rotation = save_pivot

	if event is InputEventMouseMotion:
		if free_look:
			pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			pivot.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			#pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(35))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			rifle.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			rifle.rotation.x = clamp(rifle.rotation.x, deg_to_rad(-45), deg_to_rad(45))
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(35))

func _physics_process(delta):
	#animate blinks and looks
	if not animation_player.is_playing():
		anim_rand = rng.randi_range(0,100)
		if anim_rand < 1:
			animation_player.play("blink")
		elif anim_rand < 2:
			animation_player.play("look_around")
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle use/shoot
	if Input.is_action_pressed("shoot"):
		if shoot_timer.is_stopped():
			shoot_timer.start(0.1)
			bullet_instance = bullet.instantiate()
			bullet_instance.position = rifle.global_position
			bullet_instance.transform.basis = rifle.global_transform.basis
			laser.play()
			get_parent().add_child(bullet_instance)
	else:
		rifle.rotation.x = lerp(rifle.rotation.x, 0.0, 0.5)

	# Handle Quitting
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Zooming Camera in and out
	if Input.is_action_just_pressed("scroll_down"):
		spring_arm_length += SPRING_ARM_ADJUSTMENT
	if Input.is_action_just_pressed("scroll_up"):
		spring_arm_length -= SPRING_ARM_ADJUSTMENT
	
	spring_arm_length = clamp(spring_arm_length, 0.75, 30.0)
	spring_arm_3d.spring_length = lerp(spring_arm_3d.spring_length, spring_arm_length, 0.05)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

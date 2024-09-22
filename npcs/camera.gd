extends Node3D

@export var SPRING_ARM_ADJUSTMENT := 2.0
@export var spring_arm_length := 2.0

@onready var paladin := $".."
@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera_node: Node3D = $"."


@onready var save_camera_node_rotation: Vector3 = camera.rotation
@onready var save_spring_arm_rotation: Vector3 = spring_arm.rotation
@onready var save_camera_rotation: Vector3 = camera.rotation


@onready var mouse_sensitivity := 0.015
var free_look = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Camera Zoom
	if Input.is_action_just_pressed("scroll_down"):
		spring_arm_length += SPRING_ARM_ADJUSTMENT
		clamp_spring()
	if Input.is_action_just_pressed("scroll_up"):
		spring_arm_length -= SPRING_ARM_ADJUSTMENT
		clamp_spring()

func _input(event):
	# Free Look Mode
	if Input.is_action_just_pressed("free_look"):
			save_camera_node_rotation = camera_node.rotation
			save_spring_arm_rotation = spring_arm.rotation
			save_camera_rotation = camera.rotation
			free_look = true
	if Input.is_action_just_released("free_look"):
			free_look = false
			camera_node.rotation = save_camera_node_rotation
			spring_arm.rotation = save_spring_arm_rotation
			camera.rotation = save_camera_rotation

	# Move Camera
	if event is InputEventMouseMotion:
		if free_look:
			#camera_target.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera_node.rotate_y(-event.relative.x * mouse_sensitivity)
			#pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			#camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/4, PI/4)
			
			#camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(80.0), deg_to_rad(-80.0))
			#print(camera.rotation_degrees.x)
			
			
			#camera_target.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			#pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(35))
			#pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		else:
			if Global.CurrentAction < Global.Action.FALL:
				paladin.rotate_y(-event.relative.x * mouse_sensitivity)
			#pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
				camera_node.rotate_x(-event.relative.y * mouse_sensitivity)
				camera_node.rotation.x = clamp(camera_node.rotation.x, -PI/4, PI/4)
	#camera.global_transform = lerp(camera.global_transform.basis, camera_target.global_transform.basis, 0.50)

func clamp_spring():
	# Clamp the Zoom Distance
	spring_arm_length = clamp(spring_arm_length, 0.75, 30.0)
	spring_arm.spring_length = lerp(spring_arm.spring_length, spring_arm_length, 0.05)

extends CharacterBody3D

@export var walk_speed : float = 200
@export var run_speed : float = 400
@export var jump_velocity : float = 4.5

@onready var speed : float = walk_speed
@onready var animation_player = %AnimationPlayer
@onready var attack_timer: Timer = $Timers/Attack_Timer
@onready var hitbox: Area3D = $hitbox
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var pray_timer: Timer = $Timers/Pray_Timer

# Inventory
@onready var helmet: MeshInstance3D = $RootNode/Skeleton3D/Helmet
@onready var body: MeshInstance3D = $RootNode/Skeleton3D/Body
@onready var shield: MeshInstance3D = $RootNode/Skeleton3D/Shield
@onready var sword: MeshInstance3D = $RootNode/Skeleton3D/Sword

var rng = RandomNumberGenerator.new()
var previous_input : Vector2 = Vector2(0, 0)
var input_dir : Vector2 = Vector2(0, 0)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_tree.active = false
	rng.randomize()

func _physics_process(delta):
	# Inventory
	if Input.is_action_just_pressed("inv_1"):
		helmet.visible = !helmet.visible
	if Input.is_action_just_pressed("inv_2"):
		sword.visible = !sword.visible
	if Input.is_action_just_pressed("inv_3"):
		shield.visible = !shield.visible
		
	if not is_on_floor():
		# Add the gravity.
		velocity.y -= gravity * delta
		velocity.y = clamp(velocity.y, -9.8, 4.5) # Terminal velocity reached?
		if velocity.y < 0:
			Global.CurrentAction = Global.Action.FALL
		elif velocity.y > 0:
			Global.CurrentAction = Global.Action.JUMP
	else:
		# Handle Action
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			Global.CurrentAction = Global.Action.JUMP
		elif Input.is_action_just_pressed("attack"):
			Global.CurrentAction = Global.Action.ATTACK
			attack_timer.start()
		elif Input.is_action_just_pressed("pray"):
			Global.CurrentAction = Global.Action.PRAY
			pray_timer.start()
		else:
			if Global.CurrentAction < Global.Action.PRAY:
				Global.CurrentAction = Global.Action.IDLE
		
		if Global.CurrentAction < Global.Action.PRAY:
			if velocity:
				if Input.is_action_pressed("run"):
					Global.CurrentAction = Global.Action.RUN
					speed = run_speed
				else:
					Global.CurrentAction = Global.Action.WALK
					speed = walk_speed
			else:
				Global.CurrentAction = Global.Action.IDLE
	process_movement(delta)
	handle_animation(Global.CurrentAction)

	if !attack_timer.is_stopped():
		if hitbox.has_overlapping_bodies():
			var bodies = hitbox.get_overlapping_bodies()
			for _body in bodies:
				if _body.has_method("take_damage"):
					var damage = randi_range(10, 25)
					_body.take_damage(damage)


func handle_animation(current_action):
	match current_action:
		Global.Action.IDLE:
			animation_tree.active = true
			animation_tree.set("parameters/air/blend_amount", 0.0)
			animation_tree.set("parameters/movement/blend_amount", lerp(animation_tree.get("parameters/movement/blend_amount"), -1.0, 0.15))
		Global.Action.WALK:
			animation_tree.active = true
			animation_tree.set("parameters/air/blend_amount", 0.0)
			animation_tree.set("parameters/movement/blend_amount", lerp(animation_tree.get("parameters/movement/blend_amount"), 0.0, 0.15))
		Global.Action.RUN:
			animation_tree.active = true
			animation_tree.set("parameters/air/blend_amount", 0.0)
			animation_tree.set("parameters/movement/blend_amount", lerp(animation_tree.get("parameters/movement/blend_amount"), 1.0, 0.15))
		Global.Action.JUMP:
			animation_tree.active = true
			animation_tree.set("parameters/air/blend_amount", 1.0)
			animation_tree.set("parameters/jumping/blend_amount", normalize(velocity.y, -9.8, 4.5))
		Global.Action.FALL:
			animation_tree.active = true
			animation_tree.set("parameters/air/blend_amount", 1.0)
			animation_tree.set("parameters/jumping/blend_amount", normalize(velocity.y, -9.8, 4.5))

		Global.Action.PRAY:
			animation_tree.active = false
			animation_player.play("pray")


		Global.Action.ATTACK:
			animation_tree.active = false
			animation_player.play("attack")


func process_movement(delta):
	input_dir = Input.get_vector("left", "right", "forward", "back")

	if Global.CurrentAction == Global.Action.FALL:
		pass
	if Global.CurrentAction == Global.Action.JUMP:
		pass
	if Global.CurrentAction == Global.Action.ATTACK:
		input_dir = Vector2.ZERO
	if Global.CurrentAction == Global.Action.PRAY:
		input_dir = Vector2.ZERO

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed * delta
		velocity.z = direction.z * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, 0.15)
		velocity.z = move_toward(velocity.z, 0, 0.15)
	
	move_and_slide()


func _on_pray_timer_timeout():
	Global.CurrentAction = Global.Action.IDLE

func _on_attack_timer_timeout():
	Global.CurrentAction = Global.Action.IDLE

func normalize(val, val_min, val_max):
	var val_range = val_max - val_min
	var ret = ((val - val_min) / val_range) * 2
	print("Shazaam: ", ret - 1.0)
	return ret - 1.0

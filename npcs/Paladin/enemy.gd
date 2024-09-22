extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var walk_speed : float = 200
@export var run_speed : float = 400
@export var jump_velocity : float = 4.5
@export var health: int = 100

@onready var speed : float = walk_speed
@onready var animation_player = %AnimationPlayer
@onready var attack_timer: Timer = $Timers/Attack_Timer
@onready var hitbox: Area3D = $hitbox

enum Action {IDLE, WALK, RUN, FALL, PRAY, JUMP, ATTACK}
var CurrentAction : Action = Action.IDLE

var rng = RandomNumberGenerator.new()
var previous_input : Vector2 = Vector2(0, 0)
var input_dir : Vector2 = Vector2(0, 0)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	rng.randomize()
	var random_position: Vector3
	random_position.x = randf_range(-50.0, 50.0)
	random_position.z = randf_range(-50.0, 50.0)
	translate(Vector3(random_position.x, position.y, random_position.z))
	select_new_destination()
	

func _physics_process(delta: float) -> void:
	var destination = navigation_agent_3d.get_next_path_position()
	
	var direction_to_destination = destination - global_position
	var direction = direction_to_destination.normalized()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if !attack_timer.is_stopped():
		if hitbox.has_overlapping_bodies():
			var bodies = hitbox.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("take_damage"):
					var damage = randi_range(10, 25)
					body.take_damage(damage)
	
	velocity = direction * speed * delta
	
	if velocity:
		CurrentAction = Action.RUN
	else:
		CurrentAction = Action.IDLE

	handle_animation(CurrentAction)

	move_and_slide()

	#have enemy face the direction he's going
	look_at(global_position + direction)
	#look_at(direction)

func handle_animation(current_action):
	match current_action:
		Action.IDLE:
			animation_player.play("idle")
		Action.WALK:
			animation_player.play("walk")
		Action.RUN:
			animation_player.play("run")
		Action.ATTACK:
			animation_player.play("attack")
		Action.JUMP:
			animation_player.play("jump")
		Action.PRAY:
			animation_player.play("pray")
		Action.FALL:
			animation_player.play("fall")
			
func select_new_destination():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-100.0, 100.0)
	random_position.z = randf_range(-100.0, 100.0)
	navigation_agent_3d.set_target_position(random_position)
	navigation_agent_3d.get_next_path_position()

func _on_navigation_agent_3d_navigation_finished() -> void:
	select_new_destination()

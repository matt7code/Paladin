extends RigidBody3D

var dir : Vector3

const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray_cast = $RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

func _on_timer_timeout():
	queue_free()

extends StaticBody3D

@export var health:int = 100
@onready var immunity_timer: Timer = $Immunity
var can_bit_hit:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_damage(damage):
	if can_bit_hit:
		health -= damage
		print(name, ": took ", damage, " damage")
		can_bit_hit = false
		immunity_timer.start()
		if health < 1:
			queue_free()


func _on_immunity_timeout() -> void:
	can_bit_hit = true

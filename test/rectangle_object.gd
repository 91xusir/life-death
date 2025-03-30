extends RigidBody2D

signal broken

var health = 3
var can_break = true

func _ready():
	contact_monitor = true
	max_contacts_reported = 10
	
func _physics_process(delta):
	for body in get_colliding_bodies():
		if body.is_in_group("player") or body.is_in_group("projectile"):
			take_damage(1)

func take_damage(amount):
	health -= amount
	if health <= 0 and can_break:
		break_apart()

func break_apart():
	can_break = false
	emit_signal("broken", global_position)
	queue_free()

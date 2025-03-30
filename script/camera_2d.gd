extends Camera2D

var ball1: BaseBall
var ball2: BaseBall
var initial_y_position: float

func _ready():
	ball1 = get_tree().get_nodes_in_group("ball")[0]
	ball2 = get_tree().get_nodes_in_group("ball")[1]
	offset = Vector2(0.0, get_viewport_rect().size.y / 2)
	position = (ball1.position + ball2.position) / 2
	initial_y_position = position.y


func _physics_process(_delta):
	var center_position = Vector2((ball1.position.x + ball2.position.x) / 2, initial_y_position)
	var smoothing_factor = 0.1
	position = position.lerp(center_position, smoothing_factor)

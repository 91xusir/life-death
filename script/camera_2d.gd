extends Camera2D

var ball1 :BaseBall
var ball2 :BaseBall

func _ready():
	# 移除偏移设置，让相机直接跟随目标
	ball1 = get_tree().get_nodes_in_group("ball")[0]
	ball2 = get_tree().get_nodes_in_group("ball")[1]
	# 立即将相机移动到两球中心
	position = (ball1.position + ball2.position) / 2

func _physics_process(_delta):
	var center_position = (ball1.position + ball2.position) / 2
	var smoothing_factor = 0.1 
	position = position.lerp(center_position, smoothing_factor)

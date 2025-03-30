extends Node2D

@export var fragment_count = 8
@export var fragment_speed = 200
@export var fragment_lifetime = 1.0
@export var fragment_color = Color(1, 1, 1)

func _ready():
	create_fragments()
	
func create_fragments():
	for i in range(fragment_count):
		var fragment = ColorRect.new()
		fragment.color = fragment_color
		fragment.size = Vector2(10, 10)
		fragment.position = Vector2.ZERO
		add_child(fragment)
		
		# 随机方向
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var distance = randf_range(30, 100)
		
		# 创建动画
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(fragment, "position", direction * distance, fragment_lifetime)
		tween.tween_property(fragment, "rotation", randf_range(-PI, PI), fragment_lifetime)
		tween.tween_property(fragment, "modulate:a", 0.0, fragment_lifetime)
	
	# 特效完成后自动销毁
	await get_tree().create_timer(fragment_lifetime + 0.1).timeout
	queue_free()

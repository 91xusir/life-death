extends Node2D

var break_effect_scene = preload("res://test/break_effect.tscn")

func _ready():
	for rectangle in get_tree().get_nodes_in_group("breakable"):
		rectangle.connect("broken", _on_rectangle_broken)

func _on_rectangle_broken(position):
	var effect = break_effect_scene.instantiate()
	effect.position = position
	effect.fragment_color = Color(0.8, 0.3, 0.2)  # 红色碎片
	add_child(effect)
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 点击鼠标左键在点击位置创建一个"子弹"来测试碰撞
		var bullet = RigidBody2D.new()
		bullet.position = event.position
		bullet.mass = 1
		bullet.add_to_group("projectile")
		
		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 10
		collision.shape = shape
		bullet.add_child(collision)
		
		var visual = MeshInstance2D.new()
		var mesh = SphereMesh.new()
		mesh.radius = 10
		mesh.height = 20
		visual.mesh = mesh
		bullet.add_child(visual)
		
		add_child(bullet)
		
		# 向随机方向发射
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		bullet.apply_impulse(direction * 500)
		
		# 2秒后删除子弹
		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(bullet):
			bullet.queue_free()

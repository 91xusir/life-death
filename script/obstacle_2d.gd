extends StaticBody2D

@export var size: Vector2 = Vector2(100, 100)
@export var color: Color = Color(1, 0, 0)  # 默认红色
@export var is_moving: bool = false
@export var move_distance: Vector2 = Vector2(0, 0)
@export var move_duration: float = 2.0

var _initial_position: Vector2
var _target_position: Vector2
var _t: float = 0.0
var _moving_forward: bool = true

func _ready():
	# 创建碰撞形状
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = size
	collision_shape.shape = rectangle_shape
	add_child(collision_shape)
	
	# 设置初始位置和目标位置
	_initial_position = position
	_target_position = _initial_position + move_distance

func _process(delta):
	if is_moving and move_distance != Vector2.ZERO:
		_t += delta / move_duration
		
		if _moving_forward:
			position = _initial_position.lerp(_target_position, _t)
			if _t >= 1.0:
				_t = 0.0
				_moving_forward = false
		else:
			position = _target_position.lerp(_initial_position, _t)
			if _t >= 1.0:
				_t = 0.0
				_moving_forward = true

func _draw():
	# 绘制矩形
	draw_rect(Rect2(-size/2, size), color)

# 当属性变化时重新绘制
func update_appearance():
	queue_redraw()

# 属性设置器
func set_size(new_size):
	size = new_size
	update_appearance()
	
func set_color(new_color):
	color = new_color
	update_appearance()

class_name BaseBall
extends CharacterBody2D

# 球的类型
enum BallName {White, Black}
@export_enum("White", "Black") var ball_name: int
@export var game: Game
@export var debug: bool = false
# 球的基本属性
var max_speed = 550.0 # 最大移动速度
var min_speed = 120.0 # 初始移动速度
const ACCELERATION = 180.0 # 加速度
const BOUNCE_FACTOR = 0.8 # 弹力系数
const FRICTION = 100
var jump_velocity = -400.0 # 跳跃速度
var current_speed = min_speed # 当前速度
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false
var initial_global_position # 初始位置
var run_direction = 0.0 # 运动方向
# 同步
@export var sync_partner: BaseBall
var is_master = false

# 粒子
@onready var trail_particles = $TrailParticles
@onready var death_particles = $DeathParticles
# 音效
@onready var pop: AudioStreamPlayer = $Pop

func _ready():
	
	initial_global_position = get_tree().get_first_node_in_group("born").global_position
	trail_particles.emitting = true
	is_master = (ball_name == BallName.Black)

func _process(delta):
	if is_dead:
		return
	if not is_master:
		if sync_partner and !sync_partner.is_dead:
			position.x = sync_partner.position.x
			position.y = -sync_partner.position.y
			velocity.x = sync_partner.velocity.x
			velocity.y = -sync_partner.velocity.y
		rotate_ball(delta)

# 物理处理
func _physics_process(delta):
	if is_dead:
		return
		
	if is_master:
		process_input(delta)
		velocity.y += gravity * delta

		var pre_collision_velocity = velocity.y
		var was_on_floor = is_on_floor()

		move_and_slide()

		if is_on_floor() and !was_on_floor:
			velocity.y = -abs(pre_collision_velocity) * BOUNCE_FACTOR
			if abs(velocity.y) < 20:
				velocity.y = 0
			pop.play() 


# 处理输入
func process_input(delta):
	var direction = Input.get_axis("run_left", "run_right")
	if not direction == 0:
		current_speed = min(current_speed + ACCELERATION * delta, max_speed)
		run_direction = direction
	else:
		current_speed = max(current_speed - FRICTION * delta, 0)
	velocity.x = current_speed * run_direction
	# 跳跃
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity


# 根据速度旋转球
func rotate_ball(delta):
	# 旋转速度系数
	var rotation_speed = 0.1
	# 根据水平速度设置旋转
	rotation += velocity.x * rotation_speed * delta
	# 同步旋转到白球
	if sync_partner and !sync_partner.is_dead:
		sync_partner.rotation = rotation


# 死亡
func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	$Sprite2D.visible = false
	trail_particles.emitting = false
	death_particles.emitting = true
	if ball_name == BallName.White:
		game.on_white_ball_death()
	else:
		game.on_black_ball_death()

# 检查死亡动画是否完成
func is_death_animation_finished() -> bool:
	return is_dead and not death_particles.emitting

# 重置球的状态
func reset():
	is_dead = false
	global_position = initial_global_position
	velocity = Vector2.ZERO
	current_speed = min_speed # 重置当前速度
	$Sprite2D.visible = true
	$Sprite2D.rotation = 0 # 重置旋转

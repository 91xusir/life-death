class_name BaseBall
extends CharacterBody2D

# 球的基本属性
const MAX_SPEED = 300.0 # 最大移动速度
const MIN_SPEED = 150.0 # 初始移动速度
const ACCELERATION = 200.0 # 加速度
const DECELERATION = 300.0 # 减速度
const BOUNCE_FACTOR = 0.7 # 弹力系数
var jump_velocity = -400.0 # 跳跃速度
const INERTIA_FACTOR = 0.95 # 惯性衰减系数
var current_speed = MIN_SPEED # 当前速度
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false
var initial_position
# 球的类型
enum BallName {White, Black}
@export_enum("White", "Black") var ball_name: int
@export var game: Game
# 粒子效果引用
@onready var trail_particles = $TrailParticles
@onready var death_particles = $DeathParticles
@onready var pop: AudioStreamPlayer = $Pop # 音效

func _ready():
	initial_position = position
	if ball_name == BallName.White:
		up_direction = Vector2.DOWN # 翻转地板方向
		gravity = - gravity # 负值，因为白球的重力是向上的
		jump_velocity = -jump_velocity
# 物理处理
func _physics_process(delta):
	if is_dead:
		return

	var previous_position = position
	
	velocity.y += gravity * delta # 重力

	# 处理水平移动
	var direction = Input.get_axis("run_left", "run_right")
	if direction:
		# 按下方向键时逐渐加速
		current_speed = min(current_speed + ACCELERATION * delta, MAX_SPEED)
		velocity.x = direction * current_speed * INERTIA_FACTOR
	else:
		# 没有按下方向键时逐渐减速
		current_speed = max(current_speed - DECELERATION * delta, MIN_SPEED)
		# 应用摩擦力减速
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		pop.play()

	if position != previous_position:
		trail_particles.emitting = true
	else:
		trail_particles.emitting = false

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	
	# 隐藏精灵并停止拖尾粒子
	$Sprite2D.visible = false
	trail_particles.emitting = false
	
	# 播放死亡粒子效果
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
	position = initial_position
	velocity = Vector2.ZERO
	$Sprite2D.visible = true
	death_particles.emitting = false
	trail_particles.emitting = false

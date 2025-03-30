class_name BaseBall
extends CharacterBody2D

enum BallName {White, Black}
@export_enum("White", "Black") var ball_name: int
@export var game: Game
var debug: bool = false
# 球的基本属性
var max_speed = 550.0 # 最大移动速度
var min_speed = 120.0 # 初始移动速度
var bounce_factor = -0.8 # 弹力系数
const ACCELERATION = 180.0 # 加速度
const FRICTION = 100 # 摩擦力
var jump_velocity = -400.0 # 跳跃速度
var current_speed = min_speed # 当前速度
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false
var initial_global_position # 初始位置
var run_direction = 0.0 # 运动方向
@export var other_ball: BaseBall # 另一个球的引用
# 粒子
@onready var trail_particles = $TrailParticles
@onready var death_particles = $DeathParticles
#粒子淡出tween
var particles_tween: Tween = null
# 音效
@onready var pop: AudioStreamPlayer = $Pop
@onready var pop_2: AudioStreamPlayer = $Pop2

func _ready():
	debug = game.debug
	trail_particles.emitting = true
	if ball_name == BallName.White:
		gravity *= -1
		jump_velocity *= -1
		bounce_factor *= -1
		initial_global_position = get_white_bron_position()
	else:
		initial_global_position = get_black_bron_position()

func _process(delta):
	if is_dead:
		return
	rotate_ball(delta)

func _physics_process(delta):
	if is_dead:
		return
	
	process_input(delta)
	velocity.y += gravity * delta
	var pre_collision_velocity = velocity.y
	var was_on_floor = is_on_floor()
	move_and_slide()
	if is_on_floor() and !was_on_floor:
		velocity.y = abs(pre_collision_velocity) * bounce_factor
		if abs(velocity.y) < 20:
			velocity.y = 0
		pop.play()
	check_obstacle_collision()

func process_input(delta):
	var direction = Input.get_axis("run_left", "run_right")
	if not direction == 0:
		current_speed = min(current_speed + ACCELERATION * delta, max_speed)
		run_direction = direction
		if debug:
			print("current_location: " + str(global_position))
	else:
		current_speed = max(current_speed - FRICTION * delta, 0)
	velocity.x = current_speed * run_direction
	# 跳跃
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity


# 旋转
func rotate_ball(delta):
	var rotation_speed = 0.1
	rotation += velocity.x * rotation_speed * delta

# 死亡
func die():
	if is_dead:
		return
	pop_2.play()
	is_dead = true
	$Sprite2D.visible = false
	velocity = Vector2.ZERO
	trail_particles.emitting = false

	if particles_tween:
		particles_tween.kill()
		particles_tween = null
	particles_tween = create_tween()
	death_particles.modulate.a = 1.0
	death_particles.restart()
	var fade_duration = death_particles.lifetime * 0.5
	var delay_before_fade = death_particles.lifetime * 0.5
	particles_tween.tween_property(death_particles, "modulate:a", 0.0, fade_duration).set_delay(delay_before_fade)

	try_revive()

# 复活
func try_revive():
	await get_tree().create_timer(0.5).timeout
	if is_dead and not other_ball.is_dead:
		print("复活")
		position.x = other_ball.position.x
		position.y = - other_ball.position.y
		velocity.x = other_ball.velocity.x
		velocity.y = - other_ball.velocity.y
		current_speed = other_ball.current_speed
		rotation = 0 # 重置旋转
		trail_particles.emitting = true
		$Sprite2D.visible = true
		is_dead = false

# 重置球的状态
func reset():
	global_position = initial_global_position
	velocity = Vector2.ZERO
	current_speed = min_speed # 重置当前速度
	rotation = 0 # 重置旋转
	trail_particles.emitting = true
	$Sprite2D.visible = true
	is_dead = false

func check_obstacle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("wall"):
			die()
			break

func get_white_bron_position() -> Vector2:
	var p = get_tree().get_first_node_in_group("born").global_position
	return Vector2(p.x, 720 - p.y)
	
func get_black_bron_position() -> Vector2:
	return get_tree().get_first_node_in_group("born").global_position

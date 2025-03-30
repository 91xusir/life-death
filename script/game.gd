extends Node2D
class_name Game
# 游戏状态变量
var game_over = false
var score = 0 # 分数
var last_obstacle_position = 0 # 上一个障碍物的位置
var obstacle_interval = 300 # 障碍物生成间隔
var obstacle_gap = 200 # 障碍物之间的空隙
var passed_obstacles = [] # 已经通过的障碍物
var difficulty_level = 0 # 当前难度等级
var difficulty_threshold = 100 # 每隔多少分提高一次难度

@export var debug := false
@onready var black_ball: BaseBall = $UpperWorld/BlackBall
@onready var white_ball: BaseBall = $LowerWorld/WhiteBall
@onready var game_bg_audio_player: AudioStreamPlayer = $GameBGAudioPlayer
@onready var hard_mode_audio_player: AudioStreamPlayer = $HardModeAudioPlayer
@onready var fade_animation_player: AnimationPlayer = $UI/FadeAnimationPlayer
@onready var restart_button_audio_player: AudioStreamPlayer = $UI/GameOverFade/RestartButton/RestartButtonAudioPlayer
@onready var exit_button_audio_player: AudioStreamPlayer = $UI/GameOverFade/ExitButton/ExitButtonAudioPlayer
@onready var upper_world: Node2D = $UpperWorld # 上半世界
@onready var lower_world: Node2D = $LowerWorld # 下半世界
@onready var game_score: Label = $UI/GameScore
@onready var obstacle_2d = preload("res://scene/obstacle_2d.tscn")

func _ready():
	fade_animation_player.queue("logo_fade_out")
	reset_game()
	game_bg_audio_player.play()
	fade_in_music(game_bg_audio_player)
	
func _process(_delta):
	if not game_over:
		check_game_state()
		update_score()
		check_obstacle_generation()

func fade_in_music(audio_player: AudioStreamPlayer):
	audio_player.volume_db = -80
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -20, 2)
	tween.play()

func fade_out_music(audio_player: AudioStreamPlayer):
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80, 2)
	tween.play()

func check_game_state():
	if black_ball.is_dead and white_ball.is_dead:
		game_over = true
		show_game_over()

func show_game_over():
	fade_animation_player.queue("game_over")
	if game_bg_audio_player.playing:
		game_bg_audio_player.stop()
	if hard_mode_audio_player.playing:
		hard_mode_audio_player.stop()

func reset_game():
	game_over = false
	black_ball.reset()
	white_ball.reset()
	score = 0
	game_score.text = "Score: 0"
	last_obstacle_position = 0
	passed_obstacles.clear()
	difficulty_level = 0 # 重置难度等级
	obstacle_interval = 300 # 重置障碍物间隔
	# 清除所有障碍物
	for obstacle in get_tree().get_nodes_in_group("obstacle"):
		obstacle.queue_free()

	# 切换回原始背景音乐
	if hard_mode_audio_player.playing:
		fade_out_music(hard_mode_audio_player)
		await get_tree().create_timer(2.0).timeout
		hard_mode_audio_player.stop()

	if !game_bg_audio_player.playing:
		game_bg_audio_player.play()

	game_bg_audio_player.pitch_scale = 1.0
	hard_mode_audio_player.pitch_scale = 1.0

	fade_in_music(game_bg_audio_player)

func _on_restart_button_pressed():
	restart_button_audio_player.play()
	if fade_animation_player.is_playing():
		await fade_animation_player.animation_finished
	fade_animation_player.play_backwards("game_over")
	reset_game()

func _on_left_area_body_entered(_body: Node2D) -> void:
	print("null area entered")
	fade_animation_player.queue("null_area")
	reset_game()


func _on_exit_button_pressed() -> void:
	exit_button_audio_player.play()
	await exit_button_audio_player.finished
	get_tree().change_scene_to_file("res://scene/main.tscn")

# 计算两球的平均x位置
func get_average_ball_position() -> float:
	return (black_ball.position.x + white_ball.position.x) / 2.0

# 根据经过的障碍物计算分数
func update_score() -> void:
	var avg_pos = get_average_ball_position()
	# 检查是否有新的障碍物被通过
	for obstacle in get_tree().get_nodes_in_group("obstacle"):
		# 如果障碍物在球的后方，且之前没有计算过分数
		if obstacle.position.x < avg_pos - 50 and not passed_obstacles.has(obstacle.get_instance_id()):
			# 记录这个障碍物已经通过
			passed_obstacles.append(obstacle.get_instance_id())
			score += 1
			game_score.text = "Score: " + str(score)
			# 检查是否达到难度提升阈值
			if score > 0 and score % difficulty_threshold == 0:
				increase_difficulty()
	# 清理已经被删除的障碍物ID
	for i in range(passed_obstacles.size() - 1, -1, -1):
		if not is_instance_valid(instance_from_id(passed_obstacles[i])):
			passed_obstacles.remove_at(i)

# 增加游戏难度
func increase_difficulty() -> void:
	difficulty_level += 1
	# obstacle_interval = max(150, 300 - difficulty_level * 30)

	obstacle_gap = max(100, 200 - difficulty_level * 10)

	if difficulty_level == 5:
		if game_bg_audio_player.playing:
			fade_out_music(game_bg_audio_player)
			await get_tree().create_timer(2.0).timeout
			game_bg_audio_player.stop()
		hard_mode_audio_player.play()
		fade_in_music(hard_mode_audio_player)
	if difficulty_level < 5:
		game_bg_audio_player.pitch_scale = 1.0 + difficulty_level * 0.01
	else:
		hard_mode_audio_player.pitch_scale = 1.0 + difficulty_level * 0.01

# 检查是否需要生成新障碍物
func check_obstacle_generation() -> void:
	var avg_pos = get_average_ball_position()
	if avg_pos > last_obstacle_position + obstacle_interval:
		last_obstacle_position = int(avg_pos / obstacle_interval) * obstacle_interval
		generate_obstacles(last_obstacle_position + obstacle_interval * 2) # 在前方生成障碍物

# 在指定位置生成障碍物
func generate_obstacles(x_position: float) -> void:

	# 为上半世界生成障碍物
	#上上
	var upper_obstacle1 = obstacle_2d.instantiate()
	# 随机高度，但确保留出足够空间给间隙和第二个障碍物
	var max_height = 360 - obstacle_gap - 50 # 确保第二个障碍物至少有50的高度
	var upper_height = randf_range(50.0, max_height) # 随机高度
	upper_obstacle1.color = Color(0, 0, 0, 1) # 黑色
	upper_obstacle1.size = Vector2(50, upper_height)
	var upper_x_offset = randf_range(-100, 100)
	upper_obstacle1.position = Vector2(x_position + upper_x_offset, -upper_height / 2)
	#上下
	var upper_obstacle2 = obstacle_2d.instantiate()
	var upper_height2 = 360 - obstacle_gap - upper_height
	upper_obstacle2.color = Color(0, 0, 0, 1) # 黑色
	upper_obstacle2.size = Vector2(50, upper_height2)
	upper_obstacle2.position = Vector2(x_position + upper_x_offset, -360 + upper_height2 / 2)
	upper_obstacle1.add_to_group("obstacle")
	upper_obstacle2.add_to_group("obstacle")
	upper_world.add_child(upper_obstacle1)
	upper_world.add_child(upper_obstacle2)
	
	var random_direction = randi_range(0, 1)
	# 为下半世界生成障碍物
	var lower_obstacle = obstacle_2d.instantiate()
	var lower_height = randf_range(50.0, 100.0) # 随机高度
	lower_obstacle.size = Vector2(50, lower_height)
	lower_obstacle.color = Color(1, 1, 1, 1) # 白色
	var lower_x_offset = randf_range(-100, 100)
	if difficulty_level >= 0:
		lower_obstacle.is_moving = true
		lower_obstacle.move_duration = randf_range(3.0, 1.0 + 0.5 / difficulty_level) # 随着难度提高，移动速度加快
	if random_direction == 0:
		lower_obstacle.position = Vector2(x_position + lower_x_offset, lower_height / 2)
		lower_obstacle.move_distance = Vector2(0, randf_range(100, 100 + difficulty_level * 25))
	else:
		lower_obstacle.position = Vector2(x_position + lower_x_offset, 360-lower_height / 2)
		lower_obstacle.move_distance = Vector2(0, -randf_range(100, 100 + difficulty_level * 25))
	lower_obstacle.add_to_group("obstacle")
	lower_world.add_child(lower_obstacle)

#创建障碍物测试
func _input(event: InputEvent) -> void:
	if not debug:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var obstacle = obstacle_2d.instantiate()
				obstacle.size = Vector2(20, 100)
				obstacle.position = get_global_mouse_position()
				obstacle.add_to_group("obstacle")
				obstacle.is_moving = true
				obstacle.move_distance = Vector2(0, 200)
				add_child(obstacle)


func _on_hard_mode_audio_player_finished() -> void:
	hard_mode_audio_player.play()
	fade_in_music(hard_mode_audio_player)


func _on_game_bg_audio_player_finished() -> void:
	game_bg_audio_player.play()
	fade_in_music(game_bg_audio_player)

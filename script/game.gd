extends Node2D
class_name Game
# 游戏状态变量
var game_over = false
var black_ball_alive = true
var white_ball_alive = true

# 获取节点引用
@onready var black_ball = $UpperWorld/BlackBall
@onready var white_ball = $LowerWorld/WhiteBall
@onready var ui_animation_player: AnimationPlayer = $GameUI/UIAnimationPlayer
@onready var game_bg_audio_player: AudioStreamPlayer = $GameBGAudioPlayer

func _ready():
	ui_animation_player.play("start")
	
	reset_game()
	
	game_bg_audio_player.volume_db = -80
	game_bg_audio_player.play()
	
	fade_in_music()

func _process(_delta):
	if not game_over:
		check_game_state()

func fade_in_music():
	var tween = create_tween()
	tween.tween_property(game_bg_audio_player, "volume_db", - 20, 2)
	tween.play()

func fade_out_music():
	var tween = create_tween()
	tween.tween_property(game_bg_audio_player, "volume_db", -80, 2)
	tween.play()

func check_game_state():
	# 检查是否两个球都死亡
	if not black_ball_alive and not white_ball_alive:
		# 两个球都死亡，游戏结束
		if black_ball.is_death_animation_finished() and white_ball.is_death_animation_finished():
			game_over = true
			show_game_over()
	elif not black_ball_alive and black_ball.is_death_animation_finished():
		# 只有黑球死亡，一秒后复活
		await get_tree().create_timer(1.0).timeout
		if not game_over: # 确保游戏还没结束
			black_ball.reset()
			black_ball_alive = true
	elif not white_ball_alive and white_ball.is_death_animation_finished():
		# 只有白球死亡，一秒后复活
		await get_tree().create_timer(1.0).timeout
		if not game_over: # 确保游戏还没结束
			white_ball.reset()
			white_ball_alive = true

func show_game_over():
	ui_animation_player.play("game_over")
	fade_out_music() # 游戏结束时淡出音乐

## 重置游戏
func reset_game():
	game_over = false
	black_ball_alive = true
	white_ball_alive = true
	# 重置球的位置和状态
	black_ball.reset()
	white_ball.reset()
	
	# 如果音乐已经停止，重新开始播放并渐入
	if !game_bg_audio_player.playing:
		game_bg_audio_player.play()
		fade_in_music()

func on_black_ball_death():
	black_ball_alive = false

func on_white_ball_death():
	white_ball_alive = false

func _on_restart_button_pressed():
	reset_game()
	fade_in_music() # 重新开始游戏时淡入音乐


func _on_left_area_body_entered(_body: Node2D) -> void:
	print("left area entered")
	ui_animation_player.play("null_area")
	await ui_animation_player.animation_finished
	reset_game()

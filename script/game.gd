extends Node2D
class_name Game
# 游戏状态变量
var game_over = false
var black_ball_alive = true
var white_ball_alive = true

@export var debug := false
# 获取节点引用
@onready var black_ball = $UpperWorld/BlackBall
@onready var white_ball = $LowerWorld/WhiteBall
@onready var game_bg_audio_player: AudioStreamPlayer = $GameBGAudioPlayer
@onready var fade_animation_player: AnimationPlayer = $UI/FadeAnimationPlayer
@onready var restart_button_audio_player: AudioStreamPlayer = $UI/GameOverFade/RestartButton/RestartButtonAudioPlayer
@onready var exit_button_audio_player: AudioStreamPlayer = $UI/GameOverFade/ExitButton/ExitButtonAudioPlayer

func _ready():
	fade_animation_player.queue("logo_fade_out")
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
	if not black_ball_alive and not white_ball_alive:
		game_over = true
		show_game_over()
	elif not black_ball_alive:
		if not game_over: 
			black_ball.reset()
			black_ball_alive = true
	elif not white_ball_alive:
		if not game_over: 
			white_ball.reset()
			white_ball_alive = true

func show_game_over():
	fade_animation_player.queue("game_over")
	fade_out_music() 

func reset_game():
	game_over = false
	black_ball_alive = true
	white_ball_alive = true
	black_ball.reset()
	white_ball.reset()
	if !game_bg_audio_player.playing:
		game_bg_audio_player.play()
		fade_in_music()

func on_black_ball_death():
	black_ball_alive = false

func on_white_ball_death():
	white_ball_alive = false

func _on_restart_button_pressed():
	restart_button_audio_player.play()
	if fade_animation_player.is_playing():
		await fade_animation_player.animation_finished
	fade_animation_player.play_backwards("game_over")
	reset_game()
	fade_in_music()

func _on_left_area_body_entered(_body: Node2D) -> void:
	print("null area entered")
	fade_animation_player.queue("null_area")
	reset_game()


func _on_exit_button_pressed() -> void:
	exit_button_audio_player.play()
	await exit_button_audio_player.finished
	get_tree().change_scene_to_file("res://scene/main.tscn")

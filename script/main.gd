extends Node
@onready var start_menu: Control = $StartMenu
@onready var animation_player: AnimationPlayer = $StartMenu/AnimationPlayer
@onready var start_music_player: AudioStreamPlayer = $StartMenu/StartMusicPlayer

var game_scene_path := "res://scene/game.tscn"

func _ready() -> void:
	play_music()

func _on_start_button_pressed() -> void:

	# 这里学习一下异步加载场景
	ResourceLoader.load_threaded_request(game_scene_path, "PackedScene")
	
	animation_player.play("start",-1,0.5)
	await animation_player.animation_finished

	var load_status = ResourceLoader.load_threaded_get_status(game_scene_path)
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(1.0).timeout
		load_status = ResourceLoader.load_threaded_get_status(game_scene_path)
		
	stop_music()
	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var game_scene = ResourceLoader.load_threaded_get(game_scene_path).instantiate()
		# get_tree().change_scene_to_packed(game_scene)
		add_child(game_scene)
	start_menu.visible = false

func play_music():
	start_music_player.volume_db = -80.0
	start_music_player.play()
	fade_in_music()

func stop_music():
	fade_out_music()
	
func fade_in_music():
	var tween = create_tween()
	tween.tween_property(start_music_player, "volume_db", -20, 1)
	tween.play()

func fade_out_music():
	var tween = create_tween()
	tween.tween_property(start_music_player, "volume_db", -80, 1)
	tween.finished.connect(start_music_player.stop)
	tween.play()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

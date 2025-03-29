extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_small_mouse_entered() -> void:
	animation_player.play("idle")

func _on_small_mouse_exited() -> void:
	animation_player.play_backwards("idle")

# 添加开始按钮点击事件处理函数
func _on_start_button_pressed() -> void:
	# 播放过渡动画（可选）
	if animation_player.has_animation("fade_out"):
		animation_player.play("fade_out")
		# 等待动画播放完成
		await animation_player.animation_finished
	
	# 切换到主游戏场景
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

# 添加退出按钮点击事件处理函数（可选）
func _on_exit_button_pressed() -> void:
	get_tree().quit()

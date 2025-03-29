extends Node2D
class_name Game
# 游戏状态变量
var game_over = false
var black_ball_alive = true
var white_ball_alive = true

# 获取节点引用
@onready var black_ball = $UpperWorld/BlackBall
@onready var white_ball = $LowerWorld/WhiteBall
@onready var ui_player: AnimationPlayer = $GameUI/UIPlayer

func _ready():
	# 初始化游戏
	#game_over_panel.visible = false
	reset_game()
	ui_player.play("game_over")

# 游戏循环
func _process(_delta):
	# 检查游戏是否结束
	if not game_over:
		check_game_state()

# 检查游戏状态
func check_game_state():
	# 检查黑球是否死亡
	if not black_ball_alive and black_ball.is_death_animation_finished():
		game_over = true
		show_game_over()
	
	# 检查白球是否死亡
	if not white_ball_alive and white_ball.is_death_animation_finished():
		game_over = true
		show_game_over()

# 显示游戏结束界面
func show_game_over():
	ui_player.play("game_over")

# 重置游戏
func reset_game():
	game_over = false
	black_ball_alive = true
	white_ball_alive = true
	
	# 重置球的位置和状态
	black_ball.reset()
	white_ball.reset()
	
	# 隐藏游戏结束界面
	#game_over_panel.visible = false

# 当黑球死亡时调用
func on_black_ball_death():
	black_ball_alive = false

# 当白球死亡时调用
func on_white_ball_death():
	white_ball_alive = false

# 重新开始按钮点击事件
func _on_restart_button_pressed():
	reset_game()

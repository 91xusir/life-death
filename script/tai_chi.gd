extends Node2D
enum BallName {White, Black}

@onready var black: Area2D = $Sprite2D/black
@onready var white: Area2D = $Sprite2D/white

var is_white_ready: bool = false
var is_black_ready: bool = false

var white_ball: BaseBall
var black_ball: BaseBall

func _on_black_body_entered(body: Node2D) -> void:
	pass

func _on_white_body_entered(body: Node2D) -> void:
	pass

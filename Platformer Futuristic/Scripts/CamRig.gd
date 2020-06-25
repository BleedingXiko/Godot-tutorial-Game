extends Node2D

onready var player = get_parent().get_node("Player")

func _ready():
	$Cam.limit_top = $CamLimits/Top.global_position.y
	$Cam.limit_bottom = $CamLimits/Bottom.global_position.y
	$Cam.limit_right = $CamLimits/Right.global_position.x
	$Cam.limit_left = $CamLimits/Left.global_position.x
	


func _process(delta):
	global_position = player.global_position

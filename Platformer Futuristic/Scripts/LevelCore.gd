extends Node2D

signal level_finished
signal level_restart

func _ready():
	$SpawnPoint.hide()
	$Player.global_position = $SpawnPoint.global_position

func level_finished(body):
	if body.is_in_group("player"):
		get_tree().paused = true
		$LevelGoal/anim.play("collected")
		yield($LevelGoal/anim, "animation_finished")
		emit_signal("level_finished")

func level_restart():
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("level_restart")


extends Node

export(int) var poole_size = 5

func _ready():
	for projectile in poole_size:
		var p = $Projectile.duplicate()
		add_child(p)

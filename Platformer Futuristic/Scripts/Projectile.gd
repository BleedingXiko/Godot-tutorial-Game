extends Area2D

export(Texture) var shot_sprite

export (String, "Player", "Enemy") var shooter = "Player"
var target_group = ""
var collision_exception = null

var damage = 0
var speed = Vector2()
var direction = Vector2(1, 0)
var velocity = Vector2()

func setup(color, _damage, _speed, _direction, start_pos):
	global_position = start_pos
	damage = _damage
	speed = _speed
	direction = _direction
	
	match shooter:
		"Player":
			target_group = "Enemy"
		"Enemy":
			target_group = "Player"
	
	
	scale.x = direction.x
	$Sprite.modulate = color
	$Sprite.texture = shot_sprite
	
	show()
	set_process(true)



func _process(delta):
	velocity = speed * direction
	position += velocity * delta





func projectile_hit_hitbox(area):
	if not visible: return
	if area.get_parent() == collision_exception: return
	
	var target = area.get_parent()
	
	if target.is_in_group(target_group):
		target.take_damage(damage)
		disable_projectile()


func projectile_hit_wall(body):
	if not visible: return
	if body == collision_exception: return
	
	disable_projectile()




func disable_projectile():
	scale = Vector2(1, 1)
	set_process(false)
	hide()

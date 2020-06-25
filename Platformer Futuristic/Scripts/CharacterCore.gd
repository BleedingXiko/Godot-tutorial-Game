extends KinematicBody2D

signal hurt
signal update_health
signal dead

var state = "Idle"
var sub_state = "Default"
var next_anim = ""
var direction = Vector2(1, 0)

export(int) var health_max = 0
onready var health_current = health_max

export(float) var gravity = 0.0
export(float) var run_speed = 0.0
export(float) var sprint_speed = 0.0
onready var move_speed = run_speed
var velocity : Vector2

export(float) var jump_force = 1
export(int) var jump_count_max
onready var jump_count = jump_count_max
export(int) var jump_duration_max
onready var jump_duration = jump_duration_max

export(int) var shot_damage = 0
export(Vector2) var shot_speed = Vector2()
var can_shoot = true





func add_gravity(delta):
	if state == "Hurt": return
	
	var gravity_mod = 0
	
	
	if state == "Fall":
		gravity_mod = 250
	
	
	velocity.y += (gravity + gravity_mod) * delta


func take_damage(amount):
	if $ImmortalDuration.time_left != 0: return
	
	health_current -= amount
	
	emit_signal("hurt")
	emit_signal("update_health", health_current)
	if health_current <= 0:
		emit_signal("dead")


func shoot(color = Color(), scale = Vector2(1, 1)):
	can_shoot = false
	
	var shot_obj
	for projectile in $Weapon/Projectiles.get_children():
		if not projectile.visible:
			shot_obj = projectile
			break
		
		
		if shot_obj == null:
			print("Charactercore | Warning Ran out of Projectiles")
			return
		
		
		shot_obj.collision_exception = self
		shot_obj.scale *= scale
		shot_obj.setup(color, shot_damage, shot_speed, direction, $Weapon/ShootPos.global_position,
		$Weapon/FireRate.start())



func get_snap():
	var snap = Vector2()
	var tile_res = 16
	
	if is_on_floor():
		snap = Vector2(tile_res, 0)
	
	
	return snap



func update_animation():
	if $CharAnim.has_animation(next_anim):
		if $CharAnim.current_animation != next_anim:
			$CharAnim.play(next_anim)
			next_anim = ""


func shooting_cooled_down():
	can_shoot = true






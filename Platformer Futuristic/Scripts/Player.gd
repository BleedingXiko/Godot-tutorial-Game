extends "res://Scripts/CharacterCore.gd"

var jump_started = false

export(int) var shot_charge_max = 100
export(int) var death_fall_height = 400
var shot_charge = 0

var charge_shot_info = {
						"Low": {"Damage": 1, "Color": Color("#6ad3f7"), "Scale": Vector2(1,1)},
						"Medium": {"Damage": 2, "Color": Color("#7dffd7"), "Scale": Vector2(1.5,1.5)},
						"High": {"Damage": 3, "Color": Color("#c8ff8c"), "Scale": Vector2(2,2)}
					}

func _ready():
	emit_signal("update_health", health_max)
	set_state("Idle")


func set_state(new_state):
	match new_state:
		"Idle":
			match sub_state:
				"Default":
					next_anim = "Idle"
				"ChargingShot":
					next_anim = "ShootIdle_Charge"
		
		"Run":
			move_speed = run_speed
			match sub_state:
				"Default":
					next_anim = "Run"
				"ChargingShot":
					next_anim = "ShootRun"
		
		"Sprint":
			move_speed = sprint_speed
			match sub_state:
				"Default":
					next_anim = "Sprint"
				"ChargingShot":
					next_anim = "ShootSprint"
		
		"Jump":
			match sub_state:
				"Default":
					next_anim = "Jump"
				"ChargingShot":
					next_anim = "ShootJump"
		
		"Hurt":
			next_anim = "Hurt"
			$ImmortalDuration.start()
			velocity *= 0
		
		"Dead":
			if state == "Dead": return
			set_physics_process(false)
			$CharAnim.play("Dead")
			yield($CharAnim, "animation_finished")
			emit_signal("dead")
		
	state = new_state



func set_sub_state(new_sub_state):
	sub_state = new_sub_state
	set_state(state)



func _physics_process(delta):
	add_gravity(delta)
	
	control_check()
	
	velocity = move_and_slide_with_snap(velocity, get_snap(), Vector2.UP, true)
	
	if global_position.y >= death_fall_height:
		set_state("Dead")
	
	state_check()
	update_animation()
	

func control_check():
	if state in ["Hurt", "Dead"]: return
	
	var move_right = Input.is_action_pressed("right")
	var move_left = Input.is_action_pressed("left")
	var sprint = Input.is_action_pressed("sprint") and is_on_floor()
	
	var jump_start = Input.is_action_just_pressed("jump") and can_start_jump()
	var jump_continue = Input.is_action_pressed("jump")
	
	var charge_shot = Input.is_action_pressed("shoot") and can_shoot
	
	
	
	
	velocity.x = 0
	
	if sprint:
		if state == "Run":
			set_state("Sprint")
	if not sprint:
		if state == "Sprint":
			set_state("Run")
	
	
	if move_right:
		velocity.x += move_speed
		direction = Vector2(1,0)
	if move_left:
		velocity.x -= move_speed
		direction = Vector2(-1,0)
	
	if jump_start:
		start_jump()
	
	if jump_continue and can_jump():
		jump_movement()
	
	
	if not jump_continue:
		if jump_started:
			jump_count -= 1
			jump_duration = jump_duration_max
			jump_started = false
	
	if charge_shot:
		shot_charge = clamp(shot_charge + 1, 0, shot_charge_max)
		set_sub_state("ChargingShot")
		update_charge_shot_preview()
		$Weapon/ChargeVisual.show()
	
	if not charge_shot and sub_state == "ChargingShot" and can_shoot:
		release_shot()



func release_shot():
	var charged_info = charge_shot_info[get_charge_level()]
	$Weapon/ChargeVisual.hide()
	shot_damage = charged_info.Damage
	shoot(charged_info.Color, charged_info.Scale)
	shot_charge = 0
	if velocity.x != 0 and is_on_floor():
		set_state("Run")
	if velocity.x == 0 and is_on_floor():
		set_state("Idle")
	if not is_on_floor():
		set_state("Fall")
	set_sub_state("Default")



func start_jump():
	velocity.y = -jump_force
	jump_started = true
	set_state("Jump")




func jump_movement():
	velocity.y -= jump_force
	
	jump_duration -= 1
	
	
	if jump_duration <= 0:
		jump_duration = jump_count_max
		jump_count -= 1
		jump_started = false



func landed():
	jump_count = jump_count_max
	jump_duration = jump_duration_max
	
	
	if velocity.x == 0:
		set_state("Idle")
	elif velocity.x != 0:
		set_state("Run")

func state_check():
	if state == "Idle":
		if velocity.x != 0:
			set_state("Run")
	
	if state in ["Run", "Sprint"]:
		if velocity.x == 0:
			set_state("Idle")
	
	if state in ["Jump", "Fall"]:
		if is_on_floor():
			landed()
	
	
	if state == "Jump":
		if not is_on_floor():
			if velocity.y > 0:
				set_state("Fall")
	
	if direction.x == 1:
		$DirectionAnim.play("Right")
	
	if direction.x == -1:
		$DirectionAnim.play("Left")


func get_charge_level():
	var power_level = "Low"
	
	if shot_charge >= shot_charge_max * 0.3:
		power_level = "Medium"
	
	if shot_charge == shot_charge_max:
		power_level = "High"
	
	return power_level

func update_charge_shot_preview():
	var power_level = get_charge_level()
	var power_tween = $Weapon/ChargeVisual/Tween
	
	power_tween.interpolate_property($Weapon/ChargeVisual/Sprite, "scale", $Weapon/ChargeVisual/Sprite.scale, charge_shot_info[power_level].Scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	power_tween.interpolate_property($Weapon/ChargeVisual/Sprite, "modulate", $Weapon/ChargeVisual/Sprite.modulate, charge_shot_info[power_level].Color, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	power_tween.start()


func can_start_jump():
	if jump_count > 0:
		return true
	
	return false

func can_jump():
	if jump_started:
		return true
	
	return false


func Char_anim_finished(anim_name):
	if anim_name == "Hurt":
		set_state("Idle")

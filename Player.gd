extends KinematicBody

var speed = 500
var rotate_speed = 2
var speed_temp = speed
var level_size = 128
var direction = Vector3()
var gravity = -10
var velocity = Vector3()
var is_moving = false
#var anim_player
var char_rot
var angle
#var anim_speed
var controller
var playerpos




# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	anim_player = $Skeleton/AnimationPlayer
#	controller = 1


			
func _physics_process(delta):
	is_moving = false
	direction = Vector3(0, 0, 0)
	playerpos = get_translation()
	#var anim_to_play

#	if controller == 1:
#		anim_to_play = "idle"
#
#	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	direction = direction.normalized()
	if abs(direction.x) > 0 || abs(direction.z) > 0:
		is_moving = true
#
#		if is_moving:
#			rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 0.1)
#			anim_to_play = "run"
#			anim_speed = 1.5
#		else:
#			anim_to_play = "idle"
#			anim_speed = 0.5
#
#		var current_anim = anim_player.get_current_animation()
#		if current_anim != anim_to_play:
#			anim_player.play(anim_to_play, -1, anim_speed, false)
#
#	else:
	if Input.is_action_pressed("ui_right"):
		rotate_y(deg2rad(-rotate_speed))
	if Input.is_action_pressed("ui_left"):
		rotate_y(deg2rad(rotate_speed))
	if Input.is_action_pressed("ui_up"):
		direction -= transform.basis.z
		is_moving = true
	if Input.is_action_pressed("ui_down"):
		direction += transform.basis.z
		is_moving = true
	
#	var next_pos = Vector3(playerpos.x+direction.x, playerpos.y, playerpos.z+direction.z)
#
#	if next_pos.x == clamp(next_pos.x, 0, level_size) && next_pos.z == clamp(next_pos.z, 0, -level_size):
#		speed_temp = speed
#	else:
#		speed_temp = 0

	var next_pos = Vector2(playerpos.x+direction.x, playerpos.z+direction.z)

	if next_pos.x == clamp(next_pos.x, 0, level_size) && next_pos.y == clamp(next_pos.y, -level_size, 0):
		speed_temp = speed
	else:
		speed_temp = 0
		
	direction = direction * speed_temp * delta

	if is_on_floor() == false:
		velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	velocity = move_and_slide_with_snap(velocity, Vector3(0, 1, 0))

	
	#Sprung:
	
	if is_on_floor() and Input.is_key_pressed(KEY_J):
		velocity.y = 10

	if Input.is_key_pressed(KEY_P):
		print(playerpos)

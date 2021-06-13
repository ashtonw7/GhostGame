extends KinematicBody2D

var test = 0

onready var sprite = $AnimatedSprite
onready var hitbox = $Hitbox
onready var hitbox_air = $HitboxAir
onready var slash = preload("res://Nodes/Player/Attacks/Slash.tscn")
onready var slash_timer = $SlashTimer
onready var left_ray = $LeftRay
onready var right_ray = $RightRay

export var speed := 75
export var gravity := 17
export var jump_speed := 265
export var friction = 0.25
export var dash_speed = 120

var attack_num = 1

var velocity = Vector2.ZERO

enum Direction {LEFT, RIGHT}
enum State {MOVING, JUMPING, DASHING, STATIONARY}

var curr_dir = Direction.RIGHT
var curr_state = State.STATIONARY

var can_dash = true

var jumps_left = 1

func _ready():
	pass # Replace with function body.
	
func handle_input():
	if curr_state != State.DASHING:
		if not Input.is_action_pressed('right') and not Input.is_action_pressed('left'):
			velocity.x = clamp(velocity.x * friction, speed * -1, speed)
			if is_on_floor():
				curr_state = State.STATIONARY
		
		else:
			if Input.is_action_pressed('right'):
				velocity.x = clamp(velocity.x + speed, speed * -1, speed)
				curr_dir = Direction.RIGHT
				curr_state = State.MOVING

			if Input.is_action_pressed('left'):
				velocity.x = clamp(velocity.x - speed, speed * -1, speed)
				curr_dir = Direction.LEFT
				curr_state = State.MOVING

		if Input.is_action_just_pressed('jump') and jumps_left > 0:
			velocity.y = jump_speed * -1
			jumps_left -= 1
			can_dash = true
		
		if Input.is_action_just_released('jump') and velocity.y < 0:
			velocity.y = 0
			
		if Input.is_action_just_pressed('attack'):
			if not has_node("Slash"): 
				var new_slash = slash.instance()
				
				attack_num = (attack_num + 1) % 2
				
				add_child(new_slash)
				
				new_slash.setup(attack_num, curr_dir)
				new_slash.play()
				
				slash_timer.start()
			
				
	if can_dash and Input.is_action_just_pressed('dash'):
		if curr_dir == Direction.RIGHT:
			velocity.x = dash_speed
		else:
			velocity.x = dash_speed * -1
		
		velocity.y = 0
		
		curr_state = State.DASHING
		can_dash = false



func handle_movement(test):
	if is_on_floor():
		jumps_left = 1
		can_dash = true
		hitbox.disabled = false
		hitbox_air.disabled = true
	else:
		hitbox_air.disabled = false
		hitbox.disabled = true

	
	if curr_state != State.DASHING:
		velocity.y = clamp(velocity.y + gravity, jump_speed * -1, gravity * 10)
		
	move_and_slide(velocity, Vector2.UP)
	
func handle_sprite():
	if curr_state != State.DASHING and sprite.animation != 'default':
		sprite.play('default')
		
	elif curr_state == State.DASHING and sprite.animation != 'dash':
		sprite.play('dash')
	
	if curr_dir == Direction.RIGHT:
		sprite.flip_h = false
	elif curr_dir == Direction.LEFT:
		sprite.flip_h = true
		
	if sprite.frame == 0:
		sprite.position.y = -2
		
	else:
		sprite.position.y = 0

func _physics_process(delta):
	test += 1
	handle_input()
	handle_sprite()
	handle_movement(test)

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == 'dash':
		velocity.x = 0
		curr_state = State.STATIONARY


func _on_SlashTimer_timeout():
	pass

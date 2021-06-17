extends KinematicBody2D

var test = 0
signal player_damage

onready var sprite = $AnimatedSprite
onready var hitbox = $Hitbox
onready var hitbox_air = $HitboxAir
onready var hurtbox = $Hurtbox/CollisionShape2D
onready var slash = preload("res://Nodes/Player/Attacks/Slash.tscn")
onready var slash_timer = $SlashTimer
onready var knockback_timer = $KnockbackTimer
onready var dash_buffer = $DashBuffer
onready var camera = $Camera2D

export var speed := 75
export var gravity := 17
export var jump_speed := 265
export var friction = 0.25
export var dash_speed = 120

var attack_num = 1

var taking_knockback = false

var velocity = Vector2.ZERO

enum Direction {LEFT, RIGHT}
enum State {MOVING, JUMPING, DASHING, STATIONARY}

var curr_dir = Direction.RIGHT
var curr_state = State.STATIONARY

var can_dash = true
var slashing = false
var dash_pressed = false

var jumps_left = 1

var invicibility = false

var health = 2

func _ready():
	pass # Replace with function body.
	
func attack():
	if not has_node("Slash"): 
		var new_slash = slash.instance()
		new_slash.connect('done_slashing', self, 'slash_done')
		
		attack_num = (attack_num + 1) % 2
		
		add_child(new_slash)
		slashing = true
		
		new_slash.setup(attack_num, curr_dir)
		new_slash.play()
		
		slash_timer.start()	
	
func handle_input():
	if curr_state != State.DASHING:
		if not taking_knockback:
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
		
		else:
			take_knockback()
			
		if Input.is_action_just_pressed('attack'):
			attack()
		
	
	if Input.is_action_just_pressed('dash'):
		dash_pressed = true
		dash_buffer.start()
				
	if can_dash and not slashing and dash_pressed:	
		if curr_dir == Direction.RIGHT:
			velocity.x = dash_speed
		else:
			velocity.x = dash_speed * -1
		
		velocity.y = 0
		
		curr_state = State.DASHING
		can_dash = false

func take_knockback():
	modulate.a = 0.5
	
	if velocity.x > speed:
		velocity.x -= speed
	elif velocity.x < speed:
		velocity.x += speed
	
	if velocity.x <= speed and velocity.x >= speed * -1:
		taking_knockback = false

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
		if not Input.is_action_pressed('down'):
			velocity.y = clamp(velocity.y + gravity, jump_speed * -1, gravity * 10)
		else:
			velocity.y = clamp(velocity.y + gravity, jump_speed * -1, gravity * 15)
		
	move_and_slide(velocity, Vector2.UP)
	
func handle_sprite():
	if curr_state != State.DASHING and sprite.animation != 'default':
		sprite.play('default')
		
	elif curr_state == State.DASHING and sprite.animation != 'dash':
		sprite.play('dash')
		invicibility = true

	if curr_dir == Direction.RIGHT and not slashing:
		sprite.flip_h = false
	elif curr_dir == Direction.LEFT and not slashing:
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
		invicibility = false


func _on_SlashTimer_timeout():
	pass


func _on_Hurtbox_area_entered(area):
	if not invicibility:
		var hit_by = area.get_parent()
		var knockback_power = hit_by.knockback_power
		var hit_pos = hit_by.global_position
		var knockback_dir = global_position.direction_to(hit_pos) * -1
		
		velocity = knockback_dir.normalized() * knockback_power
			
		taking_knockback = true
		
		invicibility = true
		
		knockback_timer.start()
		
		health -= 1
		emit_signal('player_damage')

func _on_KnockbackTimer_timeout():
	invicibility = false
	modulate.a = 1

func slash_done():
	slashing = false


func _on_DashBuffer_timeout():
	dash_pressed = false

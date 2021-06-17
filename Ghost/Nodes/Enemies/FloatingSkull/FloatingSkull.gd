extends KinematicBody2D

onready var sprite = $AnimatedSprite
onready var health_label = $HealthLabel

enum {LEFT, RIGHT}

export var direction = RIGHT
export var speed = 10
export var max_speed = 50
export var knockback_power = 500
export var health = 30
export var knockback_max = 1000

var taking_knockback = false

var most_recent_hit_id = -1

var velocity = Vector2.RIGHT

func handle_sprite():
	if direction == RIGHT:
		sprite.flip_h = true
		
	else:
		sprite.flip_h = false
		
func take_knockback():		
	if velocity.x > max_speed:
		velocity.x -= speed
	elif velocity.x < max_speed:
		velocity.x += speed
	
	if velocity.x <= max_speed and velocity.x >= max_speed * -1:
		taking_knockback = false
		
func move(delta):
	if not taking_knockback:
		if direction == RIGHT:
			velocity.x = clamp(velocity.x + speed, max_speed * -1, max_speed)	
		
		elif direction == LEFT:
			velocity.x = clamp(velocity.x - speed, max_speed * -1, max_speed)
	else:
		take_knockback()

	var collision = move_and_collide(velocity * delta)
	
	if collision:
		direction = (direction + 1) % 2
		if direction == LEFT:
			velocity.x = max_speed * -1
		else:
			velocity.x = max_speed
		handle_sprite()
	
func take_damage(damage, pos, knockback, id):
	most_recent_hit_id = id

	health -= damage
	health_label.text = str(health)
	if health <= 0:
		health_label.text = "DEAD"
		
	if pos.x > global_position.x:
		velocity.x = knockback * -1
	else:
		velocity.x = knockback
		
	taking_knockback = true
	
func _ready():
	handle_sprite()
	health_label.text = str(health)
	
	
func _physics_process(delta):
	move(delta)

extends KinematicBody2D

signal circle_completed

onready var collision_shape = $CollisionShape2D
onready var animation = $AnimatedSprite

export var speed = 150
export var knockback_power = 300

var velocity = Vector2.ZERO

var launching = false

func launch(pos):
	launching = true
	collision_shape.disabled = false
	
	velocity = global_position.direction_to(pos).normalized() * speed
	
func play(flip_h):
	if flip_h == true:
		animation.frame = 16
		animation.play('default', true)
	else:
		animation.play('default', false)

func _on_FlameCircle_animation_finished():
	animation.playing = false
	
	emit_signal('circle_completed')

func _physics_process(delta):	
	if launching:
		var collision = move_and_collide(velocity * delta)
		if collision:
			queue_free()


func _on_Hurtbox_area_entered(area):
	if launching and area.is_in_group('Player') or area.is_in_group('PlayerAttacks'):
		queue_free()

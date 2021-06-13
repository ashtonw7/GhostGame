extends Node2D

onready var sprite = $AnimatedSprite
var slash_num = 1
enum {LEFT, RIGHT}
var facing = LEFT


func setup(sn, f):
	slash_num = sn
	facing = f
	if facing == LEFT:
		sprite.flip_h = true
	sprite.frame = 0

func play():
	if slash_num == 0:
		sprite.flip_v = false
		sprite.play('slash_one')
	else:
		sprite.flip_v = true
		sprite.play('slash_one')

func _on_AnimatedSprite_animation_finished():
	queue_free()

func _process(delta):
	if facing == RIGHT: 
		global_position = Vector2(get_parent().global_position.x + 14, get_parent().global_position.y - 6)
	else:
		global_position = Vector2(get_parent().global_position.x - 16, get_parent().global_position.y - 6)

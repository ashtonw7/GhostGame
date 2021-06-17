extends Node2D

onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
var slash_num = 1
enum {LEFT, RIGHT}
var facing = LEFT
signal done_slashing

func setup(sn, f):
	slash_num = sn
	facing = f
	if facing == LEFT:
		sprite.flip_h = true
		hurtbox.position.x += 12
		
	sprite.frame = 0

func play():
	if slash_num == 0:
		sprite.flip_v = false
		sprite.position.y = 0
		sprite.play('slash_one')
	else:
		sprite.flip_v = true
		sprite.position.y = 2
		sprite.play('slash_one')

func _on_AnimatedSprite_animation_finished():
	emit_signal('done_slashing')
	queue_free()

func _process(delta):
	if facing == RIGHT: 
		global_position = Vector2(get_parent().global_position.x + 13, get_parent().global_position.y - 6)
	else:
		global_position = Vector2(get_parent().global_position.x - 16, get_parent().global_position.y - 6)

func _on_Hurtbox_area_entered(area):
	if area.is_in_group('Enemies'):
		var slash_id = get_instance_id()
		
		var enemy = area.get_parent()
		
		if enemy.most_recent_hit_id != slash_id:
			enemy.take_damage(10, get_parent().global_position, 200, slash_id)

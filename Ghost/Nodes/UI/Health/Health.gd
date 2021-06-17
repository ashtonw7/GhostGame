extends AnimatedSprite

var health = 2
var refilling = false

func refill_health(amount):
#	health += amount
	health = clamp(health + amount, 1 , 2)
	
	refilling = true
	
	if health == 2:
		animation = 'full'
		play('full', true)
		
	elif health == 1:
		animation = 'half'
		play('half', true)
		
	visible = true

func take_damage():
	refilling = false
	
	play()

	health -= 1


func _on_Health_animation_finished():
	playing = false
	
	if not refilling:
		if animation == 'full':
			animation = 'half'
		else:
			visible = false
	else:
		refilling = false

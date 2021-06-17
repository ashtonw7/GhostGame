extends Control

onready var heart_one = $Heart1
onready var heart_two = $Heart2
onready var heart_three = $Heart3

func increase_health(amount):
	if heart_one.health < 2:
		heart_one.refill_health(amount)
	elif heart_two.health < 2:
		heart_two.refill_health(amount)
	elif heart_three.health < 2:
		heart_three.refill_health(amount)

func decrease_health():
	if heart_three.health != 0:
		heart_three.take_damage()
	elif heart_two.health != 0:
		heart_two.take_damage()
	elif heart_one.health != 0:
		heart_one.take_damage()

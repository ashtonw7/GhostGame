extends Sprite

onready var tilemap = get_parent().get_node('BasicTiles')
onready var visibility = $VisibilityNotifier2D
onready var used_cells = tilemap.get_used_cells()
onready var map_limits = tilemap.get_used_rect()
onready var teleport_timer = $TeleportTimer
onready var flame_timer = $FlameTimer
onready var player = get_parent().get_node('Player')
onready var flame = preload("res://Nodes/Enemies/Wizard/Attack/FlameCircle.tscn")
onready var health_label = $HealthLabel

var most_recent_hit_id = -1

var health = 40

var knockback_power = 500

export var max_flames = 4
var flames_spawned = 0
var flames_launched = 0
var all_flames = []

var enemy_list = []

var next_coords = Vector2.ZERO

func _ready():
	randomize()
	health_label.text = str(health)
#	for node in get_parent().get_children():
#		if node.is_in_group('Enemies'):
#			enemy_list += 'Enemies'

	flame_timer.start()

func testing():
	pass
	
func get_cell(coordinates):
	return tilemap.get_cellv(coordinates)
	
func get_next_pos(previous_cell):
	var next_cell = used_cells[randi() % used_cells.size()]
	
	if next_cell == previous_cell:
		return get_next_pos(previous_cell)
	
	var one_above = Vector2(next_cell.x, next_cell.y - 1)
	var two_above = Vector2(next_cell.x, next_cell.y - 2)

	while(get_cell(one_above) != -1 or get_cell(two_above) != -1 or next_cell.y == map_limits.position.y):
		return get_next_pos(previous_cell)
	
	var next_pos = tilemap.map_to_world(next_cell)
	next_pos.x += 10
	return next_pos

func start_attack():
	flames_spawned += 1
	
	var new_flame = flame.instance()
	all_flames.append(new_flame)
	
	new_flame.connect("circle_completed", self, "launch_flame", [new_flame])
	
	get_parent().add_child(new_flame)
	
	if not flip_h:
		new_flame.global_position = Vector2(global_position.x - 2, global_position.y - 12)
	else:
		new_flame.global_position = Vector2(global_position.x, global_position.y - 12)
		
	new_flame.play(flip_h)
			
func launch_flame(flame):
	flame.launch(player.global_position)
	
	flames_launched += 1

	if flames_spawned == flames_launched:
		teleport_timer.start()

func teleport():
	flames_spawned = 0
	flames_launched = 0
	all_flames = []
	
	var curr_cell = tilemap.world_to_map(position)
	position = get_next_pos(curr_cell)
	handle_sprite()
	flame_timer.start()
	
func take_damage(damage, pos, knockback, id):
	for flame in all_flames:
		if flame:
			flame.queue_free()
	
	most_recent_hit_id = id

	health -= damage
	
	health_label.text = str(health)
	
	if health <= 0:
		health_label.text = "DEAD"
		
	teleport()
	
func handle_sprite():
	if player.position.x < position.x:
		flip_h = false
	elif player.position.x > position.x:
		flip_h = true
	
func _physics_process(delta):
	testing()


func _on_TeleportTimer_timeout():
	teleport()

func _on_FlameTimer_timeout():
	if flames_spawned != max_flames:
		start_attack()
		flame_timer.start()

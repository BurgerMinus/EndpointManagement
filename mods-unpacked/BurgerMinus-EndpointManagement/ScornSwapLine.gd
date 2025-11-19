extends Sprite2D

var anim_frame = 0
var last_frame = 3
var anim_timer = 0.05
var frame_width = 80
var speed_scale = 1.0

var persistent = true
var startpoint_target = null
var endpoint_target = null
var golem_boss = null
var lifetime = 5.0

@onready var collision_shape = $CollisionShape2D

func set_endpoints(start, end):
	startpoint_target = start
	endpoint_target = end
	global_position = start.global_position
	var dir = start.global_position.direction_to(end.global_position)
	rotation = dir.angle()
	var dist = (end.global_position - start.global_position).length()
	scale = Vector2(dist/80, 1)
	var num_tiles = dist/8
	global_position += (end.global_position - start.global_position)/2
	material.set_shader_parameter('h_tiles', num_tiles)

func _process(delta):
	anim_timer -= delta*speed_scale
	
	if persistent:
		lifetime -= delta
		if lifetime < 0.0 or not (is_instance_valid(endpoint_target) and is_instance_valid(startpoint_target)):
			queue_free()
			return
			
		set_endpoints(startpoint_target, endpoint_target)
	
	if anim_timer < 0:
		anim_timer += 0.05
		anim_frame += 1
		
		if persistent:
			if anim_frame >= last_frame:
				anim_frame = 0
				flip_v = not flip_v
				damage_intersecting_entities()
			
		else:
			if anim_frame >= last_frame:
				queue_free()
				return
				
	update_anim_frame(anim_frame)
	
func damage_intersecting_entities():
	var attack = Attack.new(golem_boss.host, 10)
	attack.stun = 0.1
	attack.ignored = [startpoint_target, endpoint_target]
	var self_attack = Attack.new(golem_boss.host, 1.5)
	if GameManager.player.true_host == startpoint_target:
		self_attack.inflict_on(startpoint_target)
	elif GameManager.player.true_host == endpoint_target:
		self_attack.inflict_on(endpoint_target)
	
	Violence.melee_attack(collision_shape, attack)

func update_anim_frame(frame_id):
	material.set_shader_parameter('region', Rect2(frame_id*frame_width, 0, frame_width, 20))

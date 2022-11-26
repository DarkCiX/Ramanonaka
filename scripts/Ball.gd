extends RigidBody

onready var original_parent = get_parent()
onready var original_collision_layer = collision_layer
onready var original_collision_mask = collision_mask

var original_transform
var speed = 6.0
var picked_up_by = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if!picked_up_by: return
	
	global_transform.origin = lerp(global_transform.origin, picked_up_by.global_transform.origin, speed * delta)

func pick_up(by):
	if picked_up_by == by:
		return
		
	if picked_up_by:
		let_go()
	
	picked_up_by = by
	original_transform = global_transform
	
	
	collision_layer = 0
	collision_mask = 0
	
	original_parent.remove_child(self)
	picked_up_by.add_child(self)
	
	global_transform = original_transform	
	
func let_go(impulse = Vector3(0.0, 0.0, 0.0)):
	if picked_up_by:
		mode = RigidBody.MODE_RIGID
		var t = global_transform
		picked_up_by.remove_child(self)
		original_parent.add_child(self)
		
		global_transform = t
		
		collision_layer = original_collision_layer
		collision_mask = original_collision_mask
		apply_impulse(Vector3(0.0, 0.0, 0.0),impulse)
		
		picked_up_by = null

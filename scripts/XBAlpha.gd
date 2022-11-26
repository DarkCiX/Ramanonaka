extends KinematicBody

export (NodePath) var Animationtree

onready var _anim_tree = get_node(Animationtree)
onready var cam = get_node("Camera")


var gravity = Vector3.ZERO

var sens = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	
func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		cam.rotation.x += -deg2rad(movement.y * sens)  
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(-90) , deg2rad(90))
		rotation.y += -deg2rad(movement.x * sens)
		

func _physics_process(delta):
	var root_motion : Transform = _anim_tree.get_root_motion_transform()
	
	var v = root_motion.origin / delta
	
	if Input.is_action_just_pressed("switch_cam"):
		if cam.current:
			cam.current = false
			get_parent().get_node("Camera").current = true
		else:
			cam.current = true
			get_parent().get_node("Camera").current = false
			

	if is_on_floor():
		gravity = Vector3.ZERO
	else:
		gravity =  Vector3(0.0 , -1 , 0.0) 
		
	
	v.y += gravity.y 
		
	
	
	if Input.is_action_pressed("forward"):
		
		_anim_tree["parameters/playback"].travel("Running")
		if Input.is_action_pressed("jump") && self.is_on_floor():

			_anim_tree["parameters/playback"].travel("Running Jump")
		
	elif Input.is_action_pressed("back"):
		
		_anim_tree["parameters/playback"].travel("Running Backward")
		
		
	elif Input.is_action_pressed("left"):
	
			_anim_tree["parameters/playback"].travel("Running left")
		

	elif Input.is_action_pressed("right"):
			_anim_tree["parameters/playback"].travel("Running right")
		
	
	else:
		
		_anim_tree["parameters/playback"].travel("Idle")
		if Input.is_action_pressed("jump") && self.is_on_floor():
			_anim_tree["parameters/playback"].travel("Jumping")
			
		
	v = v.rotated(Vector3.UP , self.rotation.y)
		
	move_and_slide(v,Vector3.UP)
	
	
	



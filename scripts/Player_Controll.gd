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
		gravity =  Vector3(0.0 , -9.93 , 0.0) 
		
	
	v += gravity 
		
	var dir : Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		dir.z += 1.0
	if Input.is_action_pressed("back"):
		dir.z -= 1.0
		
	if Input.is_action_pressed("left"):
		dir.x += 1.0

	if Input.is_action_pressed("right"):
		dir.x -= 1.0
	 
	if dir.length_squared() > 0.01:
		dir = dir.rotated(Vector3.UP, $Camera.rotation.y)

		var player_heading_2d := Vector2( self.transform.basis.z.x , self.transform.basis.z.z ) 
		var desired_heading_2d := Vector2(dir.x , dir.z)
		
		var phi : float = desired_heading_2d.angle_to(player_heading_2d)
		
		#self.rotation.y += phi 
		
		v = v.rotated(Vector3.UP , self.rotation.y)
		
		if Input.is_action_pressed("run"):
			_anim_tree["parameters/playback"].travel("Run")
		else:
			_anim_tree["parameters/playback"].travel("Walk")
	else:
		v = v.rotated(Vector3.UP , self.rotation.y)
		_anim_tree["parameters/playback"].travel("Idle")
		
	move_and_slide(v,Vector3.UP)
	



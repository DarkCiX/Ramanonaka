extends KinematicBody

export (NodePath) var Animationtree

onready var _anim_tree = get_node(Animationtree)
onready var cam = $Camera
onready var raycast = $Camera/RayCast
onready var pickpoint = $XBAlpha_In_place/Armature/Skeleton/BoneAttachment/Pick_Point

var AmIJumping = false
var AmIThrowing = false
var launcher  = false

var pickUp = false
var speed = 2
var acceleration = 20
var gravity = 9.8
var jump = 3
var capncrunch = Vector3()

var throw_force: float = 3
var picked_up = null
var collider = RigidBody

var sens = 0.2

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()

var animation_name = "Idle-loop"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	
func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		cam.rotation.x += -deg2rad(movement.y * sens)  
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(-90) , deg2rad(90))
		rotation.y += -deg2rad(movement.x * sens)
		

func _process(delta):
	
	
	if Input.is_action_just_pressed("switch_cam"):
		if cam.current:
			cam.current = false
			get_parent().get_node("Camera").current = true
		else:
			cam.current = true
			get_parent().get_node("Camera").current = false
			
	direction = Vector3()
	
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_Blending("Running Jump-loop", "Fast Run-loop" , 0.2)
	
	
	if not is_on_floor():
		fall.y -= gravity * delta
		
		
	if Input.is_action_just_pressed("jump") && self.is_on_floor() && AmIJumping == false && not Input.is_action_pressed("run") && AmIThrowing == false:
		fall.y = jump
		set_Blending(animation_name , "Simple Jump-loop" , 0.2)
		animation_name = "Simple Jump-loop"
		AmIJumping = true
		yield(get_tree().create_timer(0.7), "timeout")
		AmIJumping = false
		set_Blending(animation_name , "Idle-loop" , 0.2)
		animation_name = "Idle-loop"
	elif Input.is_action_just_pressed("jump") && self.is_on_floor() && AmIJumping == false && Input.is_action_pressed("run") && AmIThrowing == false:
		jump = 4
		fall.y = jump
		set_Blending(animation_name , "Running Jump-loop" , 0.1)
		animation_name = "Running Jump-loop"
		var old_speed= speed
		speed = 8
		AmIJumping = true
		yield(get_tree().create_timer(0.7), "timeout")
		AmIJumping = false
		speed = old_speed
		set_Blending(animation_name , "Idle-loop" , 0.2)
		jump = 3
		animation_name = "Idle-loop"
	
	#Simple Player Move
	if launcher == false:
		if raycast.is_colliding() && !picked_up:
			collider = raycast.get_collider()
			
		if Input.is_action_just_pressed("pick up"):
			if !collider or (collider && !collider.has_method("pick_up")):
				var bodies = $PickArea.get_overlapping_bodies()
				if !bodies:return
				var smallest_dist = 5
				var closest_object = null
				for body in bodies:
					var dist = global_transform.origin.distance_to(body.global_transform.origin)
					if dist < smallest_dist && body.has_method("pick_up"):
						smallest_dist = dist
						closest_object = body
				if picked_up:
					launcher = true
					return
				elif closest_object:
					closest_object.pick_up(pickpoint)
					picked_up = closest_object
					launcher = true
					
			else:
				if picked_up:return
				elif collider.has_method("pick_up"):
					collider.pick_up(pickpoint)
					picked_up = collider;
					launcher = true
					
		if Input.is_action_pressed("forward") : 
			direction += transform.basis.z
			if AmIJumping == false :
				set_Blending(animation_name , "Walking (1)-loop" , 0.2)
				animation_name = "Walking (1)-loop"
				
				if Input.is_action_pressed("run"):
					speed = 7
					set_Blending(animation_name , "Fast Run-loop" , 0.1)
					animation_name ="Fast Run-loop"
					
				if Input.is_action_just_released("run"):
					speed = 2
					set_Blending( animation_name , "Walking (1)-loop", 0.2)
					animation_name = "Walking (1)-loop"
				
				
		elif Input.is_action_just_released("forward"):
				speed = 2
				set_Blending( animation_name , "Idle-loop" , 0.2)
				animation_name = "Idle-loop"
		
		
		elif Input.is_action_pressed("back"):
			direction -= transform.basis.z
			
			if AmIJumping == false:
				set_Blending(animation_name , "Walking Backwards-loop" , 0.2)
			
				animation_name = "Walking Backwards-loop"
				if Input.is_action_pressed("run"):
					speed = 4
					set_Blending(animation_name , "Running Backward-loop" , 0.2)
					animation_name = "Running Backward-loop"
				if Input.is_action_just_released("run"):
					speed = 2
					set_Blending(animation_name , "Walking Backwards-loop" , 0.2)
					animation_name = "Walking Backwards-loop"
		elif Input.is_action_just_released("back"):
				speed = 2
				set_Blending(animation_name , "Idle-loop" , 0.2)
				animation_name = "Idle-loop"
		
		if Input.is_action_pressed("left"):
			direction += transform.basis.x
			if AmIJumping == false:
				
				set_Blending(animation_name , "Left Strafe Walking-loop" , 0.2)
				animation_name = "Left Strafe Walking-loop"
				if Input.is_action_pressed("run"):
					speed = 4
					set_Blending(animation_name , "Left Strafe-loop" , 0.2)
					animation_name = "Left Strafe-loop"
				if Input.is_action_just_released("run"):
					speed = 2
					set_Blending(animation_name , "Left Strafe Walking-loop" , 0.2)
					animation_name = "Left Strafe Walking-loop"
		elif Input.is_action_just_released("left"):
				speed = 2
				set_Blending(animation_name , "Idle-loop" , 0.2)
				animation_name = "Idle-loop"
		
		elif Input.is_action_pressed("right"):
			direction -= transform.basis.x
			if AmIJumping == false:
				
				set_Blending(animation_name , "Right Strafe Walking-loop" , 0.2)
				animation_name = "Right Strafe Walking-loop"
				if Input.is_action_pressed("run"):
					speed = 4
					set_Blending(animation_name , "Right Strafe-loop" , 0.2)
					animation_name = "Right Strafe-loop"
				if Input.is_action_just_released("run"):
					speed = 2
					set_Blending(animation_name , "Right Strafe Walking-loop" , 0.2)
					animation_name = "Right Strafe Walking-loop"
		elif Input.is_action_just_released("right"):
				speed = 2
				set_Blending(animation_name , "Idle-loop"  , 0.2)
				animation_name ="Idle-loop" 
				
	else: # Launcher Move
		if Input.is_action_just_pressed("throw"):
			if !picked_up:
				return
			AmIThrowing = true
			set_Blending(animation_name , "Throw Object-loop"  , 0.2)
			animation_name = "Throw Object-loop"
			direction = direction * 0
			yield(get_tree().create_timer(0.7), "timeout")
			
			
			picked_up.let_go(-$Camera.global_transform.basis.z * throw_force )
			yield(get_tree().create_timer(1.3), "timeout")
			AmIThrowing = false
			picked_up = null
			launcher = false
			set_Blending(animation_name , "Idle-loop"  , 0.2)
			animation_name = "Idle-loop"
		
		if Input.is_action_pressed("forward") : 
			if AmIThrowing == false :
				direction += transform.basis.z
				if AmIJumping == false :
					set_Blending(animation_name , "Standing Walk Forward-loop" , 0.2)
					animation_name = "Standing Walk Forward-loop"
					
					if Input.is_action_pressed("run"):
						speed = 7
						set_Blending(animation_name , "Standing Sprint Forward-loop" , 0.1)
						animation_name ="Standing Sprint Forward-loop"
						
					if Input.is_action_just_released("run"):
						speed = 2
						set_Blending( animation_name , "Standing Walk Forward-loop", 0.2)
						animation_name = "Standing Walk Forward-loop"
					
				
		elif Input.is_action_just_released("forward"):
				speed = 2
				set_Blending( animation_name , "Standing Idle-loop" , 0.2)
				animation_name = "Standing Idle-loop"
		
		
		elif Input.is_action_pressed("back"):
			if AmIThrowing == false :
				direction -= transform.basis.z
			
				if AmIJumping == false && AmIThrowing == false:
					set_Blending(animation_name , "Walking Backwards-loop" , 0.2)
				
					animation_name = "Walking Backwards-loop"
					if Input.is_action_pressed("run"):
						speed = 4
						set_Blending(animation_name , "Running Backward-loop" , 0.2)
						animation_name = "Running Backward-loop"
					if Input.is_action_just_released("run"):
						speed = 2
						set_Blending(animation_name , "Walking Backwards-loop" , 0.2)
						animation_name = "Walking Backwards-loop"
		elif Input.is_action_just_released("back"):
				speed = 2
				set_Blending(animation_name , "Standing Idle-loop" , 0.2)
				animation_name = "Standing Idle-loop"
		
		if Input.is_action_pressed("left"):
			if AmIThrowing == false :
				direction += transform.basis.x
				if AmIJumping == false && AmIThrowing == false:
					
					set_Blending(animation_name , "Standing Walk Left-loop" , 0.2)
					animation_name = "Standing Walk Left-loop"
					if Input.is_action_pressed("run"):
						speed = 4
						set_Blending(animation_name , " Standing Run Left-loop" , 0.2)
						animation_name = "Standing Run Left-loop"
					if Input.is_action_just_released("run"):
						speed = 2
						set_Blending(animation_name , "Standing Walk Left-loop" , 0.2)
						animation_name = "Standing Walk Left-loop"
		elif Input.is_action_just_released("left"):
				speed = 2
				set_Blending(animation_name , "Standing Idle-loop" , 0.2)
				animation_name = "Standing Idle-loop"
		
		elif Input.is_action_pressed("right"):
			if AmIThrowing == false :
				direction -= transform.basis.x
				if AmIJumping == false && AmIThrowing == false:
					
					set_Blending(animation_name , "Standing Walk Right-loop" , 0.2)
					animation_name = "Standing Walk Right-loop"
					if Input.is_action_pressed("run"):
						speed = 4
						set_Blending(animation_name , "Standing Run Right-loop" , 0.2)
						animation_name = "Standing Run Right-loop"
					if Input.is_action_just_released("run"):
						speed = 2
						set_Blending(animation_name , "Standing Walk Right-loop" , 0.2)
						animation_name = "Standing Walk Right-loop"
		elif Input.is_action_just_released("right"):
				speed = 2
				set_Blending(animation_name , "Standing Idle-loop"  , 0.2)
				animation_name ="Standing Idle-loop" 
	
			

	$XBAlpha_In_place/AnimationPlayer.play(animation_name)
	
	
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	move_and_slide(velocity, Vector3.UP)
	move_and_slide(fall,Vector3.UP)
	
	

		
	
	
	
	
func set_Blending(animation, nextanimation, time):
	$XBAlpha_In_place/AnimationPlayer.set_blend_time(animation, nextanimation , time)


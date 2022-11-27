extends KinematicBody

export (NodePath) var Animationtree

#test
export (NodePath) onready var network_tick_rate = get_node(network_tick_rate)
export (NodePath) onready var movement_tween = get_node(movement_tween)

var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector2()
#fin test

onready var _anim_tree = get_node(Animationtree)
onready var cam = $Camera
onready var raycast = $Camera/RayCast
onready var pickpoint = $XBAlpha_In_place/Armature/Skeleton/BoneAttachment/Pick_Point

var AmIJumping = false
var AmIThrowing = false
var launcher  = false
var AmIFalling = false
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
	set_Blending("Running Jump-loop", "Falling Idle-loop" , 0.5)
	set_Blending("Simple Jump-loop", "Falling Idle-loop" , 0.5)
	
	
	if not is_on_floor():
		fall.y -= gravity * delta
		if AmIJumping == false:
			AmIFalling = true
			verify_fall()
	else:
		AmIFalling = false
		verify_fall()
		

	if Input.is_action_just_pressed("jump"):
		jump()
		
	
	if Input.is_action_pressed("forward") : 
		direction += transform.basis.z
		if AmIJumping == false && AmIFalling == false:
			set_forward_anim()
			
	elif Input.is_action_just_released("forward"):
			set_idle_anim()


	elif Input.is_action_pressed("back"):
		direction -= transform.basis.z
		
		if AmIJumping == false && AmIFalling == false:
			set_backward_anim()
			
	elif Input.is_action_just_released("back"):
			set_idle_anim()

	if Input.is_action_pressed("left"):
		direction += transform.basis.x
		if AmIJumping == false && AmIFalling == false:
			set_left_anim()
			
	elif Input.is_action_just_released("left"):
			set_idle_anim()

	elif Input.is_action_pressed("right"):
		direction -= transform.basis.x
		if AmIJumping == false && AmIFalling == false:
			set_right_anim()
			
	elif Input.is_action_just_released("right"):
			set_idle_anim()


	if Input.is_action_just_pressed("pick up"):
		pick()
		
	if Input.is_action_just_pressed("throw"):
		throw()
		
	$XBAlpha_In_place/AnimationPlayer.play(animation_name)
	
	
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	move_and_slide(velocity, Vector3.UP)
	move_and_slide(fall,Vector3.UP)
	
	

		
	
	
	#Animation  functions
	
func set_Blending(animation, nextanimation, time):
	$XBAlpha_In_place/AnimationPlayer.set_blend_time(animation, nextanimation , time)

func set_forward_anim():
	 if AmIJumping == false && AmIFalling == false:
		 if launcher == true:
			 if Input.is_action_pressed("run"):
					speed = 7
					set_Blending(animation_name , "Standing Sprint Forward-loop" , 0.1)
					animation_name ="Standing Sprint Forward-loop"
			 else:
					speed = 2
					set_Blending(animation_name , "Standing Walk Forward-loop" , 0.2)
					animation_name = "Standing Walk Forward-loop"
		 else:			
			 if Input.is_action_pressed("run"):
				 speed = 7
				 set_Blending(animation_name , "Fast Run-loop" , 0.1)
				 animation_name = "Fast Run-loop"
				
			 else:
				 speed = 2
				 set_Blending(animation_name , "Walking (1)-loop" , 0.2)
				 animation_name = "Walking (1)-loop"
				
func set_backward_anim():
	 if AmIJumping == false && AmIFalling == false:
		 if Input.is_action_pressed("run"):
			 speed = 4
			 set_Blending(animation_name , "Running Backward-loop" , 0.2)
			 animation_name = "Running Backward-loop"
		 else:
			 speed = 2
			 set_Blending(animation_name , "Walking Backwards-loop" , 0.2)
			 animation_name = "Walking Backwards-loop"

func set_left_anim():
	if AmIJumping == false && AmIFalling == false:
		 if launcher == true:
			 if Input.is_action_pressed("run"):
					speed = 4
					set_Blending(animation_name , " Standing Run Left-loop" , 0.2)
					animation_name = "Standing Run Left-loop"
			 else:
					speed = 2
					set_Blending(animation_name , "Standing Walk Left-loop" , 0.2)
					animation_name = "Standing Walk Left-loop"
		 else:			
			 if Input.is_action_pressed("run"):
				 speed = 4
				 set_Blending(animation_name , "Left Strafe-loop" , 0.2)
				 animation_name = "Left Strafe-loop"
				
			 else:
				 speed = 2
				 set_Blending(animation_name , "Left Strafe Walking-loop" , 0.2)
				 animation_name = "Left Strafe Walking-loop"

func set_right_anim():
	if AmIJumping == false && AmIFalling == false:
		 if launcher == true:
			 if Input.is_action_pressed("run"):
					speed = 4
					set_Blending(animation_name , " Standing Run Right-loop" , 0.2)
					animation_name = "Standing Run Right-loop"
			 else:
					speed = 2
					set_Blending(animation_name , "Standing Walk Right-loop" , 0.2)
					animation_name = "Standing Walk Right-loop"
		 else:			
			 if Input.is_action_pressed("run"):
				 speed = 4
				 set_Blending(animation_name , "Right Strafe-loop" , 0.2)
				 animation_name = "Right Strafe-loop"
				
			 else:
				 speed = 2
				 set_Blending(animation_name , "Right Strafe Walking-loop" , 0.2)
				 animation_name = "Right Strafe Walking-loop"

func set_idle_anim():
	if launcher == false:
		set_Blending(animation_name , "Idle-loop" , 0.2)
		animation_name = "Idle-loop"
	else:
		set_Blending(animation_name , "Standing Idle-loop" , 0.2)
		animation_name = "Standing Idle-loop"

func pick():
	if raycast.is_colliding() && !picked_up:
		collider = raycast.get_collider()
	if launcher == false:
		
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

func throw():
	if launcher == true:
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
		set_idle_anim()

func jump():
	if self.is_on_floor() && AmIJumping == false &&  AmIThrowing == false:
		var anim = "Simple Jump-loop"
		var old_speed = speed
		if Input.is_action_pressed("run") :
			speed = 8
			anim = "Running Jump-loop"
		
		fall.y = jump
		AmIFalling = false
		set_Blending(animation_name , anim , 0.2)
		animation_name = anim
		AmIJumping = true
		yield(get_tree().create_timer(0.7), "timeout")
		AmIJumping = false
		speed = old_speed
		set_idle_anim()

puppet func update_state(puppet_position,puppet_velocity,puppet_rotation):
	puppet_position = puppet_position
	puppet_velocity = puppet_velocity
	puppet_rotation = puppet_rotation
	
	movement_tween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis, puppet_position), 0.1)
	movement_tween.start()


func _on_NetworkTickRate_timeout():
	if is_network_master():
		rpc_unreliable("update_state", global_transform.origin, velocity, Vector2(cam.rotate.x, rotation.y))
	else:
		network_tick_rate.stop()
func verify_fall():
	if AmIFalling == true:
		set_Blending(animation_name , "Falling Idle-loop" , 0.2)
		animation_name = "Falling Idle-loop"
	else:
		set_idle_anim()

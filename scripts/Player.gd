extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 10
var gravity = 15
var jump = 10

var cameraAcceleration = 50
var sense = .1

var snap 

var direction = Vector3()
var vel = Vector3()
var gravityVector = Vector3()
var movement = Vector3()

var throw_force: float = 2
var picked_up = null
var collider = RigidBody


onready var head = $Head
onready var camera = $Head/Camera
onready var raycast = $Head/RayCast

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * sense))
		head.rotate_x(deg2rad(-event.relative.y * sense))
		
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90),deg2rad(90))
	pass

func _physics_process(delta: float) -> void:
	direction = Vector3.ZERO
	var horizontalRot = global_transform.basis.get_euler().y
	var forwardInput = Input.get_action_strength("moveBack") - Input.get_action_strength("moveForward")
	var horizontalInput = Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")
	direction = Vector3(horizontalInput,0,forwardInput).rotated(Vector3.UP, horizontalRot).normalized()
	
	if is_on_floor():
		snap = -get_floor_normal()
		gravityVector = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		gravityVector += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():

		snap = Vector3.ZERO
		
		gravityVector = Vector3.UP * jump 
	
	if Input.is_action_pressed("run") and is_on_floor():
		speed = 25
	else:
		speed = 10
		
	vel = vel.linear_interpolate(direction*speed, delta)
	movement = vel + gravityVector
	
	move_and_slide_with_snap(movement,snap,Vector3.UP)
	
	if raycast.is_colliding() && !picked_up:
		collider = raycast.get_collider()
		
	if Input.is_action_just_pressed("lancer"):
		if !picked_up:
			return
		picked_up.let_go(-$Head/PickPoint.global_transform.basis.z * throw_force)
		picked_up = null
		
	if Input.is_action_just_pressed("pick"):
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
			if picked_up:return
			elif closest_object:
				closest_object.pick_up($Head/PickPoint)
				picked_up = closest_object
	else:
		if picked_up:return
		elif collider.has_method("pick_up"):
			collider.pick_up($Head/PickPoint)
			picked_up = collider;
	
	
	
	
	
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

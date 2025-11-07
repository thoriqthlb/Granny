extends CharacterBody3D

#Player Nodes
@onready var head: Node3D = $head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var interact_area: Area3D = $InteractArea

#Speed Vars
var current_speed = 5.0

const walk_speed = 5.0
const sprint_speed = 8.0
const crouch_speed = 3.0

#Movement Vars
const jump_velocity = 4.5
var crouch_depth = -0.5
var lerp_speed = 10


#Input Vars
var direction = Vector3.ZERO
const mouse_sense = 0.15


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Make sure the interact area is monitoring bodies
	if interact_area:
		interact_area.monitoring = true
		interact_area.monitorable = true

func _input(event: InputEvent) -> void:
	
	#Mouse
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta):
	
	#Handle Movement State
	#Crouch
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y, 1.8 + crouch_depth, delta*lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		#Stand
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta*lerp_speed)
		
		#Sprint
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed
			
			#Walk
		else:
			current_speed = walk_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Interaction: press "interact" (E) to toggle follow on a nearby NPC
	if Input.is_action_just_pressed("interact") and interact_area:
		var bodies = interact_area.get_overlapping_bodies()
		for b in bodies:
			# call NPC's toggle_follow(self) if present
			if b and b.has_method("toggle_follow"):
				b.toggle_follow(self)
				# optionally break after toggling the first NPC
				break

	move_and_slide()

extends CharacterBody3D

@export var speed: float = 4.0
@export var stopping_distance: float = 1.6
@export var rotation_speed: float = 6.0

var target: Node3D = null
var following: bool = false

# === 🧭 Navigation agent for automatic pathfinding & avoidance ===
@onready var agent: NavigationAgent3D = $NavigationAgent3D
var moving_to_location: bool = false


func _ready() -> void:
	# Enable avoidance so patients don’t block each other
	agent.avoidance_enabled = true
	agent.radius = 0.6
	agent.avoidance_layers = 1
	agent.avoidance_mask = 1
	# Optional: smoother path updates
	agent.path_max_distance = 0.5
	agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_CORRIDORFUNNEL

func move_to_location(target_position: Vector3) -> void:
	moving_to_location = true
	agent.target_position = target_position


func _physics_process(delta: float) -> void:
	# === Gravity ===
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0.0

	# === 🧭 Move using NavigationAgent ===
	if moving_to_location:
		if agent.is_navigation_finished():
			moving_to_location = false
			velocity.x = 0
			velocity.z = 0
		else:
			# Request next path point (Godot handles dynamic avoidance)
			var next_pos: Vector3 = agent.get_next_path_position()
			var dir = (next_pos - global_transform.origin).normalized()

			velocity.x = dir.x * speed
			velocity.z = dir.z * speed

			# Smoothly rotate toward next direction
			if dir.length_squared() > 0.001:
				var desired_rot_y = atan2(-dir.x, -dir.z)
				rotation.y = lerp_angle(rotation.y, desired_rot_y, rotation_speed * delta)

	# === 🧍 Follow target logic (manual follow mode) ===
	elif following and target:
		var to_target: Vector3 = target.global_transform.origin - global_transform.origin
		var horizontal = Vector3(to_target.x, 0, to_target.z)
		var dist = horizontal.length()

		if dist > stopping_distance:
			var dir = horizontal.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)
			velocity.z = move_toward(velocity.z, 0, speed * 4 * delta)

		if horizontal.length_squared() > 0.001:
			var desired_dir = horizontal.normalized()
			var desired_rot = Vector3(0, atan2(-desired_dir.x, -desired_dir.z), 0)
			var cur_rot = rotation
			cur_rot.y = lerp_angle(cur_rot.y, desired_rot.y, clamp(rotation_speed * delta, 0, 1))
			rotation = cur_rot

	else:
		velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)
		velocity.z = move_toward(velocity.z, 0, speed * 4 * delta)

	move_and_slide()


# === API ===
func start_follow(new_target: Node3D) -> void:
	if new_target:
		target = new_target
		following = true

func stop_follow() -> void:
	following = false
	target = null

func toggle_follow(new_target: Node3D) -> void:
	if following:
		stop_follow()
	else:
		start_follow(new_target)

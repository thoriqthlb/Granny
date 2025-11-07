extends CharacterBody3D

# Simple NPC follower script.
# Place this script on your NPC root (CharacterBody3D).
# It exposes start/stop/toggle API so the player can call it when pressing E.

@export var speed: float = 4.0
@export var stopping_distance: float = 1.6
@export var rotation_speed: float = 6.0

var target: Node3D = null
var following: bool = false

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		# keep a small downward velocity when on floor to remain stable
		velocity.y = 0.0

	if following and target:
		var to_target: Vector3 = target.global_transform.origin - global_transform.origin
		var horizontal = Vector3(to_target.x, 0, to_target.z)
		var dist = horizontal.length()
		if dist > stopping_distance:
			var dir = horizontal.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
		else:
			# slow down when close
			velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)
			velocity.z = move_toward(velocity.z, 0, speed * 4 * delta)

		# Smoothly rotate to face player on the Y axis
		if horizontal.length_squared() > 0.001:
			var desired_dir = horizontal.normalized()
			var desired_rot = Vector3(0, atan2(-desired_dir.x, -desired_dir.z), 0)
			var cur_rot = rotation
			cur_rot.y = lerp_angle(cur_rot.y, desired_rot.y, clamp(rotation_speed * delta, 0, 1))
			rotation = cur_rot
	else:
		# idle friction
		velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)
		velocity.z = move_toward(velocity.z, 0, speed * 4 * delta)

	move_and_slide()

# API: start following a target (usually the player)
func start_follow(new_target: Node3D) -> void:
	if new_target:
		target = new_target
		following = true

# API: stop following
func stop_follow() -> void:
	following = false
	target = null

# API: toggle follow state; if turning on, set given target
func toggle_follow(new_target: Node3D) -> void:
	if following:
		stop_follow()
	else:
		start_follow(new_target)

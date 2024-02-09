extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_flash: GPUParticles3D = $Camera3D/pistol/MuzzleFlash

const SPEED = 10.0
const JUMP_VELOCITY = 10.0

var gravity: float = 20.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera_3d.rotate_x(-event.relative.y * .005)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -PI/2, PI/2)

	if Input.is_action_just_pressed("shoot") && animation_player.current_animation != "shoot":
		_play_shoot_effects()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if animation_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO && is_on_floor():
		animation_player.play("move")
	else:
		animation_player.play("idle")

	move_and_slide()


func _play_shoot_effects() -> void:
	animation_player.stop()
	animation_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

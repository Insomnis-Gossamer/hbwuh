extends CharacterBody3D

var speed = 0.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const GROUND_DECELERATION = 0.4
const AIR_ACCEL = 0.2
const JUMP_VELOCITY = 4.5
#TODO: add sensitivity slider in-game
const SENSITIVITY = 0.003

#Stuff for head bobbing
const BOB_FREQ = 2.5
const BOB_AMP = 0.08
var t_bob = 0.0

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Get the player's mouse input and move the camera
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		#might want to change this to rotate the whole body instead of just the head
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Sprinting stuff
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = move_toward(speed, WALK_SPEED, GROUND_DECELERATION)
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# TODO: Add controller support and allow players to rebind buttons
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, (WALK_SPEED * direction.x), AIR_ACCEL)
			velocity.z = move_toward(velocity.z, (WALK_SPEED * direction.z), AIR_ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, GROUND_DECELERATION)
		velocity.z = move_toward(velocity.z, 0, GROUND_DECELERATION)
	
	#Head bob code
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	
#TODO: add accessibility setting to disable head bobbing
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(t_bob * BOB_FREQ * 0.5) * BOB_AMP
	return pos 

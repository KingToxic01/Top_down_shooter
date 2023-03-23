extends KinematicBody2D
var bullet = preload("res://Bullet.tscn")
# Export variables can be changed in the editor
# "running_speed" and "place_holder_speed" are integers that can be modified
# "mouse_speed" is a float that can be modified, with a default value of 0.8
export (int) var running_speed 
export (int) var place_holder_speed
export (float) var mouse_speed = 0.8
export (int) var bullet_speed = 1000
export (float) var fire_rate = 0.1
var can_fire : bool = true
# The velocity variable stores the player's movement speed and direction
# The "speed" variable is initialized in the _ready function
# The "running" variable keeps track of whether the player is running
var velocity = Vector2()
var speed
var running : bool = false

func _ready():
	# Set the "speed" variable to the value of "place_holder_speed"
	speed = place_holder_speed

# Called when the node enters the scene tree for the first time.
func get_input():
	# Get the position of the mouse in the global coordinate system
	var mousePos = get_global_mouse_position()
	# Get the direct space state of the world
	var space = get_world_2d().direct_space_state

	# Check if there's a collision at the mouse position
	if space.intersect_point(mousePos, 1):
		# Set the place_holder_speed to 0 if there is a collision
		place_holder_speed = 0
	else:
		# Set the place_holder_speed to running_speed if running is true, or speed otherwise
		place_holder_speed = running_speed if running else speed

	# Make the player look at the position of the mouse
	look_at(mousePos)
	# Reset the velocity vector
	velocity = Vector2()
	# Get the keyboard input
	get_keyboard()

func get_keyboard():
	# Move the player in the corresponding direction if the corresponding arrow key is pressed
	if Input.is_action_pressed("down"):
		velocity = Vector2(-place_holder_speed, 0).rotated(rotation)
	if Input.is_action_pressed("up"):
		velocity = Vector2(place_holder_speed, 0).rotated(rotation)
	if Input.is_action_pressed("left"):
		velocity = Vector2(0, -place_holder_speed).rotated(rotation)
	if Input.is_action_pressed("right"):
		velocity = Vector2(0, place_holder_speed).rotated(rotation)

	# Check if the "run" button is pressed or released, and set the speed accordingly
	if Input.is_action_pressed("run"):
		place_holder_speed = running_speed
		running = true
	elif Input.is_action_just_released("run"):
		place_holder_speed = speed
		running = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Fire") and can_fire:
		var bullet_instance = bullet.instance()
		bullet_instance.position = $BulletPoint.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(),Vector2(bullet_speed,0).rotated(rotation))
		get_tree().get_root().add_child(bullet_instance)
		can_fire = false 
		yield(get_tree().create_timer(fire_rate),"timeout")
		can_fire = true
		
	# Get the input and update the velocity vector
	get_input()
	# Move and slide the player with the updated velocity vector
	velocity = move_and_slide(velocity)

extends Camera3D

var tabout = false;

var mouseX = 0;
var mouseY = 0;
const sensitivity = 10;
var velocity = Vector3.ZERO;
var SPEED=1;
var grav = false
var shakeOffset=Vector3.ZERO
var frequency=0
var magnitude=0
var shakeTime=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !tabout:
		mouseX += event.screen_relative.y/-sensitivity;
		mouseY += event.screen_relative.x/-sensitivity;
	else:
		if Input.is_action_just_pressed("tab_out"):
			tabout=!tabout;
			if tabout:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

	


var warping=false
func _physics_process(_delta: float) -> void:
	
	rotation_degrees.x = clamp(mouseX,-90,90);
	rotation_degrees.y=mouseY;
	
	if Input.is_action_pressed("ui_accept"):
		velocity.y=SPEED;
	else:
		if Input.is_action_pressed("descend"):
			velocity.y=-SPEED;
		else:
			velocity.y=0;
	
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	global_position+=velocity;

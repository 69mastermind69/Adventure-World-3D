
extends CharacterBody3D

const SPEED = 7.0
const JUMP_FORCE = 6.5

var gravity = 18.0

func _ready():
    setup_input()

func setup_input():
    var actions = [
        "move_forward",
        "move_back",
        "move_left",
        "move_right",
        "jump"
    ]

    for action in actions:
        if not InputMap.has_action(action):
            InputMap.add_action(action)

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump"):
        if is_on_floor():
            velocity.y = JUMP_FORCE

    var input_dir = Input.get_vector(
        "move_left",
        "move_right",
        "move_forward",
        "move_back"
    )

    var direction = Vector3(
        input_dir.x,
        0,
        input_dir.y
    )

    if direction.length() > 0:
        direction = direction.normalized()

        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED

        rotation.y = lerp_angle(
            rotation.y,
            atan2(-direction.x, -direction.z),
            delta * 8.0
        )
    else:
        velocity.x = move_toward(
            velocity.x, 0, SPEED
        )

        velocity.z = move_toward(
            velocity.z, 0, SPEED
        )

    move_and_slide()

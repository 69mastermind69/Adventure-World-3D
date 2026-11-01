
extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const COIN_SCRIPT = preload("res://scripts/coin.gd")

var score := 0
var score_label: Label

func _ready():
    randomize()
    create_environment()
    create_ground()
    create_player()
    create_trees()
    create_coins()
    create_mobile_controls()
    create_hud()

func create_environment():
    var world = WorldEnvironment.new()
    var env = Environment.new()

    env.background_mode = Environment.BG_SKY

    var sky = Sky.new()
    var sky_mat = ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.12, 0.45, 0.85)
    sky_mat.sky_horizon_color = Color(0.65, 0.85, 1.0)
    sky.sky_material = sky_mat

    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.8, 0.85, 1.0)
    env.ambient_light_energy = 0.8

    world.environment = env
    add_child(world)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

func create_ground():
    var ground = StaticBody3D.new()
    ground.name = "Ground"

    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(100, 2, 100)

    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 0.55, 0.22)
    box.material = mat

    mesh.mesh = box
    mesh.position.y = -1
    ground.add_child(mesh)

    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(100, 2, 100)
    collision.shape = shape
    collision.position.y = -1
    ground.add_child(collision)

    add_child(ground)

func create_player():
    var player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 2, 8)
    player.set_script(PLAYER_SCRIPT)

    var body = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.45
    capsule.height = 1.8

    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.1, 0.3, 0.95)
    capsule.material = mat

    body.mesh = capsule
    body.position.y = 0.9
    player.add_child(body)

    var collision = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.45
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    player.add_child(collision)

    var pivot = Node3D.new()
    pivot.position.y = 1.5
    player.add_child(pivot)

    var camera = Camera3D.new()
    camera.position = Vector3(0, 2.5, 7)
    camera.rotation_degrees = Vector3(-15, 0, 0)
    camera.current = true
    pivot.add_child(camera)

    add_child(player)

func create_trees():
    for i in range(40):
        var tree = Node3D.new()

        var x = randf_range(-43, 43)
        var z = randf_range(-43, 43)

        if Vector2(x, z).length() < 11:
            continue

        tree.position = Vector3(x, 0, z)

        var trunk = MeshInstance3D.new()
        var trunk_mesh = CylinderMesh.new()
        trunk_mesh.top_radius = 0.2
        trunk_mesh.bottom_radius = 0.3
        trunk_mesh.height = 2.0

        var trunk_mat = StandardMaterial3D.new()
        trunk_mat.albedo_color = Color(0.35, 0.18, 0.08)
        trunk_mesh.material = trunk_mat

        trunk.mesh = trunk_mesh
        trunk.position.y = 1
        tree.add_child(trunk)

        var leaves = MeshInstance3D.new()
        var leaf_mesh = SphereMesh.new()
        leaf_mesh.radius = 1.2
        leaf_mesh.height = 2.2

        var leaf_mat = StandardMaterial3D.new()
        leaf_mat.albedo_color = Color(0.05, 0.38, 0.12)
        leaf_mesh.material = leaf_mat

        leaves.mesh = leaf_mesh
        leaves.position.y = 2.5
        tree.add_child(leaves)

        add_child(tree)

func create_coins():
    for i in range(20):
        var coin = Area3D.new()
        coin.set_script(COIN_SCRIPT)

        coin.position = Vector3(
            randf_range(-25, 25),
            1.1,
            randf_range(-25, 25)
        )

        var mesh = MeshInstance3D.new()
        var cylinder = CylinderMesh.new()
        cylinder.top_radius = 0.4
        cylinder.bottom_radius = 0.4
        cylinder.height = 0.12

        var gold = StandardMaterial3D.new()
        gold.albedo_color = Color(1, 0.75, 0.05)
        gold.metallic = 0.6

        cylinder.material = gold
        mesh.mesh = cylinder
        coin.add_child(mesh)

        var collision = CollisionShape3D.new()
        var shape = SphereShape3D.new()
        shape.radius = 0.7
        collision.shape = shape
        coin.add_child(collision)

        coin.coin_collected.connect(add_score)
        add_child(coin)

func create_hud():
    var canvas = CanvasLayer.new()
    add_child(canvas)

    score_label = Label.new()
    score_label.position = Vector2(25, 20)
    score_label.add_theme_font_size_override("font_size", 30)
    score_label.text = "COINS: 0"
    canvas.add_child(score_label)

func add_score():
    score += 1
    score_label.text = "COINS: " + str(score)

func create_mobile_controls():
    var canvas = CanvasLayer.new()
    canvas.name = "MobileControls"
    add_child(canvas)

    create_control_button(canvas, "UP", "move_forward",
        Vector2(120, -190), Control.PRESET_BOTTOM_LEFT)

    create_control_button(canvas, "DOWN", "move_back",
        Vector2(120, -90), Control.PRESET_BOTTOM_LEFT)

    create_control_button(canvas, "LEFT", "move_left",
        Vector2(20, -90), Control.PRESET_BOTTOM_LEFT)

    create_control_button(canvas, "RIGHT", "move_right",
        Vector2(220, -90), Control.PRESET_BOTTOM_LEFT)

    create_control_button(canvas, "JUMP", "jump",
        Vector2(-150, -110), Control.PRESET_BOTTOM_RIGHT)

func create_control_button(parent, title, action, pos, preset):
    var button = Button.new()
    button.text = title
    button.custom_minimum_size = Vector2(85, 75)
    button.size = Vector2(85, 75)
    button.set_anchors_preset(preset)
    button.position = pos

    button.add_theme_font_size_override("font_size", 20)
    parent.add_child(button)

    button.button_down.connect(
        func(): Input.action_press(action)
    )

    button.button_up.connect(
        func(): Input.action_release(action)
    )

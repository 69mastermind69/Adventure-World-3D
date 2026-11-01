
extends Area3D

signal coin_collected

var collected = false

func _ready():
    body_entered.connect(on_body_entered)

func _process(delta):
    rotate_y(delta * 2.5)

func on_body_entered(body):
    if collected:
        return

    if body.name == "Player":
        collected = true
        coin_collected.emit()
        queue_free()

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pressHold()

func pressHold():
	if Input.is_action_pressed("leftclick"):
		var a = get_global_mouse_position()
		$Whiterook.position = a

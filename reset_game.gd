extends Button

var clickonce : int = 0
var button : Rect2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("leftclick"):
		var mouse = get_global_mouse_position()
		button = Rect2i(get_global_rect())
		print(button)
		var xllimit = button.position.x
		var xhlimit = button.position.x + button.size.x
		var yllimit = button.position.y
		var yhlimit = button.position.y + button.size.y
		if mouse.x <= xllimit or mouse.x >= xhlimit or mouse.y <= yllimit or mouse.y >= yhlimit:
			clickonce = 0
			text = "RESET GAME"
			modulate = Color.WHITE


func _on_pressed() -> void:
	if clickonce == 0:
		clickonce = 1
		text = "ARE YOU SURE"
		modulate = Color.RED
		
	elif clickonce == 1:
		Global.whitetimer = 300
		Global.blacktimer = 300
		Global.increment = 0
		Global.started = false
		get_tree().reload_current_scene()

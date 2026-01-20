extends PopupMenu



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Queen", 2)
	add_item("Rook", 5)
	add_item("Bishop", 3)
	add_item("Knight", 4)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		popup(Rect2( 100, 100, 100, 100))

func _on_chess_pop_up_promotion(position2: Vector2i) -> void:
	popup(Rect2( position2.x*100+140, position2.y*100+140, 100, 100))

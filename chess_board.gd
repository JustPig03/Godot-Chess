#this draws the board
extends Node2D
var pixelOffset: int = 140
var pixelSize: int = 100
var text: bool = true
var windowSize: Vector2i

#chess notation Color
var default_font : Font = ThemeDB.fallback_font
var NumberColor = Color.BLACK

#chess notations:
var YchessNotation = ["8", "7", "6", "5", "4", "3", "2", "1"]
var XchessNotation = ["a", "b", "c", "d", "e", "f", "g", "h"]

func _ready() -> void:
	windowSize = get_viewport_rect().size   #shoudl be (1920,1080)
	$WhiteEatenValue.position = Vector2i(800, 60)
	$BlackEatenvalue.position = Vector2i(800, 970)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	## for future reference: if created a setting to update: queue redraw after clcikign save (which will prob trigger soem int or sth)

#this function is only called once and never updated
func _draw():
	for i in range(8):
		for j in range(8):
			if (i + j) % 2 == 0:
				draw_rect(Rect2( pixelSize * i + pixelOffset, pixelSize * j + pixelOffset, pixelSize, pixelSize), Color.GRAY)
			else:
				draw_rect(Rect2( pixelSize * i + pixelOffset, pixelSize * j + pixelOffset, pixelSize, pixelSize), Color.BROWN)
	
	draw_rect(Rect2(pixelOffset - 5, pixelOffset - 5, pixelSize * 8 + 10, pixelSize * 8 + 10), Color.BLACK, false, 10)
	
	if text:
		for i in range(8):
			draw_string(default_font, Vector2( pixelSize * i + pixelOffset, pixelOffset + pixelSize * 8), XchessNotation[i], HORIZONTAL_ALIGNMENT_RIGHT, 100, 25, NumberColor)
		for i in range(8):
			draw_string(default_font, Vector2( pixelOffset, pixelSize * i + pixelOffset + pixelSize), YchessNotation[i], HORIZONTAL_ALIGNMENT_LEFT, 50, 25, NumberColor)
	
	
	var panelDistance: int = pixelSize * 8 + 2 * pixelOffset
	#side panel at the side
	draw_rect( Rect2 ( panelDistance , 0, (windowSize.x - panelDistance), windowSize.x ), Color.ROSY_BROWN)
	
	#Player 1 and Player 2
	draw_rect( Rect2 ( pixelOffset, pixelOffset - 90, 190, 80), Color.BROWN)
	draw_rect( Rect2 ( pixelOffset - 5, pixelOffset - 90, 195, 85), Color.BLACK, false, 10)
	
	draw_rect( Rect2 ( pixelOffset, pixelOffset - 90 + pixelSize*8 + 100, 190, 80), Color.BROWN)
	draw_rect( Rect2 ( pixelOffset - 5, pixelOffset - 90 + pixelSize*8 + 95, 195, 85), Color.BLACK, false, 10)

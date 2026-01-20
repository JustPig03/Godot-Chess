extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	position = Vector2i(1080,140)
	var screensize = Vector2i(1920, 1080)
	size = Vector2i(screensize.x - position.x, screensize.y - position.y)
	$VBoxContainer/Shorttime/fivepluszero.modulate = Color.GREEN #original is 5+0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("leftclick"):
		var x = get_global_mouse_position()
		print(x)




func _on_open_settings_pressed() -> void:
	visible = (false if visible else true)

#add 15s to white
func _on_add_15_white_pressed() -> void:
	Global.whitetimer += 15.0

#add 60s to white
func _on_add_60_white_pressed() -> void:
	Global.whitetimer += 60.0

#add 15s to black
func _on_add_15_black_pressed() -> void:
	Global.blacktimer += 15.0

#add 60s to black
func _on_add_60_black_pressed() -> void:
	Global.blacktimer += 60.0

func disableallcolour():
	$VBoxContainer/Shorttime/onepluszero.modulate = Color.WHITE
	$VBoxContainer/Shorttime/oneplusone.modulate = Color.WHITE
	$VBoxContainer/Shorttime/threepluszero.modulate = Color.WHITE
	$VBoxContainer/Shorttime/threeplusthree.modulate = Color.WHITE
	$VBoxContainer/Shorttime/fivepluszero.modulate = Color.WHITE
	$VBoxContainer/Shorttime/fiveplusthree.modulate = Color.WHITE
	var parent = $VBoxContainer/LongerTimeControl
	
	for x in parent.get_children():
		x.modulate = Color.WHITE

func settimer(timer : int, incre : int):
	Global.whitetimer = timer
	Global.blacktimer = timer
	Global.increment = incre
	disableallcolour()

func _on_onepluszero_pressed() -> void:
	if !Global.started:
		settimer(60, 0)
		$VBoxContainer/Shorttime/onepluszero.modulate = Color.GREEN
		

func _on_oneplusone_pressed() -> void:
	if !Global.started:
		settimer(60, 1)
		$VBoxContainer/Shorttime/oneplusone.modulate = Color.GREEN


func _on_threeplusone_pressed() -> void:
	if !Global.started:
		settimer(180, 0)
		$VBoxContainer/Shorttime/threepluszero.modulate = Color.GREEN

func _on_threeplusthree_pressed() -> void:
	if !Global.started:
		settimer(180, 3)
		$VBoxContainer/Shorttime/threeplusthree.modulate = Color.GREEN


func _on_fivepluszero_pressed() -> void:
	if !Global.started:
		settimer(300, 0)
		$VBoxContainer/Shorttime/fivepluszero.modulate = Color.GREEN


func _on_fiveplusthree_pressed() -> void:
	if !Global.started:
		settimer(300, 5)
		$VBoxContainer/Shorttime/fiveplusthree.modulate = Color.GREEN


func _on_tenpluszero_pressed() -> void:
	if !Global.started:
		settimer(600, 0)
		$VBoxContainer/LongerTimeControl/tenpluszero.modulate = Color.GREEN


func _on_tenplusfive_pressed() -> void:
	if !Global.started:
		settimer(600, 5)
		$VBoxContainer/LongerTimeControl/tenplusfive.modulate = Color.GREEN

func _on_fifteenplusfive_pressed() -> void:
	if !Global.started:
		settimer(900, 5)
		$VBoxContainer/LongerTimeControl/fifteenplusfive.modulate = Color.GREEN

func _on_thirthyplusfifteen_pressed() -> void:
	if !Global.started:
		settimer(1800, 15)
		$VBoxContainer/LongerTimeControl/thirthyplusfifteen.modulate = Color.GREEN

func _on_hourplusone_pressed() -> void:
	if !Global.started:
		settimer(3600, 60)
		$VBoxContainer/LongerTimeControl/hourplusone.modulate = Color.GREEN

func _on_notime_pressed() -> void:
	if !Global.started:
		settimer(-10000, 0)
		$VBoxContainer/LongerTimeControl/Notime.modulate = Color.GREEN

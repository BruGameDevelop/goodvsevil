extends Control

# Beschreibung: Startmenü mit zwei Buttons – Spiel starten oder beenden
func _ready():
	for child in get_children():
		print(child.name)
	# Buttons über Index ansprechen
	var start_button = $".".get_child(0)
	var quit_button = $".".get_child(1)

	start_button.text = "Spiel starten"
	quit_button.text = "Spiel Beenden"

	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

# Beschreibung: Wechselt zur Hauptspielszene
func _on_start_pressed():
	get_tree().change_scene_to_file("res://szene/modecontrol.tscn")  # <- Pfad anpassen

# Beschreibung: Beendet das Spiel
func _on_quit_pressed():
	get_tree().quit()

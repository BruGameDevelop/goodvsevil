extends Control

# Beschreibung: Menü zur Auswahl des Spielmodus
var assigned_player_index := randi() % 12  # Zufällig für den Trainingsmodus, später ersetzt durch echten Spielerindex


func _ready():
	var training_button = $VBoxContainer.get_child(0)
	var multiplayer_button = $VBoxContainer.get_child(1)
	var back_button = $VBoxContainer.get_child(2)

	training_button.pressed.connect(_on_training_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_training_pressed():
	var lobby_scene = preload("res://szene/team_lobby.tscn")
	var lobby = lobby_scene.instantiate()
	lobby.local_slot_index = 0  # z. B. Spieler 0, später dynamisch zuweisen
	get_tree().root.add_child(lobby)
	hide()  # Oder: queue_free(), wenn das Menü nicht mehr gebraucht wird

func _on_multiplayer_pressed():
	print("Mehrspieler ausgewählt")
	# get_tree().change_scene_to_file("res://multiplayer_menu.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://szene/Mainmenu.tscn")  # Pfad ggf. anpassen

# MultiplayerMenu.gd
extends Control

# Referenzen
@onready var name_input = $VBoxContainer/NameInput
@onready var status_label = $VBoxContainer/StatusLabel
@onready var connect_button = $VBoxContainer/ConnectButton
@onready var menu_options = $VBoxContainer/MenuOptions
@onready var room_list_container = $RoomList
@onready var create_room_button =$VBoxContainer/MenuOptions/CreateRoomButton
@onready var id_label = $VBoxContainer/MenuOptions/PlayerID

var player_name = ""


func _ready():
	connect_button.pressed.connect(_on_connect_pressed)
	create_room_button.pressed.connect(_on_create_room_pressed)
	MultiplayerManager.connection_success.connect(_on_connected)
	MultiplayerManager.connection_failed.connect(_on_failed)
	menu_options.visible = false
	multiplayer.connected_to_server.connect(_on_connected_to_server)

# Wird beim Klick auf "Verbinden" aufgerufen
func _on_connect_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		status_label.text = "Bitte Namen eingeben."
		return

	status_label.text = "Verbinde mit Server..."
	MultiplayerManager.connect_to_server(player_name)

func _on_connected():
	status_label.text = "Verbunden als: " + MultiplayerManager.player_name
	id_label.text = "ID: " + str(multiplayer.get_unique_id())
	menu_options.visible = true

func _on_failed():
	status_label.text = "Verbindung fehlgeschlagen. Ist der Server online?"
	
func _on_connected_to_server():
	player_name = name_input.text
	MultiplayerManager.rpc_id(1, "request_room_list")
	
@rpc
func update_room_list(room_list: Array):
	print("📡 update_room_list called with: ", room_list)
	room_list_container.clear()

	for room in room_list:
		print("📁 Raum: ", room)
		var room_id = room["id"] # falls id als String ankommt
		var title = room.get("title", "Unbenannt")
		var players = room.get("players", 0)
		var max_players = room.get("max_players", 12)

		var button = Button.new()
		button.text = "%s (%d/%d)" % [title, players, max_players]
		button.name = "RoomButton_%d" % room_id

		button.pressed.connect(func():
			print("👆 Beitreten zu Raum:", room_id)
			MultiplayerManager.rpc_id(1, "request_join_room", room_id)  # ruft Server-Funktion auf
		)

		room_list_container.add_child(button)
		
func _on_create_room_pressed():
	var popup = AcceptDialog.new()
	popup.dialog_text = "Raumtitel eingeben:"
	popup.min_size = Vector2(300, 100)

	var input = LineEdit.new()
	input.name = "InputField"
	popup.add_child(input)

	popup.get_ok_button().text = "Erstellen"

	popup.confirmed.connect(func():
		var title = input.text.strip_edges()
		if title == "":
			print("⚠ Kein Titel eingegeben.")
			return

		var max_players = 12

		# Immer per RPC an dedizierten Server senden (Server hat peer_id 1)
		print("Sende RPC an Server zur Raumerstellung:", title)
		MultiplayerManager.rpc_id(1, "request_create_room", title, max_players)
	)

	add_child(popup)
	popup.popup_centered()

	# Fokus setzen NACHDEM popup im SceneTree ist
	await get_tree().process_frame
	input.grab_focus()
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://szene/modecontrol.tscn")
	
@rpc("any_peer", "call_local")
func enter_room_lobby(room_id: int):  # Änderung: int statt String
	print("➡️ Raum betreten mit ID:", room_id)
	GameState.current_room_id = str(room_id)  # falls du eine String-ID brauchst
	get_tree().change_scene_to_file("res://szene/team_lobby_multiplayer.tscn")

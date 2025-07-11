# MultiplayerManager.gd
extends Node
var server: Node
var player_name := ""
var player_id := ""
var is_connected := false
var room_list: Array = []

signal connection_success
signal connection_failed

# Stellt Verbindung zum Server her
func connect_to_server(name: String):
	player_name = name

	var peer := ENetMultiplayerPeer.new()

	# Signale **vorher** verbinden!
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)

	var error := peer.create_client("127.0.0.1", 9999)
	print("Fehlercode beim Verbindungsversuch:", error)

	if error != OK:
		emit_signal("connection_failed")
		return

	print("Client: MultiplayerPeer wird gesetzt")
	multiplayer.multiplayer_peer = peer

# Erfolgreiche Verbindung
func _on_connected():
	is_connected = true
	player_id = str(multiplayer.get_unique_id())
	print("Verbunden mit ID: ", player_id)
	print("Meine ID:", multiplayer.get_unique_id())
	 # Sende Spielernamen an Server
	MultiplayerManager.rpc_id(1, "register_player_name", player_name)
	emit_signal("connection_success")
@rpc("any_peer")  # Nur Server darf diese Methode ausführen
func register_player_name(name: String):
	# Hier Spielername speichern oder verarbeiten
	print("Spielername vom Client:", name) # wird nur auf dem Server ausgeführt
# Fehlgeschlagene Verbindung
func _on_connection_failed():
	is_connected = false
	emit_signal("connection_failed")
	
	
@rpc("authority", "call_local")  # oder "any_peer", "call_local"
func update_room_list(room_list: Array) -> void:
	print("📥 Raumliste empfangen:", room_list)
	# TODO: Liste anzeigen oder speichern
	
@rpc("any_peer")
func request_room_list():
	var client_id = multiplayer.get_remote_sender_id()
	update_room_list.rpc_id(client_id, server.get_room_list_data())
	
	
@rpc("any_peer")
func request_create_room(title: String, max_players: int):
	var client_id = multiplayer.get_remote_sender_id()
	server.request_create_room(title, max_players)
	

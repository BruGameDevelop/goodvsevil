# Server.gd
extends Node
class_name RoomDataBoy

const MAX_CLIENTS = 12
const SERVER_PORT = 9999

class RoomInfo:
	var id: int
	var title: String
	var max_players: int
	var players: Dictionary = {}
	
	func add_player(peer_id: int) -> void:
		players[peer_id] = {}
	
# Speichert verbundene Spieler mit ihrer ID
var connected_players := {}
# Räume nach Raum-ID
var rooms := {}
var next_room_id := 1

@onready var keep_alive_timer = $KeepAliveTimer
@onready var status_label := $Statuslabel
@onready var connection_button := $HBoxContainer/werda


func _ready():
	MultiplayerManager.server = self
	if multiplayer.is_server():
		print_log("✅ Server gestartet. Meine Peer-ID ist: " + str(multiplayer.get_unique_id()))
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(SERVER_PORT, MAX_CLIENTS)
	if error != OK:
		print("Fehler beim Starten des Servers: ", error)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	keep_alive_timer.timeout.connect(_on_keep_alive_tick)
	keep_alive_timer.start()
	connection_button.pressed.connect(_gibspielers)

	print_log("Server läuft auf Port " + str(SERVER_PORT))

func _on_peer_connected(id: int):
	print_log("Client verbunden mit ID: " + str(id))
	connected_players[id] = { "name": "Unbekannt" }

func _on_peer_disconnected(id: int):
	print_log("Client getrennt mit ID: " + str(id))
	connected_players.erase(id)

func _on_keep_alive_tick():
	# Debug-Ausgabe für aktive Clients
	#print_log("--- Aktive Verbindungen ---")
	#for id in connected_players.keys():
		#print_log("Spieler " + str(id))
	pass	

func register_player_name(name: String):
	var sender_id = multiplayer.get_remote_sender_id()
	print_log("🔐 Spieler" +  str(sender_id) + "meldet Namen an:" + str(name))
	if connected_players.has(sender_id):
		connected_players[sender_id].name = name
		print_log("Spieler " + str(sender_id) + " heißt jetzt: " + name)
	else:
		print_log("❌ Fehler: Spieler-ID " + str(sender_id) + " nicht im Dictionary.")
		
		

func request_create_room(title: String, max_players: int):
	var sender_id = multiplayer.get_remote_sender_id()
	print_log("📥 Server: request_create_room erhalten von Spieler " + str(sender_id))

	if max_players < 2 or max_players > 12:
		print_log("🔢 max_players Wert erhalten: " + str(max_players))
		print_log("❌ Ungültige Spieleranzahl")
		return

	# Eindeutige Raum-ID erzeugen
	var room_id = next_room_id
	
	if not connected_players.has(sender_id):
		connected_players[sender_id] = {}
		connected_players[sender_id]["room_id"] = room_id
	# Raum erstellen
	var room = RoomInfo.new()
	room.title = title
	room.max_players = max_players
	room.add_player(sender_id)
	room.id = room_id

	# Im Server speichern
	rooms[room_id] = room
	connected_players[sender_id]["room_id"] = room_id
	room.id = room_id
	next_room_id += 1

	print_log("✅ Raum erstellt: " + title + " (ID " + room_id + ") durch Spieler " + str(sender_id))

	# Sende aktualisierte Raumliste an alle Clients
	update_room_list.rpc(get_room_list_data())

	# Sende Lobby-Betreten an den Ersteller
	rpc_id(sender_id, "enter_room_lobby", room_id)
	print_log("➡️ Sende enter_room_lobby an Spieler " + str(sender_id) + " für Raum " + room_id)
	

func request_room_list():
	update_room_list.rpc_id(multiplayer.get_remote_sender_id(), get_room_list_data())

 # oder "any_peer", je nach Zweck
func update_room_list(room_list: Array) -> void:
	print("📤 update_room_list aufgerufen mit", room_list)
	# Update das UI oder speichere die Liste lokal
	

func get_room_list_data() -> Array:
	var list := []
	for room_id in rooms:
		var r = rooms[room_id]
		list.append({
			"id": r.id,
			"title": r.title,
			"players": r.players.size(),
			"max_players": r.max_players
		})
	return list	
	
	

func request_join_room(room_id: int):
	var sender_id = multiplayer.get_remote_sender_id()

	# Prüfen, ob der Raum existiert
	if not rooms.has(room_id):
		print_log("❌ Fehler: Raum " + str(room_id) + " existiert nicht.")
		return

	var room = rooms[room_id]

	# Prüfen, ob Spieler schon drin ist
	if room.players.has(sender_id):
		print_log("⚠️ Spieler " + str(sender_id) + " ist bereits in Raum " + str(room_id))
		return

	# Prüfen, ob Platz frei ist
	if room.players.size() >= room.max_players:
		print_log("❌ Raum " + str(room_id) + " ist voll.")
		return

	# Spieler hinzufügen
	
	room.add_player(sender_id)
	connected_players[sender_id]["room_id"] = room_id

	print_log("✅ Spieler " + str(sender_id) + " ist Raum " + str(room_id) + " beigetreten.")

	# Aktualisierte Raumliste an alle senden
	update_room_list.rpc(get_room_list_data())	
	
func print_log(msg):
	if status_label:
		status_label.text += str(msg) + "\n"
	print(msg)
	
func _gibspielers():
	for id in connected_players.keys():
		print_log("Spieler " + str(id))
		

func enter_room_lobby(room_id: int):
	# Auf dem Client implementieren
	pass

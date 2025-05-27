extends Node

@export var is_host: bool = true
@export var port: int = 12345
@export var peer_address: String = "127.0.0.1" # IP für Client

func _ready():
	if is_host:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(port, 2)
		get_tree().multiplayer.multiplayer_peer = peer
		print("Hosting server on port %d" % port)
	else:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(peer_address, port)
		get_tree().multiplayer.multiplayer_peer = peer
		print("Connecting to server %s:%d" % [peer_address, port])

	get_tree().multiplayer.connect("peer_connected", self, "_on_peer_connected")
	get_tree().multiplayer.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(id):
	print("Peer connected: %d" % id)

func _on_peer_disconnected(id):
	print("Peer disconnected: %d" % id)

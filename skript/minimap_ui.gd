# minimap_ui.gd
extends Control

@export var map_size := Vector2(36000, 36000)  # Größe der echten Weltkarte
@export var minimap_size := Vector2(256, 256)  # Größe des Bildes
@onready var player_marker := $MinimapBackground/PlayerMarker
var player_node: Node2D = null

func _process(delta):
	if player_node:
		update_marker_position()

func set_player_node(node: Node2D):
	player_node = node

func update_marker_position():
	# Spielerposition in Welt
	var pos = player_node.global_position

	# Verhältnis berechnen
	var scale = minimap_size / map_size
	var minimap_pos = pos * scale

	# Markerposition setzen (relativ zum Minimapbild)
	player_marker.position = minimap_pos
	

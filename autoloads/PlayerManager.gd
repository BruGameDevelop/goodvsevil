extends Node

## Globale Verwaltung aller Spieler
var player_container : Node = null
var player_scene : PackedScene = preload("res://szene/spieler.tscn")

# Muss vom Trainingsmodus oder der Hauptszene gesetzt werden!
func set_container(container: Node) -> void:
	player_container = container

func spawn_player(position: Vector2, klasse_name: String, is_local_player := false) -> Node2D:
	if player_container == null:
		push_error("❌ PlayerContainer wurde nicht gesetzt!")
		return null

	var instance = player_scene.instantiate()
	instance.position = position

	var klasse_path = "res://szene/klassen/%s.tres" % klasse_name
	var klasse = load(klasse_path)
	if klasse == null:
		push_error("❌ Klasse konnte nicht geladen werden: %s" % klasse_path)
		return null

	instance.set_klasse(klasse)

	player_container.add_child(instance)

	if is_local_player:
		var cam = player_container.get_node_or_null("../Camera2D")
		if cam:
			cam.set("spieler_ref", instance)

	return instance

extends Node2D

@export var player_scene : PackedScene
@onready var spawnpunkte_node = $PlayerSpawner  # Prüfen, ob korrekt

var spawn_data := {
	"Team1": {
		"Rot": { "klasse": "hellrot", "spawnpoint_name": "Spawnpoint_Hellrot" },
		"Blau": { "klasse": "hellblau", "spawnpoint_name": "Spawnpoint_Hellblau" },
	},
	"Team2": {
	"Gruen": { "klasse": "dunkelgruen", "spawnpoint_name": "Spawnpoint_Dunkelgruen" },
	"Rot": { "klasse": "dunkelrot", "spawnpoint_name": "Spawnpoint_Dunkelrot" }
	}
					}

func _ready() -> void:
	var team = GameState.local_team
	var color = GameState.local_color

	# SpielerContainer setzen
	var container = get_node_or_null("PlayerContainer")
	if container:
		PlayerManager.set_container(container)
	else:
		push_error("❌ PlayerContainer nicht gefunden!")
		return

	# Spawn-Daten prüfen
	if not (spawn_data.has(team) and spawn_data[team].has(color)):
		push_error("❌ Ungültige Team/Farbe-Kombination: %s / %s" % [team, color])
		return

	var player_info = spawn_data[team][color]
	var klasse_name = player_info["klasse"]
	var spawn_name = player_info["spawnpoint_name"]
	var spawn_point = spawnpunkte_node.get_node_or_null(spawn_name)
	if spawn_point == null:
		push_error("❌ Spawnpunkt '%s' nicht gefunden!" % spawn_name)
		return

	# Spieler spawnen und referenzieren
	var player = PlayerManager.spawn_player(spawn_point.global_position, klasse_name, true)
	GameState.player_instance = player

	# Kamera an Spieler koppeln (optional)
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.set("spieler_ref", player)

	# HUD laden und Ziel setzen
	var hud_scene = preload("res://szene/hud.tscn").instantiate()
	add_child(hud_scene)
	hud_scene.set_player_reference(player)

	

	

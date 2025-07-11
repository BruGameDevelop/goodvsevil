extends Control

@onready var progress = $ProgressBar
@onready var timer = $Timer
@onready var spawn_data = {
	"Team1": {
		"Rot": {
			"class": preload("res://szene/klassen/hellrot.tres"),
			"spawn_name": "HellrotSpawn"
		},
		# ...
	},
	"Team2": {
		"Rot": {
			"class": preload("res://szene/klassen/dunkelrot.tres"),
			"spawn_name": "DunkelrotSpawn"
		},
		# ggf. weitere Farben/Klassen
	}

}


func _ready():
	print("🟡 Ladebildschirm gestartet...")
	await get_tree().process_frame

	_prepare_player()

	if progress:
		progress.value = 0
		progress.max_value = 100
		progress.modulate = Color.YELLOW

		var tween := create_tween()
		tween.tween_property(progress, "value", 100, 2)

	await get_tree().create_timer(2).timeout
	print("✅ Ladezeit vorbei – wechsle zur Spielszene...")
	get_tree().change_scene_to_file("res://szene/trainingsmode.tscn")

func _on_load_complete():
	print("✅ Ladezeit vorbei – wechsle zur Spielszene...")
	# Hier kannst du später Map, Spielinstanz, o. ä. laden:
	get_tree().change_scene_to_file("res://szene/trainingsmode.tscn")
	
	
func _prepare_player():
	var team = GameState.local_team
	var color = GameState.local_color

	var data = spawn_data[team][color]
	var player_scene = preload("res://szene/spieler.tscn")
	var player = player_scene.instantiate()

	player.current_class = data["class"]
	
	GameState.spawn_name = data["spawn_name"]
	GameState.player_instance = player

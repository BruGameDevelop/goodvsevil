# GameManager.gd
extends Node


var quest_activated := false

func _ready():
	set_process(true)
	

func _process(delta):
	
	GameState.seconds_since_round_start += delta
	if not quest_activated and GameState.seconds_since_round_start >= 5:
		print("→ Bedingung erfüllt, aktiviere Quest!")
		quest_activated = true
		activate_start_quest()# Beispiel: Quest bei Rundenstart aktivieren
		
func activate_start_quest():
	print("Starte activate_start_quest()")
	var quest = load("res://szene/quests/start_destroy_stones.tres")
	print("Quest geladen:", quest, "Typ:", typeof(quest))
	
	QuestManager.activate_quest(quest)
	spawn_start_steine()

func spawn_start_steine():
	for i in range(3):
		var stein = preload("res://szene/hellrotquest1stein.tscn").instantiate()
		stein.position = Vector2(12250 + i * 100, 650)
		get_tree().current_scene.add_child(stein)

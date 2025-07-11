# quest_manager.gd
extends Node

var active_quests: Dictionary = {}
var all_quests: Array[QuestResource] = []
var completed_quests: Dictionary = {}
var quest_progress: Dictionary = {}
var seconds_since_round_start := 0
var hud_ref: Node = null

func _ready():
#	hud_ref = get_tree().get_root().get_node("/root/Trainingsmode/HUD") # z. B. "World/HUD"
	pass
	
func _process(_delta):
	
	if hud_ref == null:
		return
	
	var time = hud_ref.spielzeit_ticks
	var power = GameState.local_powerlevel
	
	for quest in all_quests:
		if not active_quests.has(quest.quest_id) and not completed_quests.has(quest.quest_id):
			if time >= quest.min_game_time and power >= quest.min_powerlevel:
				activate_quest(quest)

func activate_quest(quest: QuestResource):
	active_quests[quest.quest_id] = quest
	print("Aktiviere Quest: %s" % quest.title)
	spawn_quest_objects(quest) # 🪨 Hier passiert der Spawn
	#QuestUI.show_quest_popup(quest) # z. B. HUD-Panel
	#MinimapUI.ping_position(quest.quest_ping_position)
	
func report_progress(quest_id: String, amount: int = 1):
	if not active_quests.has(quest_id): return
	quest_progress[quest_id] = quest_progress.get(quest_id, 0) + amount

	if quest_progress[quest_id] >= 3:
		complete_quest(quest_id)

func complete_quest(quest_id: String):
	completed_quests[quest_id] = true
	active_quests.erase(quest_id)
	print("Quest abgeschlossen:", quest_id)
	#QuestUI.show_quest_completed_popup(quest_id)
	
	
func spawn_quest_objects(quest: QuestResource):
	for spawn_info in quest.spawn_objects:
		var scene_path = spawn_info.get("scene_path", "")
		if scene_path == "":
#			push_error("Fehlender scene_path in spawn_info: %s" % spawn_info)
			continue
		var scene = load(scene_path)
		if not scene:
#			push_error("Konnte Szene nicht laden: %s" % scene_path)
			continue
		var instance = scene.instantiate()
		instance.global_position = spawn_info.get("position", Vector2.ZERO)
		get_tree().get_current_scene().add_child(instance)
		print("Spawning:", scene_path, "at", spawn_info["position"])

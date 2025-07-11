# quest_resource.gd
extends Resource
class_name QuestResource

@export var quest_id: String
@export var title: String
@export var description: String
@export var is_repeatable: bool = false

@export var min_powerlevel: int = 0
@export var min_game_time: int = 0 # Sekunden
@export var quest_type: String = "start" # "start", "scalable", "final", "boss"
@export var quest_ping_position: Vector2 = Vector2.ZERO # Karte/Minimap-Position
@export var spawn_objects: Array[Dictionary] = [] 

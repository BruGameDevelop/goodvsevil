# zerstörbarer_stein.gd
extends Area2D

@export var quest_id: String = "start_destroy_3_stones"
@export var max_health: int = 100
var current_health: int

func _ready():
	current_health = max_health

# Diese Funktion wird vom Angriff aufgerufen
func take_damage(amount: int, attacker):
	current_health -= amount
	print("Stein HP:", current_health, "nach Schaden:", amount)
	if current_health <= 0:
		QuestManager.report_progress(quest_id, 1)
		queue_free()

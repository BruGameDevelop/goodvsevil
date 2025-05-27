extends Area2D

@export var damage: int = 40
@export var duration: float = 0.2
var attacker = null  # <- Hier speichern wir den Spieler

func _ready():
	$CollisionShape2D.disabled = false
	# Hitbox verschwindet nach kurzer Zeit
	await get_tree().create_timer(duration).timeout
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage, attacker)

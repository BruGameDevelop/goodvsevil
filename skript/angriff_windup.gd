extends Node2D

@export var windup_time: float = 0.8
@export var active_time: float = 0.2
@export var attack_scene: PackedScene

var attacker: Node = null
var offset: Vector2 = Vector2.ZERO
var rotation_offset: float = 0.0

@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

func _ready():
	# Collider deaktivieren, optisch vorbereiten
	shape.disabled = true
	sprite.modulate = Color(1, 1, 0, 0.5)

	# Offset zur Elternposition (Spieler) merken
	offset = position
	rotation_offset = rotation

	connect("body_entered", Callable(self, "_on_body_entered"))

	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 0.5), windup_time)

	await get_tree().create_timer(windup_time).timeout

	# Nun Angriff auslösen
	_spawn_attack()
	queue_free()

func _process(_delta):
	if attacker:
		global_position = attacker.global_position + offset.rotated(attacker.global_rotation)
		rotation = attacker.global_rotation + rotation_offset
		
func initialize_windup(p_attacker: Node, p_offset: Vector2, p_rotation_offset: float):
	attacker = p_attacker
	offset = p_offset
	rotation_offset = p_rotation_offset
# Funktion: Angriff auslösen an gleicher Stelle & Rotation
func _spawn_attack():
	if not attack_scene:
		return

	var attack = attack_scene.instantiate()
	attack.position = self.position
	attack.rotation = rotation

	# Nur attacker wird ggf. übergeben
	if "attacker" in attack:
		attack.attacker = attacker

	get_parent().add_child(attack)

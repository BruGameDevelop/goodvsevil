extends CharacterBody2D

signal npc_died
@export var max_health = 100
@export var power_reward = 1

var current_health = max_health
var player = null
var is_aggressive = false
var power_level = 1
# Speichert, ob der Creep sichtbar ist
var is_visible_in_light := false
var spawn_position: Vector2
var chase_timer: Timer
var attacker = null

@onready var health_bar = $lebensbalkencreep
@onready var power_label = $powerlevelcreep

func _ready():
	add_to_group("fog_sensitive")
	visible = false
	health_bar.max_value = max_health
	health_bar.value = current_health
	power_label.text =  str(power_level)
	power_label.position = Vector2(0, -60)
	health_bar.position = Vector2(-30, -40)
	spawn_position = global_position
	
	# Timer initialisieren
	chase_timer = Timer.new()
	chase_timer.wait_time = 30.0
	chase_timer.one_shot = true
	chase_timer.autostart = false
	add_child(chase_timer)
	chase_timer.connect("timeout", Callable(self, "_on_chase_timer_timeout"))
	
func _process(delta):
	if is_aggressive and attacker and attacker.is_inside_tree():
		# NPC verfolgt den Angreifer
		var direction = (attacker.global_position - global_position).normalized()
		velocity = direction * 100  # Geschwindigkeit anpassen
		move_and_slide()
	else:
		# NPC läuft zurück zum Spawnpunkt
		var direction = (spawn_position - global_position)
		if direction.length() > 5:  # kleine Toleranz
			velocity = direction.normalized() * 80  # Rückkehrgeschwindigkeit
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			
func update_visibility(player_position: Vector2, light_radius: float):
	var dist = global_position.distance_to(player_position)
	is_visible_in_light = dist <= light_radius
	visible = is_visible_in_light
func show_in_light():
	visible = true
func hide_in_darkness():
	visible = false
	
func take_damage(amount,attacker):
	print("Schaden erhalten:", amount, "von:", attacker.name)
	current_health -= amount
	health_bar.value = current_health
	is_aggressive = true  # Optional: Wird aggressiv, wenn gdetroffen
	chase_player(amount, attacker)
	

	if current_health <= 0:
		emit_signal("npc_died", self)
		die(attacker)

func die(killer):
	if killer != null:
		killer.power_level += power_reward
	
	queue_free()
func chase_player(damage: int, attacker) -> void:
	is_aggressive = true
	self.attacker = attacker

	if chase_timer.is_stopped():
		chase_timer.start()
	else:
		var time_left = chase_timer.time_left
		if time_left < 15.0:
			chase_timer.start(15.0)
		else:
			chase_timer.start(30.0)
			
func _on_chase_timer_timeout() -> void:
	is_aggressive = false
	attacker = null

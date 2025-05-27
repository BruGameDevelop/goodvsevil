extends CharacterBody2D

@onready var attack_zone_scene = preload("res://szene/angriff.tscn")
@onready var attack_spawn_point = $angriffspawn
@onready var power_label = $powerlevel
@onready var stamina_bar = $ausdauerbalken


const SPEED = 300
const ACCELERATION = 1000
const FRICTION = 800
const SPRINT_FORCE = 600
const SPRINT_DURATION = 0.2
const SPRINT_COOLDOWN = 1.0
const ATTACK_COOLDOWN = 0.5

var angle = 0
var sprint_timer = 0.0
var sprint_cooldown_timer = 0.0
var is_sprinting = false
var sprint_velocity = Vector2.ZERO
var attack_cooldown = 0.0
var power_level = 1
var stamina = 100.0
var max_stamina = 100.0
var stamina_regen_timer = 0.0
var last_input_time = 0.0
var stamina_regen_delay = 5.0  # Sekunden
var stamina_regen_rate = 100.0  # wie viel Ausdauer pro Sekunde
var health = 1
var stamina_depleted = false

func _ready():
	power_label.position = Vector2(0, -60)
	stamina_bar.position = Vector2(-30, -40)



func _process(delta):
	# Bewegungstracker
	if velocity.length_squared() > 0:
		last_input_time = 0.0
		if not stamina_depleted:
			stamina_regen_timer = 0.0
	else:
		last_input_time += delta

	# Ausdauer-Regeneration
	if not stamina_depleted:
		if last_input_time >= stamina_regen_delay:
			stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
	else:
		# Ausdauer aufgebraucht, nicht bewegen
		if last_input_time >= stamina_regen_delay:
			stamina_depleted = false
			stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
			
	# Ausdauerbegrenzung
	if stamina < 0:
		stamina = 0
	if stamina == 0:
		stamina_depleted = true

	# Cooldowns aktualisieren
	if sprint_cooldown_timer > 0:
		sprint_cooldown_timer -= delta
	if sprint_timer > 0:
		sprint_timer -= delta
	else:
		is_sprinting = false

	if attack_cooldown > 0:
		attack_cooldown -= delta

	var input_dir = Input.get_vector("links", "rechts", "hoch", "runter")
	# Marker Stuff
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	attack_spawn_point.position = direction * 35
	attack_spawn_point.rotation = direction.angle()

	# Sprint aktivieren
	if Input.is_action_just_pressed("sprint") and input_dir.length() > 0 and sprint_cooldown_timer <= 0 and not stamina_depleted:
		sprint_velocity = input_dir.normalized() * SPRINT_FORCE
		sprint_timer = SPRINT_DURATION
		sprint_cooldown_timer = SPRINT_COOLDOWN
		is_sprinting = true
		stamina -= 20

	# Angriff aktivieren
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0 and not stamina_depleted:
		perform_attack()
		attack_cooldown = ATTACK_COOLDOWN
		stamina -= 15

	# Bewegung
	if is_sprinting:
		velocity = sprint_velocity
	elif not stamina_depleted:
		if input_dir.length() > 0:
			angle = int(round(input_dir.angle() / (PI / 4))) % 8
			var target_velocity = input_dir.normalized() * SPEED
			velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = Vector2.ZERO

	# GUI aktualisieren
	power_label.text = str(power_level)
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina

	move_and_slide()

func perform_attack():
	var angriff = attack_zone_scene.instantiate()
	angriff.position = attack_spawn_point.position
	angriff.rotation = attack_spawn_point.rotation
	angriff.attacker = self  # Spieler wird als Angreifer übergeben!
	add_child(angriff)

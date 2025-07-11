extends CharacterBody2D

@onready var attack_zone_scene = preload("res://szene/angriff.tscn")
@onready var attack_spawn_point = $angriffspawn
@onready var power_label = $powerlevel
@onready var stamina_bar = $ausdauerbalken
@onready var light_area = $LightArea

const SPEED = 300
const ACCELERATION = 1000
const FRICTION = 800
const SPRINT_FORCE = 600
const SPRINT_DURATION = 0.2
const SPRINT_COOLDOWN = 1.0
const ATTACK_COOLDOWN = 1.5

var angle = 0
var sprint_timer = 0.0
var sprint_cooldown_timer = 0.0
var is_sprinting = false
var sprint_velocity = Vector2.ZERO
var attack_cooldown = 0.0
var power_level = 1
var current_class : PlayerClassResource  # Basisklassen-Referenz
var stamina = 100.0
var max_stamina = 100.0
var stamina_regen_timer = 0.0
var regen_boost_timer = 0.0  # misst die Boostzeit
var last_input_time = 0.0
var stamina_regen_delay = 5.0  # Sekunden
var stamina_regen_boost_duration = 3.0  # Sekunden mit schneller Regeneration
var normal_stamina_regen_rate = 10.0
var stamina_regen_rate = normal_stamina_regen_rate  # wie viel Ausdauer pro Sekunde
var boosted_stamina_regen_rate = 100.0
var health = 1
var stamina_depleted = false
@onready var trainingsmode = get_tree().root.get_node("Trainingsmode")
@onready var hud = trainingsmode.get_node("HUD")

func _ready():
	
	
	if current_class:
		print("🟥 Klasse zugewiesen:", current_class.name)
	power_label.position = Vector2(0, -60)
	stamina_bar.position = Vector2(-30, -40)
	$LightArea.body_entered.connect(_on_light_body_entered)
	$LightArea.body_exited.connect(_on_light_body_exited)
	hud = get_tree().get_root().get_node("Trainingmode/HUD")  # Pfad ggf. anpassen!
	if hud:
		hud.set_player_reference(self)
	
	
	
func _process(delta):
	# Bewegungstracker
	if velocity.length_squared() > 0:
		last_input_time = 0.0
	else:
		last_input_time += delta

	# Ausdauer-Regeneration
	if not stamina_depleted:
		# Boost-Phase läuft?
		if regen_boost_timer > 0:
			regen_boost_timer -= delta
			stamina_regen_rate = boosted_stamina_regen_rate
		else:
			stamina_regen_rate = normal_stamina_regen_rate

		stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
	else:
		# In Erschöpfungs-Phase: Countdown läuft
		stamina_regen_timer += delta
		if stamina_regen_timer >= stamina_regen_delay:
			# Boost starten
			stamina_depleted = false
			regen_boost_timer = stamina_regen_boost_duration
			stamina_regen_timer = 0.0

	# Ausdauerbegrenzung
	stamina = clamp(stamina, 0, max_stamina)

# Erschöpfungs-Logik
	if stamina == 0 and not stamina_depleted:
		stamina_depleted = true
		stamina_regen_timer = 0.0  # Startet die Wartezeit

# Wenn man nach der Pause regenerieren darf:
	if stamina_depleted:
		stamina_regen_timer += delta
	if stamina_regen_timer >= stamina_regen_delay:
		stamina_depleted = false
		regen_boost_timer = stamina_regen_boost_duration
		stamina_regen_timer = 0.0

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

		
		
# Wird ausgelöst, wenn ein Creep den Lichtbereich betritt
func _on_light_body_entered(body):
	if body.is_in_group("fog_sensitive"):
		body.show_in_light()
		
func _on_light_body_exited(body):
	if body.is_in_group("fog_sensitive"):
		body.hide_in_darkness()
		
func perform_attack():
	var _angriff = attack_zone_scene.instantiate()
	var windup = preload("res://szene/angriff_windup.tscn").instantiate()
	add_child(windup)
	
	var offset = attack_spawn_point.position
	var rotation_offset = (attack_spawn_point.global_position - global_position).angle()

	windup.position = offset
	windup.rotation = rotation_offset
	windup.initialize_windup(self, offset, rotation_offset)
	windup.attacker = self
	windup.attack_scene = preload("res://szene/angriff.tscn")
	#alterstuff
	#get_parent().add_child(windup)
	#var angriff = attack_zone_scene.instantiate()
	#angriff.position = attack_spawn_point.position
	#angriff.rotation = attack_spawn_point.rotation
	#angriff.attacker = self  # Spieler wird als Angreifer übergeben!
	#add_child(angriff)
	
	
func set_klasse(k: PlayerClassResource) -> void:
	current_class = k
	print("✅ Klasse gesetzt:", current_class.name)
func get_stamina():
	return {
		"current": stamina,
		"max": max_stamina
	}
	
func get_health():
	return {
		"current": health,
		"max": 1  # Später: max_health
	}	

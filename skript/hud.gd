extends CanvasLayer

@onready var leben_bar = $MarginContainer/VBoxContainer/Leben
@onready var ausdauer_bar = $MarginContainer/VBoxContainer/Ausdauer
@onready var ressourcen_bar = $MarginContainer/VBoxContainer/Energie
@onready var spielzeit_label = $TimeClock/Spielzeit
@onready var tageszeit_label = $TimeClock/Tageszeit
@onready var skill_slots = $Skillbar/HBoxContainer
@onready var charakter_portrait = $Characterportrait
@onready var minimap = $MinimapUI
var spielzeit_ticks := 0
var tick_timer := 0.0

func _ready():
	# Dummy-Werte zum Testen
	set_leben(75, 100)
	set_ausdauer(40, 100)
	set_ressource(0, 100) # leer, weil klassenabhängig
	#update_zeit(780) # 13:00 Uhr (13*60 = 780)

	for i in range(5):
			var slot = Label.new()
			slot.text = "Skill %d" % (i + 1)
			slot.custom_minimum_size = Vector2(64, 64)
			slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			skill_slots.add_child(slot)
func _process(delta):
	tick_timer += delta
	if tick_timer >= 1.0:
		tick_timer -= 1.0
		spielzeit_ticks += 1
		GameState.seconds_since_round_start = spielzeit_ticks
		update_zeit(spielzeit_ticks)
		
			
func set_leben(value: float, max_value: float):
	leben_bar.value = value
	leben_bar.max_value = max_value

func set_ausdauer(value: float, max_value: float):
	ausdauer_bar.value = value
	ausdauer_bar.max_value = max_value

func set_ressource(value: float, max_value: float):
	ressourcen_bar.value = value
	ressourcen_bar.max_value = max_value

func update_zeit(ticks: int):
	spielzeit_label.text = "Zeit: %02d:%02d" % [ticks / 60, ticks % 60]
	tageszeit_label.text = "Tageszeit: %s" % get_tageszeit_name(ticks)

func get_tageszeit_name(ticks: int) -> String:
	var zeit_im_zyklus = ticks % 600  # 10 Minuten-Zyklus (600 Sekunden)

	if zeit_im_zyklus < 120:
		return "Morgen"
	elif zeit_im_zyklus < 300:
		return "Tag"
	elif zeit_im_zyklus < 420:
		return "Abend"
	else:
		return "Nacht"
		
func set_player_reference(player: Node2D):
	minimap.set_player_node(player)
	# Wenn Spieler Health oder Stamina als Variable hat:
	if player.has_method("get_health"):
		var health = player.get_health()
		set_leben(health.current, health.max)
	if player.has_method("get_stamina"):
		var stamina = player.get_stamina()
		set_ausdauer(stamina.current, stamina.max)

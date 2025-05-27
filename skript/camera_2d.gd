extends Camera2D

@export var rand_bereich := 30              # Pixel vom Bildschirmrand für Bewegung
@export var scroll_speed := 500.0           # Geschwindigkeit der freien Kamera
@export_node_path("Node2D") var spieler_pfad : NodePath = "../TileMapLayer/spieler"

var folge_spieler := true
var spieler_ref : Node2D

func _ready():
	spieler_ref = get_node(spieler_pfad)
	make_current()

func _process(delta):
	if folge_spieler and is_instance_valid(spieler_ref):
		global_position = global_position.lerp(spieler_ref.global_position, delta * 5)
	elif not folge_spieler:
		bewegung_durch_maus(delta)
		
	if Input.is_action_just_pressed("einheiteins"):
		folge_spieler = true
	if Input.is_action_just_pressed("raus"):
		folge_spieler = false
			


func bewegung_durch_maus(delta):
	var maus_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	var bewegung := Vector2.ZERO

	if maus_pos.x <= rand_bereich:
		bewegung.x = -1
	elif maus_pos.x >= screen_size.x - rand_bereich:
		bewegung.x = 1

	if maus_pos.y <= rand_bereich:
		bewegung.y = -1
	elif maus_pos.y >= screen_size.y - rand_bereich:
		bewegung.y = 1

	if bewegung != Vector2.ZERO:
		global_position += bewegung.normalized() * scroll_speed * delta

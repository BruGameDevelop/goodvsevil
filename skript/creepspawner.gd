extends Node2D
@onready var npc_scene = preload("res://szene/creep.tscn")
@onready var spawn_timer: Timer = $Timer


@export var spawn_interval: float = 5.0


var current_npc = null

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	if current_npc == null or not is_instance_valid(current_npc):
		if npc_scene:
			current_npc = npc_scene.instantiate()
			get_parent().add_child(current_npc)
			current_npc.global_position = global_position
			#current_npc.npc_died.connect(_on_npc_died)

			

			# Tod-Signal verbinden
			current_npc.connect("npc_died",Callable(self, "_on_npc_died"))
	else:
		spawn_timer.start()

func _on_npc_died(_creep):
	current_npc = null
	spawn_timer.start()

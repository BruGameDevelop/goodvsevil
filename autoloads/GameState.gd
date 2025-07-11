extends Node

# Globale Spielstatus-Variablen
var local_slot_index: int = -1
var is_training_mode := false
# Team des lokalen Spielers ("Team1" oder "Team2")
var local_team: String = ""
var seconds_since_round_start: int = 0

# Farbe des lokalen Spielers (z. B. "Rot", "Blau" usw.)
var local_color: String = ""

# Die Klasse des lokalen Spielers (optional, wenn du sie dort speichern willst)
var local_class = null

# Der gewählte Spawnpunkt (Name des Spawn-Nodes)
var spawn_name: String = ""

# Referenz zur vorbereiteten Spielerinstanz
var player_instance: Node = null

	

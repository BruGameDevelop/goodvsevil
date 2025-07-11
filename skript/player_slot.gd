extends HBoxContainer
class_name PlayerSlot

# Referenzen auf die UI-Elemente
@onready var name_field = $NameField
@onready var color_dropdown = $ColorDropdown
@onready var ready_check = $ReadyCheck
@onready var team_switch_button = $TeamswitchButton
var is_editable := false
var current_team: String = ""
var selected_color: String = ""

# Signale
signal color_selected(index: int, color: String)
signal ready_state_changed(is_ready: bool)
signal team_change_requested(slot: PlayerSlot)

func _ready():
	# Dropdown befüllen
	color_dropdown.clear()
	color_dropdown.add_item("Keine Auswahl")
	color_dropdown.add_item("Rot")
	color_dropdown.add_item("Blau")
	color_dropdown.add_item("Grün")
	color_dropdown.add_item("Gelb")
	color_dropdown.add_item("Weiß")
	color_dropdown.add_item("Schwarz")

	# Event-Verbindungen
	color_dropdown.item_selected.connect(_on_color_selected)
	ready_check.toggled.connect(_on_ready_toggled)

	# Teamswitch-Button verbinden
	team_switch_button.pressed.connect(_on_team_button_pressed)

	# Button anfangs ausblenden
	team_switch_button.visible = false

func _on_team_button_pressed():
	if is_editable:
		emit_signal("team_change_requested", self)

func _on_color_selected(index: int):
	selected_color = color_dropdown.get_item_text(index)
	var color = color_dropdown.get_item_text(index)
	if color == "Keine Auswahl":
		ready_check.set_pressed(false)
		ready_check.disabled = true
	else:
		ready_check.set_pressed(false)  # Ready-Status zurücksetzen
		ready_check.disabled = false

	_update_team_switch_visibility()
	emit_signal("color_selected", index, color)

func _on_ready_toggled(pressed: bool):
	_update_team_switch_visibility()
	emit_signal("ready_state_changed", pressed)

func set_editable(value: bool):
	is_editable = value
	name_field.editable = value
	color_dropdown.disabled = not value
	ready_check.disabled = not value or (color_dropdown.selected == 0)

	# 🔄 Sichtbarkeit des Teamwechselbuttons aktualisieren
	_update_team_switch_visibility()
	
func _update_team_switch_visibility():
	GameState.local_team = current_team
	GameState.local_color = selected_color
	var is_ready = ready_check.button_pressed
	team_switch_button.visible = is_editable and not is_ready
	#print("🔘 TeamSwitch sichtbar:", team_switch_button.visible, " editable:", is_editable, " ready:", is_ready)
	
func get_data() -> Dictionary:
	return {
		"name": name_field.text,
		"color_index": color_dropdown.selected,
		"ready": ready_check.button_pressed
	}

func apply_data(data: Dictionary) -> void:
	name_field.text = data.get("name", "")
	color_dropdown.select(data.get("color_index", 0))
	ready_check.button_pressed = data.get("ready", false)

	# Ready-Status sperrt Felder, aber nur sichtbar bei set_editable
	# set_editable kümmert sich um alle Abhängigkeiten!
func set_team(team_name: String) -> void:
	current_team = team_name
	_update_team_switch_visibility()
	
func clear():
	name_field.text = ""
	color_dropdown.select(0)  # "Keine Auswahl"
	ready_check.button_pressed = false
	ready_check.disabled = true
	# NICHT set_editable(false) hier, sonst wird der Slot fälschlich deaktiviert
func get_selected_color() -> String:
	if not is_instance_valid(color_dropdown):
		return "Keine Auswahl"
	return color_dropdown.get_item_text(color_dropdown.selected)

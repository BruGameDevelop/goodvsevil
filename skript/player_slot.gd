extends HBoxContainer
class_name PlayerSlot

# Referenzen auf die UI-Elemente
@onready var name_field = $NameField
@onready var color_dropdown = $ColorDropdown
@onready var ready_check = $ReadyCheck
@onready var team_switch_button = $"../../../TeamswitchButton"
var is_editable := false

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
	var color = color_dropdown.get_item_text(index)
	if color == "Keine Auswahl":
		ready_check.button_pressed = false
		ready_check.disabled = true
	else:
		ready_check.disabled = false
	emit_signal("color_selected", index, color)


func _on_ready_toggled(pressed: bool):
	emit_signal("ready_state_changed", pressed)


func set_editable(value: bool):
	is_editable = value
	name_field.editable = value
	color_dropdown.disabled = not value
	ready_check.disabled = not value
	team_switch_button.visible = value

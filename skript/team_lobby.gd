extends Control

@onready var start_button = $StartButton
@onready var team1_container = $TeamsContainer/Team1Container
@onready var team2_container = $TeamsContainer/Team2Container
@onready var farb_popup = $ErrorLabel  # Jetzt ein AcceptDialog

var farben = ["Rot", "Blau", "Grün", "Gelb", "Weiß", "Schwarz"]
var all_slots: Array[PlayerSlot] = []
var assigned_index: int = -1  # Wird beim Laden vom vorherigen Menü gesetzt
var local_slot_index := -1  # Wird von außen gesetzt


func _ready():
	var team1 = team1_container.get_children()
	var team2 = team2_container.get_children()
	var all_containers = team1_container.get_children() + team2_container.get_children()
	for i in all_containers.size():
		var slot = all_containers[i]
		if slot is PlayerSlot:
			all_slots.append(slot)
			slot.set_editable(i == assigned_index)
			slot.ready_state_changed.connect(_on_ready_state_changed)
			slot.team_change_requested.connect(_on_team_change_requested)
	
	for slot in team1 + team2:
		if slot is PlayerSlot:
			all_slots.append(slot)
			slot.ready_state_changed.connect(_on_ready_state_changed)
			slot.color_selected.connect(_on_farbe_changed.bind(slot))
			slot.team_change_requested.connect(_on_team_change_requested.bind(slot))
			
			# Nur der zugewiesene Slot wird editierbar
	_init_local_player_slot()

func _on_ready_state_changed(_ready):
	# Prüfen, ob alle belegten Spieler bereit sind
	var all_ready = true
	for slot in all_slots:
		if slot.color_dropdown.selected == 0:
			continue # Slot leer
		if not slot.ready_check.button_pressed:
			all_ready = false
	start_button.disabled = not all_ready

func _on_farbe_changed(index: int, new_value: String, changed_slot):
	if new_value == "Keine Auswahl":
		return
		
	# Prüfen, ob die Farbe schon im gleichen Team verwendet wird
	for slot in all_slots:
		if slot == changed_slot:
			continue
		if is_same_team(slot, changed_slot):
			var slot_farbe = slot.color_dropdown.get_item_text(slot.color_dropdown.selected)
			if slot_farbe == new_value:
				changed_slot.color_dropdown.select(0)  # Zurücksetzen
				show_farb_error()
				return

func is_same_team(slot_a, slot_b) -> bool:
	return slot_a.get_parent() == slot_b.get_parent()

	# Farbe ist gültig → alles ok, Bereitschaft wird im Slot verwaltet
func _on_team_change_requested(from_slot: PlayerSlot):
	var from_index = all_slots.find(from_slot)
	var from_team = team1_container if team1_container.get_children().has(from_slot) else team2_container
	var to_team = team2_container if from_team == team1_container else team1_container

	# Finde freien Slot im Zielteam
	for slot in to_team.get_children():
		if slot.player_name.text == "":
			# Slot wechseln
			var from_data = from_slot.get_data()
			from_slot.clear()
			from_slot.set_editable(false)

			slot.apply_data(from_data)
			slot.set_editable(true)
			slot.color_dropdown.select(0)
			slot.ready_check.button_pressed = false
			slot.ready_check.disabled = true

			# UI neu prüfen (Start-Button)
			_on_ready_state_changed(true)
			return

	# Wenn kein freier Slot gefunden wurde
	show_voll_error()
func _init_local_player_slot():
	if local_slot_index >= 0 and local_slot_index < all_slots.size():
		all_slots[local_slot_index].set_editable(true)
			
func show_farb_error():
	farb_popup.dialog_text = "Farbe bereits vergeben!"
	farb_popup.popup_centered()

func show_voll_error():
		farb_popup.dialog_text = "Team bereits voll"
		farb_popup.popup_centered()

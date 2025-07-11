extends Control

@onready var start_button = $StartButton
@onready var team1_container = $TeamsContainer/Team1Container
@onready var team2_container = $TeamsContainer/Team2Container
@onready var farb_popup = $ErrorLabel  # Jetzt ein AcceptDialog
@onready var back_button = $BackButton  
@onready var countdown_timer: Timer = $CountdownTimer
@onready var countdown_label: Label = $CountdownLabel
var RoomInfo = preload("res://server/server.gd").new()


var farben = ["Rot", "Blau", "Grün", "Gelb", "Weiß", "Schwarz"]
var all_slots: Array[PlayerSlot] = []
var assigned_index: int = -1  # Wird beim Laden vom vorherigen Menü gesetzt
var local_slot_index := -1  # Wird von außen gesetzt
var countdown_time := 10

func _ready():
	_connect_ready_signals()
	countdown_timer.timeout.connect(_on_countdown_tick)
	if not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
	local_slot_index = GameState.local_slot_index
	if GameState.is_training_mode:
		_setup_for_training_mode()
	back_button.pressed.connect(on_back_button_pressed)
	all_slots.clear()
	var all_containers = team1_container.get_children() + team2_container.get_children()
	
	for slot in get_tree().get_nodes_in_group("player_slots"):
		if slot is PlayerSlot and slot.has_signal("ready_state_changed"):
			if not slot.is_connected("ready_state_changed", Callable(self, "_on_ready_state_changed")):
				slot.connect("ready_state_changed", Callable(self, "_on_ready_state_changed"))
		else:
			print("⚠️ Ignoriere Node in player_slots-Gruppe: ", slot.name, " (", slot.get_class(), ")")
			
	for i in range(all_containers.size()):
		var slot = all_containers[i]
		if slot is PlayerSlot:
			all_slots.append(slot)
 # <- HIER könnte das Problem liegen
		if not slot.ready_state_changed.is_connected(_on_ready_state_changed):
			slot.ready_state_changed.connect(_on_ready_state_changed)

		if not slot.team_change_requested.is_connected(_on_team_change_requested):
			slot.team_change_requested.connect(_on_team_change_requested)

		if not slot.color_selected.is_connected(_on_farbe_changed):
			slot.color_selected.connect(_on_farbe_changed.bind(slot))
	
	_init_local_player_slot()
	

func _on_ready_state_changed(_pressed):
	var all_ready = true
	var sloty = get_node_or_null("Team1/PlayerSlot_" + str(GameState.local_slot_index))
	if not sloty:
		sloty = get_node_or_null("Team2/PlayerSlot_" + str(GameState.local_slot_index))

	if sloty:
		print("Aktueller Spieler ist in Team:", sloty.get_parent().name, "mit Farbe:", sloty.get_selected_color())
		
	for slot in all_slots:
		if slot == null:
			continue
		if not slot.has_node("ColorDropdown"):
			continue  # Noch nicht fertig initialisiert
		
		if slot.color_dropdown.selected == 0:
			continue # Slot leer
		
		if not slot.ready_check.button_pressed:
			all_ready = false
	start_button.disabled = not all_ready

func _on_farbe_changed(_index: int, new_value: String, changed_slot):
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
				_refresh_all_slots()
				return

	# Farbe ist gültig → Slots aktualisieren
	_refresh_all_slots()

func is_same_team(slot_a, slot_b) -> bool:
	return slot_a.get_parent() == slot_b.get_parent()

	# Farbe ist gültig → alles ok, Bereitschaft wird im Slot verwaltet

func _on_team_change_requested(from_slot: PlayerSlot):
	if from_slot.ready_check.button_pressed:
		print("❌ Teamwechsel nicht möglich, Spieler ist bereit")
		return

	print("🔁 Versuche, Team zu wechseln...")
	var from_team = from_slot.get_parent()
	var to_team = team2_container if from_team == team1_container else team1_container

	for slot in to_team.get_children():
		if slot is PlayerSlot and slot.name_field.text == "":
			# Speicher Index in Slotliste
			var from_index = all_slots.find(from_slot)
			var to_index = all_slots.find(slot)

			var _from_data = from_slot.get_data()

			# Zielslot entfernen (Platzhalter)
			to_team.remove_child(slot)

			# Ursprungslot aus Team entfernen
			from_team.remove_child(from_slot)

			# Ursprungslot in Zielteam einfügen (Position übernehmen)
			to_team.add_child(from_slot)

			# Update Slot-Liste
			all_slots[to_index] = from_slot

			# Leeren Slot neu erstellen und an freie Position setzen
			var new_empty_slot := preload("res://szene/player_slot.tscn").instantiate()
			from_team.add_child(new_empty_slot)
			all_slots[from_index] = new_empty_slot

			# Editierbarkeit
			from_slot.set_editable(true)
			new_empty_slot.set_editable(false)

			local_slot_index = to_index
			print("📦 Spieler ist jetzt in Team: ", from_slot.get_parent().name)
			print("🎨 Farbe: ", from_slot.get_selected_color())
			_on_ready_state_changed(true)
			_refresh_all_slots()
			print("✅ Slot erfolgreich verschoben")
			return

	show_voll_error()

	
func _refresh_all_slots():
	print("🔄 Aktualisiere alle Slots...")
	for i in all_slots.size():
		var slot = all_slots[i]
		var is_local = slot == all_slots[local_slot_index]
		var is_ready = slot.ready_check.button_pressed
		print("Slot %d → local:%s ready:%s" % [i, is_local, is_ready])
		
		var editable = is_local and not is_ready
		print("🔧 Slot %d → editable: %s" % [i, editable])
		slot.set_editable(editable)
			
						
func _init_local_player_slot():
	print("🧪 Initialisiere lokalen Slot mit Index:", local_slot_index)
	for slot in all_slots:
		slot.set_editable(false)

	if local_slot_index >= 0 and local_slot_index < all_slots.size():
		all_slots[local_slot_index].set_editable(true)
		print("✅ Slot", local_slot_index, "wurde editierbar gemacht!")
	else:
		print("❌ Kein gültiger Slot-Index gesetzt.")


func show_farb_error():
	farb_popup.dialog_text = "Farbe bereits vergeben!"
	farb_popup.popup_centered()

func show_voll_error():
		farb_popup.dialog_text = "Team bereits voll"
		farb_popup.popup_centered()


func on_back_button_pressed():
		# Informiere Server, dass Spieler den Raum verlässt
	rpc_id(1, "leave_room", GameState.current_room_id)

	get_tree().change_scene_to_file("res://szene/multiplayer_menu.tscn")
	_reset_lobby_state()

func _on_start_button_pressed():
	# Schritt 1: Sperre alle Slots
	for slot in all_slots:
		slot.set_editable(false)

	start_button.disabled = true
	back_button.disabled = true

	countdown_label.visible = true
	countdown_label.text = str(countdown_time)
	countdown_label.add_theme_color_override("font_color", Color.RED)

	countdown_time = 10
	countdown_timer.start()

	
		#countdown_time -= 1
		#countdown_label.text = str(countdown_time)
		

	print("✅ Countdown beendet, starte Spielvorbereitung...")
	#countdown_timer.queue_free()
	#countdown_label.queue_free()
	
	var local_slot: PlayerSlot = null
	# Prüfe erst Team1
	var team1_container = get_node("TeamsContainer/Team1Container")
	for slot in team1_container.get_children():
		# Beispiel: Nimm den ersten Slot mit einer Farbauswahl (oder einer anderen Logik)
		if slot.get_selected_color() != "Keine Auswahl":
			local_slot = slot
			GameState.local_team = "Team1"
			break
	
	# Wenn kein Slot in Team1, prüfe Team2
	if local_slot == null:
		var team2_container = get_node("TeamsContainer/Team2Container")
		for slot in team2_container.get_children():
			if slot.get_selected_color() != "Keine Auswahl":
				local_slot = slot
				GameState.local_team = "Team2"
				break
	
	# Falls local_slot gefunden wurde, setze Farbe und starte Spiel
	if local_slot != null:
		GameState.local_color = local_slot.get_selected_color()
	#	_start_game()
	#else:
	#	print("⚠️ Kein Spieler-Slot mit Farbe gefunden, Spielstart abgebrochen")
		# Optional: Countdown abbrechen und Buttons wieder freischalten

	countdown_timer.start()
	
func _validate_lobby() -> bool:
	var team1_colors := []
	var team2_colors := []

	for slot in all_slots:
		# Nur belegte Slots prüfen
		if slot.name_field.text.strip_edges() == "":
			continue

		if slot.color_dropdown.selected == 0 or not slot.ready_check.button_pressed:
			return false  # Ungültig

		var color = slot.color_dropdown.get_item_text(slot.color_dropdown.selected)
		if slot.get_parent() == team1_container:
			if color in team1_colors:
				return false
			team1_colors.append(color)
		else:
			if color in team2_colors:
				return false
			team2_colors.append(color)

	return true
	
func _reset_lobby_state():
	print("🔁 Setze Lobby zurück")
	for slot in all_slots:
		var is_local = slot == all_slots[local_slot_index]
		slot.set_editable(is_local and not slot.ready_check.button_pressed)

	start_button.disabled = false
	back_button.disabled = false

func _start_game():
	var loader_scene = preload("res://szene/Ladebildschirm.tscn")
	if loader_scene:
		var loader = loader_scene.instantiate()
		add_child(loader)
		hide()
	else:
		print("❌ Ladebildschirm konnte nicht geladen werden!")


func start_countdown():
	countdown_timer.stop()  # Sicherheitshalber stoppen, falls er noch läuft
	countdown_time = 10
	countdown_label.visible = true
	countdown_label.text = str(countdown_time)
	countdown_timer.start()

func _on_countdown_tick():
	countdown_time -= 1

	if countdown_time <= 0:
		countdown_label.text = "Start!"
		countdown_timer.stop()
		print("🚀 Countdown abgeschlossen!")
# Ladebildschirm vorbereiten
		var ladebildschirm_scene = load("res://szene/Ladebildschirm.tscn")
		if ladebildschirm_scene:
			get_tree().change_scene_to_packed(ladebildschirm_scene)
		else:
			push_error("❌ Konnte Ladebildschirm.tscn nicht laden!")
		return# Wichtig: kein weiterer Code soll ausgeführt werden!

	# Nur wenn countdown > 0
	countdown_label.text = str(countdown_time)
	print("⏳ Countdown: ", countdown_time)
func _setup_for_training_mode():
	print("🧪 Trainingsmodus aktiviert")
	for slot in all_slots:
		slot.set_editable(false)
	if all_slots.size() > 0:
		all_slots[0].set_editable(true)
		all_slots[0].name_field.text = "Spieler 1"
		all_slots[0].ready_check.button_pressed = true
		all_slots[0].color_dropdown.select(1)  # z. B. "Rot"
		_on_ready_state_changed(true)
		
func _connect_ready_signals():
	for slot in get_tree().get_nodes_in_group("player_slots"):
		if slot is PlayerSlot and slot.has_signal("ready_state_changed"):
			slot.connect("ready_state_changed", Callable(self, "_on_ready_state_changed"))
		else:
			print("⚠️ Ungültiger Node in Gruppe 'player_slots': ", slot.name, " (", slot.get_class(), ")")
			
@rpc("any_peer")
func request_slot_update(name: String, color: String, team: String, ready: bool):
	if multiplayer.is_server():
		var peer_id = multiplayer.get_remote_sender_id()
		print("📡 Slot-Update von Peer ", peer_id, ": ", name, color, team, ready)
		RoomInfo.update_player_data(peer_id, name, color, team, ready)
		# An alle senden
		_sync_lobby_state()
		
@rpc("authority")
func _sync_lobby_state():
	for peer_id in RoomInfo.players:
		var player_data = RoomInfo.players[peer_id]
		rpc_id(peer_id, "_apply_lobby_state", RoomInfo.players)
		
@rpc("any_peer")
func _apply_lobby_state(data: Dictionary):
	# Hier wendest du das erhaltene Dictionary auf die Slots an:
	for i in data.size():
		var entry = data.values()[i]
		var slot = all_slots[i]
		slot.name_field.text = entry["name"]
		slot.color_dropdown.select(farben.find(entry["color"]) + 1)
		slot.ready_check.button_pressed = entry["ready"]
		slot.set_editable(false)

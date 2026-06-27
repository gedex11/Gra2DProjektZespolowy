extends Node

signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)

var quests: Dictionary = {
	"kill_enemies": {
		"name": "Zabójca Potworów",
		"description": "Zabij 5 potworów na dowolnym poziomie.",
		"target": 5,
		"current": 0,
		"completed": false,
		"reward_exp": 200
	}
}

var ui_canvas: CanvasLayer
var ui_panel: Panel
var ui_label: RichTextLabel
var is_ui_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		_toggle_ui()

func _create_ui() -> void:
	ui_canvas = CanvasLayer.new()
	ui_canvas.layer = 100
	add_child(ui_canvas)
	
	ui_panel = Panel.new()
	ui_panel.set_anchors_preset(Control.PRESET_CENTER)
	ui_panel.offset_left = -200
	ui_panel.offset_top = -150
	ui_panel.offset_right = 200
	ui_panel.offset_bottom = 150
	ui_panel.visible = false
	ui_canvas.add_child(ui_panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.6, 0.1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	ui_panel.add_theme_stylebox_override("panel", style)
	
	var title = Label.new()
	title.text = "Dziennik Zadań"
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 10
	title.offset_left = -100
	title.offset_right = 100
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	ui_panel.add_child(title)
	
	ui_label = RichTextLabel.new()
	ui_label.bbcode_enabled = true
	ui_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_label.offset_left = 20
	ui_label.offset_top = 50
	ui_label.offset_right = -20
	ui_label.offset_bottom = -20
	ui_panel.add_child(ui_label)
	
	_update_ui_text()

func _toggle_ui() -> void:
	is_ui_open = !is_ui_open
	ui_panel.visible = is_ui_open
	if is_ui_open:
		_update_ui_text()

func _update_ui_text() -> void:
	var text = ""
	for q_id in quests:
		var q = quests[q_id]
		var color = "green" if q["completed"] else "white"
		text += "[color=" + color + "][b]" + q["name"] + "[/b][/color]\n"
		text += "[i][color=gray]" + q["description"] + "[/color][/i]\n"
		text += "Postęp: " + str(q["current"]) + " / " + str(q["target"]) + "\n\n"
		
		if q["completed"]:
			text += "[color=gold]Zakończono! Odebrano " + str(q["reward_exp"]) + " EXP.[/color]\n"
			
	ui_label.text = text

func get_quest(quest_id: String) -> Dictionary:
	if quests.has(quest_id):
		return quests[quest_id]
	return {}

func on_enemy_killed(enemy_type: String = "") -> void:
	var q = quests["kill_enemies"]
	if not q["completed"]:
		q["current"] += 1
		quest_updated.emit("kill_enemies")
		if is_ui_open:
			_update_ui_text()
			
		if q["current"] >= q["target"]:
			q["completed"] = true
			quest_completed.emit("kill_enemies")
			if is_ui_open:
				_update_ui_text()
			# Rozdanie nagrody
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("add_exp"):
				player.add_exp(q["reward_exp"])
			print("Zadanie ukończone! " + q["name"])
			_show_quest_complete_notification(q["name"])

func _show_quest_complete_notification(q_name: String) -> void:
	var lbl = Label.new()
	lbl.text = "Zadanie ukończone:\n" + q_name
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 4)
	
	lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	lbl.offset_top = 100
	lbl.offset_left = -200
	lbl.offset_right = 200
	ui_canvas.add_child(lbl)
	
	var tween = get_tree().create_tween()
	tween.tween_property(lbl, "position:y", 50.0, 3.0)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 3.0)
	tween.tween_callback(lbl.queue_free)

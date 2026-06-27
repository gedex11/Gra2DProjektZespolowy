extends SceneTree

func _init() -> void:
	var items_dir = "res://resources/items/"
	var dir = DirAccess.open(items_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = load(items_dir + file_name)
				if res and res.get("icon") == null:
					res.icon = load("res://icon.svg")
					ResourceSaver.save(res, items_dir + file_name)
					print("Dodano ikone do: ", file_name)
			file_name = dir.get_next()
	quit()

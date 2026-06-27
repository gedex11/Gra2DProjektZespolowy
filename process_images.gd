extends SceneTree

func _init() -> void:
	var artifact_dir = "C:/Users/oskar/.gemini/antigravity-ide/brain/b42e5962-88b3-46e3-bc32-7eb2f7a761be/"
	var out_dir = "res://assets/textures/items/"
	
	var d = DirAccess.open("res://assets/textures/")
	if d:
		d.make_dir("items")
	
	var files = {
		"health_potion.png": "health_potion_1782576055934.png",
		"iron_armor.png": "iron_armor_1782576066079.png",
		"leather_armor.png": "leather_armor_1782576074812.png",
		"chest.png": "chest_1782576085495.png"
	}
	
	for out_name in files:
		var in_path = artifact_dir + files[out_name]
		var img = Image.new()
		if img.load(in_path) == OK:
			var target_color = Color.WHITE
			var threshold = 0.05
			for y in range(img.get_height()):
				for x in range(img.get_width()):
					var c = img.get_pixel(x, y)
					if c.r > 0.95 and c.g > 0.95 and c.b > 0.95:
						c.a = 0.0
						img.set_pixel(x, y, c)
			img.save_png(out_dir + out_name)
			print("Zapisano: ", out_name)
		else:
			print("Blad wczytywania: ", in_path)
			
	quit()

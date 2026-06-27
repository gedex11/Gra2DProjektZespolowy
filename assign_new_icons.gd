extends SceneTree

func _init() -> void:
	var items = {
		"health_potion.tres": "health_potion.png",
		"iron_armor.tres": "iron_armor.png",
		"leather_armor.tres": "leather_armor.png"
	}
	
	for res_name in items:
		var res = load("res://resources/items/" + res_name)
		if res:
			var tex = load("res://assets/textures/items/" + items[res_name])
			if tex:
				res.icon = tex
				ResourceSaver.save(res, "res://resources/items/" + res_name)
				print("Zaktualizowano ikone dla: ", res_name)
			else:
				print("Nie znaleziono tekstury: ", items[res_name])
				
	quit()

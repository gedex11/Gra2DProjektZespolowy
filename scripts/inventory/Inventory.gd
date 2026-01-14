extends RefCounted
class_name Inventory

var items: Array[Item] = []

func add_item(item: Item) -> bool:
	items.append(item)
	return true

func remove_item(item: Item):
	items.erase(item)

func get_items_of_type(cls_name: String) -> Array:
	# cls_name = nazwa klasy np. "WeaponItem"
	return items.filter(func(i): return i.get_class() == cls_name)

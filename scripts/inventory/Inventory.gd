extends RefCounted
class_name Inventory

signal changed

const MAX_SLOTS := 15

var items: Array[Item] = []


func _init() -> void:
	items.resize(MAX_SLOTS)
	
	for i in range(MAX_SLOTS):
		items[i] = null


func add_item(item: Item) -> bool:
	for i in range(MAX_SLOTS):
		if items[i] == null:
			items[i] = item
			changed.emit()
			print("Dodano item do slotu ", i + 1, ": ", item.name)
			return true
	
	print("Ekwipunek pełny!")
	return false


func remove_item_at(index: int) -> void:
	if index < 0 or index >= MAX_SLOTS:
		return
	
	items[index] = null
	changed.emit()


func get_item(index: int) -> Item:
	if index < 0 or index >= MAX_SLOTS:
		return null
	
	return items[index]


func get_items_of_type(cls_name: String) -> Array:
	var result := []
	
	for item in items:
		if item != null and item.get_class() == cls_name:
			result.append(item)
	
	return result

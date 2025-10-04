class_name Inventory

var _items: Array[Item] = []
var maxItemCount: int = 0

func AddItem(item):
	if _items.size() == maxItemCount:
		print("Cannot add item. Inventory is full.")
		return
	_items.append(item)

func GetItem(index) -> Item:
	return _items[index]

func HasItem(name) -> bool:
	for	item in _items:
		if item.name == name:
			return true
	return false

func GetItemCount(name) -> int:
	#Slow
	var count = 0
	for	item in _items:
		if item.name == name:
			count += 1
	return count

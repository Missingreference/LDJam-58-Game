class_name Inventory

signal changed
var maxItemCount: int = -1 

var _items: Dictionary # Dict[String, Array[Item]]
var _item_count = 0

func AddItem(item: Item) -> bool:
	if _item_count == maxItemCount:
		print("Cannot add item. Inventory is full.")
		return false

	if _items.has(item.name):
		_items[item.name].append(item)
	else:
		_items[item.name] = [item]

	changed.emit()

	_item_count += 1

	return true


func RemoveItem(item: Item) -> Item:
	var result = null

	if _items.has(item.name):
		result = _items[item.name]

		_items.erase(item.name)
		_item_count -= 1

		changed.emit()

	return result 


func HasItem(item: Item) -> bool:
	return self._items.has(item.name)


func GetItemCount(item: Item) -> int:
	if self._items.has(item.name):
		return self._items[item.name].size()
	else:
		return 0
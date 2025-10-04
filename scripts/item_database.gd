class_name ItemDatabase

static var _allItems: Array[ItemData] = []

static func _static_init() -> void:
	RegisterItem("Potion", Item.ItemType.Consumable, "")
	RegisterItem("Sword", Item.ItemType.Equipment, "")
	RegisterItem("Bow", Item.ItemType.Equipment, "")

static func GetName(id) -> String:
	return _allItems[id].name

static func FindID(name) -> int:
	var i = 0
	for itemData in _allItems:
		if name == itemData.name:
			return i
		i += 1
		
	#Not found
	return -1

static func GetType(id) -> Item.ItemType:
	return _allItems[id].type

static func FindType(name):
	for itemData in _allItems:
		if name == itemData:
			return itemData.type
			
	#Not found
	return null

static func GetSpritePath(id) -> String:
	return _allItems[id].spritePath

static func FindSpritePath(name) -> String:
	for itemData in _allItems:
		if name == itemData:
			return itemData.spritePath
		
	#Not found
	return ""

class ItemData:
	var name
	var spritePath
	var type
	
static func RegisterItem(name, type, spritePath):
	var newItem:ItemData = ItemData.new()
	newItem.name = name
	newItem.type = type
	newItem.spritePath = spritePath
	
	_allItems.append(newItem)

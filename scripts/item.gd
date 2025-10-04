class_name Item
	
var name
var rarity = Rarity.Normal
var ID

enum Rarity
{
	Normal,
	Rare,
	Legendary
}

enum ItemType
{
	Consumable,
	Equipment
}

static func Create(baseName, _name=baseName) -> Item:
	var id = ItemDatabase.FindID(baseName)
	if id < 0:
		push_error("Name not found: " + baseName) 
		return null
	
	return Item.new(id, _name)

func _init(id, _name) -> void:
	ID = id
	name = _name
	return

func GetBaseName() -> String:
	return ItemDatabase.GetName(ID)

func GetType() -> ItemType:
	return ItemDatabase.GetType(ID)

func GetSpritePath() -> String:
	return ItemDatabase.GetSpritePath(ID)
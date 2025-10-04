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

func GetSprite() -> Texture:
    return ItemDatabase.GetSprite(ID)

func GetBaseValue() -> int:
    return ItemDatabase.GetValue(ID)

func GetValue() -> int:
    var base_value = self.GetBaseValue()
    if self.rarity == Rarity.Rare:
        base_value *= 1.2
    elif self.rarity == Rarity.Legendary:
        base_value *= 1.5

    return base_value
    
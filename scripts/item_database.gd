class_name ItemDatabase

#Sprites
static var potionSprite = preload("res://assets/sprites/potion_placeholder.png")
static var swordSprite = preload("res://assets/sprites/sword_placeholder.png")

static var _allItems: Array[ItemData] = []

static func _static_init() -> void:
    RegisterItem("Potion", Item.ItemType.Consumable, potionSprite)
    RegisterItem("Sword", Item.ItemType.Equipment, swordSprite)
    RegisterItem("Bow", Item.ItemType.Equipment, null)

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

static func GetSprite(id) -> Texture:
    return _allItems[id].sprite

static func FindSprite(name) -> Texture:
    for itemData in _allItems:
        if name == itemData:
            return itemData.sprite

    #Not found
    return null

class ItemData:
    var name
    var sprite
    var type

static func RegisterItem(name, type, sprite):
    var newItem:ItemData = ItemData.new()
    newItem.name = name
    newItem.type = type
    newItem.sprite = sprite

    _allItems.append(newItem)

class_name ItemDatabase

#Sprites
static var potionSprite = preload("res://assets/sprites/icon_potion.png")
static var swordSprite = preload("res://assets/sprites/icon_sword.png")
static var bowSprite = preload("res://assets/sprites/icon_bow.png")

static var _allItems: Array[ItemData] = []

static func _static_init() -> void:
    RegisterItem("Potion", Item.ItemType.Consumable, 10, potionSprite)
    RegisterItem("Sword", Item.ItemType.Equipment, 50, swordSprite)
    RegisterItem("Bow", Item.ItemType.Equipment, 30, bowSprite)

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

static func GetValue(id) -> int:
    return _allItems[id].value

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
    var type
    var value
    var sprite

static func RegisterItem(name, type, value, sprite):
    var newItem:ItemData = ItemData.new()
    newItem.name = name
    newItem.type = type
    newItem.value = value
    newItem.sprite = sprite

    _allItems.append(newItem)

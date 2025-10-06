class_name Item

var ID
var rarity = Rarity.Normal
var strength: int
var enchantment: Enchantment
# Base attributes
var attributes: Customer.Attributes = Customer.Attributes.new()

# Here for backwards compatibility, but should really use GetName() instead
var name

enum Rarity
{
    Normal,
    Rare,
    Legendary
}

enum ItemType
{
    Consumable,
    Weapon,
    Armor,
}

static func Create(baseName, _rarity: Rarity=Rarity.Normal, _strength: int=0, _enchantment: Enchantment=null) -> Item:
    var id = ItemDatabase.FindID(baseName)
    if id < 0:
        push_error("Name not found: " + baseName)
        return null

    return Item.new(id, _rarity, _strength, _enchantment)


static func CreateRandom() -> Item:
    # Pick a random item from the database
    var item_id = Globals.rng.randi_range(0, ItemDatabase.GetItemCount() - 1)
    var item_name = ItemDatabase.GetName(item_id)

    # Roll for rarity
    var item_rarity: Rarity = Rarity.Normal
    var rarity_roll = Globals.rng.randi_range(1, 100)
    # 10% change for legendary
    if rarity_roll >= 90:
        item_rarity = Rarity.Legendary
    # 30% change for rare
    elif rarity_roll >= 70:
        item_rarity = Rarity.Rare

    # Roll for strength
    var item_strength: int = 0
    var strength_roll = Globals.rng.randi_range(1, 100)
    # 10% change for Strong
    if strength_roll >= 90:
        item_strength = 2
    # 30% change for Normal (or 100% if rarity is Rare or Legendary)
    elif strength_roll >= 70 or item_rarity != Rarity.Normal:
        item_strength = 1

    # If item is a potion, it must have an enchantment
    var random_enchantment = Globals.rng.randi_range(0, Item.enchantments.size() - 1)
    var item_enchantment: Enchantment
    if item_name == "Potion":
        item_enchantment = Item.enchantments[random_enchantment]
    else:
        # If the item is not a potion, give it a 20% chance of having an enchantment
        var enchantment_roll = Globals.rng.randi_range(1, 100)
        if enchantment_roll >= 80:
            item_enchantment = Item.enchantments[random_enchantment]


    return Item.new(item_id, item_rarity, item_strength, item_enchantment)


func _init(id, _rarity, _strength, _enchantment) -> void:
    self.ID = id
    self.rarity = _rarity
    self.strength = _strength
    self.enchantment = _enchantment

    # Adjust attributes based on rarity
    var attr_modifier = 1
    if rarity == Rarity.Rare:
        attr_modifier = 3
    if rarity == Rarity.Legendary:
        attr_modifier = 6

    # Adjust attributes based on item type
    var base_name = self.GetBaseName()
    if base_name == "Sword":
        self.attributes.add_attr(Customer.Attr.str, attr_modifier)
    elif base_name == "Bow":
        self.attributes.add_attr(Customer.Attr.dex, attr_modifier)
    elif base_name == "Armor":
        self.attributes.add_attr(Customer.Attr.con, attr_modifier)

    # Adjust attributes based on enchantment
    if self.enchantment != null:
        self.attributes.add_attr(self.enchantment.attr, self.enchantment.value)

    self.name = GetName()


# Generate name based on rarity, strength, and enchantment
func GetName() -> String:
    var _name = GetBaseName()
    if self.strength == 0:
        _name = "Weak " + _name
    elif self.strength == 1:
        # No name modifier for "normal" items
        _name = _name
    else:
        _name = "Strong " + _name

    if self.rarity == Rarity.Rare:
        _name = "Rare " + _name
    elif self.rarity == Rarity.Legendary:
        _name = "Legendary " + _name

    if self.enchantment != null:
        _name = _name + " of " + self.enchantment.name

    return _name
    

func GetBaseName() -> String:
    return ItemDatabase.GetName(ID)

func GetType() -> ItemType:
    return ItemDatabase.GetType(ID)

func GetSprite() -> Texture:
    var base_name = GetBaseName()
    if base_name == "Potion":
        return POTION_SPRITES[rarity][strength][enchantment.attr]
    
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


# Enchantements add new stats to items
static var enchantments: Array[Enchantment] = [
    Enchantment.new("Strength", Customer.Attr.str, 2),
    Enchantment.new("Healing", Customer.Attr.con, 2),
    Enchantment.new("Dodge", Customer.Attr.dex, 2),
    Enchantment.new("Intellect", Customer.Attr.int, 2),
    Enchantment.new("Knowing", Customer.Attr.wis, 2),
    Enchantment.new("Love", Customer.Attr.cha, 2),
]


class Enchantment:
    var name: String
    var attr: Customer.Attr
    var value: int

    func _init(_name: String, _attr: Customer.Attr, _value):
        self.name = _name
        self.attr = _attr
        self.value = _value
        
# The nested dictionary storing all potion sprites
const POTION_SPRITES = {
    Rarity.Normal: {
        0: { # Weak
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/weak_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/weak_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/weak_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/weak_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/weak_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/weak_strength_potion.png")
        },
        1: { # Normal
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/strength_potion.png")
        },
        2: { # Strong
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/strong_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/strong_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/strong_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/strong_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/strong_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/strong_strength_potion.png")
        }
    },
    Rarity.Rare: {
        0: { # Weak
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/rare_weak_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/rare_weak_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/rare_weak_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/rare_weak_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/rare_weak_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/rare_weak_strength_potion.png")
        },
        1: { # Normal
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/rare_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/rare_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/rare_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/rare_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/rare_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/rare_strength_potion.png")
        },
        2: { # Strong
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/rare_strong_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/rare_strong_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/rare_strong_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/rare_strong_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/rare_strong_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/rare_strong_strength_potion.png")
        }
    },
    Rarity.Legendary: {
        0: { # Weak
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/legendary_weak_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/legendary_weak_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/legendary_weak_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/legendary_weak_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/legendary_weak_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/legendary_weak_strength_potion.png")
        },
        1: { # Normal
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/legendary_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/legendary_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/legendary_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/legendary_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/legendary_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/legendary_strength_potion.png")
        },
        2: { # Strong
            Customer.Attr.dex: preload("res://assets/sprites/items/potions/legendary_strong_dodge_potion.png"),
            Customer.Attr.con: preload("res://assets/sprites/items/potions/legendary_strong_healing_potion.png"),
            Customer.Attr.int: preload("res://assets/sprites/items/potions/legendary_strong_intellect_potion.png"),
            Customer.Attr.wis: preload("res://assets/sprites/items/potions/legendary_strong_knowing_potion.png"),
            Customer.Attr.cha: preload("res://assets/sprites/items/potions/legendary_strong_love_potion.png"),
            Customer.Attr.str: preload("res://assets/sprites/items/potions/legendary_strong_strength_potion.png")
        }
    }
}

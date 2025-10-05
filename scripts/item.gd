class_name Item

var name
var rarity = Rarity.Normal
var ID

var attributes: Customer.Attributes = Customer.Attributes.new()

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

static func Create(baseName, _rarity: Rarity=Rarity.Normal, _name=baseName) -> Item:
    var id = ItemDatabase.FindID(baseName)
    if id < 0:
        push_error("Name not found: " + baseName)
        return null

    return Item.new(id, _name, _rarity)


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

    # TODO: Give rare and legendary items special effects and names
    if item_rarity != Rarity.Normal:
        pass

    return Item.new(item_id, item_name, item_rarity)


func _init(id, _name, _rarity) -> void:
    ID = id
    name = _name
    rarity = _rarity

    # Adjust attributes based on item type and rarity
    var attr_modifier = 1
    if rarity == Rarity.Rare:
        attr_modifier = 3
    if rarity == Rarity.Legendary:
        attr_modifier = 6

    var base_name = self.GetBaseName()
    if base_name == "Sword":
        self.attributes.add_attr(Customer.Attr.str, attr_modifier)
    elif base_name == "Bow":
        self.attributes.add_attr(Customer.Attr.dex, attr_modifier)
    elif base_name == "Armor":
        self.attributes.add_attr(Customer.Attr.con, attr_modifier)
    elif base_name == "Potion":
        # For potions, pick a random attribute to buff
        var random_attribute = Globals.rng.randi_range(0, 5)
        self.attributes.add_attr(random_attribute, attr_modifier)


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

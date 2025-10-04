class_name Customer
extends TextureRect

var customer_name: String
var coins: int
var weapon: Item
var armor: Item
var small_items: Array[Item]

var base_attr: Attributes = Attributes.new()

func _init():
    print("Created: %s" % self)


func _to_string() -> String:
    return "Customer(name: %s, coins: %d, weapon: %s, armor: %s, small_items: %s) \n %s" % [
        self.customer_name,
        self.coins,
        self.weapon,
        self.armor,
        self.small_items,
        self.base_attr
    ]


class Attributes:
    var strength: int = 1
    var constitution: int = 1
    var dexterity: int = 1
    var intelligence: int = 1
    var wisdom: int = 1
    var charisma: int = 1

    func _init():
        # Modify attributes randomly by +0, +1, +2, or +3
        self.strength = max(self.strength + Globals.rng.randi_range(-2, 3), 1)
        self.constitution+= max(self.constitution + Globals.rng.randi_range(-2, 3), 1)
        self.dexterity = max(self.dexterity + Globals.rng.randi_range(-2, 3), 1)
        self.intelligence = max(self.intelligence + Globals.rng.randi_range(-2, 3), 1)
        self.wisdom = max(self.wisdom + Globals.rng.randi_range(-2, 3), 1)
        self.charisma = max(self.charisma + Globals.rng.randi_range(-2, 3), 1)

    func _to_string() -> String:
        return "Attributes { \n    str: %d\n    con: %d\n    dex: %d\n    int: %d\n    wis: %d\n    cha: %d\n}" % [
            self.strength,
            self.constitution,
            self.dexterity,
            self.intelligence,
            self.wisdom,
            self.charisma
        ]

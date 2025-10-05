class_name Customer
extends Control

signal selected
signal info_changed(Customer)

var customer_name: String
var gold: int

# Use setters for these to trigger info_changed signal
var _weapon: Item
var _armor: Item
var _small_item_1: Item
var _small_item_2: Item

var base_attr: Attributes = Attributes.create_for_customer()

static var _customer_scene = preload("res://scenes/customer.tscn")

# TODO: replace rectangle highlight with texture shader
@onready var _highlight: ColorRect = $TextureRect/Highlight
@onready var _customer_info: CustomerInfo = $CustomerInfo

var _persist_customer_info: bool = false
var _selection_enabled: bool = false
var _highlight_animation: Tween


static func create_default_customers() -> Array[Customer]:
    # Generate a random set of starting customers
    var result: Array[Customer] = []
    for i in range(10):
        var customer = Customer._customer_scene.instantiate()
        customer.customer_name = Names.generate_customer_name()

        result.append(customer)

    return result


func set_weapon(item: Item):
    self._weapon = item
    self.info_changed.emit(self)


func get_weapon() -> Item:
    return self._weapon


func set_armor(item: Item):
    self._armor = item
    self.info_changed.emit(self)


func get_armor() -> Item:
    return self._armor


func set_small_item_1(item: Item):
    self._small_item_1 = item
    self.info_changed.emit(self)


func get_small_item_1() -> Item:
    return self._small_item_1


func set_small_item_2(item: Item):
    self._small_item_2 = item
    self.info_changed.emit(self)


func get_small_item_2() -> Item:
    return self._small_item_2


func enable_selection():
    self._selection_enabled = true
    self._highlight.color.a = 0.5
    self._highlight_animation.play()


func disable_selection():
    self._selection_enabled = false
    self._highlight_animation.stop()
    self._highlight.color.a = 0.0


func persist_customer_info(enable: bool):
    self._persist_customer_info = enable
    if enable:
        # TODO: animation would be nice here
        self._customer_info.visible = true
    else:
        self._customer_info.visible = false

# Get base skill for a particular attribute plus any modifiers
func get_skill(attribute: Attr) -> int:
    var value = self.base_attr.get_attr(attribute)
    if self._weapon != null:
        value += self._weapon.attributes.get_attr(attribute)
    if self._armor != null:
        value += self._armor.attributes.get_attr(attribute)
    return value


func add_item(item: Item):
    var item_type = item.GetType()
    if item_type == Item.ItemType.Weapon:
        self.set_weapon(item)
    elif item_type == Item.ItemType.Armor:
        self.set_armor(item)
    elif self._small_item_1 == null:
        self.set_small_item_1(item)
    else:
        self.set_small_item_2(item)


func _to_string() -> String:
    return "Customer(name: %s, gold: %d, weapon: %s, armor: %s, small_item_1: %s, small_item_2: %s) \n %s" % [
        self.customer_name,
        self.gold,
        self._weapon.name,
        self._armor.name,
        self._small_item_1.name,
        self._small_item_2.name,
        self.base_attr
    ]


func _ready():
    self._highlight_animation = create_tween()
    self._highlight_animation.tween_property(self._highlight, "color:a", 0.1, 1.0)
    self._highlight_animation.tween_property(self._highlight, "color:a", 0.5, 1.0)
    self._highlight_animation.set_loops()
    self._highlight_animation.stop()

    if get_tree().current_scene == self:
        self.position = get_viewport_rect().size / 2
        # Test
        self.customer_name = "Long John Silver"
        self.gold = 9999999
        self._weapon = Item.Create("Sword")
        self._small_item_2 = Item.Create("Potion")
        self.enable_selection()

    self.info_changed.connect(self._customer_info.set_customer_info)
    self.info_changed.emit(self)


func _on_mouse_entered():
    if self._selection_enabled:
        self._highlight_animation.stop()
        self._highlight.color.a = 0.5

    if not self._persist_customer_info:
        self._customer_info.visible = true


func _on_mouse_exited():
    if self._selection_enabled:
        self._highlight.color.a = 0.5
        self._highlight_animation.play()

    if not self._persist_customer_info:
        self._customer_info.visible = false


func _on_gui_input(event: InputEvent):
    if event.is_pressed():
        print("Customer pressed")
        if self._selection_enabled:
            self.selected.emit()
        else:
            # TODO: persist info box?
            pass


class Attributes:
    var _values: Dictionary[Attr, int] = {
        Attr.str: 0,
        Attr.con: 0,
        Attr.dex: 0,
        Attr.int: 0,
        Attr.wis: 0,
        Attr.cha: 0
    }

    # Ensure that the minimum value for each attribute is 1
    static func create_for_customer() -> Attributes:
        var result = Attributes.new()

        # Modify attributes randomly to be 1, 2, 3, or 4
        for attr in result._values:
            result._values[attr] = max(Globals.rng.randi_range(-3, 4), 1)

        return result


    func get_attr(attribute: Attr) -> int:
        return self._values[attribute]


    func set_attr(attribute: Attr, value: int):
        self._values[attribute] = max(value, 0)


    # Add a value to an attribute.
    # Cannot fall below zero
    func add_attr(attribute: Attr, value: int):
        self._values[attribute] += value
        self._values[attribute] = max(self._values[attribute], 0)


enum Attr {
    str,
    con,
    dex,
    int,
    wis,
    cha
}

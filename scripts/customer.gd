class_name Customer
extends Control

signal selected

var customer_name: String
var gold: int
var weapon: Item
var armor: Item
var small_item_1: Item
var small_item_2: Item

var base_attr: Attributes = Attributes.new()

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



func _to_string() -> String:
    return "Customer(name: %s, gold: %d, weapon: %s, armor: %s, small_item_1: %s, small_item_2: %s) \n %s" % [
        self.customer_name,
        self.gold,
        self.weapon,
        self.armor,
        self.small_item_1,
        self.small_item_2,
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
        self.weapon = Item.Create("Sword")
        self.small_item_2 = Item.Create("Potion")
        self.enable_selection()

    self._customer_info.set_customer_info(self)


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

class_name Customer
extends TextureRect

signal selected

var customer_name: String
var coins: int
var weapon: Item
var armor: Item
var small_items: Array[Item]

var base_attr: Attributes = Attributes.new()

static var _customer_scene = preload("res://scenes/customer.tscn")

# TODO: replace rectangle highlight with texture shader
@onready var _highlight: ColorRect = $Highlight

var _highlight_animation: Tween


static func create_default_customers() -> Array[Customer]:
    # Generate a random set of starting customers
    var result: Array[Customer] = []
    for i in range(10):
        var customer = Customer._customer_scene.instantiate()
        customer.customer_name = Names.generate_customer_name()

        result.append(customer)

    return result


func _to_string() -> String:
    return "Customer(name: %s, coins: %d, weapon: %s, armor: %s, small_items: %s) \n %s" % [
        self.customer_name,
        self.coins,
        self.weapon,
        self.armor,
        self.small_items,
        self.base_attr
    ]


func _ready():
    self._highlight_animation = create_tween()
    self._highlight_animation.tween_property(self._highlight, "color:a", 0.1, 1.0)
    self._highlight_animation.tween_property(self._highlight, "color:a", 0.5, 1.0)
    self._highlight_animation.set_loops()
    self._highlight_animation.stop()

    if get_tree().current_scene == self:
        # Test
        self.enable_selection()


func enable_selection():
    if not self._highlight.mouse_entered.is_connected(self._on_highlight_mouse_entered):
        self._highlight.mouse_entered.connect(self._on_highlight_mouse_entered)
    if not self._highlight.mouse_exited.is_connected(self._on_highlight_mouse_exited):
        self._highlight.mouse_exited.connect(self._on_highlight_mouse_exited)
    if not self._highlight.gui_input.is_connected(self._on_highlight_gui_event):
        self._highlight.gui_input.connect(self._on_highlight_gui_event)
    self._highlight.color.a = 0.5
    self._highlight_animation.play()


func disable_selection():
    self._highlight_animation.stop()
    self._highlight.mouse_entered.disconnect(self._on_highlight_mouse_entered)
    self._highlight.mouse_exited.disconnect(self._on_highlight_mouse_exited)
    self._highlight.gui_input.disconnect(self._on_highlight_gui_event)
    self._highlight.color.a = 0.0


func _on_highlight_mouse_entered():
    self._highlight_animation.stop()
    self._highlight.color.a = 0.5


func _on_highlight_mouse_exited():
    self._highlight.color.a = 0.5
    self._highlight_animation.play()


func _on_highlight_gui_event(event: InputEvent):
    if event.is_pressed():
        self.selected.emit()


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

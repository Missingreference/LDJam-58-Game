class_name Collection
extends Control

signal closed

# TODO Change all of these preload to be the actual textures we want
static var _a_missing_texture = preload("res://assets/sprites/customer_info_sword_placeholder.png")
static var _b_missing_texture = preload("res://assets/sprites/customer_info_armor_placeholder.png")
static var _c_missing_texture = preload("res://assets/sprites/customer_info_potion_placeholder.png")
static var _a_1_texture = preload("res://assets/sprites/icon_sword.png")
static var _a_2_texture = preload("res://assets/sprites/icon_sword.png")
static var _a_3_texture = preload("res://assets/sprites/icon_sword.png")
static var _b_1_texture = preload("res://assets/sprites/icon_sword.png")
static var _b_2_texture = preload("res://assets/sprites/icon_sword.png")
static var _b_3_texture = preload("res://assets/sprites/icon_sword.png")
static var _c_1_texture = preload("res://assets/sprites/icon_sword.png")
static var _c_2_texture = preload("res://assets/sprites/icon_sword.png")
static var _c_3_texture = preload("res://assets/sprites/icon_sword.png")

@onready var _collection_a_1: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer1/TextureRect1
@onready var _collection_a_2: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer1/TextureRect2
@onready var _collection_a_3: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer1/TextureRect3
@onready var _collection_b_1: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/TextureRect1
@onready var _collection_b_2: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/TextureRect2
@onready var _collection_b_3: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/TextureRect3
@onready var _collection_c_1: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer3/TextureRect1
@onready var _collection_c_2: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer3/TextureRect2
@onready var _collection_c_3: TextureRect = $MarginContainer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer3/TextureRect3
@onready var _tooltip: InventoryTooltip = $InventoryTooltip

@onready var _collection_a_slots: Array[TextureRect] = [
    _collection_a_1,
    _collection_a_2,
    _collection_a_3,
]

@onready var _collection_b_slots: Array[TextureRect] = [
    _collection_b_1,
    _collection_b_2,
    _collection_b_3,
]

@onready var _collection_c_slots: Array[TextureRect] = [
    _collection_c_1,
    _collection_c_2,
    _collection_c_3,
]

var _collection_a: Array[Collectable] = [
    Collectable.new("Collectable A1", "A1 Description", _a_missing_texture, _a_1_texture),
    Collectable.new("Collectable A2", "A2 Description", _a_missing_texture, _a_2_texture),
    Collectable.new("Collectable A3", "A3 Description", _a_missing_texture, _a_3_texture)
]

var _collection_b: Array[Collectable] = [
    Collectable.new("Collectable B1", "B1 Description", _b_missing_texture, _b_1_texture),
    Collectable.new("Collectable B2", "B2 Description", _b_missing_texture, _b_2_texture),
    Collectable.new("Collectable B3", "B3 Description", _b_missing_texture, _b_3_texture)
]

var _collection_c: Array[Collectable] = [
    Collectable.new("Collectable C1", "C1 Description", _c_missing_texture, _c_1_texture),
    Collectable.new("Collectable C2", "C2 Description", _c_missing_texture, _c_2_texture),
    Collectable.new("Collectable C3", "C3 Description", _c_missing_texture, _c_3_texture)
]

var remaining_collectables_a = _collection_a.duplicate()
var remaining_collectables_b = _collection_b.duplicate()
var remaining_collectables_c = _collection_c.duplicate()


# Get one of the remaining collectable
func get_remaining_collectable() -> Collectable:
    var remaining_a = RandomUtils.pick_random(self.remaining_collectables_a)
    if remaining_a != null:
        return remaining_a

    var remaining_b = RandomUtils.pick_random(self.remaining_collectables_b)
    if remaining_b != null:
        return remaining_b

    return RandomUtils.pick_random(self.remaining_collectables_c)


func add_to_collection(collectable: Collectable):
    print("Adding to collection: %s" % collectable.collectable_name)
    var index = self._collection_a.find(collectable)
    if index >= 0:
        self._collection_a_slots[index].texture = collectable.found_texture
        self.remaining_collectables_a.erase(collectable)
        return

    index = self._collection_b.find(collectable)
    if index >= 0:
        self._collection_b_slots[index].texture = collectable.found_texture
        self.remaining_collectables_b.erase(collectable)
        return

    index = self._collection_c.find(collectable)
    if index >= 0:
        self._collection_c_slots[index].texture = collectable.found_texture
        self.remaining_collectables_c.erase(collectable)
        return


func _ready():
    self._collection_a_1.texture = self._collection_a[0].missing_texture
    self._collection_a_2.texture = self._collection_a[1].missing_texture
    self._collection_a_3.texture = self._collection_a[2].missing_texture
    self._collection_b_1.texture = self._collection_b[0].missing_texture
    self._collection_b_2.texture = self._collection_b[1].missing_texture
    self._collection_b_3.texture = self._collection_b[2].missing_texture
    self._collection_c_1.texture = self._collection_c[0].missing_texture
    self._collection_c_2.texture = self._collection_c[1].missing_texture
    self._collection_c_3.texture = self._collection_c[2].missing_texture

    # Connect tooltip signals
    self._collection_a_1.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_a[0]))
    self._collection_a_1.mouse_exited.connect(self._on_mouse_exit)
    self._collection_a_2.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_a[1]))
    self._collection_a_2.mouse_exited.connect(self._on_mouse_exit)
    self._collection_a_3.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_a[2]))
    self._collection_a_3.mouse_exited.connect(self._on_mouse_exit)
    self._collection_b_1.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_b[0]))
    self._collection_b_1.mouse_exited.connect(self._on_mouse_exit)
    self._collection_b_2.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_b[1]))
    self._collection_b_2.mouse_exited.connect(self._on_mouse_exit)
    self._collection_b_3.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_b[2]))
    self._collection_b_3.mouse_exited.connect(self._on_mouse_exit)
    self._collection_c_1.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_c[0]))
    self._collection_c_1.mouse_exited.connect(self._on_mouse_exit)
    self._collection_c_2.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_c[1]))
    self._collection_c_2.mouse_exited.connect(self._on_mouse_exit)
    self._collection_c_3.mouse_entered.connect(self._on_mouse_enter.bind(self._collection_c[2]))
    self._collection_c_3.mouse_exited.connect(self._on_mouse_exit)


func _on_close_button_pressed():
    self.closed.emit()


func _input(event):
    if not self.visible:
        return

    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE or event.keycode == KEY_C:
            get_viewport().set_input_as_handled()
            self.closed.emit()
        # DEBUG, find a random collectable
        # elif event.keycode == KEY_A:
        #     get_viewport().set_input_as_handled()
        #     var collectable = RandomUtils.pick_random(self.remaining_collectables_a)
        #     if collectable != null:
        #         self.add_to_collection(collectable)
        # elif event.keycode == KEY_B:
        #     get_viewport().set_input_as_handled()
        #     var collectable = RandomUtils.pick_random(self.remaining_collectables_b)
        #     if collectable != null:
        #         self.add_to_collection(collectable)
        # elif event.keycode == KEY_F:
        #     get_viewport().set_input_as_handled()
        #     var collectable = RandomUtils.pick_random(self.remaining_collectables_c)
        #     if collectable != null:
        #         self.add_to_collection(collectable)


func _on_mouse_enter(collectable: Collectable):
    # TODO Check if found
    self._tooltip.visible = true
    self._tooltip.move_to_front()
    print("Title: %s" %  collectable.collectable_name)
    self._tooltip.item_title.text = collectable.collectable_name
    self._tooltip.item_description.text = collectable.description


func _on_mouse_exit():
    _tooltip.visible = false



enum Type {
    A,
    B,
    C
}

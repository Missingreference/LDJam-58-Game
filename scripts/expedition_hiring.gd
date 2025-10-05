class_name ExpeditionHiring
extends Control

@onready var _placeholder_1: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot1/Placeholder
@onready var _placeholder_2: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot5/Placeholder

@onready var _slot_1: Control = $MarginContainer/HBoxContainer/CustomerSlot1
@onready var _slot_2: Control = $MarginContainer/HBoxContainer/CustomerSlot2
@onready var _slot_3: Control = $MarginContainer/HBoxContainer/CustomerSlot3
@onready var _slot_4: Control = $MarginContainer/HBoxContainer/CustomerSlot4
@onready var _slot_5: Control = $MarginContainer/HBoxContainer/CustomerSlot5

@onready var _customer_slots: Array[Control] = [
    _slot_1,
    _slot_2,
    _slot_3,
    _slot_4,
    _slot_5,
]

var _game_data: GameData
var _customers: Array[Customer]

func set_game_data(game_data: GameData):
    self._game_data = game_data


func start():
    # Pick some random adventurers
    self._customers = RandomUtils.pick_random_count(self._game_data.customers, 5)
    var customer_names = self._customers.map(func(c): return c.customer_name)
    print("Customers: %s" % ", ".join(customer_names))

    assert(self._customers.size() <= self._customer_slots.size())

    const tween_speed = 300  # pixels/s
    var tweens: Array[Tween] = []

    for i in range(self._customers.size()):
        var customer = self._customers[i]
        self._customer_slots[i].add_child(customer)

        print("Positioning customer (%d): %s" % [i, customer.customer_name])

        # Tween into the position from off screen
        var end_position = self._customer_slots[i].global_position
        customer.global_position = end_position
        customer.global_position.x = -10

        var tween_time = abs(customer.global_position.x - end_position.x) / tween_speed

        var tween = self.create_tween()
        tween.tween_property(self._customers[i], "global_position", end_position, tween_time)
        tweens.append(tween)

    for t in tweens:
        await t.finished

    # Display customer info and hire buttons
    for customer in self._customers:
        customer.

func stop():
    for customer in self._customers:
        self.remove_child(customer)


func _ready():

    # Remove placeholders
    self._slot_1.remove_child(self._placeholder_1)
    self._slot_5.remove_child(self._placeholder_2)

    if get_tree().current_scene == self:
        # Test
        self.set_game_data(GameData.new())

        # Defer call to next frame update so that layouts have a chance to update
        self.start.call_deferred()

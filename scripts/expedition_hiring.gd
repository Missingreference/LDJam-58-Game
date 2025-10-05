class_name ExpeditionHiring
extends Control

# Speed used for customers moving into the scene
const tween_speed = 250  # pixels/s

signal customer_hired(Customer)

@onready var _placeholder_1: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot1/CenterContainer/Placeholder
@onready var _placeholder_2: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot2/CenterContainer/Placeholder
@onready var _placeholder_3: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot3/CenterContainer/Placeholder
@onready var _placeholder_4: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot4/CenterContainer/Placeholder
@onready var _placeholder_5: TextureRect = $MarginContainer/HBoxContainer/CustomerSlot5/CenterContainer/Placeholder

@onready var _placeholders: Array[TextureRect] = [
    _placeholder_1,
    _placeholder_2,
    _placeholder_3,
    _placeholder_4,
    _placeholder_5,
]

@onready var _hire_button_1: Button = $MarginContainer/HBoxContainer/CustomerSlot1/HireButton
@onready var _hire_button_2: Button = $MarginContainer/HBoxContainer/CustomerSlot2/HireButton
@onready var _hire_button_3: Button = $MarginContainer/HBoxContainer/CustomerSlot3/HireButton
@onready var _hire_button_4: Button = $MarginContainer/HBoxContainer/CustomerSlot4/HireButton
@onready var _hire_button_5: Button = $MarginContainer/HBoxContainer/CustomerSlot5/HireButton

@onready var _hire_buttons: Array[Button] = [
    _hire_button_1,
    _hire_button_2,
    _hire_button_3,
    _hire_button_4,
    _hire_button_5,
]


var _game_data: GameData
var _customers: Array

func set_game_data(game_data: GameData):
    self._game_data = game_data


func start():
    # Enable mouse input
    self.mouse_filter = Control.MOUSE_FILTER_STOP
    self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED

    # Pick some random adventurers
    self._customers = RandomUtils.pick_random_count(self._game_data.customers, 5)
    var customer_names = self._customers.map(func(c): return c.customer_name)
    print("Customers: %s" % ", ".join(customer_names))

    assert(self._customers.size() <= self._placeholders.size())

    # Animate customers coming into scene
    self._animate_customer_entry()


func stop():
    # Disable mouse input
    self.mouse_filter = Control.MOUSE_FILTER_IGNORE
    self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED

    for customer in self._customers:
        customer.persist_customer_info(false)
        self.remove_child(customer)

    # Hide buttons
    # Change alpha (rather than visible property) so we can retain size in layout
    for hire_button in self._hire_buttons:
        if hire_button.pressed.is_connected(self._on_hire_button_pressed):
            hire_button.pressed.disconnect(self._on_hire_button_pressed)
        hire_button.modulate = Color(1, 1, 1, 0)


func _ready():
    # Hide placeholders
    # Change alpha (rather than visible property) so we can retain size in layout
    for placeholder in self._placeholders:
        placeholder.modulate = Color(1, 1, 1, 0)

    # Hide buttons
    # Change alpha (rather than visible property) so we can retain size in layout
    for hire_button in self._hire_buttons:
        hire_button.modulate = Color(1, 1, 1, 0)

    if get_tree().current_scene == self:
        # Test
        self.set_game_data(GameData.new())

        # Defer call to next frame update so that layouts have a chance to update
        self.start.call_deferred()


func _animate_customer_entry():
    var tweens: Array[Tween] = []
    for i in range(self._customers.size()):
        var customer = self._customers[i]
        self.add_child(customer)

        # Tween into the position from off screen
        var end_position = self._placeholders[i].global_position
        customer.global_position = end_position
        customer.global_position.x = -10

        print("Positioning customer (%d) '%s', from %s to %s" % [i, customer.customer_name, customer.global_position, end_position])

        var tween_time = abs(customer.global_position.x - end_position.x) / tween_speed

        var tween = self.create_tween()
        tween.tween_property(self._customers[i], "global_position", end_position, tween_time)
        tweens.append(tween)

    # As each customer finishes moving, display their info
    for i in range(self._customers.size()):
        await tweens[i].finished
        var customer = self._customers[i]
        var hire_button = self._hire_buttons[i]

        customer.persist_customer_info(true)

        # Determine hire price and update button label
        var price = self._compute_hire_price(customer)

        hire_button.text = "Hire %dgp" % price

        # Disable button if we don't have enough gold
        var gold = self._game_data.get_gold()
        if price <= gold:
            hire_button.disabled = false
            hire_button.pressed.connect(self._on_hire_button_pressed.bind(customer, price))
        else:
            print("Cannot afford %s, %d (gold) vs %d (cost)" % [customer.customer_name, gold, price])
            hire_button.disabled = true

    # Reveal buttons after all customers are done moving
    for hire_button in self._hire_buttons:
        hire_button.modulate = Color(1, 1, 1, 1)




func _compute_hire_price(customer: Customer):
    # Set some arbitrary base price
    var price = 40

    # Increase price with increased attributes
    var total_attr_points = (
        customer.base_attr.strength +
        customer.base_attr.constitution +
        customer.base_attr.dexterity +
        customer.base_attr.intelligence +
        customer.base_attr.wisdom +
        customer.base_attr.charisma
    )
    price += total_attr_points * 10

    # Increase price based on equipment
    if customer.weapon != null:
        price += customer.weapon.GetValue() / 2
    if customer.armor != null:
        price += customer.armor.GetValue() / 2
    if customer.small_item_1 != null:
        price += customer.small_item_1.GetValue() / 2
    if customer.small_item_2 != null:
        price += customer.small_item_2.GetValue() / 2

    # TODO: increase / decrease price based on traits

    return price


func _on_hire_button_pressed(hired_customer: Customer, price: int):
    # Hide all buttons
    for hire_button in self._hire_buttons:
        hire_button.disabled = true
        hire_button.modulate = Color(1, 1, 1, 0)

    self._game_data.add_gold(-price)

    # Disappear non-hired customers
    var tweens: Array[Tween] = []
    for customer in self._customers:
        if customer == hired_customer:
            continue

        var tween = self.create_tween()
        tween.tween_property(customer, "modulate:a", 0.0, 3.0)
        tweens.append(tween)

    for t in tweens:
        await t.finished

    hired_customer.persist_customer_info(false)

    # TODO: happy animation for hired customer

    self.customer_hired.emit(hired_customer)

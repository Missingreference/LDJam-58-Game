class_name CustomerQueue
extends Node2D

signal queue_emptied
signal customer_left

var _game_data: GameData

@onready var _queue: Control = $Queue
@onready var _customer_offer_ui: CustomerOfferUI = $CustomerOfferUI

# var _customer_offer_ui_scene = preload("res://scenes/customer_offer_ui.tscn")

# Debug properties
@onready var _test_add_button = $TestAddButton
@onready var _accept_dialog: AcceptDialog = $AcceptDialog

# Offscreen spawn position range
const spawn_min_pos = 20.0
const spawn_max_pos = 300.0

# The size of a customer position in the queue
const queue_space_size = 80

const CUSTOMER_SPACING: float = 100.0
const CUSTOMER_MOVE_SPEED: float = 100.0

var _leaving_customers: Array[Customer]

signal _wait_for_dialog


func set_game_data(game_data: GameData):
    self._game_data = game_data


func start():
    self._enqueue_customers(self._game_data.customers)


func stop():
    await self._clear()


func _ready():
    _customer_offer_ui.visible = false
    self._accept_dialog.confirmed.connect(self._wait_for_dialog.emit)
    self._accept_dialog.canceled.connect(self._wait_for_dialog.emit)

    if get_tree().current_scene == self:
        # Center in view
        self.global_position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y * 0.8)

        # Test data
        self.set_game_data(GameData.new())
        # Add some items to the shop inventory
        self._game_data.shop_inventory.AddItem(Item.Create("Sword"))
        self._game_data.shop_inventory.AddItem(Item.Create("Bow"))
        self._game_data.shop_inventory.AddItem(Item.Create("Potion"))
        self.start()
    else:
        # Remove test buttons
        self.remove_child(self._test_add_button)


# Enqueue a random number of customers from the game data pool
func _enqueue_customers(customers: Array[Customer], min_count: int = 3, max_count: int = 7):
    var customer_count = Globals.rng.randi_range(min_count, max_count)

    # Constain based on number of available customers
    customer_count = min(customer_count, customers.size())

    # Pick N random customers from the pool
    var chosen_customers = RandomUtils.pick_random_count(customers, customer_count)

    # Add to queue node (add in reverse order so node visual order appears in desired way)
    for i in range(chosen_customers.size() - 1, -1, -1):
        var customer = chosen_customers[i]
        self._queue.add_child(customer)
        # Set initial position (off screen right)
        customer.global_position.x = get_viewport_rect().size.x + Globals.rng.randf_range(spawn_min_pos, spawn_max_pos)
        customer.global_position.y = self._queue.global_position.y

    var customer_names = chosen_customers.map(func(c): return c.customer_name)
    print("Enqueuing %d customers: %s" % [customer_count, ", ".join(customer_names)])

    # While there are still customers in the queue
    while not chosen_customers.is_empty():
        # Update queue
        await self._do_queue_animation(chosen_customers)

        # Pop chosen customer
        var customer = chosen_customers.pop_front()

        # Process customer offer
        if not await self._do_customer_offer(customer):
            # Nothing left to offer
            break


    print("No more queued customers")
    self.queue_emptied.emit()


func _do_queue_animation(customers):
    print("Upating customer queue")
    # Animate each customer into the screen
    var tweens: Array[Tween] = []
    for i in customers.size():
        var customer: Customer = customers[i]

        # Tween into the position from off screen
        customer.animator.play_walk_animation()
        customer.animator.set_animation_frame(Globals.rng.randi_range(0,6))
        customer.animator.set_flip_horizontal(false)
        customer.animator.set_animation_speed_scale(Globals.customer_walk_animate_speed)

        var end_position = Vector2(self._queue.global_position.x + self.queue_space_size * i, customer.global_position.y)
        var tween_time = abs(customer.global_position.x - end_position.x) / Globals.customer_walk_tween_speed

        var tween = self.create_tween()
        tween.tween_property(customer, "global_position", end_position, tween_time)
        tweens.append(tween)

    # await tweens in reverse order (the order we expect them to finish)
    for i in range(tweens.size() - 1, -1, -1):
        print("waiting for %s" % customers[i].customer_name)
        if tweens[i].is_running():
            await tweens[i].finished
        print("%s done moving" % customers[i].customer_name)
        customers[i].animator.play_idle3_animation()


func _do_customer_offer(customer) -> bool:
    # Pick an item from the shop
    var item = self._game_data.shop_inventory.GetRandomItem()

    # If we don't have any more items, then notify the user and evacuate the queue
    if item == null:
        self._accept_dialog.popup_centered()
        await self._wait_for_dialog
        self._clear()
        return false

    # Generate an offer
    var offer = CustomerOffer.create_random_offer(customer, item)

    # Display the offer to the user
    self._customer_offer_ui.set_customer_offer(offer)
    self._customer_offer_ui.visible = true
    # var ui_size = customer_offer_ui.size()
    # customer_offer_ui.global_position = customer.global_position + Vector2(ui_size.x / 2, -(ui_size.y / 2) - 20)

    print("Prepared customer offer, awaiting user input")

    # Wait for user
    var result = await self._customer_offer_ui.offer_result

    # Process offer result
    if result[0] == CustomerOfferUI.OfferResult.accepted:
        var final_price = result[1]
        self._game_data.shop_inventory.RemoveItem(item)
        customer.add_item(item)
        self._game_data.add_gold(final_price)

        print("%s purchased %s for %d gold" % [customer.customer_name, item.name, final_price])

    self._customer_offer_ui.visible = false

    self._queue.remove_child(customer)

    self._do_leave_animate(customer)

    return true


func _do_leave_animate(customer: Customer):
    self.add_child(customer)
    self._leaving_customers.append(customer)

    # Temporarily lower z-index so they walk behind other customers
    customer.z_index -= 1
    customer.animator.play_walk_animation()
    customer.animator.set_flip_horizontal(true)

    var end_position = Vector2(get_viewport_rect().size.x, customer.global_position.y)
    var tween_time = abs(customer.global_position.x - end_position.x) / Globals.customer_walk_tween_speed
    var leave_tween = create_tween()
    leave_tween.tween_property(customer, "global_position", end_position, tween_time)
    leave_tween.finished.connect(func():
        self._leaving_customers.erase(customer)
        self.remove_child(customer)
        # Restore z-index
        customer.z_index += 1

        self.customer_left.emit()
    )


# Clear out any remaining customers waiting in the queue
func _clear():
    for child in self._queue.get_children():
        self._queue.remove_child(child)
        self._do_leave_animate(child)

    var customer_left_callback = func():
        if self._leaving_customers.is_empty():
            print("QUEUE EMPTY")
            self.queue_emptied.emit()

    self.customer_left.connect(customer_left_callback)

    if not self._leaving_customers.is_empty():
        await self.queue_emptied

    self.customer_left.disconnect(customer_left_callback)

    print("Customer queue cleared")


# FIXME: Broken
# func _on_test_add_button_pressed():
#     var available_customers = self._game_data.customers.filter(func(c): return not self._queue.get_children().has(c))
#     self._enqueue_customers(available_customers, 1, 1)

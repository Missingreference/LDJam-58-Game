class_name CustomerQueue
extends Node2D

signal queue_emptied

var _game_data: GameData

@onready var _queue: Control = $Queue
@onready var _customer_offer_ui: CustomerOfferUI = $CustomerOfferUI

# var _customer_offer_ui_scene = preload("res://scenes/customer_offer_ui.tscn")

# Debug properties
@onready var _test_add_button = $TestAddButton
@onready var _accept_dialog: AcceptDialog = $AcceptDialog

const SPAWN_POSITION_X: float = 700.0
const SPAWN_VARIATION_AMOUNT: float = 50.0
const CUSTOMER_SPACING: float = 100.0
const CUSTOMER_MOVE_SPEED: float = 100.0

var _leaving_customers: Array[Customer]

func set_game_data(game_data: GameData):
    self._game_data = game_data


func start():
    self._enqueue_customers(self._game_data.customers)


func stop():
    self._clear()
    
func _process(delta: float):
    if _queue.get_child_count() > 0:
        var customers = _queue.get_children()
        for i in customers.size():
            var customer: Customer = customers[i]
            var targetXPosition = i * CUSTOMER_SPACING
            if customer.position.x > targetXPosition:
                customer.position.x -= CUSTOMER_MOVE_SPEED * delta
                if customer.position.x <= targetXPosition:
                    #Customer reached the it's destination
                    customer.position.x = targetXPosition
                    _on_customer_ready(i)
                    
    if _leaving_customers.size() > 0:
        var iterator = 0
        while iterator < _leaving_customers.size():
            var customer: Customer = _leaving_customers[iterator]
            customer.position.x += CUSTOMER_MOVE_SPEED * delta
            if customer.position.x >= SPAWN_POSITION_X:
                customer.position.x = SPAWN_POSITION_X
                _on_customer_left(iterator)
                #_on_customer_left removes the item
                iterator -= 1
            iterator += 1

func _ready():
    _customer_offer_ui.visible = false

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

    var customer_names = chosen_customers.map(func(c): return c.customer_name)
    print("Enqueuing %d customers: %s" % [customer_count, ", ".join(customer_names)])

    # Enqueue
    
    for i in chosen_customers.size():
        var customer: Customer = chosen_customers[i]
        self._queue.add_child(customer)
        var spawn_variation = Globals.rng.randf_range(-SPAWN_VARIATION_AMOUNT, SPAWN_VARIATION_AMOUNT)
        customer.position = Vector2(SPAWN_POSITION_X + (CUSTOMER_SPACING * i) + spawn_variation, customer.position.y)
        customer.animator.play_walk_animation()
        customer.animator.set_animation_frame(Globals.rng.randi_range(0,6))
        customer.animator.set_flip_horizontal(false)
        #Further in the queue means behind the guy in front of the queue
        customer.z_index = -i

    #self._enable_next_customer_selection()
    
func _on_customer_ready(queue_index: int):
    var customer: Customer = _queue.get_child(queue_index)
    customer.animator.play_idle3_animation()
    if queue_index == 0:
        #_enable_next_customer_selection()
        _do_customer_offer()

# func _enable_next_customer_selection():
#     var queued_customers = self._queue.get_children()
#     if queued_customers.size() == 0:
#         print("No more queued customers")
#         self.queue_emptied.emit()
#         return

#     # Connect signals for the customer at the front of the queue
#     var next_customer: Customer = queued_customers.front()
#     if next_customer != null:
#         print("Next customer in queue is '%s'" % next_customer.customer_name)
#         if not next_customer.selected.is_connected(self._do_customer_offer):
#             next_customer.selected.connect(self._do_customer_offer)
#         next_customer.enable_selection()


func _do_customer_offer():
    var customer: Customer = self._queue.get_children().front()
    assert(customer != null)

    #customer.selected.disconnect(self._do_customer_offer)
    customer.disable_selection()

    # Pick an item from the shop
    var item = self._game_data.shop_inventory.GetRandomItem()

    # If we don't have any more items, then notify the user and evacuate the queue
    if item == null:
        self._accept_dialog.popup_centered()
        if not self._accept_dialog.confirmed.is_connected(self._clear):
            self._accept_dialog.confirmed.connect(self._clear)
        if not self._accept_dialog.canceled.is_connected(self._clear):
            self._accept_dialog.canceled.connect(self._clear)
        return

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
    
    #Show them leaving
    self.add_child(customer)
    _leaving_customers.append(customer)
    customer.z_index = -((_queue.get_child_count()+1)*2)
    customer.animator.play_walk_animation()
    customer.animator.set_flip_horizontal(true)
    
    #Enable walking animation for all the other customers
    for other_customer: Customer in _queue.get_children():
        other_customer.animator.play_walk_animation()

func _on_customer_left(leaving_index: int):
    var customer: Customer = _leaving_customers[leaving_index]
    _leaving_customers.remove_at(leaving_index)
    
    #Reset flip just to be nice
    customer.animator.set_flip_horizontal(false)
    
    self.remove_child(customer)
    
    if _queue.get_child_count() == 0 && _leaving_customers.size() == 0:
        #All done!
        self.queue_emptied.emit()

# Clear out any remaining customers waiting in the queue
func _clear():
    # TODO: animate
    for child in self._queue.get_children():
        child.disable_selection()
        self._queue.remove_child(child)

    self.queue_emptied.emit()

func _on_test_add_button_pressed():
    var available_customers = self._game_data.customers.filter(func(c): return not self._queue.get_children().has(c))
    self._enqueue_customers(available_customers, 1, 1)

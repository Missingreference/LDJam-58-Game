class_name CustomerQueue
extends Node2D

signal customer_selected(Customer)
signal queue_emptied

var _game_data: GameData

@onready var _queue: HBoxContainer = $Queue

# Debug properties
@onready var _placeholder_1 = $Queue/CustomerPlaceholder1
@onready var _placeholder_2 = $Queue/CustomerPlaceholder2
@onready var _placeholder_3 = $Queue/CustomerPlaceholder3
@onready var _test_add_button = $TestAddButton


func set_game_data(game_data: GameData):
    self._game_data = game_data


func start():
    self._enqueue_customers(self._game_data.customers)


func stop():
    self._clear()


func _ready():
    # Remove placeholder sprites
    self._queue.remove_child(self._placeholder_1)
    self._queue.remove_child(self._placeholder_2)
    self._queue.remove_child(self._placeholder_3)

    if get_tree().current_scene == self:
        self.set_game_data(GameData.new())
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
    for customer in chosen_customers:
        self._queue.add_child(customer)

    self._enable_next_customer_selection()


func _enable_next_customer_selection():
    var queued_customers = self._queue.get_children()
    if queued_customers.size() == 0:
        print("No more queued customers")
        self.queue_emptied.emit()
        return

    # Connect signals for the customer at the front of the queue
    var next_customer: Customer = queued_customers.front()
    if next_customer != null:
        if not next_customer.selected.is_connected(self._pop_front):
            next_customer.selected.connect(self._pop_front)
            next_customer.enable_selection()


# Remove and return the customer at the front of the line
# Returns null if there are no more customers in the queue
func _pop_front() -> Customer:
    var customer = self._queue.get_children().front()
    assert(customer != null)

    customer.selected.disconnect(self._pop_front)
    customer.disable_selection()
    self._queue.remove_child(customer)
    self.customer_selected.emit(customer)
    self._enable_next_customer_selection()

    return customer


# Clear out any remaining customers waiting in the queue
func _clear():
    for child in self._queue.get_children():
        self._queue.remove_child(child)



func _on_test_add_button_pressed():
    var available_customers = self._game_data.customers.filter(func(c): return not self._queue.get_children().has(c))
    self._enqueue_customers(available_customers, 1, 1)

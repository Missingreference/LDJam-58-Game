class_name CustomerQueue
extends Node2D

var game_data: GameData

@onready var _queue: HBoxContainer = $Queue

# Debug properties
@onready var _placeholder_1 = $Queue/CustomerPlaceholder1
@onready var _placeholder_2 = $Queue/CustomerPlaceholder2
@onready var _placeholder_3 = $Queue/CustomerPlaceholder3
@onready var _test_add_button = $TestAddButton
@onready var _test_remove_button = $TestRemoveButton

var _customer_scene = preload("res://scenes/customer.tscn")
var _test_customers: Array[Customer] = []


func _ready():
    # Remove placeholder sprites
    self._queue.remove_child(self._placeholder_1)
    self._queue.remove_child(self._placeholder_2)
    self._queue.remove_child(self._placeholder_3)

    if get_tree().current_scene == self:
        for i in range(0, 10):
            var customer = self._customer_scene.instantiate()
            customer.customer_name = "Foo%d" % i
            self._test_customers.append(customer)

        self.enqueue_customers(self._test_customers)
    else:
        # Remove test buttons
        self.remove_child(self._test_add_button)
        self.remove_child(self._test_remove_button)


# Enqueue a random number of customers from the game data pool
func enqueue_customers(customers: Array[Customer], min_count: int = 3, max_count: int = 7):
    var customer_count = Globals.rng.randi_range(min_count, max_count)

    # Constain based on number of available customers
    customer_count = min(customer_count, customers.size())

    print("Enqueuing %d customers" % customer_count)

    # Pick N random customers from the pool
    var chosen_customers = RandomUtils.pick_random_count(customers, customer_count)

    var customer_names = chosen_customers.map(func(c): return c.customer_name)
    print("Picked %s" % ",".join(customer_names))

    # Enqueue
    for customer in chosen_customers:
        self._queue.add_child(customer)


# Remove and return the customer at the front of the line
# Returns null if there are no more customers in the queue
func pop_front() -> Customer:
    var customer = self._queue.get_children().front()

    if customer != null:
        self._queue.remove_child(customer)

    return customer


func _on_test_add_button_pressed():
    var available_customers = self._test_customers.filter(func(c): return not self._queue.get_children().has(c))
    self.enqueue_customers(available_customers, 1, 1)


func _on_test_remove_button_pressed():
    self.pop_front()

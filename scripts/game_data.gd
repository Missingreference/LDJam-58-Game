class_name GameData

signal gold_changed(gold)

enum GamePhase {
    one,
    two,
    three,
    four
}

var warehouse_inventory = Inventory.create_default_inventory()

# Items available in the shop
# Index on the name of the item
var shop_inventory = Inventory.new()

var _gold: int = 100

var customers: Array[Customer] =  Customer.create_default_customers()
var phase: GamePhase = GamePhase.one
var is_tutorial: bool = true


func get_gold() -> int:
    return _gold


func set_gold(value: int):
    self._gold = value
    self.gold_changed.emit(self._gold)


func add_gold(value: int):
    self._gold = max(self._gold + value, 0)
    self.gold_changed.emit(self._gold)

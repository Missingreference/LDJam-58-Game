class_name GameData

signal gold_changed(gold)

enum GamePhase {
    one,
    two,
    three,
    four
}

# Items stored in the warehouse
var warehouse_inventory = Inventory.create_default_inventory()

# Items available in the shop
var shop_inventory = Inventory.new()

# Players gold
var _gold: int = 100

# Regulars
var customers: Array[Customer] =  Customer.create_default_customers()

# Current phase of the game
var phase: GamePhase = GamePhase.one

# If tutorial mode is enabled
var is_tutorial: bool = true

var day_count: int = 0


func get_gold() -> int:
    return _gold


func set_gold(value: int):
    self._gold = value
    self.gold_changed.emit(self._gold)


func add_gold(value: int):
    self._gold = max(self._gold + value, 0)
    self.gold_changed.emit(self._gold)


static var collectables: Array[Collectable] = [

]

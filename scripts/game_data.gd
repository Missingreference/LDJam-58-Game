class_name GameData

enum GamePhase {
    one,
    two,
    three,
    four
}

var warehouse_inventory = Inventory.new()

# Items available in the shop
# Index on the name of the item
var shop_inventory = Inventory.new()

var coins = 0
var customers: Array[Customer] = []
var phase: GamePhase = GamePhase.one
var is_tutorial: bool = true

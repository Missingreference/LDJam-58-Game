class_name GameData

enum GamePhase {
    one,
    two,
    three,
    four
}

var inventory = Inventory.new()

# Items available in the shop
# Index on the name of the item
var shop_items = Inventory.new()

var coins = -1
var adventurers = []
var phase: GamePhase = GamePhase.one
var is_tutorial: bool = true

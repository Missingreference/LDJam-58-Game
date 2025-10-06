class_name ExpeditionLoot
extends Control

signal finished

@onready var _loot_ui: InventoryUI = $HBoxContainer/Loot
@onready var _warehouse_ui: InventoryUI = $HBoxContainer/Warehouse

var _game_data: GameData
var _loot: Inventory


func _ready():
    if get_tree().current_scene == self:
        # Test
        self.set_game_data(GameData.new())

        var loot = Inventory.new()
        loot.AddItem(Item.Create("Bow"))
        loot.AddItem(Item.Create("Potion"))
        loot.AddItem(Item.Create("Sword"))
        loot.AddItem(Item.Create("Potion"))
        self.set_loot(loot)

        self.start()


func set_game_data(game_data: GameData):
    self._game_data = game_data


func set_loot(loot: Inventory):
    self._loot = loot



func start():
    # Configure warehouse inventory ui
    self._warehouse_ui.SetMode(InventoryUI.Mode.Picker)
    self._warehouse_ui.SetTargetInventory(self._game_data.warehouse_inventory)
    self._warehouse_ui.EnableExit(false)
    self._warehouse_ui.itemChosen.connect(self._warehouse_item_chosen)

    # Configure loot inventory ui
    self._loot_ui.SetMode(InventoryUI.Mode.Picker)
    self._loot_ui.SetTargetInventory(self._loot)
    self._loot_ui.EnableExit(false)
    self._loot_ui.SetTitle("Loot")
    self._loot_ui.itemChosen.connect(self._loot_item_chosen)



func stop():
    pass


func _warehouse_item_chosen(item: Item):
    if not self._loot.AddItem(item):
        print("Loot area is full")
        return

    self._game_data.warehouse_inventory.RemoveItem(item)
    print("Moved %s from warehouse to loot inventory" % item.name)


func _loot_item_chosen(item: Item):
    if not self._game_data.warehouse_inventory.AddItem(item):
        print("Warehouse inventory is full")
        return

    self._loot.RemoveItem(item)
    print("Moved %s from loot inventory to warehouse" % item.name)
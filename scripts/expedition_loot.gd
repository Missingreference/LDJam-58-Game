class_name ExpeditionLoot
extends Control

signal finished

@onready var _loot_ui: InventoryUI = $HBoxContainer/Loot
@onready var _warehouse_ui: InventoryUI = $HBoxContainer/Warehouse


func _ready():
    if get_tree().current_scene == self:
        # Test
        var loot = Inventory.new()
        loot.AddItem(Item.Create("Bow"))
        loot.AddItem(Item.Create("Potion"))
        loot.AddItem(Item.Create("Sword"))
        loot.AddItem(Item.Create("Potion"))

        self.start(GameData.new(), loot)


func start(game_data: GameData, loot: Inventory):
    # Configure warehouse inventory ui
    self._warehouse_ui.SetMode(InventoryUI.Mode.Picker)
    self._warehouse_ui.SetTargetInventory(game_data.warehouse_inventory)
    self._warehouse_ui.EnableExit(false)
    self._warehouse_ui.SetTitle("Inventory")
    self._warehouse_ui.itemChosen.connect(self._warehouse_item_chosen.bind(game_data, loot))

    # Configure loot inventory ui
    self._loot_ui.SetMode(InventoryUI.Mode.Picker)
    self._loot_ui.SetTargetInventory(loot)
    self._loot_ui.EnableExit(false)
    self._loot_ui.SetTitle("Loot")
    self._loot_ui.itemChosen.connect(self._loot_item_chosen.bind(game_data, loot))
    self._loot_ui.EnableSelectAll(true)
    self._loot_ui.all_selected.connect(self._all_loot_selected.bind(game_data, loot))


func _warehouse_item_chosen(item: Item, game_data: GameData, loot: Inventory):
    if not loot.AddItem(item):
        print("Loot area is full")
        return

    game_data.warehouse_inventory.RemoveItem(item)
    print("Moved %s from warehouse to loot inventory" % item.name)


func _loot_item_chosen(item: Item, game_data: GameData, loot: Inventory):
    if not game_data.warehouse_inventory.AddItem(item):
        print("Warehouse inventory is full")
        return

    loot.RemoveItem(item)
    print("Moved %s from loot inventory to warehouse" % item.name)


func _all_loot_selected(game_data: GameData, loot: Inventory):
    # Sort all loot by value
    var loot_items = loot.GetItemsArray()
    loot_items.sort_custom(func(a, b): return a.GetValue() > b.GetValue())

    for item in loot_items:
        if not game_data.warehouse_inventory.AddItem(item):
            print("Warehouse inventory is full")
            break

        loot.RemoveItem(item)
        print("Moved %s from loot inventory to warehouse" % item.name)


func _on_accept_button_pressed():
    self.finished.emit()
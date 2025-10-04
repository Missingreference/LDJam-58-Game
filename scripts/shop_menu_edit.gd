extends Node2D

signal closed

const test_scene = preload("res://scenes/test.tscn")
const inventory_ui_scene = preload("res://scenes/inventory_ui.tscn")
const shop_menu_edit_item = preload("res://scenes/shop_menu_edit_item.tscn")

@onready var _edit_item_list = $Sprite2D/MarginContainer/VBoxContainer/VBoxContainer
@onready var _plus_button = $Sprite2D/MarginContainer/VBoxContainer/PlusButton

var game_data: GameData


func _ready():
    # If running scene standalone
    if get_tree().current_scene == self:
        # Test data
        self.game_data = GameData.new()
        self.game_data.inventory = Inventory.create_default_inventory()

    var shop_items = self.game_data.shop_items.GetItems()
    for items_array in shop_items.values():
        var quantity = items_array.size()
        self._add_edit_item_node(items_array[0], quantity)


func _on_plus_button_pressed():
    # Disable UI controls
    self._plus_button.pressed.disconnect(self._on_plus_button_pressed)

    # Fetch item from warehouse inventory
    var inventory_ui: InventoryUI = self.inventory_ui_scene.instantiate()
    self.add_child(inventory_ui)
    inventory_ui.global_position = get_viewport_rect().size / 2.0
    inventory_ui.SetMode(InventoryUI.Mode.Picker)
    inventory_ui.SetTargetInventory(self.game_data.inventory)
    inventory_ui.itemChosen.connect(self._inventory_item_chosen.bind(inventory_ui))
    inventory_ui.exited.connect(func():
        self.remove_child(inventory_ui)
        self._enable_controls()
    )


func _inventory_item_chosen(item: Item, inventory_ui):
    self.remove_child(inventory_ui)
    var success = self.game_data.inventory.RemoveItem(item)
    assert(success, "Tried to remove item that didn't exist!")
    self.game_data.shop_items.AddItem(item)

    # TODO check if we actually need to make a new edit item
    self._add_edit_item_node(item, 1)

    self._enable_controls()


func _enable_controls():
    # Restore UI controls
    self._plus_button.pressed.connect(self._on_plus_button_pressed)


func _add_edit_item_node(item: Item, quantity: int):
    var edit_item = shop_menu_edit_item.instantiate()
    edit_item.item_name = item.name
    edit_item.price = 10
    edit_item.quantity = quantity
    self._edit_item_list.add_child(edit_item)

    # Update button state based on item count available
    var item_count = self.game_data.inventory.GetItemCount(item)
    if item_count <= 0:
        edit_item.plus_button.disabled = true

    edit_item.quantity_changed.connect(self._item_quantity_changed.bind(edit_item, item))

    # Check if at max capacity
    if self._edit_item_list.get_child_count() >= 5:
        self._plus_button.visible = false


func _item_quantity_changed(change_amount, edit_item: ShopMenuEditItem, item: Item):
    # Update warehouse inventory
    # NOTE: assuming we only ever change by an amount of -1 or +1
    if change_amount < 0:
        var success = self.game_data.shop_items.RemoveItem(item)
        assert(success, "Inconsistent item quantity between inventory and shop menu (1)")
        self.game_data.inventory.AddItem(item)
    elif change_amount > 0:
        var success = self.game_data.inventory.RemoveItem(item)
        assert(success, "Inconsistent item quantity between inventory and shop menu (2)")
        self.game_data.shop_items.AddItem(item)

    # Update button state based on item count available
    var item_count = self.game_data.inventory.GetItemCount(item)
    if item_count <= 0:
        edit_item.plus_button.disabled = true
    else:
        edit_item.plus_button.disabled = false

    if edit_item.quantity <= 0:
        self._edit_item_list.remove_child(edit_item)

    # Check if at max capacity
    if self._edit_item_list.get_child_count() < 5:
        self._plus_button.visible = true


func _on_close_button_pressed():
    self.closed.emit()

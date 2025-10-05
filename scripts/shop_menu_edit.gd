class_name ShopMenuEdit
extends Control

signal closed

const inventory_ui_scene = preload("res://scenes/inventory_ui.tscn")
const shop_menu_edit_item = preload("res://scenes/shop_menu_edit_item.tscn")

@onready var _edit_item_list = $Sprite2D/MarginContainer/VBoxContainer/VBoxContainer
@onready var _plus_button = $Sprite2D/MarginContainer/VBoxContainer/PlusButton

var max_edit_item_count: int = 5
var game_data: GameData

var _item_name_to_edit_item: Dictionary[String, ShopMenuEditItem] = {}


func _ready():
    # If running scene standalone
    if get_tree().current_scene == self:
        # Center in view
        self.global_position = get_viewport_rect().size / 2

        # Test data
        self.game_data = GameData.new()
        self.game_data.warehouse_inventory = Inventory.create_default_inventory()
        self.game_data.warehouse_inventory.max_item_count = 18
        self.game_data.warehouse_inventory.AddItem(Item.Create("Bow", Item.Rarity.Rare, "Rare Bow"))
        self.game_data.warehouse_inventory.AddItem(Item.Create("Bow", Item.Rarity.Legendary, "Legendary Bow"))
        self.game_data.warehouse_inventory.AddItem(Item.Create("Sword", Item.Rarity.Rare, "Rare Sword"))
        self.game_data.warehouse_inventory.AddItem(Item.Create("Sword", Item.Rarity.Legendary, "Legendary Sword"))

    var shop_inventory = self.game_data.shop_inventory.GetItems()
    for items_array in shop_inventory.values():
        for item in items_array:
            self._add_edit_item_node(item)


func _on_plus_button_pressed():
    # Disable UI controls
    self._plus_button.pressed.disconnect(self._on_plus_button_pressed)

    # Fetch item from warehouse inventory
    var inventory_ui: InventoryUI = self.inventory_ui_scene.instantiate()
    self.add_child(inventory_ui)
    inventory_ui.SetMode(InventoryUI.Mode.Picker)
    inventory_ui.SetTargetInventory(self.game_data.warehouse_inventory)
    inventory_ui.itemChosen.connect(self._inventory_item_chosen.bind(inventory_ui))
    inventory_ui.exited.connect(func():
        self.remove_child(inventory_ui)
        self._enable_controls()
    )


func _inventory_item_chosen(item: Item, inventory_ui):
    self.remove_child(inventory_ui)
    var success = self.game_data.warehouse_inventory.RemoveItem(item)
    assert(success, "Tried to remove item that didn't exist!")
    self.game_data.shop_inventory.AddItem(item)

    self._add_edit_item_node(item)
    self._enable_controls()


func _enable_controls():
    # Restore UI controls
    self._plus_button.pressed.connect(self._on_plus_button_pressed)


func _update_buttons_state(edit_item: ShopMenuEditItem, item_name: String):
    # Update plus button state based on item count available
    var item_count = self.game_data.warehouse_inventory.GetItemCount(item_name)
    if item_count <= 0:
        edit_item.plus_button.disabled = true
    else:
        edit_item.plus_button.disabled = false

    # Update minus button state based on inventory count
    if self.game_data.warehouse_inventory.IsFull():
        # TODO: show tooltip to inform user that inventory is full
        for i in self._item_name_to_edit_item.values():
            i.minus_button.disabled = true
    else:
        for i in self._item_name_to_edit_item.values():
            i.minus_button.disabled = false

    # Check if at max capacity
    self._plus_button.visible = self._edit_item_list.get_child_count() < self.max_edit_item_count


func _add_edit_item_node(item: Item):
    # Check if we already have an edit item
    var edit_item: ShopMenuEditItem
    if self._item_name_to_edit_item.has(item.name):
        edit_item = self._item_name_to_edit_item[item.name]
        edit_item.quantity += 1
    else:
        edit_item = shop_menu_edit_item.instantiate()
        edit_item.item_name = item.name
        edit_item.price = 10
        edit_item.quantity = 1
        edit_item.quantity_changed.connect(self._item_quantity_changed.bind(edit_item, item))
        self._edit_item_list.add_child(edit_item)
        self._item_name_to_edit_item[item.name] = edit_item

    edit_item.update_labels()
    self._update_buttons_state(edit_item, item.name)

    # Check if at max capacity
    if self._edit_item_list.get_child_count() >= self.max_edit_item_count:
        self._plus_button.visible = false


func _item_quantity_changed(change_amount, edit_item: ShopMenuEditItem, item: Item):
    # Update warehouse inventory
    # NOTE: assuming we only ever change by an amount of -1 or +1
    if change_amount < 0:
        var success = self.game_data.shop_inventory.RemoveItem(item)
        assert(success, "Inconsistent item quantity between inventory and shop menu (1)")
        self.game_data.warehouse_inventory.AddItem(item)
    elif change_amount > 0:
        var success = self.game_data.warehouse_inventory.RemoveItem(item)
        assert(success, "Inconsistent item quantity between inventory and shop menu (2)")
        self.game_data.shop_inventory.AddItem(item)

    # If quantity drops to zero for the EditItem, remove it
    if edit_item.quantity <= 0:
        self._edit_item_list.remove_child(edit_item)
        self._item_name_to_edit_item.erase(edit_item.item_name)

    self._update_buttons_state(edit_item, item.name)


# Fill up remaining space available in shop inventory with most valuable warehouse items
func _on_autofill_button_pressed():
    # Sort warehouse items descending by value
    var warehouse_items = self.game_data.warehouse_inventory.GetItemsArray()
    warehouse_items.sort_custom(func(a, b): return a.GetValue() > b.GetValue())

    # For each warehouse item, check if we can fit it in the shop inventory
    for item in warehouse_items:
        # If we don't already have the item type in the shop
        if not self.game_data.shop_inventory.HasItem(item):
            # Check if we have hit the max number of unique items
            if self.game_data.shop_inventory.GetUniqueItemCount() >= self.max_edit_item_count:
                # No room for item
                continue

        # Otherwise, we have room for the item
        self.game_data.warehouse_inventory.RemoveItem(item)
        self.game_data.shop_inventory.AddItem(item)

    # Update UI
    self._update_ui()


# Update UI based on state of shop_inventory
func _update_ui():
    # Clear any existing items
    self._item_name_to_edit_item.clear()
    for child in self._edit_item_list.get_children():
        self._edit_item_list.remove_child(child)

    var inventory = self.game_data.shop_inventory.GetItems()
    for item_name in inventory:
        var item = inventory[item_name][0]
        var item_count = inventory[item_name].size()

        var edit_item = shop_menu_edit_item.instantiate()
        edit_item.item_name = item_name
        edit_item.price = item.GetValue()
        edit_item.quantity = item_count
        edit_item.quantity_changed.connect(self._item_quantity_changed.bind(edit_item, item))
        self._edit_item_list.add_child(edit_item)
        self._item_name_to_edit_item[item_name] = edit_item

    # Update plus button
    self._plus_button.visible = self._edit_item_list.get_child_count() >= self.max_edit_item_count

    # Update item buttons
    for item_name in self._item_name_to_edit_item:
        var edit_item = self._item_name_to_edit_item[item_name]
        self._update_buttons_state(edit_item, item_name)


func _on_close_button_pressed():
    self.closed.emit()

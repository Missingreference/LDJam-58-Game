extends Control

signal closed

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
    # TODO: fetch item from warehouse
    var item = Item.Create("Sword")
    self.game_data.inventory.RemoveItem(item)
    self._add_edit_item_node(item, 1)


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


func _on_close_button_pressed():
    self.closed.emit()

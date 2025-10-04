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
        var potions = []
        potions.resize(10)
        potions.fill(Item.Create("Potion"))
        self.game_data = GameData.new()
        self.game_data.inventory.AddItem(Item.Create("Sword"))
        self.game_data.inventory.AddItem(Item.Create("Sword"))
        self.game_data.inventory.AddItem(Item.Create("Bow"))
        self.game_data.inventory.AddItem(Item.Create("Bow"))
        self.game_data.inventory.AddItem(Item.Create("Bow"))
        for pot in potions:
            self.game_data.inventory.AddItem(pot)


func _on_plus_button_pressed():
    # TODO: fetch item from warehouse
    var item = Item.Create("Sword")
    self.game_data.inventory.RemoveItem(item)

    var edit_item = shop_menu_edit_item.instantiate()
    edit_item.item_name = item.name
    edit_item.price = 10

    # Update button state based on item count available
    var item_count = self.game_data.inventory.GetItemCount(item)
    if item_count <= 0:
        edit_item.plus_button.disabled = true

    edit_item.quantity_changed.connect(self._item_quantity_changed.bind(edit_item, item))
    self._edit_item_list.add_child(edit_item)

    # Check if at max capacity
    if self._edit_item_list.get_child_count() >= 5:
        self._plus_button.visible = false


func _item_quantity_changed(change_amount, edit_item: ShopMenuEditItem, item: Item):
    # Update warehouse inventory
    if change_amount < 0:
        self.game_data.inventory.AddItem(item)
    elif change_amount > 0:
        var success = self.game_data.inventory.RemoveItem(item)
        assert(success, "Inconsistent item quantity between inventory and shop menu")

    # Update button state based on item count available
    var item_count = self.game_data.inventory.GetItemCount(item)
    if item_count <= 0:
        edit_item.plus_button.disabled = true
    else:
        edit_item.plus_button.disabled = false

    if edit_item.quantity <= 0:
        self.remove_child(edit_item)


func _on_close_button_pressed():
    self.closed.emit()

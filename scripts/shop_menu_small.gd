class_name ShopMenuSmall
extends ColorRect

var shop_menu_edit_scene = preload("res://scenes/shop_menu_edit.tscn")

@onready var item_1: HBoxContainer = $MarginContainer/VBoxContainer/Item1
@onready var item_2: HBoxContainer = $MarginContainer/VBoxContainer/Item2
@onready var item_3: HBoxContainer = $MarginContainer/VBoxContainer/Item3
@onready var item_4: HBoxContainer = $MarginContainer/VBoxContainer/Item4
@onready var item_5: HBoxContainer = $MarginContainer/VBoxContainer/Item5


@onready var item_label_1: Label = $MarginContainer/VBoxContainer/Item1/Label
@onready var item_label_2: Label = $MarginContainer/VBoxContainer/Item2/Label
@onready var item_label_3: Label = $MarginContainer/VBoxContainer/Item3/Label
@onready var item_label_4: Label = $MarginContainer/VBoxContainer/Item4/Label
@onready var item_label_5: Label = $MarginContainer/VBoxContainer/Item5/Label

@onready var display_items = [
    item_1,
    item_2,
    item_3,
    item_4,
    item_5,
]

@onready var display_labels = [
    item_label_1,
    item_label_2,
    item_label_3,
    item_label_4,
    item_label_5,
]

@onready var highlight_color_rect: ColorRect = $HighlightColorRect

var _game_data: GameData


func _ready():
    assert(display_items.size() == display_labels.size())

    # Hide display items
    for item in display_items:
        item.visible = false

    # If running scene standalone
    if get_tree().current_scene == self:
        # Test data
        var game_data = GameData.new()
        set_game_data(game_data)

        game_data.warehouse_inventory = Inventory.create_default_inventory()
        var potion = game_data.warehouse_inventory.RemoveItem(Item.Create("Potion"))
        print("Adding shop item")
        game_data.shop_inventory.AddItem(potion)



func set_game_data(game_data: GameData):
    self._game_data = game_data
    self._game_data.shop_inventory.changed.connect(self._update_shop_display)


func _update_shop_display():
    print("Updating shop item display")
    var shop_inventory = self._game_data.shop_inventory.GetItems()

    var shop_item_names = shop_inventory.keys()

    # Loop over display slots and either populate it an item name and count,
    # or hide if there are not enough items to fill the display
    for display_index in range(display_items.size()):
        if display_index < shop_item_names.size():
            var item_name = shop_item_names[display_index]
            var item_count = shop_inventory[item_name].size()
            # Update the display label
            self.display_labels[display_index].text = "%s: %d" % [item_name, item_count]
            self.display_items[display_index].visible = true
        else:
            # There are not enough items to fill the display
            # Hide display item
            self.display_items[display_index].visible = false


func _on_mouse_entered():
    self.highlight_color_rect.color.a = 0.5


func _on_mouse_exited():
    self.highlight_color_rect.color.a = 0.0


func _on_gui_input(event: InputEvent):
    if event.is_pressed():
        self._open_shop_menu_edit()


func _open_shop_menu_edit():
    # Disable UI
    self.mouse_entered.disconnect(self._on_mouse_entered)
    self.mouse_exited.disconnect(self._on_mouse_exited)
    self.gui_input.disconnect(self._on_gui_input)
    self.highlight_color_rect.color.a = 0.0

    # Open shop edit scene
    var shop_edit = self.shop_menu_edit_scene.instantiate()
    shop_edit.game_data = self._game_data
    shop_edit.closed.connect(self._close_shop_menu_edit.bind(shop_edit))
    self.add_child(shop_edit)
    shop_edit.global_position = get_viewport_rect().size / 2.0


func _close_shop_menu_edit(shop_edit):
    # Close shop edit scene
    self.remove_child(shop_edit)

    # Enable UI
    self.mouse_entered.connect(self._on_mouse_entered)
    self.mouse_exited.connect(self._on_mouse_exited)
    self.gui_input.connect(self._on_gui_input)

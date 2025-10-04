class_name ShopMenuSmall
extends Node2D


@onready var item_1: HBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Item1
@onready var item_2: HBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Item2
@onready var item_3: HBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Item3
@onready var item_4: HBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Item4
@onready var item_5: HBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Item5


@onready var item_label_1: Label = $ColorRect/MarginContainer/VBoxContainer/Item1/Label
@onready var item_label_2: Label = $ColorRect/MarginContainer/VBoxContainer/Item2/Label
@onready var item_label_3: Label = $ColorRect/MarginContainer/VBoxContainer/Item3/Label
@onready var item_label_4: Label = $ColorRect/MarginContainer/VBoxContainer/Item4/Label
@onready var item_label_5: Label = $ColorRect/MarginContainer/VBoxContainer/Item5/Label

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


func _ready():
    assert(display_items.size() == display_labels.size())

    # Hide display items
    for item in display_items:
        item.visible = false

    # If running scene standalone
    if get_tree().current_scene == self:
        # Center in viewport
        var viewport_center = get_viewport().get_visible_rect().size / 2.0
        self.global_position = viewport_center

        # Test data
        var potions = []
        potions.resize(10)
        potions.fill(Item.Create("Potion"))
        var shop_items = {
            "Sword": [Item.Create("Sword")],
            # "Armor": [Item.Create("Armor"), Item.Create("Armor")],
            "Bows": [Item.Create("Bow"), Item.Create("Bow"), Item.Create("Bow")],
            "Potion":  potions,
        }
        self.update(shop_items)


func update(shop_items: Dictionary):
    print("Updating shop item display")

    var shop_item_names = shop_items.keys()

    # Loop over display slots and either populate it an item name and count,
    # or hide if there are not enough items to fill the display
    for display_index in range(display_items.size()):
        if display_index < shop_item_names.size():
            var item_name = shop_item_names[display_index]
            var item_count = shop_items[item_name].size()
            # Update the display label
            self.display_labels[display_index].text = "%s: %d" % [item_name, item_count]
            self.display_items[display_index].visible = true
        else:
            # There are not enough items to fill the display
            # Hide display item
            self.display_items[display_index].visible = false

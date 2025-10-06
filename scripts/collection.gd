class_name Collection
extends Control

signal closed

@onready var inventory_ui: InventoryUI = $InventoryUI

var _collection: Inventory

func set_collection(collection: Inventory):
    self._collection = collection


func _ready():
    self.inventory_ui.SetMode(InventoryUI.Mode.Readonly)
    self.inventory_ui.SetTargetInventory(self._collection)
    self.inventory_ui.SetTitle("Collection")
    self.inventory_ui.closed.connect(self.closed.emit)
        

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE or event.keycode == KEY_C:
            get_viewport().set_input_as_handled()
            self.closed.emit()
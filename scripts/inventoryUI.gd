#Usage:
#-Call SetMode
#-Call SetInventory
#-Listen for signals
class_name InventoryUI
extends Node2D
var item_slot_scene =  preload("res://scenes/item_slot.tscn")

@onready var colorRect: ColorRect = $ColorRect
@onready var titleLabel: Label = $ColorRect/Title
@onready var marginContainer: MarginContainer = $ColorRect/MarginContainer
@onready var gridContainer: GridContainer = $ColorRect/MarginContainer/GridContainer
@onready var selectionHighlighter: ColorRect = $ColorRect/"Selection Highlighter"
@onready var exitButton: Button = $"ColorRect/Exit Button"
@onready var chooseButton: Button = $"ColorRect/Choose Button"

signal itemChosen
signal exited

var _inventory: Inventory
var _mode: Mode
var _selectedSlot: ItemSlot

enum Mode
{
    #Nothing
    Readonly,
    #Be able to pick an item
    Picker,
    #Be able to delete any items
    Manage
}

const SLOT_PIXEL_SIZE = 40
const SLOT_SPACING = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    selectionHighlighter.visible = false

    SetMode(Mode.Readonly)

    if get_tree().current_scene == self:
        # Center in viewport
        self.global_position = get_viewport_rect().size / 2.0

        #Debug
        SetMode(Mode.Manage)

        var debugInventory = Inventory.new()
        debugInventory.max_item_count = 10
        debugInventory.AddItem(Item.Create("Potion"))
        SetTargetInventory(debugInventory)

func Refresh():
    #Remove old slots
    #Note: It would be better to resuse these item slots
    for child in gridContainer.get_children():
        gridContainer.remove_child(child)

    var itemCountSoFar = 0
    var inventoryItems = _inventory.GetItems().values()
    for itemArray in inventoryItems:
        for item in itemArray:
            gridContainer.add_child(_createSlot(item))
            itemCountSoFar += 1

    while itemCountSoFar < _inventory.max_item_count:
        gridContainer.add_child(_createSlot(null))
        itemCountSoFar += 1

func SetMode(mode):
    if mode == Mode.Readonly:
        titleLabel.text = "Inventory"
        chooseButton.visible = false
    elif mode == Mode.Picker:
        titleLabel.text = "Select an Item"
        chooseButton.visible = true
        chooseButton.disabled = true
    elif mode == Mode.Manage:
        titleLabel.text = "Inventory"
        chooseButton.visible = false

    _mode = mode

func SetTargetInventory(inventory: Inventory):
    _inventory = inventory
    _inventory.changed.connect(Refresh)

    #Define spacing and column count
    var columnCount = floor(self.colorRect.size.x / (SLOT_PIXEL_SIZE + SLOT_SPACING))
    var remainingSpace = self.colorRect.size.x - ((columnCount * SLOT_PIXEL_SIZE) + ((columnCount-1) * SLOT_SPACING))
    gridContainer.columns = columnCount
    gridContainer.add_theme_constant_override("h_separation", SLOT_SPACING)
    marginContainer.offset_left = remainingSpace * 0.5

    Refresh()

func _createSlot(item: Item) -> ItemSlot:
    var newSlot: ItemSlot = item_slot_scene.instantiate()
    newSlot.item = item
    newSlot.custom_minimum_size = Vector2(SLOT_PIXEL_SIZE, SLOT_PIXEL_SIZE)

    if _mode == Mode.Manage:
        newSlot.manageable = true
        newSlot.selectable = false
        newSlot.deleted.connect(_onSlotDeleted.bind(newSlot))
    elif _mode == Mode.Picker:
        newSlot.manageable = false
        newSlot.selected.connect(_onSlotSelected.bind(newSlot))
        if item != null:
            newSlot.selectable = true
    else:
        newSlot.manageable = false
        newSlot.selectable = false

    return newSlot

func _onSlotSelected(slot: ItemSlot):
    _selectedSlot = slot
    chooseButton.disabled = false
    selectionHighlighter.visible = true
    selectionHighlighter.global_position = slot.global_position + (-(selectionHighlighter.size / 2)) + (slot.size / 2)
    print(selectionHighlighter.global_position)

func _onSlotDeleted(slot: ItemSlot):
    _inventory.RemoveItem(slot.item)
    Refresh()

func _onChooseButtonPressed():
    chooseButton.disabled = true
    itemChosen.emit(_selectedSlot.item)

func _onExitButtonPressed():
    exited.emit()

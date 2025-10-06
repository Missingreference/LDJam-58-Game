#Usage:
#-Call SetMode
#-Call SetInventory
#-Listen for signals
class_name InventoryUI
extends Control
var item_slot_scene =  preload("res://scenes/item_slot.tscn")

@onready var aspect_layout_control: Control = $"AspectRatioContainer/AspectLayoutControl"
@onready var background: TextureRect = $"AspectRatioContainer/AspectLayoutControl/Background"
@onready var titleLabel: Label = $"AspectRatioContainer/AspectLayoutControl/Background/Title"
@onready var selectionHighlighter: ColorRect = $"AspectRatioContainer/AspectLayoutControl/Background/Selection Highlighter"
@onready var exitButton: Button = $"AspectRatioContainer/AspectLayoutControl/Background/Exit Button"
@onready var selectButton: Button = $AspectRatioContainer/AspectLayoutControl/Background/HBoxContainer/SelectButton
@onready var selectAllButton: Button = $AspectRatioContainer/AspectLayoutControl/Background/HBoxContainer/SelectAllButton

var itemSlots: Array[ItemSlot] = []

signal itemChosen(Item)
signal all_selected
signal exited

var _inventory: Inventory
var _mode: Mode
var _selectedSlot: ItemSlot
var _inventory_tooltip_scene = preload("res://scenes/inventory_tooltip.tscn")
var _tooltip: InventoryTooltip

enum Mode
{
    #Nothing
    Readonly,
    #Be able to pick an item
    Picker,
    #Be able to delete any items
    Manage
}

func _init() -> void:
    _tooltip = _inventory_tooltip_scene.instantiate()
    self.add_child(_tooltip)
    _tooltip.visible = false

func _ready() -> void:
    selectionHighlighter.visible = false

    SetMode(Mode.Readonly)

    assert(aspect_layout_control != null)

    for i in 18:
        var itemSlot: ItemSlot = aspect_layout_control.find_child("ItemSlot" + str(i+1), false)
        assert(itemSlot != null)
        itemSlots.append(itemSlot)
        itemSlot.deleted.connect(_onSlotDeleted.bind(itemSlot))
        itemSlot.connect("mouse_entered", _on_mouse_enter_slot.bind(itemSlot))
        itemSlot.connect("mouse_exited", _on_mouse_exit_slot.bind())
        itemSlot.selected.connect(_onSlotSelected.bind(itemSlot))
        itemSlot.chosen.connect(_on_slot_chosen.bind(itemSlot))


    if get_tree().current_scene == self:
        # Center in viewport
        #self.global_position = get_viewport_rect().size / 2.0

        #Debug
        SetMode(Mode.Picker)

        var debugInventory = Inventory.new()
        debugInventory.max_item_count = 18
        for i in 18:
            debugInventory.AddItem(Item.Create("Potion", Item.Rarity.Normal))
        SetTargetInventory(debugInventory)


func EnableExit(enable: bool):
    self.exitButton.visible = enable


func EnableSelectAll(enable: bool):
    self.selectAllButton.visible = enable


func SetTitle(value: String):
    self.titleLabel.text = value


func Refresh():
    var itemCountSoFar = 0
    for item in _inventory.GetItemsArray():
        _get_slot(itemCountSoFar, item)
        itemCountSoFar += 1

    while itemCountSoFar < 18: #_inventory.max_item_count:
        _get_slot(itemCountSoFar, null)
        itemCountSoFar += 1

    self._setNoSlotSelect()

func SetMode(mode):
    if mode == Mode.Readonly:
        titleLabel.text = "Inventory"
        selectButton.visible = false
        selectAllButton.visible = false
    elif mode == Mode.Picker:
        titleLabel.text = "Select an Item"
        selectButton.visible = true
        selectButton.disabled = true
        # select all button is disabled by default
        selectAllButton.visible = false
    elif mode == Mode.Manage:
        titleLabel.text = "Inventory"
        selectButton.visible = false
        selectAllButton.visible = false

    _mode = mode

func SetTargetInventory(inventory: Inventory):
    _inventory = inventory
    _inventory.changed.connect(Refresh)

    Refresh()

func _get_slot(slotIndex: int, item: Item) -> ItemSlot:
    var itemSlot: ItemSlot = itemSlots[slotIndex]

    if _mode == Mode.Manage:
        itemSlot.manageable = true
        itemSlot.selectable = false
    elif _mode == Mode.Picker:
        itemSlot.manageable = false
        if item != null:
            itemSlot.selectable = true
    else:
        itemSlot.manageable = false
        itemSlot.selectable = false

    itemSlot.set_item(item)

    return itemSlot

func _onSlotSelected(slot: ItemSlot):
    if _mode != Mode.Picker || slot.get_item() == null: return
    _selectedSlot = slot
    selectButton.disabled = false
    selectionHighlighter.visible = true
    selectionHighlighter.global_position = slot.global_position + (-(selectionHighlighter.size / 2)) + (slot.size / 2)

func _setNoSlotSelect():
    _selectedSlot = null
    selectButton.disabled = true
    selectionHighlighter.visible = false

func _onSlotDeleted(slot: ItemSlot):
    if _mode != Mode.Manage || slot.get_item() == null: return
    var popupMenu: GamePopupMenu = GamePopupMenu.Create("Throw away " + slot.get_item().name + "?", "This item will be lost.")
    self.add_child(popupMenu)
    print(popupMenu.global_position)
    print(popupMenu.anchor_left)
    popupMenu.confirmed.connect(func():
        self.remove_child(popupMenu)
        _inventory.RemoveItem(slot.get_item())
        Refresh()
    )
    popupMenu.cancelled.connect(func():
        self.remove_child(popupMenu)
    )

func _on_slot_chosen(slot: ItemSlot):
    if _mode != Mode.Picker || slot.get_item() == null: return
    _onSlotSelected(slot)
    _onSelectButtonPressed()

func _onSelectButtonPressed():
    selectButton.disabled = true
    itemChosen.emit(_selectedSlot.get_item())

func _on_select_all_button_pressed():
    self.all_selected.emit()

func _onExitButtonPressed():
    exited.emit()

func _on_mouse_enter_slot(slot: ItemSlot):
    if slot.get_item() == null: return
    _tooltip.visible = true
    _tooltip.move_to_front()
    _tooltip.item_title.text = slot.get_item().name
    _tooltip.item_description.text = "Type: " + str(slot.get_item().GetType()) + "\n" + "Rarity: " + str(slot.get_item().rarity) + "\n" + "Value: " + str(20)

func _on_mouse_exit_slot():
    _tooltip.visible = false

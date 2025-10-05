class_name ItemSlot
extends Control

signal selected
signal chosen
signal deleted

@onready var placeholderLabel: Label = $"Placeholder Label"
@onready var itemTexture: TextureRect = $"TextureRect"
@onready var deleteButton: Button = $"Delete Button"

var _item: Item = null
var selectable: bool = false
var manageable: bool = false

func _init():
    pass

func _ready() -> void:
    self.connect("gui_input", _on_texture_rect_gui_input)
    pass
    
func get_item() -> Item:
    return _item

func set_item(item: Item):
    _item = item
    
    if _item == null:
        placeholderLabel.text = ""
        #placeholderLabel.text = "[debug empty]"
        itemTexture.visible = false
        deleteButton.visible = false
    else:
        
        itemTexture.texture = _item.GetSprite()
        if itemTexture.texture == null:
            placeholderLabel.text = "[debug: " + _item.name + "]"
        else:
            placeholderLabel.text = ""
        if manageable:
            deleteButton.visible = true
        else:
            deleteButton.visible = false
        
func _on_texture_rect_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
        if event.double_click:
            chosen.emit()
        elif event.is_pressed():
            selected.emit()

func _on_delete_button_pressed() -> void:
    deleted.emit()    

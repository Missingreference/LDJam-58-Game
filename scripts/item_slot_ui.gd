class_name ItemSlot
extends ColorRect

signal selected
signal deleted

@onready var placeholderLabel: Label = $"Placeholder Label"
@onready var itemTexture: TextureRect = $"TextureRect"
@onready var deleteButton: Button = $"Delete Button"


var item: Item = null
var selectable: bool = false
var manageable: bool = false

func _init():
    pass

func _ready() -> void:
    if item == null:
        placeholderLabel.text = "[debug empty]"
        itemTexture.visible = false
        deleteButton.visible = false
    else:
        placeholderLabel.text = "[debug: " + item.name + "]"
        itemTexture.texture = item.GetSprite()
        if manageable:
            deleteButton.visible = true
        else:
            deleteButton.visible = false
        
func _on_texture_rect_gui_input(event: InputEvent) -> void:
    if event.is_pressed():
        print("Pressed!")
        selected.emit()


func _on_delete_button_pressed() -> void:
    deleted.emit()

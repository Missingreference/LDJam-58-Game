class_name InventoryTooltip
extends PanelContainer

@onready var item_title: Label = $"VBoxContainer/Item Title"
@onready var item_description: Label = $"VBoxContainer/MarginContainer/Item Description"

var offset : Vector2 = Vector2(20, 20)

func _ready() -> void:
    #self.visibility_changed.connect(_on_visibility_changed)
    pass


func _input(event: InputEvent) -> void:
    if visible && event is InputEventMouseMotion:
        var home_position = get_global_mouse_position() + offset
        if home_position.x + self.size.x > get_viewport_rect().size.x:
            global_position.x = get_global_mouse_position().x - offset.x - self.size.x
        else: 
            global_position.x = home_position.x
        if home_position.y + self.size.y > get_viewport_rect().size.y:
            global_position.y = get_global_mouse_position().y - offset.y - self.size.y
        else:
            global_position.y = home_position.y
    pass

#func _on_visibility_changed():
 #   if visible :
  #      global_position = get_global_mouse_position() +

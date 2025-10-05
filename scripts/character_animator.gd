extends Node2D

func _ready() -> void:
    for i in self.get_child_count():
        get_child(i).play()
    pass


func _process(delta: float) -> void:
    pass

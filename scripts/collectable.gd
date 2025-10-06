class_name Collectable
extends TextureRect


var collectable_name: String
var missing_texture
var found_texture


func _init(_name: String, _missing_texture, _found_texture):
    self.collectable_name = name
    self.missing_texture = _missing_texture
    self.found_texture = _found_texture
    self.texture = _found_texture
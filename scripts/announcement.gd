class_name Announcement
extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $"ColorRect/CenterContainer/Center Point/Label"

var background_animate_time = 0.75
var text_animate_time = 0.75
var background_size = 250.0

func _ready() -> void:
    if get_tree().current_scene == self:
        announce("[Debug Message 1]", "[Debug Message 2]")
    pass

func announce(message1: String, message2: String):
    visible = true
    
    #init label
    label.modulate.a = 0
    
    var vertical_center = get_viewport_rect().size.y / 2
    #Use set_deferred to hide warning of setting size
    color_rect.set_deferred("size", Vector2(color_rect.size.x, 0))
    
    color_rect.global_position.x = 0
    color_rect.global_position.y = vertical_center
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(color_rect, "size:y", background_size, background_animate_time)
    tween.tween_property(color_rect, "position:y", vertical_center - background_size / 2.0, background_animate_time)
    
    await tween.finished
    
    label.text = message1
    label.position.y = -(color_rect.size.y / 2.0)
    var label_target_pos_y = 0 - (label.size.y/2.0)
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(label, "modulate:a", 1.0, text_animate_time - 0.1)
    tween.tween_property(label, "position:y", label_target_pos_y, text_animate_time)
    
    await tween.finished
    
    label_target_pos_y = (color_rect.size.y / 2.0) - label.size.y
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(label, "modulate:a", 0.0, text_animate_time - 0.1)
    tween.tween_property(label, "position:y", label_target_pos_y, text_animate_time)
    
    await tween.finished
    
    label.text = message2
    label.position.y = -(color_rect.size.y / 2.0)
    label_target_pos_y = 0 - (label.size.y/2.0)
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(label, "modulate:a", 1.0, text_animate_time - 0.1)
    tween.tween_property(label, "position:y", label_target_pos_y, text_animate_time)
    
    await tween.finished
    
    label_target_pos_y = (color_rect.size.y / 2.0) - label.size.y
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(label, "modulate:a", 0.0, text_animate_time - 0.1)
    tween.tween_property(label, "position:y", label_target_pos_y, text_animate_time)
    
    await tween.finished
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(color_rect, "size:y", 0, background_animate_time)
    tween.tween_property(color_rect, "position:y", vertical_center, background_animate_time)
    
    await tween.finished
    
    visible = false

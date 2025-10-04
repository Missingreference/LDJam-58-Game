class_name GamePopupMenu
extends Control

signal confirmed
signal cancelled

@onready var titleLabel: Label = $ColorRect/Title
@onready var messageLabel: Label = $ColorRect/Message
@onready var confirmButton: Button = $ColorRect/ConfirmButton
@onready var cancelButton: Button = $ColorRect/CancelButton

static var _game_popup_menu_scene = preload("res://scenes/popup_menu.tscn")

static func Create(title: String, message: String) -> GamePopupMenu:
    var newPopupMenu:GamePopupMenu = _game_popup_menu_scene.instantiate()
    newPopupMenu.SetTitle(title)
    newPopupMenu.SetMessage(message)
    return newPopupMenu
    
var _title: String = ""
var _message: String = ""

func _ready() -> void:
    confirmButton.pressed.connect(_on_confirm_button_pressed)
    cancelButton.pressed.connect(_on_cancel_button_pressed)
    
    titleLabel.text = _title
    messageLabel.text = _message
    pass
    
func SetTitle(title: String):
    _title = title
    if titleLabel != null:
        titleLabel.text = _title

func SetMessage(message: String):
    _message = message
    if messageLabel != null:
        messageLabel.text = message

func _on_confirm_button_pressed():
    confirmButton.disconnect("pressed", _on_confirm_button_pressed)
    confirmed.emit()
    
func _on_cancel_button_pressed():
    cancelButton.disconnect("pressed", _on_cancel_button_pressed)
    cancelled.emit()

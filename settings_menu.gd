class_name SettingsMenu
extends Control

signal closed

@onready var closeButton: Button = $ColorRect/CloseButton
@onready var quitButton: Button = $ColorRect/QuitButton
@onready var volumeSlider: Slider = $ColorRect/VBoxContainer/VolumeContainer/VolumeSlider
@onready var volumePercentLabel: Label = $ColorRect/VBoxContainer/VolumeContainer/VolumePercentLabel
@onready var fullscreenCheckButton: CheckButton = $ColorRect/VBoxContainer/FullscreenContainer/CheckButton

func _ready() -> void:
    #Volume Slider
    var currentVolume = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
    volumePercentLabel.text = str(ceili(currentVolume)) + "%"
    
    #Fullscreen toggle
    if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
        fullscreenCheckButton.set_pressed_no_signal(true)
    else:
        fullscreenCheckButton.set_pressed_no_signal(false)

func _volume_changed(value: float):
    AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
    volumePercentLabel.text = str(ceili(value)) + "%"
    pass
    
func _fullscreen_checkbutton_pressed():
    if fullscreenCheckButton.button_pressed:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _close_button_pressed():
    _disable_controls()
    closed.emit()
    pass
    
func _quit_button_pressed():
    _disable_controls()
    
    var popupMenu: GamePopupMenu = GamePopupMenu.Create("Quit Game?", "All progress will be lost.")
    self.add_child(popupMenu)
    popupMenu.confirmed.connect(func():
        get_tree().quit()
    )
    
    popupMenu.cancelled.connect(func():
        self.remove_child(popupMenu)
        _enable_controls()
    )

func _enable_controls():
    closeButton.disabled = false
    quitButton.disabled = false
    volumeSlider.editable = true
    fullscreenCheckButton.disabled = false
    pass

func _disable_controls():
    closeButton.disabled = true
    quitButton.disabled = true
    volumeSlider.editable = false
    fullscreenCheckButton.disabled = true
    pass

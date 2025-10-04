class_name Game
extends Control

@onready var inventory_button: Button = $InventoryButton
@onready var settings_button: Button = $SettingsButton
@onready var gold_label: Label = $GoldLabel
@onready var finish_button: Button = $FinishButton
@onready var phase_label: Label = $PhaseLabel
@onready var shop_menu: ShopMenuSmall = $ShopMenuSmall
@onready var customer_queue: CustomerQueue = $CustomerQueue

var game_data = GameData.new()

var inventory_ui_scene = preload("res://scenes/inventory_ui.tscn")
var settings_menu_scene = preload("res://scenes/settings_menu.tscn")


func _ready():
    self.game_data.gold_changed.connect(self._update_gold_label)
    self._update_gold_label(self.game_data.get_gold())
    self.shop_menu.set_game_data(self.game_data)
    self.customer_queue.set_game_data(self.game_data)
    self._start_phase_one()


func _start_phase_one():
    print("Starting phase one")

    self.phase_label.text = "Phase One"
    self.game_data.phase = GameData.GamePhase.one
    self.finish_button.pressed.connect(self._finish_phase_one)
    self.finish_button.visible = true
    self.shop_menu.start()


func _finish_phase_one():
    print("Finished phase one")

    self.finish_button.pressed.disconnect(self._finish_phase_one)
    self.finish_button.visible = false
    self.shop_menu.stop()
    self._start_phase_two()


func _start_phase_two():
    print("Starting phase two")
    self.phase_label.text = "Phase Two"
    self.game_data.phase = GameData.GamePhase.two
    self.customer_queue.queue_emptied.connect(self._finish_phase_two)
    self.customer_queue.start()



func _finish_phase_two():
    print("Finished phase two")

    self.customer_queue.queue_emptied.disconnect(self._finish_phase_two)
    self.customer_queue.stop()
    self._start_phase_three()


func _start_phase_three():
    print("Starting phase three")

    self.phase_label.text = "Phase Three"
    self.game_data.phase = GameData.GamePhase.three
    self.finish_button.pressed.connect(self._finish_phase_three)
    self.finish_button.visible = true


func _finish_phase_three():
    print("Finished phase three")

    self.finish_button.pressed.disconnect(self._finish_phase_three)
    self.finish_button.visible = false
    self._start_phase_four()


func _start_phase_four():
    print("Starting phase four")

    self.phase_label.text = "Phase Four"
    self.game_data.phase = GameData.GamePhase.four
    self.finish_button.pressed.connect(self._finish_phase_four)
    self.finish_button.visible = true


func _finish_phase_four():
    print("Finished phase four")

    self.finish_button.pressed.disconnect(self._finish_phase_four)
    self.finish_button.visible = false
    self._start_phase_one()


func _update_gold_label(value: int):
    self.gold_label.text = "Gold: %d" % value


func _inventory_button_pressed():
    _disable_controls()

    var inventory_ui: InventoryUI = inventory_ui_scene.instantiate()
    self.add_child(inventory_ui)
    inventory_ui.global_position = get_viewport_rect().size / 2.0
    inventory_ui.SetMode(InventoryUI.Mode.Manage)
    inventory_ui.SetTargetInventory(game_data.warehouse_inventory)
    inventory_ui.exited.connect(func():
        self.remove_child(inventory_ui)
        _enable_controls()
    )

func _settings_button_pressed():
    _disable_controls()

    var settingsMenu: SettingsMenu = settings_menu_scene.instantiate()
    self.add_child(settingsMenu)
    settingsMenu.global_position = get_viewport_rect().size / 2.0
    settingsMenu.exited.connect(func():
        self.remove_child(settingsMenu)
        _enable_controls()
    )

func _enable_controls():
    inventory_button.disabled = false
    settings_button.disabled = false
    finish_button.disabled = false
    if game_data.phase == GameData.GamePhase.one:
        self.shop_menu.mouse_filter = Control.MOUSE_FILTER_STOP

func _disable_controls():
    inventory_button.disabled = true
    settings_button.disabled = true
    finish_button.disabled = true
    self.shop_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE

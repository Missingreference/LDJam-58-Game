class_name Game
extends Control

@onready var inventory_button: Button = $InventoryButton
@onready var settings_button: Button = $SettingsButton
@onready var info_tooltip_label: Label = $InfoTooltip
@onready var gold_label: Label = $GoldLabel
@onready var finish_button: Button = $FinishButton
@onready var phase_title: Label = $PhaseTitle
@onready var phase_texture: TextureRect = $PhaseTexture
@onready var shop_menu: ShopMenuSmall = $ShopMenuSmall
@onready var customer_queue: CustomerQueue = $CustomerQueue
@onready var empty_shop_dialog: ConfirmationDialog = $EmptyShopDialog

var game_data = GameData.new()

var inventory_ui_scene = preload("res://scenes/inventory_ui.tscn")
var settings_menu_scene = preload("res://scenes/settings_menu.tscn")

var phase_1_sprite = preload("res://assets/sprites/phase1_active.png")
var phase_2_sprite = preload("res://assets/sprites/phase2_active.png")
var phase_3_sprite = preload("res://assets/sprites/phase3_active.png")
var phase_4_sprite = preload("res://assets/sprites/phase4_active.png")


# Internal signal to know the result of the EmptyShopDialog
signal _empty_shop_confirm(bool)


func _ready():
    info_tooltip_label.text = ""
    
    # Setup empty shop dialog signals
    self.empty_shop_dialog.canceled.connect(func(): self._empty_shop_confirm.emit(false))
    self.empty_shop_dialog.confirmed.connect(func(): self._empty_shop_confirm.emit(true))

    self.game_data.gold_changed.connect(self._update_gold_label)
    self._update_gold_label(self.game_data.get_gold())
    self.shop_menu.set_game_data(self.game_data)
    self.customer_queue.set_game_data(self.game_data)
    self._start_phase_one()


func _start_phase_one():
    print("Starting phase one")

    self.phase_title.text = "Preparation"
    self.phase_texture.texture = phase_1_sprite
    self.game_data.phase = GameData.GamePhase.one
    self.finish_button.pressed.connect(self._finish_phase_one)
    self.finish_button.visible = true
    self.shop_menu.start()

func _finish_phase_one():
    self.finish_button.pressed.disconnect(self._finish_phase_one)
    self.finish_button.visible = false
    self.shop_menu.stop()
    self.phase_title.text = ""

    # If shop inventory is empty, warn the user
    if self.game_data.shop_inventory._item_count <= 0:
        self.empty_shop_dialog.popup_centered()

        # Wait for confirmation
        var do_continue = await self._empty_shop_confirm
        if not do_continue:
            # stay in phase one, redo setup
            self._start_phase_one()
            return

    print("Finished phase one")
    self._start_phase_two()


func _start_phase_two():
    print("Starting phase two")
    
    self.phase_title.text = "Customers"
    self.phase_texture.texture = phase_2_sprite
    self.game_data.phase = GameData.GamePhase.two
    self.customer_queue.queue_emptied.connect(self._finish_phase_two)
    self.customer_queue.start()



func _finish_phase_two():
    print("Finished phase two")
    
    self.phase_title.text = ""
    self.customer_queue.queue_emptied.disconnect(self._finish_phase_two)
    self.customer_queue.stop()
    self._start_phase_three()


func _start_phase_three():
    print("Starting phase three")

    self.phase_title.text = "Hire Adventurers"
    self.phase_texture.texture = phase_3_sprite
    self.game_data.phase = GameData.GamePhase.three
    self.finish_button.pressed.connect(self._finish_phase_three)
    self.finish_button.visible = true


func _finish_phase_three():
    print("Finished phase three")
    
    self.phase_title.text = ""
    self.finish_button.pressed.disconnect(self._finish_phase_three)
    self.finish_button.visible = false
    self._start_phase_four()


func _start_phase_four():
    print("Starting phase four")
    
    self.phase_title.text = "End Day Report"
    self.phase_texture.texture = phase_4_sprite
    self.game_data.phase = GameData.GamePhase.four
    self.finish_button.pressed.connect(self._finish_phase_four)
    self.finish_button.visible = true


func _finish_phase_four():
    print("Finished phase four")
    
    self.phase_title.text = ""
    self.finish_button.pressed.disconnect(self._finish_phase_four)
    self.finish_button.visible = false
    self._start_phase_one()


func _update_gold_label(value: int):
    self.gold_label.text = "Gold: %d" % value


func _inventory_button_pressed():
    _disable_controls()

    var inventory_ui: InventoryUI = inventory_ui_scene.instantiate()
    self.add_child(inventory_ui)
    inventory_ui.SetMode(InventoryUI.Mode.Manage)
    inventory_ui.SetTargetInventory(game_data.warehouse_inventory)
    inventory_ui.exited.connect(func():
        self.remove_child(inventory_ui)
        _enable_controls()
    )

func _inventory_button_enter():
    info_tooltip_label.text = "Inventory"
    pass
    
func _inventory_button_exit():
    info_tooltip_label.text = ""
    pass

func _settings_button_pressed():
    _disable_controls()

    var settingsMenu: SettingsMenu = settings_menu_scene.instantiate()
    self.add_child(settingsMenu)
    settingsMenu.closed.connect(func():
        self.remove_child(settingsMenu)
        _enable_controls()
    )
    
func _settings_button_enter():
    info_tooltip_label.text = "Settings"
    
func _settings_button_exit():
    info_tooltip_label.text = ""

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

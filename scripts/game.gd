class_name Game
extends Control

@onready var inventory_button: Button = $InventoryButton
@onready var settings_button: Button = $SettingsButton
@onready var info_tooltip_label: Label = $InfoTooltip
@onready var gold_label: Label = $GoldLabel
@onready var end_phase_button: TextureButton = $EndPhaseButton
@onready var phase_title: Label = $PhaseTitle
@onready var day_count_label: Label = $"DayCount Text"
@onready var phase_texture: TextureRect = $PhaseTexture
@onready var shop_menu: ShopMenuSmall = $ShopMenuSmall
@onready var customer_queue: CustomerQueue = $CustomerQueue
@onready var expedition_hiring: ExpeditionHiring = $ExpeditionHiring
@onready var empty_shop_dialog: ConfirmationDialog = $EmptyShopDialog
@onready var collection: Collection = $Collection

var game_data = GameData.new()

var keyboard_input_disabled = false

var inventory_ui_scene = preload("res://scenes/inventory_ui.tscn")
var settings_menu_scene = preload("res://scenes/settings_menu.tscn")
var collection_scene = preload("res://scenes/collection.tscn")
var expedition_result_scene = preload("res://scenes/expedition_result.tscn")
var expedition_loot_scene = preload("res://scenes/expedition_loot.tscn")

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

    # Connect gold label for updates
    self.game_data.gold_changed.connect(self._update_gold_label)
    self._update_gold_label(self.game_data.get_gold())

    # Artificially constrain warehouse inventory to 18 slots (this is all InventoryUI can handle)
    self.game_data.warehouse_inventory.max_item_count = 18

    # Pass game data to children that need it
    self.shop_menu.set_game_data(self.game_data)
    self.customer_queue.set_game_data(self.game_data)
    self.expedition_hiring.set_game_data(self.game_data)

    self._start_phase_one()


func _start_phase_one():
    print("Starting phase one")
    
    game_data.day_count += 1
    day_count_label.text = "Day " + str(game_data.day_count)
    
    self.phase_title.text = "Preparation"
    self.phase_texture.texture = phase_1_sprite
    self.game_data.phase = GameData.GamePhase.one

    await self.shop_menu.start()

    self.end_phase_button.pressed.connect(self._finish_phase_one)
    self.end_phase_button.disabled = false


func _finish_phase_one():
    print("Finishing phase one")

    self.end_phase_button.pressed.disconnect(self._finish_phase_one)
    self.end_phase_button.disabled = true

    await self.shop_menu.stop()

    # If shop inventory is empty, warn the user
    if self.game_data.shop_inventory._item_count <= 0:
        self.empty_shop_dialog.popup_centered()

        # Wait for confirmation
        var do_continue = await self._empty_shop_confirm
        if not do_continue:
            # stay in phase one, redo setup
            self._start_phase_one()
            return

    self._start_phase_two()


func _start_phase_two():
    print("Starting phase two")

    self.phase_title.text = "Customers"
    self.phase_texture.texture = phase_2_sprite
    self.game_data.phase = GameData.GamePhase.two

    self.customer_queue.queue_emptied.connect(self._finish_phase_two)
    await self.customer_queue.start()

    self.end_phase_button.pressed.connect(self._finish_phase_two)
    self.end_phase_button.disabled = false


func _finish_phase_two():
    print("Finished phase two")

    self.end_phase_button.pressed.disconnect(self._finish_phase_two)
    self.end_phase_button.disabled = true

    self.customer_queue.queue_emptied.disconnect(self._finish_phase_two)
    await self.customer_queue.stop()

    self._start_phase_three()


func _start_phase_three():
    print("Starting phase three")

    self.phase_title.text = "Hire Adventurers"
    self.phase_texture.texture = phase_3_sprite
    self.game_data.phase = GameData.GamePhase.three

    self.expedition_hiring.customer_hired.connect(self._finish_phase_three)
    await self.expedition_hiring.start()

    self.end_phase_button.pressed.connect(self._finish_phase_three_on_button_press)
    self.end_phase_button.disabled = false


func _finish_phase_three_on_button_press():
    print("Phase three hiring skipped")
    self._finish_phase_three(null)


func _finish_phase_three(hired_customer: Customer):
    print("Finished phase three")

    self.end_phase_button.pressed.disconnect(self._finish_phase_three_on_button_press)
    self.end_phase_button.disabled = true

    self.expedition_hiring.customer_hired.disconnect(self._finish_phase_three)
    await self.expedition_hiring.stop()

    self._start_phase_four(hired_customer)


func _start_phase_four(hired_customer: Customer):
    print("Starting phase four")

    self.phase_title.text = "End Day Report"
    self.phase_texture.texture = phase_4_sprite
    self.game_data.phase = GameData.GamePhase.four

    var expedition_report: ExpeditionReport
    if hired_customer != null:
        var dungeon = Dungeon.create_random()
        print("Hire %s is performing expedition in %s" % [hired_customer.customer_name, dungeon.name])
        expedition_report = ExpeditionSimulator.run(dungeon, hired_customer, self.collection)
    else:
        expedition_report = ExpeditionReport.create_empty()

    # Display expedition result
    var expedition_result: ExpeditionResult = self.expedition_result_scene.instantiate()
    self.add_child(expedition_result)
    expedition_result.set_expedition_report(expedition_report)
    await expedition_result.finished
    self.remove_child(expedition_result)

    var loot = expedition_report.get_loot()
    if loot.GetUniqueItemCount() > 0:
        # Display loot scene
        var expedition_loot: ExpeditionLoot = self.expedition_loot_scene.instantiate()
        self.add_child(expedition_loot)
        expedition_loot.start(self.game_data, loot)
        await expedition_loot.finished
        self.remove_child(expedition_loot)

    self.end_phase_button.pressed.connect(self._finish_phase_four)
    self.end_phase_button.disabled = false


func _finish_phase_four():
    print("Finished phase four")

    self.end_phase_button.pressed.disconnect(self._finish_phase_four)
    self.end_phase_button.disabled = true

    # TODO

    self._start_phase_one()


func _update_gold_label(value: int):
    self.gold_label.text = "Gold: %d" % value


func _inventory_button_pressed():
    self._disable_controls()

    var inventory_ui: InventoryUI = inventory_ui_scene.instantiate()
    self.add_child(inventory_ui)
    inventory_ui.SetMode(InventoryUI.Mode.Manage)
    inventory_ui.SetTargetInventory(game_data.warehouse_inventory)
    await inventory_ui.closed
    self.remove_child(inventory_ui)

    self._enable_controls()


func _inventory_button_enter():
    info_tooltip_label.text = "Inventory"


func _inventory_button_exit():
    info_tooltip_label.text = ""


func _settings_button_pressed():
    self._disable_controls()

    var settingsMenu: SettingsMenu = settings_menu_scene.instantiate()
    self.add_child(settingsMenu)
    await settingsMenu.closed
    self.remove_child(settingsMenu)

    self._enable_controls()


func _settings_button_enter():
    info_tooltip_label.text = "Settings"


func _settings_button_exit():
    info_tooltip_label.text = ""


func _enable_controls():
    print("ENABLE CONTROLS")
    keyboard_input_disabled = false
    inventory_button.disabled = false
    settings_button.disabled = false
    end_phase_button.disabled = false
    if game_data.phase == GameData.GamePhase.one:
        self.shop_menu.mouse_filter = Control.MOUSE_FILTER_STOP


func _disable_controls():
    print("DISABLE CONTROLS")
    keyboard_input_disabled = true
    inventory_button.disabled = true
    settings_button.disabled = true
    end_phase_button.disabled = true
    self.shop_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _collectables_button_pressed() -> void:
    print("Opening collection")
    self._disable_controls()

    self.collection.visible = true
    await collection.closed
    self.collection.visible = false

    self._enable_controls()
    print("Closing collection")


func _collectables_button_enter() -> void:
    info_tooltip_label.text = "Collection"


func _collectables_button_exit() -> void:
    info_tooltip_label.text = ""


func _input(event):
    if event is InputEventKey and event.pressed:
        if keyboard_input_disabled:
            return

        if event.keycode == KEY_ESCAPE:
            get_viewport().set_input_as_handled()
            self._settings_button_pressed()
        elif event.keycode == KEY_I:
            get_viewport().set_input_as_handled()
            self._inventory_button_pressed()
        elif event.keycode == KEY_C:
            get_viewport().set_input_as_handled()
            self._collectables_button_pressed()

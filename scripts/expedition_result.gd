class_name ExpeditionResult
extends Control

signal finished

const log_item_scene = preload("res://scenes/expedition_result_log_item.tscn")

@onready var expedition_log: VBoxContainer = $NinePatchRect/MarginContainer/VBoxContainer/ScrollContainer/Log
@onready var customer_texture: TextureRect = $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/CustomerTexture
@onready var customer_name_label: Label = $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/CustomerNameLabel
@onready var success_fail_label: Label = $NinePatchRect/MarginContainer/VBoxContainer/SuccessFailLabel


func set_expedition_report(report: ExpeditionReport):
    # Populate success/fail label
    if report.result == ExpeditionReport.Result.success:
        self.success_fail_label.text = "Success"
        self.success_fail_label.add_theme_color_override("font_color", Color(0, 1, 0))
    elif report.result == ExpeditionReport.Result.failure:
        self.success_fail_label.text = "Failure"
        self.success_fail_label.add_theme_color_override("font_color", Color(1, 0, 0))
    else:
        self.success_fail_label.text = "No expedition to report"
        self.success_fail_label.add_theme_color_override("font_color", Color(1, 1, 1))
        return

    # Populate customer info
    self.customer_texture.texture = report.customer.texture
    self.customer_name_label.text = report.customer.customer_name

    # Populate detailed log
    for i in range(report.events.size()):
        var event: Dungeon.Event = report.events[i]
        var outcome: Dungeon.Outcome = report.outcomes[i]
        var log_item = self.log_item_scene.instantiate()
        self.expedition_log.add_child(log_item)
        log_item.set_result_data(event, outcome)


func _ready():
    if get_tree().current_scene == self:
        # Test data
        var report = ExpeditionReport.new()
        report.result = ExpeditionReport.Result.failure
        var events = RandomUtils.pick_random_count(DungeonEvents.events, 10)
        for event in events:
            var outcome = RandomUtils.pick_random([event.success, event.fail])
            report.log(event, outcome)

        report.customer = Customer.create_default_customers().front()

        self.set_expedition_report(report)



func _on_accept_button_pressed() -> void:
    self.finished.emit()

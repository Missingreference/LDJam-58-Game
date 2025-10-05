class_name ExpeditionResultLogItem
extends MarginContainer

@onready var _color_rect: ColorRect = $ColorRect
@onready var _event_desc_label: Label = $Container/EventDescLabel
@onready var _outcome_flavor_label: Label = $Container/OutcomeFlavorLabel
@onready var _item_label: Label = $Container/ItemLabel


func set_result_data(event: Dungeon.Event, outcome: Dungeon.Outcome):
    self._event_desc_label.text = event.description
    self._outcome_flavor_label.text = outcome.get_flavor()

    var item_log_text: Array[String] = []
    var gained_items = outcome.get_items_gained()
    if gained_items.size() != 0:
        item_log_text.append("Gained: %s" % ", ".join(gained_items.map(func(i): return i.name)))

    var lost_items = outcome.get_items_lost()
    if lost_items.size() != 0:
        item_log_text.append("Lost: %s" % ", ".join(lost_items.map(func(i): return i.name)))

    self._item_label.text = "%s" % ", ".join(item_log_text)

    if outcome.success:
        self._color_rect.modulate = Color(0, 0.8, 0, 0.8)
    else:
        self._color_rect.modulate = Color(0.8, 0, 0, 0.8)

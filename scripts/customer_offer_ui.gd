class_name CustomerOfferUI
extends Control

signal offer_result(OfferResult, final_price: int)

#@onready var _color_rect: ColorRect=  $ColorRect
@onready var _nine_patch_rect: NinePatchRect = $TileScaleContainer/NinePatchRect
@onready var _customer_name_label: Label =  $MarginContainer/VBoxContainer/CustomerNameLabel
@onready var _flavor_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/FlavorLabel
@onready var _offer_label: Label = $MarginContainer/VBoxContainer/OfferLabel
@onready var _item_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer3/ItemIcon
@onready var _item_name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer3/ItemName
@onready var _item_value_label: Label = $MarginContainer/VBoxContainer/HBoxContainer3/ValueLabel

var _offer: CustomerOffer

func set_customer_offer(offer: CustomerOffer):
    self._offer = offer
    self._customer_name_label.text = offer.customer.customer_name
    self._flavor_label.text = offer.flavor_text + offer.item_wanted.name + "."
    self._offer_label.text = "Offer: %dgp" % offer.gold_offered
    self._item_icon.texture = offer.item_wanted.GetSprite()
    self._item_name_label.text = offer.item_wanted.name
    self._item_value_label.text = "(value: %dgp)" % offer.item_wanted.GetValue()


func size() -> Vector2:
    return  self._nine_patch_rect.size


func _on_accept_button_pressed():
    self.offer_result.emit(OfferResult.accepted, self._offer.gold_offered)


func _on_decline_button_pressed():
    self.offer_result.emit(OfferResult.declined, self._offer.gold_offered)


func _on_haggle_button_pressed():
    # TODO
    pass


enum OfferResult {
    accepted,
    declined,
}

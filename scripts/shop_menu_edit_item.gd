class_name ShopMenuEditItem
extends HBoxContainer

signal quantity_changed(int)

@onready var _qty_label: Label = $QtyLabel
@onready var _name_label: Label = $NameLabel
@onready var _price_label: Label = $PriceLabel

@onready var plus_button: Button = $PlusButton
@onready var minus_button: Button = $MinusButton

var item_name: String
var price: int
var quantity: int = 1


func _ready():
    self.update_labels()


func update_labels():
    self._qty_label.text = "%d" % self.quantity
    self._name_label.text = self.item_name
    self._price_label.text = "%d" % self.price


func _on_minus_button_pressed():
    self.quantity -= 1
    self.quantity_changed.emit(-1)
    self._qty_label.text = "%d" % self.quantity


func _on_plus_button_pressed():
    self.quantity += 1
    self.quantity_changed.emit(1)
    self._qty_label.text = "%d" % self.quantity
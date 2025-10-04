class_name CustomerOffer
extends Node

var gold_offered: int 
var item_wanted: Item
var customer: Customer


func _init(_gold_offered: int, _item_wanted: Item, _customer: Customer):
    self.gold_offered = _gold_offered
    self.item_wanted = _item_wanted
    self.customer = _customer
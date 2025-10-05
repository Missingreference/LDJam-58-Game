class_name CustomerOffer
extends Node

var gold_offered: int 
var item_wanted: Item
var customer: Customer
var flavor_text: String


func _init(_gold_offered: int, _item_wanted: Item, _customer: Customer, _flavor_text: String):
	self.gold_offered = _gold_offered
	self.item_wanted = _item_wanted
	self.customer = _customer
	self.flavor_text = _flavor_text


static func create_random_offer(_customer: Customer, _item: Item) -> CustomerOffer:
	# TODO: constrain offer to amount of gold the customer has and the value of the item
	var gold = Globals.rng.randi_range(10, 100)
	var flavor = "%s %s" % [RandomUtils.pick_random(CustomerOffer.greetings), RandomUtils.pick_random(CustomerOffer.flavors)]

	return CustomerOffer.new(gold, _item, _customer, flavor)


const flavors: Array[String] = [
	"Let me take a look at your wares...",
	"I'd like to make a purchase.",
	"Where did you find this?",
	"I must have it!",
	"I'm sure this will come in handy",
	"What say you?",
]

const greetings: Array[String] = [
	"Good morrow.",
	"How fare thee?",
	"Well met!",
	"Hey, listen!",
	"You there!",
	"A fine day, huzzah!",
]

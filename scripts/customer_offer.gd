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
	"I'd like to purchase a ",
	"Could I trouble you for one ",
	"I seek to buy a ",
	"If you've got one in stock, I'd like to purchase a ",
	"I wish to acquire a ",
	"I wish to acquire one ",
	"I'll take one ",
	"I'm in need of a ",
	"I've coin for one ",
	"I'd like to buy one ",
	"I'd like to purchase one ",
	"I've gold for a "
]

const greetings: Array[String] = [
	"Good morrow.",
	"How fare thee?",
	"Well met!",
	"Hey, listen!",
	"You there!",
	"A fine day, huzzah!",
	"Hail, merchant!",
	"Ah, fortune smiles upon me!",
	"Salutations, shopkeeper.",
	"By the gods, your wares are splendid!",
	"Peace upon you, merchant.",
	"Well met, friend.",
	"Ah, I've heard fine things of your shop!"
	
	
	
]

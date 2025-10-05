class_name CustomerInfo
extends ColorRect

@onready var _name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var _str_label: Label = $MarginContainer/VBoxContainer/Attributes/StrLabel
@onready var _con_label: Label = $MarginContainer/VBoxContainer/Attributes/ConLabel
@onready var _dex_label: Label = $MarginContainer/VBoxContainer/Attributes/DexLabel
@onready var _int_label: Label = $MarginContainer/VBoxContainer/Attributes/IntLabel
@onready var _wis_label: Label = $MarginContainer/VBoxContainer/Attributes/WisLabel
@onready var _cha_label: Label = $MarginContainer/VBoxContainer/Attributes/ChaLabel
@onready var _traits: = $MarginContainer/VBoxContainer/Traits
@onready var _weapon_icon: TextureRect = $MarginContainer/VBoxContainer/GridContainer/WeaponSlot
@onready var _armor_icon: TextureRect = $MarginContainer/VBoxContainer/GridContainer/ArmorSlot
@onready var _item_1_icon: TextureRect = $MarginContainer/VBoxContainer/GridContainer/ItemSlot1
@onready var _item_2_icon: TextureRect = $MarginContainer/VBoxContainer/GridContainer/ItemSlot2
@onready var _gold_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label


func set_customer_info(customer: Customer):
    self._name_label.text = customer.customer_name
    self._str_label.text = "STR %d" % customer.base_attr.get_attr(Customer.Attr.str)
    self._con_label.text = "CON %d" % customer.base_attr.get_attr(Customer.Attr.con)
    self._dex_label.text = "DEX %d" % customer.base_attr.get_attr(Customer.Attr.dex)
    self._int_label.text = "INT %d" % customer.base_attr.get_attr(Customer.Attr.int)
    self._wis_label.text = "WIS %d" % customer.base_attr.get_attr(Customer.Attr.wis)
    self._cha_label.text = "CHA %d" % customer.base_attr.get_attr(Customer.Attr.cha)

    for child in self._traits.get_children():
        self._traits.remove_child(child)

    # TODO: customer traits

    var weapon = customer.get_weapon()
    if weapon != null:
        self._weapon_icon.texture = weapon.GetSprite()
        self._weapon_icon.tooltip_text = weapon.name
    else:
        self._weapon_icon.texture = NoiseTexture2D.new()

    var armor = customer.get_armor()
    if armor != null:
        self._armor_icon.texture = armor.GetSprite()
        self._armor_icon.tooltip_text = armor.name
    else:
        self._armor_icon.texture = NoiseTexture2D.new()

    var small_item_1 = customer.get_small_item_1()
    if small_item_1 != null:
        self._item_1_icon.texture = small_item_1.GetSprite()
        self._item_1_icon.tooltip_text = small_item_1.name
    else:
        self._item_1_icon.texture = NoiseTexture2D.new()

    var small_item_2 = customer.get_small_item_2()
    if small_item_2 != null:
        self._item_2_icon.texture = small_item_2.GetSprite()
        self._item_2_icon.tooltip_text = small_item_2.name
    else:
        self._item_2_icon.texture = NoiseTexture2D.new()

    self._gold_label.text = "%d" % customer.gold

class_name DungeonEvents
extends Node

# A list of hand-crafted events to pull from
static var events: Array[Dungeon.Event] = [
    Dungeon.Event.new(
        "It's a trap!",
        Customer.Attr.dex,
        10,
        Dungeon.Outcome.new().flavor("Disarmed!").resolve(1),
        Dungeon.Outcome.new().flavor("Ouchie!").resolve(-2),
    ),
    Dungeon.Event.new(
        "A lone globin",
        Customer.Attr.str,
        10,
        Dungeon.Outcome.new().flavor("Easily defeated").resolve(1),
        Dungeon.Outcome.new().flavor("It was just one goblin...").resolve(-2),
    ),
    Dungeon.Event.new(
        "A globin, and they brought friends",
        Customer.Attr.str,
        15,
        Dungeon.Outcome.new().flavor("That was NOT easy").resolve(2),
        Dungeon.Outcome.new().flavor("Overwelmed").resolve(-3),
    ),
    Dungeon.Event.new(
        "The door is jammed",
        Customer.Attr.str,
        10,
        Dungeon.Outcome.new().flavor("A swift kick and the door opened").resolve(1),
        Dungeon.Outcome.new().flavor("How embarassing").resolve(-2),
    ),
    Dungeon.Event.new(
        "A treasure chest!",
        Customer.Attr.wis,
        13,
        Dungeon.Outcome.new().flavor("Loot!").gain_item(Item.CreateRandom()).resolve(1),
        Dungeon.Outcome.new().flavor("Rats, it's a mimic").resolve(-2),
    ),
]

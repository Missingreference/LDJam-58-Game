class_name Dungeon
extends Node


var events: Array


static func create_random() -> Dungeon:
    var number_of_events = Globals.rng.randi_range(5, 10)
    var _events = RandomUtils.pick_random_count(DungeonEvents.events, number_of_events)

    return Dungeon.new(_events)


func _init(_events: Array):
    self.events = _events



class Event:
    var description: String
    var skill: Customer.Attr
    var skill_check: int
    var success: Outcome
    var fail: Outcome

    func _init(_description: String, _skill: Customer.Attr, _skill_check: int, _success: Outcome, _fail: Outcome):
        self.description = _description
        self.skill = _skill
        self.skill_check = _skill_check
        self.success = _success
        self.success.success = true
        self.fail = _fail
        self.fail.success = false

    func evaluate(customer: Customer) -> Outcome:
        # Saving roll
        var roll_value = Globals.rng.randi_range(1, 20)

        # Add innate skill and equipment modifiers
        roll_value += customer.get_skill(self.skill)

        if roll_value < skill_check:

            # Check if we can use an item to save
            var small_item_1 = customer.get_small_item_1()
            if small_item_1 != null:
                var item_value = small_item_1.attributes.get_attr(self.skill)
                if (roll_value + item_value) >= skill_check:
                    success.lose_item(small_item_1)
                    customer.set_small_item_1(null)
                    return success

            # Check if we can use an item to save
            var small_item_2 = customer.get_small_item_2()
            if small_item_2 != null:
                var item_value = small_item_2.attributes.get_attr(self.skill)
                if (roll_value + item_value) >= skill_check:
                    success.lose_item(small_item_2)
                    customer.set_small_item_2(null)
                    return success

            return fail

        return success



class Outcome:
    # Skill check pass
    var success: bool

    # How likely the customer is to continue
    var _resolve: int = 0

    # Flavor text
    var _flavor: String = ""

    # Items lost
    var _items_lost: Array[Item]= []

    # Items gained
    var _items_gained: Array[Item] = []


    func get_resolve() -> int:
        return self._resolve

    func get_flavor() -> String:
        return self._flavor


    func get_items_lost() -> Array[Item]:
        return self._items_lost


    func get_items_gained() -> Array[Item]:
        return self._items_gained


    func resolve(value: int) -> Outcome:
        self._resolve += value
        return self


    func flavor(value: String) -> Outcome:
        self._flavor = value
        return self


    func lose_item(item: Item) -> Outcome:
        self._items_lost.append(item)
        return self


    func gain_item(item: Item) -> Outcome:
        self._items_gained.append(item)
        return self


    func _to_string() -> String:
        var result = "%s" % _flavor
        result += " RESOLVE: %d" % self._resolve
        result += " ITEMS LOST: [%s]" % ", ".join(self._items_lost)
        result += " ITEMS GAINED: [%s]" % ", ".join(self._items_gained)

        return result

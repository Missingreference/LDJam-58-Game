class_name Inventory

signal changed
var max_item_count: int = -1

var _items: Dictionary # Dict[String, Array[Item]]
var _item_count = 0

func AddItem(item: Item) -> bool:
    if self.IsFull():
        print("Cannot add item. Inventory is full.")
        return false

    if _items.has(item.name):
        _items[item.name].append(item)
    else:
        _items[item.name] = [item]

    changed.emit()

    _item_count += 1

    return true


# Remove a single item matching the given item
func RemoveItem(item: Item) -> Item:
    var result = null

    if _items.has(item.name):
        result = _items[item.name].pop_back()

        if _items[item.name].size() == 0:
            _items.erase(item.name)

        _item_count -= 1

        changed.emit()

    return result


# Remove all items matching the given item
func RemoveAllItems(item: Item) -> Array[Item]:
    var result = null

    if _items.has(item.name):
        result = _items[item.name]

        _item_count -= _items[item.name].size()
        _items.erase(item.name)

        changed.emit()

    return result


func GetItems() -> Dictionary:
    return self._items


func HasItem(item: Item) -> bool:
    return self._items.has(item.name)


func IsFull() -> bool:
    return self.max_item_count >=0 and self._item_count >= self.max_item_count


func GetItemCount(item: Item) -> int:
    if self._items.has(item.name):
        return self._items[item.name].size()
    else:
        return 0


static func create_default_inventory() -> Inventory:
    var inventory = Inventory.new()

    inventory.AddItem(Item.Create("Sword"))
    inventory.AddItem(Item.Create("Sword"))
    inventory.AddItem(Item.Create("Bow"))
    inventory.AddItem(Item.Create("Bow"))
    inventory.AddItem(Item.Create("Bow"))

    var potions = []
    potions.resize(10)
    potions.fill(Item.Create("Potion"))
    for pot in potions:
        inventory.AddItem(pot)

    return inventory

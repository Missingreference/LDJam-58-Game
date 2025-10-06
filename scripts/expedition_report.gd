class_name ExpeditionReport
extends Node

var result: Result
var summary: String
var customer: Customer
var events: Array[Dungeon.Event] = []
var outcomes: Array[Dungeon.Outcome] = []


static func create_empty() -> ExpeditionReport:
    var report = ExpeditionReport.new()
    report.summary = "No expeditions happened today"
    report.result = Result.none
    return report


func log(event: Dungeon.Event, outcome: Dungeon.Outcome):
    self.events.append(event)
    self.outcomes.append(outcome)

func get_loot() -> Inventory:
    # Loop over outcomes to collect looted items
    var inventory = Inventory.new()
    # Artificially constrain loot to 18 slots (this is all InventoryUI can handle)
    inventory.max_item_count = 18
    for outcome in self.outcomes:
        for item in outcome.get_items_gained():
            inventory.AddItem(item)

    return inventory


enum Result {
    success,
    failure,
    none
}

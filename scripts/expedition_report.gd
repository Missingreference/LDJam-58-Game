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

enum Result {
    success,
    failure,
    none
}

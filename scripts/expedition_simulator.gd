class_name ExpeditionSimulator
extends Node


static func run(dungeon: Dungeon, customer: Customer) -> ExpeditionReport:
    print("Start expedition:")
    var report = ExpeditionReport.new()
    report.customer = customer

    var customer_resolve: int = 10

    for event in dungeon.events:
        # Evaluate the event
        var event_outcome = event.evaluate(customer)

        # For debug
        var success_string: String = ""
        if event_outcome.success:
            success_string = "SUCCESS"
        else:
            success_string = "FAILURE"


        print("    %s %s: %s" % [success_string, event.description, event_outcome])

        # Log the event and outcome
        report.log(event, event_outcome)

        # Update resolve
        customer_resolve += event_outcome.get_resolve()

        # Check if we need to end the expedition
        if customer_resolve <= 0:
            print("    %s has lost all resolve" % customer.customer_name)
            report.result = ExpeditionReport.Result.failure
            break

    # If the character made it to the end of the dungeon
    # Provide a bonus outcome
    if customer_resolve > 0:
        print("    Dungeon completed")

        report.result = ExpeditionReport.Result.success

        # Gain reward for completing dungeon
        var bonus_outcome = Dungeon.Outcome.new()
        bonus_outcome.gain_item(Item.CreateRandom())
        bonus_outcome.gain_item(Item.CreateRandom())
        bonus_outcome.gain_item(Item.CreateRandom())
        var complete_event = Dungeon.Event.new(
            "Dungeon complete",
            Customer.Attr.wis, 0,
            bonus_outcome,
            Dungeon.Outcome.new()
        )
        report.log(complete_event, bonus_outcome)

        # Chance to find a missing collectable
        var find_roll = Globals.rng.randi(1, 100)
        if find_roll >= 25:


        var collectable
        var collectable_found_outcome = Dungeon.Outcome.new()
        bonus_outcome.gain_collectble(collectable)
        var complete_event = Dungeon.Event.new(
            "Dungeon complete",
            Customer.Attr.wis, 0,
            bonus_outcome,
            Dungeon.Outcome.new()
        )
        report.log(complete_event, bonus_outcome)


        # TODO: consider modifying character stats (e.g. level up or gain traits)

    print("End expedition")
    return report

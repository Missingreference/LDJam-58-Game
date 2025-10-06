class_name ExpeditionSimulator
extends Node


static func run(dungeon: Dungeon, customer: Customer, collection: Collection) -> ExpeditionReport:
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

        # Chance to find a coveted collectable
        var find_collectable_roll = Globals.rng.randi_range(1, 100)
        var collectable = collection.get_remaining_collectable()
        if collectable != null and find_collectable_roll >= 85:
            collection.add_to_collection(collectable)
            var collectable_outcome = Dungeon.Outcome.new()
            collectable_outcome.flavor("Found the coveted %s" % collectable.collectable_name)

            var collectable_event = Dungeon.Event.new(
                "Collectable found!",
                Customer.Attr.wis, 0,
                collectable_outcome,
                Dungeon.Outcome.new()
            )
            report.log(collectable_event, collectable_outcome)

        # TODO: consider modifying character stats (e.g. level up or gain traits)

    print("End expedition")
    return report

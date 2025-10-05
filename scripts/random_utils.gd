class_name RandomUtils
extends Node


# Shuffle an array randomly
static func shuffle(array: Array):
    for i in range(array.size() - 1):
        var j = Globals.rng.randi_range(i, array.size() - 1)
        var temp = array[i]
        array[i] = array[j]
        array[j] = temp


# Pick a random element from an array
static func pick_random(array: Array):
    if array.size() == 0:
        return null
    var index = Globals.rng.randi_range(0, array.size() - 1)
    return array[index]


# Pick N random elements from an array
static func pick_random_count(array: Array, count: int):
    if array.size() == 0:
        return []

    var result = []
    var available_indexes = range(array.size())
    for i in range(0, count):

        # If there are no more valid available indexes, return early
        if available_indexes.size() == 0:
            return result

        var j = Globals.rng.randi_range(0, available_indexes.size() - 1)
        var array_index = available_indexes[j]
        result.append(array[array_index])
        available_indexes.remove_at(j)

    return result

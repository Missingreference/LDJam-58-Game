class_name Globals
extends Node

static var rng: RandomNumberGenerator = RandomNumberGenerator.new()

static func _static_init():
    print("RNG seed: %d" % rng.seed)

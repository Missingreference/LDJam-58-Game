class_name Globals
extends Node

static var rng: RandomNumberGenerator = RandomNumberGenerator.new()

static func _static_init():
    print("RNG seed: %d" % rng.seed)

# Speed used for customers moving into the scene
const customer_walk_tween_speed = 250  # pixels/s
const customer_walk_animate_speed = 2.0


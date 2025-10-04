class_name GameData

enum GamePhase {
    one,
    two,
    three,
    four
}

var inventory = {}
var coins = -1
var adventurers = []
var phase: GamePhase = GamePhase.one
var is_tutorial: bool = true
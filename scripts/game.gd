class_name Game
extends Node2D

@onready var finish_button: Button = $FinishButton
@onready var phase_label: Label = $PhaseLabel

var game_data = GameData.new()


func _ready():
    self._start_phase_one()


func _finish_phase_one():
    print("Finished phase one")

    self.finish_button.pressed.disconnect(self._finish_phase_one)
    self._start_phase_two()


func _start_phase_one():
    print("Starting phase one")

    self.phase_label.text = "Phase One"
    self.game_data.phase = GameData.GamePhase.one
    self.finish_button.pressed.connect(self._finish_phase_one)
    self.finish_button.visible = true


func _start_phase_two():
    print("Starting phase two")
    self.phase_label.text = "Phase Two"
    self.game_data.phase = GameData.GamePhase.two
    self.finish_button.pressed.connect(self._finish_phase_two)
    self.finish_button.visible = true


func _finish_phase_two():
    print("Finished phase two")

    self.finish_button.pressed.disconnect(self._finish_phase_two)
    self._start_phase_three()


func _start_phase_three():
    print("Starting phase three")

    self.phase_label.text = "Phase Three"
    self.game_data.phase = GameData.GamePhase.three
    self.finish_button.pressed.connect(self._finish_phase_three)
    self.finish_button.visible = true


func _finish_phase_three():
    print("Finished phase three")

    self.finish_button.pressed.disconnect(self._finish_phase_three)
    self._start_phase_four()



func _start_phase_four():
    print("Starting phase four")

    self.phase_label.text = "Phase Four"
    self.game_data.phase = GameData.GamePhase.four
    self.finish_button.pressed.connect(self._finish_phase_four)
    self.finish_button.visible = true


func _finish_phase_four():
    print("Finished phase four")

    self.finish_button.pressed.disconnect(self._finish_phase_four)
    self._start_phase_one()

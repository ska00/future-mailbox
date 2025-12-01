extends HSlider


@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var num_label: Label = $NumL
@onready var width := size.x

const display_offset_x := -2


func _ready():
	update_number_label()


func _on_value_changed(_value: float) -> void:
	audio_player.play()
	update_number_label()


func update_number_label():
	var new_pos_x = (size.x / tick_count) * value + display_offset_x
	
	num_label.position.x = new_pos_x
	num_label.text = str(int(value))

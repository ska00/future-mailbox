extends HSlider

@onready var width := size.x 
@onready var display_num: Label = $NumL
var display_offset_x := -2

func _ready():
	update_display_num()

func _on_value_changed(_value: float) -> void:
	update_display_num()

func update_display_num():
	var new_pos = (size.x / tick_count) * value + display_offset_x
	display_num.position.x = new_pos
	
	display_num.text = str(int(value))

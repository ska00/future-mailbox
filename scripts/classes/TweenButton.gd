extends Button
class_name TweenButton


@onready var tween: Tween 
const SCALE_OFFSET = 0.04


func _ready() -> void:
	# Scale from center
	pivot_offset = size * Vector2(0.5, 0.5)
	
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	connect("button_down", _on_button_down)
	connect("button_up", _on_button_up)


func _on_button_down():
	kill_tween()
	scale = Vector2.ONE - Vector2(SCALE_OFFSET, SCALE_OFFSET)


func _on_button_up() -> void:
	reset_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	
	
func _on_mouse_entered() -> void:
	reset_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.4)


func _on_mouse_exited() -> void:
	reset_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)


func reset_tween():
	kill_tween()
	tween = create_tween()


func kill_tween():
	if tween:
		tween.kill()

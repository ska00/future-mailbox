extends Node

const next_scene_file := "res://scenes/recieving_page.tscn"

@export_range(0, 12) var Months : int
@export_range(0, 10) var Years: int

@onready var notif_check: CheckBox = %NotifCheck
@onready var month_slider: HSlider = %MonthSlider
@onready var year_slider: HSlider = %YearSlider




func _ready():
	month_slider.value = Months
	year_slider.value = Years
	
	%SelectFileBtn.connect("copied_file", _on_copied_file)
	
	#SaveFile.load_file()
	if SaveFile.contents.sending:
		call_deferred("next_scene")


func next_scene():
	get_tree().change_scene_to_file(next_scene_file)


func _on_copied_file() -> void:
	SaveFile.load_file()
	SaveFile.contents["sending"] = true
	SaveFile.contents["send_date"] = Time.get_date_dict_from_system()
	SaveFile.contents["chosen_timespan"]["months"] = int(month_slider.value)
	SaveFile.contents["chosen_timespan"]["years"] = int(year_slider.value)
	
	if notif_check.pressed:
		WindowsScheduler.setup_daily_notifications()
	else:
		WindowsScheduler.create_userdata()
		
	SaveFile.contents["copied_files"] = true
	
	SaveFile.save_file()
		
	call_deferred("next_scene")


func _on_debug_btn_pressed() -> void:
	_on_copied_file()

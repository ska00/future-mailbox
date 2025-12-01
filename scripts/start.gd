extends Node

const next_scene_file := "res://scenes/safehold.tscn"

@export_group("DEBUG")
@export var debugging = false

@export_range(0, 12) var Months : int
@export_range(0, 10) var Years: int

@onready var month_slider: HSlider = %MonthSlider
@onready var year_slider: HSlider = %YearSlider

@onready var is_locked = SaveFile.contents.is_locked
@onready var open_date = SaveFile.contents.open_date


func _ready():
	WindowsScheduler.setup_daily_notifications()
	$FileBtn.connect("send", _on_file_btn_sent)
	
	if is_locked:
		call_deferred("next_scene")


func next_scene():
	#pass
	get_tree().change_scene_to_file(next_scene_file)


func _on_file_btn_sent() -> void:
	SaveFile.load_file()
	
	SaveFile.contents.time_gap.months = month_slider.value
	SaveFile.contents.time_gap.years = year_slider.value
	
	var date
	if debugging:
		date = Date.new({"day": 10, "month":10, "year":2024})
	else:
		date = Date.new()
	
	SaveFile.contents.locked_date = date.get_dict()
	
	date.add_months(month_slider.value)
	date.add_years(year_slider.value)
	
	print("The opening date is ", date)
	
	is_locked = true
	open_date = date.get_dict()
	
	SaveFile.contents.open_date = open_date
	SaveFile.contents.is_locked = is_locked
	
	SaveFile.save_file()
	
	if not SaveFile.contents.task_scheduler_is_installed:
		WindowsScheduler.setup_daily_notifications()
	
	call_deferred("next_scene")

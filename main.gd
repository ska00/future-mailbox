extends Node

@export_range(0, 12) var Months : int
@export_range(0, 10) var Years: int

@onready var month_slider: HSlider = $Selection/MonthSlider
@onready var year_slider: HSlider = $Selection/YearSlider

@onready var lock_state = SaveLoad.contents_to_save.lock_state
@onready var open_date = SaveLoad.contents_to_save.open_date

func _ready():
	if lock_state:
		get_tree().change_scene_to_file("res://locked.tscn")
	
	#var date = Date.new({"day": 10, "month":10, "year":2024})
	##var date = Date.new()
	#date.add_months(Months)
	#date.add_years(Years)
	#
	#lock_state = true
	#open_date = date.get_dict()
	#
	#SaveLoad.contents_to_save.open_date = open_date
	#SaveLoad.contents_to_save.lock_state = lock_state
	#
	#SaveLoad.save_file()

		
func _on_file_btn_sent() -> void:
	SaveLoad.contents_to_save.time_gap.months = month_slider.value
	SaveLoad.contents_to_save.time_gap.years = year_slider.value
	
	var date = Date.new()
	date.add_months(month_slider.value)
	date.add_years(year_slider.value)
	
	print(date)
	
	lock_state = true
	open_date = date.get_dict()
	
	SaveLoad.contents_to_save.open_date = open_date
	SaveLoad.contents_to_save.lock_state = lock_state
	
	SaveLoad.save_file()
	
	get_tree().change_scene_to_file("res://locked.tscn")

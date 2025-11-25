extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var title: RichTextLabel = $Title

var years_left:int
var months_left:int


func _ready() -> void:
	SaveLoad.load_file()
	var open_date = Date.new(SaveLoad.contents_to_save.open_date)
	#var current_date = Time.get_date_dict_from_system()
	
	if open_date.has_passed():
		unlock()
	
	
	var time_left = open_date.get_time_gap()
	months_left = time_left.months
	years_left = time_left.years 
			
	# Upgade the progress bar
	var time_gap = SaveLoad.contents_to_save.time_gap
	var value = years_left * 12 + months_left
	
	progress_bar.max_value = time_gap.years * 12 + time_gap.months
	progress_bar.value = progress_bar.max_value - value
	
	# Upgrade the text
	var text = "Recieving letter in "
	if years_left > 0:
		text = text + str(years_left) + " years"
	if months_left > 0:
		if years_left > 0:
			text = text + " and "
		text = text + str(months_left) + " months"
	
	title.text = text
	

func unlock():
	pass

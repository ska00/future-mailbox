extends Node

@export_range(0, 12) var Months : int
@export_range(0, 10) var Years: int

@onready var lock_state = SaveLoad.contents_to_save.lock_state
@onready var open_date = SaveLoad.contents_to_save.open_date

func _ready():
	if not lock_state:
		var date = Date.new({"day": 10, "month":10, "year":2024})
		#var date = Date.new()
		date.add_months(Months)
		date.add_years(Years)
		SaveLoad.contents_to_save.open_date = date.get_dict()
		SaveLoad.contents_to_save.lock_state = true
		SaveLoad.save_file()
	else:
		print("print state is locked now")
		print(SaveLoad.contents_to_save.open_date)
		
	
	#Here we would save the date to a file
	

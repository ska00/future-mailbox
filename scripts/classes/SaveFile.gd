extends Node

@onready var LOCATION = OS.get_user_data_dir() + "/userdata/save_file.json"

#const DEFAULT_CONTENTS: Dictionary = {
	#"is_locked": false,
	#"open_date": {"year":1, "month":1, "day":1},
	#"locked_date": {"year":1, "month":1, "day":1},
	#"time_gap": {"months": 0, "years": 0},
	#"path": "user://",
	#"task_scheduler_is_installed": false
#}

const DEFAULT_CONTENTS : Dictionary = {
	"sending" : false,
	"is_notifying": false,
	"letter_path" : "",
	"send_date" : {"year": 0, "month": 0, "day": 0},
	"recieve_date" : {"year": 0, "month": 0, "day": 0},
	"chosen_timespan" : {"months": 0, "years": 0},
	"timeto_delivery" : {"months": 0, "years": 0},
	"delivered": false }


var contents : Dictionary = {}


func _ready():
	if not FileAccess.file_exists(LOCATION) or Globals.EMPTYSAVE:
		initialize()
	else:
		load_file()
	
	# load_file()
	
	if Globals.DEBUGGING: print(SaveFile.contents)


func save_file():
	var file = FileAccess.open(LOCATION, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(contents))
		file.close()
	else:
		push_error("Failed to open file for writing.")


func load_file():
	var file = FileAccess.open(LOCATION, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()  # create an instance of JSON
		var parse_result = json.parse(json_text)  # call parse on the instance
		if parse_result == OK:
			contents = json.data
			# print("Loaded contents:", contents)
		else:
			push_error("Failed to parse JSON:", parse_result.error, parse_result.error_line, parse_result.error_column)
	else:
		push_error("Failed to open file for reading.")

	
	
func initialize():
	contents = DEFAULT_CONTENTS.duplicate(true)  # deep copy
	save_file()

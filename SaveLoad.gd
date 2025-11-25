extends Node

const save_location = "user://SaveFile.json"

var contents_to_save: Dictionary = {
	"lock_state":false,
	"open_date": {"year":1, "month":1, "day":1}
}

func _ready():
	load_file()

func save_file():
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	file.store_var(contents_to_save )
	file.close()

func load_file():
	if FileAccess.file_exists(save_location):
		var file = FileAccess.open(save_location, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		for keys in contents_to_save.keys():
			print(keys)
			contents_to_save[keys] = data[keys]
	

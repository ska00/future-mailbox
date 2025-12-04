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


func _on_copied_file(letter_path : String) -> void:
	SaveFile.load_file()
	SaveFile.contents["sending"] = true
	SaveFile.contents["letter_path"] = letter_path
	SaveFile.contents["send_date"] = Time.get_date_dict_from_system()
	SaveFile.contents["chosen_timespan"]["months"] = int(month_slider.value)
	SaveFile.contents["chosen_timespan"]["years"] = int(year_slider.value)
	
	if notif_check.pressed:
		WindowsScheduler.setup_daily_notifications()
	else:
		WindowsScheduler.create_userdata()
		
	SaveFile.contents["copied_files"] = true
	
	run_notifier()
		
	call_deferred("next_scene")


func run_notifier():

	var arg_path = ProjectSettings.globalize_path(SaveFile.LOCATION)
	var exe_filepath = OS.get_user_data_dir() + "/userdata/notifier.exe"
	var output = []
	
	if not FileAccess.file_exists(exe_filepath):
		push_error("Notifier executable not found at: " + exe_filepath)
		return

	var json = JSON.stringify(SaveFile.contents)
	var f := FileAccess.open(arg_path, FileAccess.WRITE)
	f.store_string(json)
	f.close()
	
	if Globals.DEBUGGING:
		print("File path:", arg_path)
		print("Argument: ", str(SaveFile.contents))
	
	var error = OS.execute(
		exe_filepath,
		["--notify_off", "--temp_filepath", arg_path],
		output,
		false,
		false)

	if error != OK:
		push_error("Failed to launch notifier.exe, error: " + str(error))

	if Globals.DEBUGGING: print("The output array is: ", output)
	if Globals.DEBUGGING: print("Python completed execution")
	
	if output:
		SaveFile.load_file()
	else:
		push_error("executable failed to provide output")

	
func _on_debug_btn_pressed() -> void:
	_on_copied_file("")

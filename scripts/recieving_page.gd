extends Control

@onready var reset_scene = "res://scenes/sending_page.tscn"

@onready var lock_state: Control = $LockState
@onready var unlock_state: Control = $UnlockState

@onready var progress_bar: ProgressBar = $LockState/ProgressBar
@onready var title: RichTextLabel = $LockState/Title

var years_left : int = 0
var months_left : int = 0
var days_left : int = 0


func connect_signals() -> void:
	$ResetBtn.connect("pressed", _on_reset_btn_pressed)
	%UnlockBtn.connect("pressed", _on_unlock_btn_pressed)


func _ready() -> void:
	
	connect_signals()
	run_notifier()
	
	var delivered = SaveFile.contents["delivered"]
	
	if delivered:
		unlock()
		return
	
	var chosen_timespan = SaveFile.contents["chosen_timespan"]
	var timeto_delivery = SaveFile.contents["timeto_delivery"]
			

	years_left = timeto_delivery["years"]
	months_left = timeto_delivery["months"]
	days_left = timeto_delivery["days"]
	
	# Upgade the progress bar
	var progress_value = years_left * 365 + months_left * 30 + days_left
	
	progress_bar.max_value = chosen_timespan.years * 365 + chosen_timespan.months * 30
	progress_bar.value = progress_bar.max_value - progress_value
	
	# Upgrade the title text
	var text = "Recieving letter in "
	if years_left > 0:
		text = text + "[color=#f2d697]" + str(years_left) + " years[/color]"
	if months_left > 0:
		if years_left > 0:
			text = text + " and "
		text = text + "[color=#f2d697]" + str(months_left) + " months[/color]"
	
	title.text = text
	

func unlock():
	lock_state.hide()
	unlock_state.show()


func prev_scene():
	get_tree().change_scene_to_file(reset_scene)


func run_notifier() -> bool:
	var exe_filepath = OS.get_user_data_dir() + "/userdata/notifier.exe"

	if not FileAccess.file_exists(exe_filepath):
		push_error("Notifier executable not found at: " + exe_filepath)
		return false
	else:
		var err = OS.execute(exe_filepath, ["--notify_off"])
		if err != OK:
			push_error("Failed to launch notifier.exe, error: " + str(err))
			return false
	return true


func _on_unlock_btn_pressed() -> void:
	# Find the file.
	SaveFile.load_file()
	var library_dir = SaveFile.contents.path
	library_dir = ProjectSettings.globalize_path(library_dir)
	var dir = FileAccess.open(library_dir, FileAccess.READ)
	
	if dir:
		$AudioBtn.play()
		OS.shell_open(library_dir)
	else:
		push_error("Couldn't open file")


func _on_reset_btn_pressed() -> void:
	SaveFile.initialize()
	WindowsScheduler.uninstall_windows_task()
	
	call_deferred("prev_scene")

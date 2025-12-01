extends Control

@onready var progress_bar: ProgressBar = $LockState/ProgressBar
@onready var title: RichTextLabel = $LockState/Title

@onready var lock_state: Control = $LockState
@onready var unlock_state: Control = $UnlockState

var years_left:int = 0
var months_left:int = 0


func _ready() -> void:
	SaveFile.load_file()
	var open_date = Date.new(SaveFile.contents.open_date)
	
	if open_date.has_passed():
		unlock()
		return
	
	
	var time_left = open_date.get_time_gap()
	months_left = time_left.months
	years_left = time_left.years 
			
	# Upgade the progress bar
	var time_gap = SaveFile.contents.time_gap
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
	lock_state.hide()
	unlock_state.show()


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

func prev_scene():
	get_tree().change_scene_to_file("res://scenes/start.tscn")

func _on_button_pressed() -> void:
	await SaveFile.reset()
	WindowsScheduler.uninstall_windows_task()
	prev_scene()
	#call_deferred("prev_scene")

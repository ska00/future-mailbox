extends Control

@onready var reset_scene = "res://scenes/sending_page.tscn"

@onready var lock_state: Control = $LockState
@onready var unlock_state: Control = $UnlockState

@onready var progress_bar: ProgressBar = $LockState/ProgressBar
@onready var title: RichTextLabel = $LockState/Title
@onready var audio_btn: AudioStreamPlayer = $AudioBtn

var years_left : int = 0
var months_left : int = 0
var days_left : int = 0


func connect_signals() -> void:
	$ResetBtn.connect("pressed", _on_reset_btn_pressed)
	%UnlockBtn.connect("pressed", _on_unlock_btn_pressed)


func _ready() -> void:
	
	connect_signals()

	var delivered = SaveFile.contents["delivered"]
	
	if delivered:
		unlock()
		return
	
	var timeto_delivery = SaveFile.contents["timeto_delivery"]
	var timeto_delivery_days = SaveFile.contents["timeto_delivery_days"]
	var init_timeto_delivery_days = SaveFile.contents["init_timeto_delivery_days"]
			
	years_left = int(timeto_delivery["years"])
	months_left = int(timeto_delivery["months"])
	days_left = int(timeto_delivery["days"])
	
	# Upgade the progress bar
	progress_bar.max_value = init_timeto_delivery_days
	progress_bar.value = progress_bar.max_value - timeto_delivery_days
	
	# Upgrade the title text
	var text = "Recieving letter in "
	if years_left > 0:
		if years_left == 1:
			text = text + "[color=#f2d697]" + str(years_left) + " year[/color]"
		else:
			text = text + "[color=#f2d697]" + str(years_left) + " years[/color]"
	if months_left > 0:
		if years_left > 0:
			if days_left > 0:
				text = text + ", "
			else:
				text = text + " and "
		if months_left == 1:
			text = text + "[color=#f2d697]" + str(months_left) + " month[/color]"
		else:
			text = text + "[color=#f2d697]" + str(months_left) + " months[/color]"
	if days_left > 0:
		if years_left > 0 or months_left > 0:
			text = text + " and "
		if days_left == 1:
			text = text + "[color=#f2d697]" + str(days_left) + " day[/color]"
		else:
			text = text + "[color=#f2d697]" + str(days_left) + " days[/color]"
	
	title.text = text
	

func unlock():
	lock_state.hide()
	unlock_state.show()


func prev_scene():
	get_tree().change_scene_to_file(reset_scene)
	

func _on_unlock_btn_pressed() -> void:
	# Find the file.
	var library_dir = SaveFile.contents["letter_path"]
	library_dir = ProjectSettings.globalize_path(library_dir)
	
	var dir = FileAccess.open(library_dir, FileAccess.READ)
	if dir:
		$AudioBtn.play()
		OS.shell_open(library_dir)
	else:
		push_error("Couldn't open file")


func _on_reset_btn_pressed() -> void:
	audio_btn.play()
	Globals.wipe_files()
	
	call_deferred("prev_scene")

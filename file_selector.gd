extends Button
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var lock_window: Window = $"../CanvasLayer/LockWindow"

@onready var file_dialog: FileDialog = %FileDialog
@onready var file_path_l: RichTextLabel = $FilePathL
@onready var lock_btn: Button = $LockBtn

var file_selected_path = null

func _ready():
	lock_btn.visible = false
	

func _on_file_dialog_file_selected(path: String):
	print("Selected file:", path)
	file_selected_path = path
	lock_btn.visible = true
	disabled = false
	file_path_l.text =  path
	text = "Change File..."
	
	

func copy_file_to_library(source_path: String):
	var library_dir = "user://library/"
	
	# Ensure folder exists
	var dir = DirAccess.open(library_dir)
	if not dir:
		var main_dir = DirAccess.open("user://")
		main_dir.make_dir_recursive(library_dir)  # returns DirAccess instance
	
	# Get the file name
	var file_name = source_path.get_file()
	var destination = library_dir + file_name
	
	# Copy the file
	if copy_file(source_path, destination):
		print("Copy Successful, wrote to:", ProjectSettings.globalize_path("user://library/"))
		lock_window.queue_free()
	else:
		print("Copy failed")

func copy_file(source_path: String, destination_path: String) -> bool:
	var src = FileAccess.open(source_path, FileAccess.READ)
	if not src:
		print("Failed to open source file")
		return false

	var dst = FileAccess.open(destination_path, FileAccess.WRITE)
	if not dst:
		print("Failed to open destination file")
		return false

	# Copy contents
	dst.store_buffer(src.get_buffer(src.get_length()))
	
	src.close()
	dst.close()
	
	return true


func _on_pressed() -> void:
	file_dialog.popup_centered()
	disabled = true
	lock_btn.visible = false
	audio_player.play()

func _on_file_dialog_canceled() -> void:
	disabled = false
	if file_path_l.text:
		file_path_l.clear()
	file_selected_path = null
	lock_btn.visible = false


func _on_lock_btn_pressed() -> void:
	if file_selected_path:
		lock_window.popup_centered()
		copy_file_to_library(file_selected_path)
	
	# Transition to lock state

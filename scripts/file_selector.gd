extends TweenButton

@onready var audio_player: AudioStreamPlayer = %AudioPlayer

@onready var file_dialog: FileDialog = %FileDialog
@onready var file_path_label: RichTextLabel = %FilePathL
@onready var send_btn: Button = %SendBtn

var file_selected_path = null

signal send


func _ready():
	super._ready()
	send_btn.hide()
	# Connect signal
	send_btn.connect("pressed", _on_send_btn_pressed)
	
	
func _on_pressed() -> void:
	disabled = true
	
	audio_player.play()
	file_dialog.popup_centered()
	send_btn.hide()
	

func _on_file_dialog_file_selected(path: String):
	disabled = false
	text = "Change File..."
	
	file_selected_path = path
	file_path_label.text =  path
	
	send_btn.show()


func _on_file_dialog_canceled() -> void:
	disabled = false
	if file_path_label.text:
		file_path_label.clear()
	file_selected_path = null
	
	send_btn.hide()


func _on_send_btn_pressed() -> void:
	if file_selected_path:
		#lock_window.popup_centered()
		
		audio_player.play()
		copy_file_to_library(file_selected_path)
		
	else:
		push_error("no file selected to send")


func copy_file_to_library(source_path: String):
	var library_dir = "user://library/"
	
	# Ensure folder exists
	var dir = DirAccess.open(library_dir)
	if not dir:
		var main_dir = DirAccess.open("user://")
		main_dir.make_dir_recursive(library_dir)  
		
	# Get the file name
	var file_name = source_path.get_file()
	var destination = library_dir + file_name
	
	SaveFile.contents.path = destination
	SaveFile.save_file()
	
	# Copy the file
	if copy_file(source_path, destination):
		print("Copy Successful, wrote to:", ProjectSettings.globalize_path(destination))
		
		# get_tree().change_scene_to_file("res://scenes/safehold.tscn")
		send.emit()
		# lock_window.queue_free()
	else:
		print("Copy failed")
		#


func copy_file(source_path: String, destination_path: String) -> bool:
	# src_path is a full OS path, e.g. "C:/Users/me/Desktop/a.png"
	var data := FileAccess.get_file_as_bytes(source_path)
	if data.is_empty():
		print("Failed to read external file:", source_path)
		return false

	var file := FileAccess.open(destination_path, FileAccess.WRITE)
	if file == null:
		print("Failed to write to:", destination_path)
		return false

	file.store_buffer(data)
	file.close()
	print("Copied to:", destination_path)
	return true

	#var src = FileAccess.open(source_path, FileAccess.READ, 	)
	#if not src:
		#print("Failed to open source file")
		#return false
	#
	#var data = src.get_buffer(src.get_length())
	#src.close()
#
	#var dst = FileAccess.open(destination_path, FileAccess.WRITE)
	#if not dst:
		#print("Failed to open destination file")
		#return false
#
	## Copy contents
	#if dst.store_buffer(data):
		#print("successful store buffer")
	#
	#dst.close()
	#
	#return true

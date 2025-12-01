extends Node


const USER_PATH = "user://"
const TASK_NAME = "LetterOpenerDailyNotifcation"

func setup_daily_notifications():
	install_python_folder()
	if OS.get_name() == "Windows":
		install_windows_task()


# ------------------------------------------------------
# COPY BUNDLED PYTHON
# ------------------------------------------------------
func install_python_folder():
	var src_dir = "res://python/"                      # Bundled Python folder
	var dst_dir = OS.get_user_data_dir() + "/python/"  # Writable copy location

	#var dir = DirAccess.open(library_dir)
	#if not dir:
		#var main_dir = DirAccess.open("user://")
		#main_dir.make_dir_recursive(library_dir)  
		
	# Ensure destination folder exists
	var dir_access = DirAccess.open(dst_dir)
	if not dir_access:
		var parent_dir = DirAccess.open(OS.get_user_data_dir())
		parent_dir.make_dir_recursive(dst_dir)

	# Copy files recursively
	copy_folder_recursive(src_dir, dst_dir)
	print("Python copied to: ", dst_dir)


func copy_folder_recursive(src, dst):
	var src_dir = DirAccess.open(src)
	if not src_dir:
		print("Source folder not found: ", src)
		return

	src_dir.list_dir_begin()
	var file_name = src_dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var src_path = src + file_name
			var dst_path = dst + file_name
			if src_dir.current_is_dir():
				var parent_dst_dir = DirAccess.open(dst)
				parent_dst_dir.make_dir_recursive(dst_path)
				copy_folder_recursive(src_path + "/", dst_path + "/")
			else:
				var f_src = FileAccess.open(src_path, FileAccess.READ)
				if f_src:
					var data = f_src.get_buffer(f_src.get_length())
					f_src.close()
					var f_dst = FileAccess.open(dst_path, FileAccess.WRITE)
					if f_dst:
						f_dst.store_buffer(data)
						f_dst.close()
		file_name = src_dir.get_next()
	src_dir.list_dir_end()

#func install_python_script():
	#var src = "res://python/notify_check.py"
	#var dst = OS.get_user_data_dir() + "/notify_check.py"
#
	#var src_data = FileAccess.get_file_as_bytes(src)
	#var dst_file = FileAccess.open(dst, FileAccess.WRITE)
	#
	#dst_file.store_buffer(src_data)
	#dst_file.close()


func install_windows_task():
	# Paths
	var exe_path = OS.get_user_data_dir() + "/python/notify_check/notify_check.exe"
	var save_path = ProjectSettings.globalize_path(SaveFile.save_location)
	var dir_path = OS.get_user_data_dir() + "/python/notify_check"
	# Absolute path to Godot save file
	# var save_file = ProjectSettings.globalize_path("user://save_file.json")

	# Load template XML
	var template_path = "res://scheduler/windows_task.xml"
	var file = FileAccess.open(template_path, FileAccess.READ)
	var xml = file.get_as_text()
	file.close()
	
	
	exe_path = exe_path.replace("/", "\\")
	#save_path = save_path.replace("/", "\\")
	dir_path = dir_path.replace("/", "\\")

	# Replace placeholders
	# Add the save file path as a quoted argument for Python
	xml = xml.replace("__EXE_PATH__", '"' + exe_path + '"')
	xml = xml.replace("__ARG_PATH__", '"' + save_path + '"')
	xml = xml.replace("__DIRECTORY_PATH__", dir_path)

	# Save final XML in a writable location (Temp or AppData)
	var final_xml_path = OS.get_user_data_dir() + "/windows_notify_task.xml"
	var out = FileAccess.open(final_xml_path, FileAccess.WRITE)
	out.store_string(xml)
	out.close()

	# Install the task
	var args = [
		"/Create",
		"/TN", "LetterOpenerDailyNotifcation",
		"/XML", final_xml_path
	]
	
	var result = OS.execute("schtasks", args, [], true)
	print("Task Scheduler result: ", result)

func uninstall_windows_task():

	# Delete the task silently
	var args = ["/Delete", "/TN", TASK_NAME, "/F"]  # /F = force delete without prompt
	var result = OS.execute("schtasks", args, [], true)
	print("Task uninstalled:", result)

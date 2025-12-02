extends Node

const DEBUG_MODE = true
const USER_DIR_NAME = "userdata"
const TASK_NAME = "FutureMailbox"

@onready var USER_PATH = OS.get_user_data_dir() + USER_DIR_NAME


func setup_daily_notifications():
	create_userdata()
	if OS.get_name() == "Windows":
		install_windows_task()


func create_userdata():
	var src_dir = "res://" + USER_DIR_NAME + "/" 
	var dst_dir = OS.get_user_data_dir() + "/" + USER_DIR_NAME + "/"
		
	# Ensure destination folder exists
	var dst_dir_access = DirAccess.open(dst_dir)
	if not dst_dir_access:
		var parent_dir = DirAccess.open(OS.get_user_data_dir())
		parent_dir.make_dir_recursive(dst_dir)

	# Copy files recursively
	copy_folder_recursive(src_dir, dst_dir)


func install_windows_task():
	var exe_path = USER_PATH + "/notifier/notifier.exe"
	var save_path = ProjectSettings.globalize_path(SaveFile.LOCATION)
	var dir_path = USER_PATH + "/notifier"

	# Load template XML
	var xml_path = "res://scheduler/windows_task.xml"
	var xml_file = FileAccess.open(xml_path, FileAccess.READ)
	var xml = xml_file.get_as_text()
	xml_file.close()
	
	# Task Scheduler only understands backslashes
	exe_path = exe_path.replace("/", "\\")
	dir_path = dir_path.replace("/", "\\")

	xml = xml.replace("__COMMAND_PATH__", '"' + exe_path + '"')
	xml = xml.replace("__ARG_PATH__", '"' + save_path + '"')
	xml = xml.replace("__DIRECTORY_PATH__", dir_path)


	var user_xml_path = USER_PATH + "/windows_notify_task.xml"
	var out = FileAccess.open(user_xml_path, FileAccess.WRITE)
	out.store_string(xml)
	out.close()

	# Install the task
	var args = [
		"/Create",
		"/TN", TASK_NAME,
		"/XML", user_xml_path
	]
	var result = OS.execute("schtasks", args, [], true)
	
	if DEBUG_MODE: print("Task Scheduler result: ", result)


func uninstall_windows_task():
	# Delete the task silently
	var args = ["/Delete", "/TN", TASK_NAME, "/F"]  # /F = force delete without prompt
	var result = OS.execute("schtasks", args, [], true)
	if DEBUG_MODE: print("Task uninstalled:", result)


func copy_folder_recursive(src, dst):
	var src_dir = DirAccess.open(src)
	if not src_dir:
		if DEBUG_MODE: print("Source folder not found: ", src)
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

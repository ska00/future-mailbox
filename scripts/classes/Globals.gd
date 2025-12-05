extends Node

const DEBUGGING = true
const EMPTYSAVE = false

func wipe_files():
	SaveFile.initialize()
	WindowsScheduler.uninstall_windows_task()
	
	var dir = DirAccess.open("user://userdata")
	if dir:
		DirAccess.remove_absolute("user://userdata/last_notify.txt")
		DirAccess.remove_absolute("user://userdata/notif_log.txt")
	
	var lib_dir = DirAccess.open("user://library")
	if lib_dir:
		for file in lib_dir.get_files():
			lib_dir.remove(file)

class_name Date

enum {
	JAN = 1, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC, INVALID = -1 }

const DAYS = {JAN: 31, FEB: 28, MAR:31, APR:30, MAY:31, JUN:30, 
					JUL:31, AUG:31, SEP:30, OCT:31, NOV:30, DEC:31 }

var day : int = 1:
	set(value):
		if day < 1 or day > DAYS[month]:
			push_error("Invalid day value (%s)" % day)
		day = value
	get:
		return day
		
var month : int = 1:
	set(value):
		if month < 1 or month > 12:
			push_error("Invalid month value (%s)" % month)
		month = value
	get:
		return month
		
var year : int :
	set(value):
		if year < 0:
			push_error("Invalid year value (%s)", year)
		year = value
	get:
		return year


func _init(datetime : Dictionary = Time.get_date_dict_from_system()): #(YYYY-MM-DD)
	day = datetime.day
	month = datetime.month
	year = datetime.year


func _to_string() -> String:
	var string = str(year) + "-"
	if month < 10:
		string = string + "0" + str(month) + "-"
	else:
		string = string + str(month) + "-"
	if day < 10:
		string = string + "0" + str(day)
	else:
		string = string + str(day)
	return string
	
func get_time_gap(other:Dictionary = Time.get_date_dict_from_system()):
	var time_gap = {"years": 0, "months":0}
	
	var years_passed = year - other.year
	var months_passed = month - other.month
	
	if months_passed < 0:
		months_passed = (months_passed) + 12
		years_passed = years_passed - 1
	
	time_gap.years = years_passed
	time_gap.months = months_passed
	
	return time_gap

func get_dict() -> Dictionary:
	return {"day": day, "month": month, "year":year}

func has_passed():
	var other = Time.get_date_dict_from_system()
	if year > other.year:
		return false
	if month > other.month:
		return false
	if day > other.day:
		return false
	return true

func add_months(delta):
	delta = int(delta)
	if delta < 0:
		push_error("Trying to subtract months")
	var new_month = month + delta
	
	if new_month > 12:
		year = year + 1
		month = new_month % 12
	else:
		month = new_month

func add_years(delta):
	if delta < 0:
		push_error("Trying to subtract years")
	year = year + delta
	
func change_to_prev_month():
	var selected_month = month
	selected_month -= 1
	if(selected_month < 1):
		month = 12
		year = year - 1
	else:
		month = selected_month

func change_to_next_month():
	var selected_month = month
	selected_month += 1
	if(selected_month > 12):
		month = 1
		year = year + 1
	else:
		month = selected_month

func change_to_prev_year():
	year = year - 1

func change_to_next_year():
	year = year + 1

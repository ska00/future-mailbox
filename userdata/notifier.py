# Packages
import argparse
import datetime
import json
import os
import sys
import traceback
from dateutil.relativedelta import relativedelta
from winotify import Notification
import re
import ast

def string_to_dict(s):
    # 1. Quote all keys
    s = re.sub(r'([{,]\s*)([A-Za-z_]\w*)\s*:', r'\1"\2":', s)
    
    # 2. Replace JSON booleans with Python booleans
    s = s.replace('true', 'True').replace('false', 'False')
    
    # 3. Replace empty values with empty string
    s = re.sub(r'":(?=[,}])', '":""', s)
    
    # 4. Convert to dictionary
    return ast.literal_eval(s)

def create_files():
    if not os.path.exists(LAST_NOTIFY):
        with open(LAST_NOTIFY, "w") as f:
            pass
    if not os.path.exists(LOG_FILE):
        with open(LOG_FILE, "w") as f:
            pass



SAVE_FILE = os.path.abspath("save_file.json")
LAST_NOTIFY = os.path.abspath("last_notify.txt")
LOG_FILE = os.path.abspath("notif_log.txt")


APP_ID = "Future Mailbox"
TITLE = "Your Daily Godot Reminder"
MESSAGE = "Unread Mail"

create_files()

parser = argparse.ArgumentParser(
    prog='Datetime interpretor',
    description='Updates time left in the save file and runs daily to check if date has passed')


parser.add_argument('-n', '--notify_off', action='store_false')
parser.add_argument("-c", "--contents")




try:
    args = parser.parse_args()
    # godot_contents = string_to_dict(args.contents)
    SAVE_FILE = args.contents
    godot_contents = None
    is_notifying = args.notify_off

    # SAVE_FILE = godot_contents

except Exception as e:
    log(f"Error reading arguments: {e}")


def main():
    log("Script started")
    update_savefile()

    today = datetime.date.today().isoformat()

    if not is_notifying:
        log("Script finished. No notification triggered")
        return

    if os.path.exists(LAST_NOTIFY):
        try:
            with open(LAST_NOTIFY, "r") as f:
                if f.read().strip() == today:
                    log("Notification already sent today, exiting")
                    return
        except Exception as e:
            log(f"Error reading last_notify.txt: {e}")

    if load_condition(always_true=True):  # True for testing
        send_notification(TITLE, MESSAGE)
        try:
            with open(LAST_NOTIFY, "w") as f:
                f.write(today)
            log("Updated last_notify.txt")
        except Exception as e:
            log(f"Error writing last_notify.txt: {e}")

    log("Script finished")



def log(msg):
    try:
        timestamp = datetime.datetime.now().isoformat()
        with open(LOG_FILE, "a") as f:
            f.write(f"{timestamp}: {msg}\n")
    except:
        pass


def load_condition(always_true = False):
    global godot_contents

    if always_true:
        log("Condition override: always true for testing")
        return True
    
    if godot_contents:
        return godot_contents["delivered"] 

    try:
        with open(SAVE_FILE, "r") as f:
            contents = json.load(f)

        return contents.delivered

    except Exception as e:
        log(f"Error updating savefile: {e}")
        log(traceback.format_exc())

        return False

  
def send_notification(title, message):
    
    toast = Notification(
        app_id = APP_ID,
        title = TITLE,
        msg = MESSAGE,
        # icon = r"C:\path\to\your\icon.ico", 
        # duration = "long"
    )
    toast.show()


def update_savefile():
    global godot_contents
    try:
        if godot_contents:
            contents = godot_contents
        else:
            with open(SAVE_FILE, "r") as f:
                contents = json.load(f)

        send_date = contents.get("send_date")
        timespan = contents.get("chosen_timespan")
        today = datetime.datetime.now()

        send_datetime = datetime.datetime(
                        send_date["year"], send_date["month"], send_date["day"])
        recieve_datetime = send_datetime + relativedelta(
                        years=timespan["years"], months=timespan["months"], days=timespan["days"])

        recieve_date = {
        "year" : recieve_datetime.year, 
        "month": recieve_datetime.month,
        "day": recieve_datetime.day }

        delivered = today > recieve_datetime
        timeto_delivery = relativedelta(recieve_datetime, today)

        contents["delivered"] = delivered
        contents["recieve_date"] = recieve_date

        if delivered:
            contents["timeto_delivery"] = {"years":0, "months":0, "days":0 } 
        else:
            contents["timeto_delivery"] = {"years":timeto_delivery.years, "months":timeto_delivery.months, "days":timeto_delivery.days} 

        if not is_notifying:
            with open(SAVE_FILE, "w") as f:
                json.dump(contents, f)
            print("success")
            godot_contents = contents
        else:
            with open(SAVE_FILE, "w") as f:
                json.dump(contents, f)

        log(f"Savefile updated successfully {today.isoformat()}")


    except Exception as e:
        log(f"Error updating savefile: {e}")
        log(traceback.format_exc())


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        log(f"Unexpected error: {e}")
        log(traceback.format_exc())
    finally:
        sys.exit(0)
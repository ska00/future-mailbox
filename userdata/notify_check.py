# Packages
import argparse
import datetime
import json
import os
import sys
import traceback
from dateutil.relativedelta import relativedelta
from winotify import Notification


SAVE_FILE = os.path.abspath("save_file.json")
LAST_NOTIFY = os.path.abspath("last_notify.txt")
LOG_FILE = os.path.abspath("notif_log.txt")


APP_ID = "Future Mailbox"
TITLE = "Your Daily Godot Reminder"
MESSAGE = "Unread Mail"


parser = argparse.ArgumentParser(
    prog='Datetime interpretor',
    description='Updates time left in the save file and runs daily to check if date has passed')


parser.add_argument('-n', '--notify_off', action='store_false')
is_notifying = parser.parse_args().notify_off


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
    
    if always_true:
        log("Condition override: always true for testing")
        return True
    
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
    try:
        with open(SAVE_FILE, "r") as f:
            contents = json.load(f)

        send_date = contents.get("send_date")

        send_datetime = datetime.datetime(
            send_date["year"], send_date["month"], send_date["day"]
        )

        timespan = contents.get("chosen_timespan")

        recieve_datetime = send_datetime + relativedelta(
            months=timespan["months"], years=timespan["years"])

        recieve_date = {
        "year" : recieve_datetime.year, 
        "month": recieve_datetime.month,
        "day": recieve_datetime.day}

        today = datetime.datetime.now() 
        delivered = today > recieve_datetime

        timeto_delivery = relativedelta(recieve_datetime, today)

        contents["delivered"] = delivered
        contents["recieve_date"] = recieve_date
        contents["timeto_delivery"] = {"months":0, "years":0} if delivered else {
            "months":timeto_delivery.months, "years": timeto_delivery.years}

        log(f"Savefile updated successfully {today.isoformat()}")

        with open(SAVE_FILE, "w") as f:
            json.dump(contents, f)
        

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
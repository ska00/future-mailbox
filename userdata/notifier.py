# Packages
import argparse
import datetime
import json
import os
import sys
import traceback
from dateutil.relativedelta import relativedelta
from winotify import Notification

APP_ID = "Future Mailbox"
TITLE = "Unread Mail"
MESSAGE = "Your letter has been delivered! You should check out your mailbox soon"


def log(msg):
    try:
        timestamp = datetime.datetime.now().isoformat()
        with open(LOG_FILE, "a") as f:
            f.write(f"{timestamp}: {msg}\n")
    except:
        pass


#------------ GLOBALS ------------#
IS_NOTIFYING = None
SAVE_FILE = os.path.abspath("save_file.json")   # Default



parser = argparse.ArgumentParser()

parser.add_argument('-n', '--notify_off', action='store_false')
parser.add_argument("-t", "--temp_filepath")


try:
    args = parser.parse_args()
    SAVE_FILE = args.temp_filepath
    IS_NOTIFYING = args.notify_off
except Exception as e:
    log(f"Error reading arguments: {e}")


SAVE_FILE = os.path.abspath(SAVE_FILE)
BASE_DIR = os.path.dirname(SAVE_FILE)
LAST_NOTIFY = os.path.join(BASE_DIR, "last_notify.txt")
LOG_FILE = os.path.join(BASE_DIR, "notif_log.txt")
ICON_FILE = os.path.join(BASE_DIR, "icon.ico")

def main():
    log("Script started")

    create_files()
    update_savefile()

    today = datetime.date.today().isoformat()

    if not IS_NOTIFYING:
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


def create_files():
    if not os.path.exists(LAST_NOTIFY):
        with open(LAST_NOTIFY, "w") as f:
            pass
    if not os.path.exists(LOG_FILE):
        with open(LOG_FILE, "w") as f:
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
        icon = ICON_FILE, 
        # duration = "long"
    )
    toast.show()


def update_savefile():

    try:
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
            contents["timeto_delivery_days"] = (recieve_date - today).days

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
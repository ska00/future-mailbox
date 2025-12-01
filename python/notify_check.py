# Packages
# import ctypes
import datetime
import json
import os
import sys
import traceback
from dateutil.relativedelta import relativedelta
# from threading import Thread


if len(sys.argv) < 2:
    sys.exit(1)

SAVE_FILE = sys.argv[1]

# Use absolute paths to avoid working directory issues
SAVE_FILE = os.path.abspath(SAVE_FILE)
BASE_DIR = os.path.dirname(SAVE_FILE)
LAST_NOTIFY_PATH = os.path.join(BASE_DIR, "last_notify.txt")
LOG_FILE = os.path.join(BASE_DIR, "notif_log.txt")

TITLE = "Your Daily Godot Reminder"
MESSAGE = "Your condition has been met."


# ------------------------------------------------------
# LOGGING
# ------------------------------------------------------
def log(msg):
    try:
        timestamp = datetime.datetime.now().isoformat()
        with open(LOG_FILE, "a") as f:
            f.write(f"{timestamp}: {msg}\n")
    except:
        pass


# ------------------------------------------------------
# DETECT INTERACTIVE SESSION
# ------------------------------------------------------
# def is_interactive_session():
#     try:
#         user32 = ctypes.windll.user32
#         fg = user32.GetForegroundWindow()
#         return fg != 0
#     except:
#         return False


# ------------------------------------------------------
# CONDITION LOGIC
# ------------------------------------------------------
def load_condition(always_true=False):
    if always_true:
        log("Condition override: always true for testing")
        return True

    if not os.path.exists(SAVE_FILE):
        log("Save file not found")
        return False

    try:
        with open(SAVE_FILE, "r") as f:
            data = json.load(f)

        locked_date = data.get("locked_date")
        if not locked_date:
            log("locked_date missing in save file")
            return False

        locked_datetime = datetime.datetime(
            locked_date["year"], locked_date["month"], locked_date["day"]
        )

        time_gap = data.get("time_gap")
        time_gap["months"] = int(time_gap["months"])
        time_gap["years"] = int(time_gap["years"])

        open_datetime = locked_datetime + relativedelta(
            months=time_gap["months"], years=time_gap["years"])

        log(f"Condition evaluated: {ready}")
        return ready

    except Exception as e:
        log(f"Error evaluating condition: {e}")
        log(traceback.format_exc())
        return False


# ------------------------------------------------------
# NOTIFICATION
# ------------------------------------------------------
def send_notification(title, message):
    # if not is_interactive_session():
    #     log("Non-interactive session, skipping notification")
    #     return

    try:
        
        from plyer import notification

        notification.notify(title=title, message=message, timeout=5)
        log("Notification sent successfully")
    except Exception as e:
        log(f"Notification error: {e}")

        # t = Thread(target=notify)
        # t.start()
        # t.join(timeout=10)

    except Exception as e:
        log(f"Failed to import notification: {e}")


# ------------------------------------------------------
# MAIN
# ------------------------------------------------------
def main():
    log("Script started")

    today = datetime.date.today().isoformat()

    if os.path.exists(LAST_NOTIFY_PATH):
        try:
            with open(LAST_NOTIFY_PATH, "r") as f:
                if f.read().strip() == today:
                    log("Notification already sent today, exiting")
                    return
        except Exception as e:
            log(f"Error reading last_notify.txt: {e}")

    if load_condition(always_true=True):  # True for testing
        send_notification(TITLE, MESSAGE)
        try:
            with open(LAST_NOTIFY_PATH, "w") as f:
                f.write(today)
            log("Updated last_notify.txt")
        except Exception as e:
            log(f"Error writing last_notify.txt: {e}")

    log("Script finished")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        log(f"Unexpected error: {e}")
        log(traceback.format_exc())
    finally:
        sys.exit(0)
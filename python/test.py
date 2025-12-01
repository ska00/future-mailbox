from winotify import Notification

toast = Notification(
    app_id="LetterOpener",
    title="Daily Reminder",
    msg="Your task has run!",
    #icon="icon.ico"
)

toast.show()
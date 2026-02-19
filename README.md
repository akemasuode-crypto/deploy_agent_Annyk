deploy_agent_annyk
PROJECT OVERVIEW

The Bash script is an automatic configuration of an Attendance Tracker project that automatically creates all necessary folders and files. It also supports Python3, accepts updates on thresholds and is able to save progress safely even when the script is interrupted.

 Requirements

Linux / Ubuntu terminal

Bash shell

Internet connection (only when Python3 is to be installed)

 How to Run

Make the script executable:

chmod +x creator.sh

Run the script:

./creator.sh

Follow the prompts to:

Enter a project folder name

Adjust attendance limits (optional)

 Project Structure
attendance_tracker_<name>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
 Archive Feature

To activate automatic archiving, press CTRL + C whilst the script is running.
The project will be shortened into:

attendance_tracker_<name>_archive.tar.gz
 Run the Attendance Checker
cd attendance_tracker_<name>
python3 attendance_checker.p




Annabel Kemasuode 
This is the link to my video
https://drive.google.com/file/d/1HbDnOitwYXIojvCJ8iOPWlY7yXZbzDDZ/view?usp=drivesdk

#!/bin/bash


#function to verify python3 is present
python3_fuction() {
    vrsn=$(python3 --version 2>&1 )

    if [ -n "$vrsn" ]; then
	echo "------------------------------------------"
        echo "python3 is installed. $vrsn"
    else
        echo "python3 has not been installed"
	#Ask user if they want python3 installed
        while true; do
                read -p "Install python3?yes/no: " py3
                if [ "$py3" = "yes" ]; then
                    sudo apt update && sudo apt install python3
                    vrsn_chk=$(python3 --version 2>&1)
                    echo "python3 has beeninstalled $version_again"
                    break
                elif [ "$py3" = "no" ]; then
                    echo "Attendance tracker will not run without python3"
                    break
                else
                    echo "Error: please enter yes or no"
                fi
        done
    fi
    echo ""
}

#Signal trap function to archive progress when the script is stopped
trap_function() {
        echo""
        echo "--------------------------------------------------------------"
        if [ -d  "$DIRECTORY" ]; then
                tar czf "attendance_tracker_${name}_archive.tar.gz" "$DIRECTORY"
                rm -rf "$DIRECTORY"
        fi
        echo "...............Archived...................."
        exit 1
}


#Sub-directories and files creation function
structure_function() {
	#creating the main directory(with user input) and sub-directories
    DIRECTORY="attendance_tracker_${name}"
    mkdir -p "$DIRECTORY/Helpers" "$DIRECTORY/reports"

    cat > "$DIRECTORY/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    try:
        with open('Helpers/config.json', 'r') as f:
            config = json.load(f)
    except FileNotFoundError:
        print("Error: Helpers/config.json not found.")
        return

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    try:
        with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
            reader = csv.DictReader(f)
            total_sessions = config['total_sessions']
            log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

            for row in reader:
                name = row['Names']
                email = row['Email']
                attended = int(row['Attendance Count'])
                attendance_pct = (attended / total_sessions) * 100

                message = ""
                if attendance_pct < config['thresholds']['failure']:
                    message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail."
                elif attendance_pct < config['thresholds']['warning']:
                    message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Be careful."

                if message:
                    if config['run_mode'] == "live":
                        log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                        print(f"Logged alert for {name}")
                    else:
                        print(f"[DRY RUN] Email to {email}: {message}")
    except FileNotFoundError:
        print("Error: Helpers/assets.csv not found.")

if __name__ == "__main__":
    run_attendance_check()
EOF

    cat > "$DIRECTORY/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

    cat > "$DIRECTORY/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

    cat > "$DIRECTORY/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF
}

# main function to create connections between other functions
main_function() {
    
    #verify python3
    python3_fuction

    #get user input with error handling
    while true; do
        read -p "Enter a string to create the directory: " name

        if [ -n "$name" ]; then
            break
        else
            echo "error: Please enter a string"
        fi
    done

    #signal trap function active incase the script is stopped
    trap 'trap_function' SIGINT

    #create subdirectories and files
    structure_function

    #Prompt user to update thresholds
    echo ""
    echo "------------------------------------------------"
    echo "Do you want to update the attendance thresholds?"
    echo "A. Warning"
    echo "B. Failure "
    echo "C. Warning and failure"
    echo "D. No updates"
    while true; do
        read -p "Enter threshold to update(A, B, C, or D): " threshold
        if [ "${threshold,,}" = "a" ]; then
      	  read -p "new threshold value: " warning
        	sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$DIRECTORY/Helpers/config.json"
		echo "........................................"
        	echo "Warning threshold changed to $warning"
		break
    	elif [ "${threshold,,}" = "b" ]; then
        	read -p "new threshold value: " failure
        	sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$DIRECTORY/Helpers/config.json"
		echo "........................................"
        	echo "Failure threshold changed to $failure"
		break
    	elif [ "${threshold,,}" = "c" ]; then
        	read -p "warning threshold vlue: " warning
        	read -p "failure threshold value: " failure
        	sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$DIRECTORY/Helpers/config.json"
        	sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$DIRECTORY/Helpers/config.json"
		echo "..................................................................."
        	echo " Success. Warning threshold: $warning. Falire threshold: $failure"
		break
    	elif [ "${threshold,,}" = "d" ]; then
		echo "....................................."
        	echo "Proceeding with directory creation"
		break
    	else
        	echo "Invalid input. Please enter A, B, C, or D"
    	fi
    done

    echo "=============================="
    echo "Directories and files created"

    #show the directory's contents
    tree ./$DIRECTORY
}

main_function

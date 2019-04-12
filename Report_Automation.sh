#!/bin/sh

clear

#Move the current files (if any) to backup
cd /var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/Output/
find . -type f -name 'Calendar_current*' | while read FILE ; do
    mv "${FILE}" "Calendar_backup.csv" ;
done;
find . -type f -name 'Filetype_current*' | while read FILE ; do
    mv "${FILE}" "Filetype_backup.csv" ;
done;
find . -type f -name 'Flart_current*' | while read FILE ; do
    mv "${FILE}" "Flart_backup.csv" ;
done;

#Make the script executable
chmod +x /var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/scripts/api_scripts/Automation_Scripts/_from_2014.py
chmod +x /var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/scripts/api_scripts/Automation_Scripts/_from_2018.py

#Generate BI datasets. Python files to could be modified on need basis.
python /var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/scripts/api_scripts/Automation_Scripts/_from_2014.py
python /var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/scripts/api_scripts/Automation_Scripts/_from_2018.py


#Delete the .7z files, which unnecessarily occupy space
find . -name "*.7z" -type f -delete

#Rename the csv files to current. This will be utilized by the update table scripts to feed into the DB
find . -type f -name 'AT-&-T-Calendar-*' | while read FILE ; do
    mv "${FILE}" "Calendar_current.csv";
done;

find . -type f -name 'AT-&-T-CeByFileType-*' | while read FILE ; do
    mv "${FILE}" "Filetype_current.csv";
done;
find . -type f -name 'AT-&-T-Flart-*' | while read FILE ; do
    mv "${FILE}" "Flart_current.csv";
done;

#Feed the _current files into the tables in the DB
# Step 1: Connect to Database using password in local file store
#chmod 0600 ~/.pgpass
#~/.pgpass
psql --host=localhost --port=5432 --dbname=att --username=postgres <<EOF
BEGIN;
select count(*) from test_automation.calendar;
set datestyle to DMY;
delete from devprofiles.att_calendar;
\COPY devprofiles.att_calendar FROM '/var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/Output/Calendar_current.csv' WITH (format csv, header);
delete from flartdataset.flartbi;
\COPY flartdataset.flartbi FROM '/var/tmp/Viral_and_Dan/Python_SDK_on_Unix/python-package-master@6a8915f345e/Output/Flart_current.csv' WITH (format csv, header);
COMMIT;
EOF

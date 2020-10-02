set filename=%date:~4,2%-%date:~7,2%-%date:~10,4%_robocopy_melbourne_incoming_purge_log.txt

robocopy "I:\01_MELBOURNE_CLIENTS\NEWCLIENTS"  "C:\Users\Mercury-Admin\Dropbox\03_Melbourne Incoming Jobs" /PURGE >> "\\galaxy\IT\AutoScripts\Logs\"%filename%
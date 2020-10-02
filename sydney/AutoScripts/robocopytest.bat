set filename=%date:~4,2%-%date:~7,2%-%date:~10,4%_robocopy_melbourne_incoming_log.txt

robocopy "C:\Users\Mercury-Admin\Dropbox\03_Melbourne Incoming Jobs" "I:\01_MELBOURNE_CLIENTS\NEWCLIENTS"  /MIR /MON:1 /XO /DCOPY:DT /XD >> "\\galaxy\IT\AutoScripts\Logs\"%filename%

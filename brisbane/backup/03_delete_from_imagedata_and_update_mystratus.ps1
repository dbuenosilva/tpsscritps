<##########################################################################
# Project: Backup
# File: 03_delete_from_imagedata_and_update_mystratus.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 19/10/2020
# Description: Delete files archived in external HD and update session
#              status on My Stratus
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

# importing classes and functions
. C:\workspace\scripts\brisbane\functions\tpsLib.ps1

$LOG_ROOT = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\03-delete-from-imagedata-and-update-mystratus\";

updateMyStratusSessionStatus "20048555ADH" "Secondary Archive Pending" "Archived to FINDING NEMO 2"

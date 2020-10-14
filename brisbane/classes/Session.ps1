<##########################################################################
# Project: Generic
# File: Session.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 12/10/2020
# Description: Define class Session       
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

class Session {
    [string]$sessionNumber
    [string]$status
    [string]$path
    [string]$folder
    [decimal]$numberOfFiles

    [string]ToString(){
        return ("{0}" -f $this.sessionNumber)
    }
}



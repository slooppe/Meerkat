﻿function Get-THR_ARP {
    <#
    .SYNOPSIS 
        Gets the arp cache.

    .DESCRIPTION 
        Gets the arp cache from all connected interfaces.

    .EXAMPLE 
        Get-THR_ARP
        
    .EXAMPLE
        $Targets = Get-ADComputer -filter * | Select -ExpandProperty Name
        ForEach ($Target in $Targets) {
            Invoke-Command -ComputerName $Target -ScriptBlock ${Function:Get-THR_ARP} | 
            Export-Csv -NoTypeInformation "c:\temp\$Target_ARP.csv"
        }

    .NOTES 
        Updated: 2018-12-30

        Contributing Authors:
            Anthony Phipps
            
        LEGAL: Copyright (C) 2018
        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.
    
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.

    .LINK
       https://github.com/TonyPhipps/THRecon
    #>

    [CmdletBinding()]
    param(
    )

	begin{

        $DateScanned = Get-Date -Format u
        Write-Verbose ("Started {0} at {1}" -f $MyInvocation.MyCommand.Name, $DateScanned)

        $stopwatch = New-Object System.Diagnostics.Stopwatch
        $stopwatch.Start()
    }

    process{
            
        $ARPEntryArray = Get-NetNeighbor | 
            Where-Object {($_.LINKLayerAddress -ne "") -and
                ($_.LINKLayerAddress -ne "FF-FF-FF-FF-FF-FF") -and # Broadcast. Filtered by LinkLayerAddress rather than "$_.State -ne "permanent" to maintain manual entries
                ($_.LINKLayerAddress -notlike "01-00-5E-*") -and   # IPv4 multicast
                ($_.LINKLayerAddress -notlike "33-33-*")           # IPv6 multicast
            }
        
        
        foreach ($ARPEntry in $ARPEntryArray) {
            $ARPEntry | Add-Member -MemberType NoteProperty -Name "Host" -Value $Hostname
            $ARPEntry | Add-Member -MemberType NoteProperty -Name "DateScanned" -Value $DateScanned
        }
        
        return $ARPEntryArray | Select-Object IfIndex, InterfaceAlias, IPAdress, LinkLayerAddress, State, PolicyStore
    }

    end{
        
        $elapsed = $stopwatch.Elapsed

        Write-Verbose ("Started at {0}" -f $DateScanned)
        Write-Verbose ("Total time elapsed: {0}" -f $elapsed)
        Write-Verbose ("Ended at {0}" -f (Get-Date -Format u))
    }
}
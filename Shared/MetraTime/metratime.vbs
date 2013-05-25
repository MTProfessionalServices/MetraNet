Option explicit

Dim control
Set control = CreateObject("MetraTech.MetraTimeControl")

Dim client
Set client = CreateObject("MetraTech.MetraTimeClient")

Main

Public Function Main()

    If wscript.arguments.length = 0 Then
        PrintTimeInfo()
        Exit function
    End If

    Dim arg
    arg = wscript.arguments(0)

    Select Case LCase(arg)
        Case "-set"
            SetTime()
        Case "-reset"
            ResetTime()
        Case "-advanceday"
            AdvanceDay()
        Case Else
            PrintUsage()
    End Select

End Function


Public Function PrintUsage()
    wscript.echo "MetraTime usage:"
    wscript.echo
    wscript.echo "no arguments    shows current date/time information"
    wscript.echo "-set            sets the time offset to a given date/time"
    wscript.echo "-reset          stops using the time offset (reverts to the current system time)"
    wscript.echo "-advanceday     move the simulated date one day forward"
    wscript.echo
    wscript.echo "metratime -set [MM/DD/YYYY] [hh:mm:ss [am|pm]]"
    wscript.echo "metratime -reset"
    wscript.echo "metratime -advanceday"
End Function


Public Function PrintTimeInfo()
    wscript.echo "The MetraTech system time is currently : " & client.GetMTOLETime 
    wscript.echo "The actual system time is currently    : " & now
    wscript.echo 


    If client.IsTimeAdjusted Then 
        wscript.echo "Time is being adjusted (offset = " & control.GetSimulatedTimeOffset & ")."
    Else
        wscript.echo "Time is not being adjusted."
    End If
    
End Function


Public Function SetTime()
    If wscript.arguments.length = 1 Then
        wscript.echo "A date/time must be specified."
        Exit function
    End If

    Dim i, arg
    For i = 1 To wscript.arguments.length - 1
        arg = arg + " " + wscript.arguments(i)
    Next

    If Not IsDate(arg) Then
        wscript.echo "The date/time speficied is in an invalid format"
        Exit function
    End If

    Dim newDate
    newDate = CDate(arg)
    wscript.echo "Changing time from " & client.GetMTOLETime & " to " & newDate
    control.SetSimulatedOLETime(newDate)
End Function


Public Function ResetTime()
    If Not client.IsTimeAdjusted Then 
        wscript.echo "Time is not currently being adjusted. Nothing to reset."
        Exit function
    End if

    wscript.echo "Changing time from " & client.GetMTOLETime & " to the system time " & Now
    control.SetSimulatedTimeOffset(0)
End Function


Public Function AdvanceDay()
    PrintTimeInfo()

    wscript.echo "Changing time ahead by one day..."
    control.SetSimulatedTimeOffset (control.GetSimulatedTimeOffset + 24 * 60 * 60)
    
    PrintTimeInfo()
End Function

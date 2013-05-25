'
' example:
' sp300_multiple_usagegen_batch.vbs -server PARIS -Prefix Batch1001 -acct_prefix perftest -acct_start 1 -acct_end 100 -random 1 -batch 1000-transactions 1000 -meter
'

'
'
' 
' Usage Generation Script for S&P300 Experiment(s)
' Author : Narayanan R S, (c) April 2001
' 

' Declare Globals

OPTION EXPLICIT

dim batch
dim transactions
dim numargs
dim synchronous
dim debug
dim prefix
dim namespace
dim server
Dim Feedback
Dim ObjMeter, ObjSession
Dim ErrNum
Dim acct_prefix
Dim acct_type
Dim acct_start
Dim acct_end
Dim random
Dim meterbool
Dim svc_def

'
' set default values
'

namespace = "sp300"
prefix = "usagetest"
server = "localhost"
feedback = 0
ErrNum = 0
numargs = 0
acct_prefix = "test"
acct_type = "large"
Acct_start = 1
Acct_end = 1
random = 0
debug = 0
transactions = 1
batch = 1
batch = 1
meterbool = 0
svc_def = 1


' Seed the Random Generator
Randomize Timer

'
' set default values
'

Sub PrintUsage()
        wscript.echo ""
        wscript.echo "Usage: cscript sp300_usagegen.vbs with the following optional arguments :"
        wscript.echo ""
        wscript.echo "  -batch : # batches (default is 1 per account)"
        wscript.echo "  -transactions : # transactions (default is 1 per account)"
        wscript.echo "  -namespace : (default is sp300)"
        wscript.echo "  -prefix : batch prefix (default is usagetest)"
        wscript.echo "  -server : machine name to meter to (default is localhost)"
        wscript.echo "  -feedback: BOOLEAN [True/False/1/0] (default is FALSE)"
        wscript.echo "  -acct_prefix : account prefix (default is test)"
        wscript.echo "  -acct_type: account type [Large/Normal/Medium] (default is Large)"
        wscript.echo "  -acct_start: starting account number (default 1)"
        wscript.echo "  -acct_end: ending account number (default 2)"
        wscript.echo "  -random: BOOLEAN [True/False/1/0] (default is FALSE, will meter sequentially)"
        wscript.echo "  -svc_def: HostedExchange_# (# = 1 - 8) Service Definition to Meter to (suffix only)"
        wscript.echo "  -help: displays this usage"
        wscript.echo "  -meter: meter usage (select defaults if no args)"
        wscript.echo ""
End Sub

Sub SetValues()

Dim arg

while numargs < wscript.arguments.length
        arg = wscript.arguments(numargs)

        Select Case LCASE(arg)

        case "-batch"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                batch = CLng(wscript.arguments(numargs))

        case "-transactions"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                transactions = CLng(wscript.arguments(numargs))

        case "-server"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                server = wscript.arguments(numargs)

        case "-prefix"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                prefix = wscript.arguments(numargs)

        case "-acct_prefix"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                acct_prefix = wscript.arguments(numargs)

        case "-acct_type"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                acct_type = LCase(wscript.arguments(numargs))
                if (acct_type <> "large" and acct_type <> "normal" and acct_type <> "medium") then
                        Wscript.Echo "Invalid Acct_Type argument!!!"
                        ErrNum = -1
                        Exit Sub
                end if

        case "-namespace"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                namespace = wscript.arguments(numargs)

        case "-acct_start"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                acct_start = CLng(wscript.arguments(numargs))

        case "-acct_end"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                acct_end = CLng(wscript.arguments(numargs))

        case "-svc_def"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                svc_def = CInt(wscript.arguments(numargs))

        case "-random"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                random = 0
                IF (UCase(CStr(wscript.arguments(numargs))) = "TRUE") Then random = 1
                IF (UCase(CStr(wscript.arguments(numargs))) = "1") Then random = 1

        case "-feedback"
                numargs = numargs + 1
                if numargs >= wscript.arguments.length then
                        ErrNum = -1
                        Exit Sub
                end if
                Feedback = 0
                IF (UCase(CStr(wscript.arguments(numargs))) = "TRUE") Then Feedback = 1
                IF (UCase(CStr(wscript.arguments(numargs))) = "1") Then Feedback = 1

        case "-help"
                ErrNum = -1
                Exit Sub

        case "-meter"
                meterbool = 1
                Wscript.Echo "Metering Using the arguments(specified/defaults)"

        case else
                if numargs = 0 then
                        '
                        ' Nothing much
                        '
                        Wscript.Echo "No arguments passed - using default values"
                        Wscript.Echo "[WILL NOT Meter unless -meter is specified]"
                end if

end select

        numargs = numargs + 1
wend

WScript.Echo ""
WScript.Echo "Obtained Arguments:"
WScript.Echo "Server : " & Server
WScript.Echo "Prefix : " & Prefix
WScript.Echo "Acct_Prefix : " & Acct_Prefix
WScript.Echo "First Account : " & acct_start
WScript.Echo "Last Account : " & acct_end
WScript.Echo "Namespace : " & Namespace
Wscript.Echo "Meter (1:TRUE/0:FALSE)  : " & meterbool
WScript.Echo "Feedback (1 = TRUE) : " & Feedback
WScript.Echo "Randomized (1 = TRUE) : " & Random
WScript.Echo "Service Definition : HostedExchange-" & svc_def
WScript.Echo "Total Transactions: " & Transactions
WScript.Echo "Total Batches : " & Batch
WScript.Echo ""

if numargs = 0 then
        '
        ' Nothing much
        '
        Wscript.Echo "No arguments passed - using default values"
        Wscript.Echo "[WILL NOT Meter unless -meter is specified]"
        Wscript.Echo ""
end if

End Sub

Sub ObjConstructor(Server)

'
' Instantiate Object and Set Values
'

set objMeter = CreateObject("MetraTechSDK.Meter")
if (isObject(objMeter)) then
        objMeter.HTTPTimeout = 30
        objMeter.HTTPRetries = 9
        Call objMeter.AddServer(0, server, 80, 0, "", "")
        Call objMeter.Startup
        Wscript.Echo ""
        Wscript.Echo "Metering Object Instantiated"
        Wscript.Echo ""
else
        Wscript.Echo ""
        Wscript.Echo "ERROR - Metering Object Instantiation failed!!!"
        Wscript.Echo ""
end if

End Sub

Sub ObjDestructor()

'
' Destructor of Object
'
if (isObject(objMeter)) then
        Call objMeter.Shutdown
        Wscript.Echo ""
        Wscript.Echo "Metering Object Destructed"
        Wscript.Echo ""
else
        Wscript.Echo ""
        Wscript.Echo "ERROR - Metering Object NOT Valid!!!"
        Wscript.Echo ""
end if

End Sub

Sub DebugVerbose(meterproperty, value)

    if (debug = 1) then
            Wscript.Echo meterproperty & " : " & value
    end if

End Sub

Function RandomString(length)

    ' Function will return a random string of specified length
    ' Note that the strings will only consist of characters from
    ' ASC 032 through ASC 122 (i.e space through 'z', including
    ' A-Z, a-z, 0-9 and some misc. characters (all printable)

    Dim i
    Dim randstr
    randstr = ""
    If (Length < 1) then
            RandomString = ""
            Exit Function
    end if

    For i = 1 to length
            randstr = randstr & chr( (25) * Rnd + 66 )
    Next

    RandomString = randstr

End Function

Function RandomFloat(lower, upper)

    ' Function to return a Random Float number
    ' Between the range specified

    Dim randfloat

    randfloat = lower + (upper - lower) * Rnd

    RandomFloat = CDbl(randfloat)

End Function

Function RandomLong(lower, upper)

    ' Function to return a Random Long number
    ' Between the range specified

    Dim randlong

    randlong = lower + (upper - lower) * Rnd

    RandomLong = CLng(randlong)

End Function


Sub Meter(acc_start, acc_end, acct_prefix, acct_type, prefix)

    '
    ' Routine to meter accounts
    '

    Dim i, j
    Dim cur_acct, cur_trans
    Dim strng, float, lng
    Dim acct_str
    Dim timestr
    Dim BatchObj

    acct_str = acct_prefix & "_" & acct_type & "_"
    cur_acct = acct_start
    timestr = now

    Wscript.Echo ""
    Wscript.Echo "Beginning Usage Metering Section"
    Wscript.Echo "Accounts are : " & acct_str & acc_start & " through " & acct_str & acc_end
    Wscript.Echo ""

    '
    ' Loop through from 1 to # Batches
    '
    For j = 1 To Batch

        Set BatchObj = objMeter.CreateBatch
        if not isObject(BatchObj) then
              WScript.Echo ""
              WScript.Echo "ERROR - Session Instantiation failed!!!"
              WScript.Echo ""
              Exit Sub
        end if

        'BatchObj.RequestResponse = Feedback

        '
        ' Loop through from 1 to # Transactions
        '
        For i = 1 to Transactions

            Set objSession = BatchObj.CreateSession("SAndPDemo/HostedExchange" & svc_def)

            if not isObject(ObjSession) then
                    WScript.Echo ""
                    WScript.Echo "ERROR - Session Instantiation failed!!!"
                    WScript.Echo ""
                    Exit Sub
            end if

            objSession.RequestResponse = Feedback

            '
            ' Handle CompanyID - generate a random one or go through sequentially
            ' This maps to Account Resolution
            '
            if (Random = 1) then
                    cur_acct = RandomLong(acct_start, acct_end)
            elseif (cur_acct > acct_end or cur_acct < acct_start) then
                    cur_acct = acct_start
            end if
            'DebugVerbose "CompanyID", acct_str & cur_acct
            Call objSession.InitProperty("CompanyID", acct_str & cur_acct)

            ' Handle Namespace
            'DebugVerbose "NameSpace", namespace
            Call objSession.InitProperty("NameSpace", namespace)

            ' Handle AccountName - random string of junk!!!
            strng = RandomString(50)
            'strng = "HardWiredAccountName"
            'DebugVerbose "AccountName", strng
            Call objSession.InitProperty("AccountName", strng)

            ' Handle PlanID
            lng = RandomLong(0,5)
            'DebugVerbose "PlanID", lng
            Call objSession.InitProperty("PlanID", lng)

            ' Handle ChannelID
            lng = RandomLong(0,5)
            'DebugVerbose "ChannelID", lng
            Call objSession.InitProperty("ChannelID", lng)

            ' Handle Batch ID - based off prefix
            'DebugVerbose "BatchID", LEFT(prefix & "_" & timestr,25)
            Call objSession.InitProperty("BatchID", LEFT(prefix & " on " & timestr,25))

            ' Handle Usage - random double
            float = RandomFloat(0, 500)
            'DebugVerbose "CurrentUsage", float
            Call objSession.InitProperty("CurrentUsage", float)

            '
            ' Don't think this is required
            '
            ' Set ObjSession = Nothing

            cur_acct = cur_acct + 1

        Next

        if (meterbool = 1) then
                CommitBatch BatchObj
        end If

        Set BatchObj = Nothing

    Next

End Sub

Dim RetVal
Dim Running
Dim i
Dim StartTime, EndTime

'
' Actual Body begins here
'

StartTime = now

SetValues
if (ErrNum = -1) then
        PrintUsage
End if

'Call Constructor - Create object
ObjConstructor(Server)

' Meter Usage
Meter acct_start, acct_end, acct_prefix, acct_type, prefix 

'Call Desctructor - Destroy object
ObjDestructor

if err then
    wscript.echo "error occurred: " & err.description
else
    wscript.echo "Successful"    
end if

EndTime = now

WScript.Echo ""
wscript.echo "Total execution time: " & DateDiff("s", StartTime, EndTime) & " seconds"
WScript.Echo ""


const MT_ERR_SERVER_BUSY = &HE1300026

sub CommitBatch(batch)

    'TRACE "committing batch."
    dim succeeded
    dim sleepTime, sleepIncrement, attempt
    ' first time we get a server busy, sleep for 30 seconds
    sleepTime = 5
    ' every time we have to sleep, wait this much longer
    sleepIncrement = 5

    attempt = 1
    succeeded = false

    Do
        'TRACE "attempting close."
        on error resume next
        batch.Close

        if err Then
            if err.Number <> MT_ERR_SERVER_BUSY then
                ' don't know what this is, reraise it
  dim myErrNum, myErrDesc
  myErrNum = err.Number
  myErrDesc = err.Description
                on error goto 0
                err.Raise myErrNum, myErrDesc
                wscript.echo "Unknown error"
            end If
        else
            'wscript.echo "Successfully committed: " & err.Number
            succeeded = true
        end if

        on error goto 0
        if not succeeded Then
            wscript.echo Now & ": Attempt " & attempt & " - server is busy - sleeping " & sleepTime & " seconds"
            wscript.sleep(sleepTime * 1000)
            ' next time wait longer
            sleepTime = sleepTime + sleepIncrement
            attempt = attempt + 1
        end If

    loop until succeeded

end Sub


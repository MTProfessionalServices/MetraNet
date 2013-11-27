option explicit

dim rerun
Dim objSessionContext

const    OPERATOR_TYPE_NONE = 0
const    OPERATOR_TYPE_LIKE = 1
const    OPERATOR_TYPE_LIKE_W = 2
const    OPERATOR_TYPE_EQUAL = 3
const    OPERATOR_TYPE_NOT_EQUAL = 4
const    OPERATOR_TYPE_GREATER = 5
const    OPERATOR_TYPE_GREATER_EQUAL = 6
const    OPERATOR_TYPE_LESS = 7
const    OPERATOR_TYPE_LESS_EQUAL = 8
const    OPERATOR_TYPE_DEFAULT = 9
const    OPERATOR_TYPE_IN = 10

Const MTPROGID_SERVERACCESS = "MTServerAccess.MTServerAccessDataSet.1"

FUNCTION IsValidObject(obj)
    If(IsObject(obj))Then 
     
        IsValidObject = Not(Obj Is Nothing) 
    Else 
        IsValidObject = FALSE         
    End If         
END FUNCTION

Function Setup(comment)
    wscript.echo "Setting up new rerun task"

    rerun.Setup comment

    wscript.echo "rerun id = " & rerun.ID
    Setup = rerun.ID
end Function

sub Identify(rerunID, filter)
    wscript.echo "Identifying sessions matching filter "

    rerun.ID = rerunID

    rerun.Identify (filter), ""
    wscript.echo "Done"

end sub

function CreateIdentificationFilter(rerunID)
    wscript.echo "Creating identification filter for rerun " & rerunID

    dim filter
    set filter = rerun.CreateFilter

    set CreateIdentificationFilter = filter
end function

sub IdentifyBatch(filter, batchID)
    wscript.echo "Identifying sessions matching batch ID " & batchID
    filter.BatchID = batchID
end sub

sub IdentifySuspendedTransactions(filter)
    wscript.echo "Identifying suspended transactions "
    filter.IsIdentifySuspendedTransactions = true
    filter.SuspendedInterval = 0.0  'default interval of 6 hrs
end sub

sub IdentifyPendingTransactions(filter)
    wscript.echo "Identifying pending transactions "
    filter.IsIdentifyPendingTransactions = true
end sub

' 6/28/2002 3:09:08 PM
sub IdentifyDateRange(filter, beginDate, endDate)
    wscript.echo "Identifying sessions between " & CDate(beginDate) & " and " & CDate(endDate)

    filter.BeginDatetime = beginDate
    filter.EndDatetime = endDate
end sub

sub IdentifyProductView(filter, pv)
    wscript.echo "Identifying sessions in product view " & pv

    filter.AddProductView pv
end sub

sub IdentifySessionID(filter, sessionid)
    wscript.echo "Identifying session " & sessionid

    filter.AddSessionID sessionid
end sub

sub IdentifyIntervalID(filter, intervalID)
    wscript.echo "Identifying sessions in interval " & intervalID
    if IsNumeric(intervalID) Then
       filter.IntervalID = intervalID
    else
       wscript.echo "Invalid Interval specified"
       exit sub
    end if   
       
end sub

sub  IdentifyBillingGroupID (filter, billinggroupID)
      wscript.echo "Identifying sessions based on billing group ID " &  billinggroupID
      if IsNumeric(billinggroupID) Then
          filter.BillingGroupID = billinggroupID
      else
          wscript.echo "Invalid billing group ID specified"
          exit sub
      end if
end sub
sub IdentifyAccounts(filter, propertyName, propertyValue)
    wscript.echo "Identifying sessions metered to accounts where " & propertyName & " = " & propertyValue

    if not IsValidObject(filter.AccountConditions) Then
        dim accFilter
        Set accFilter = CreateObject("MTSQLRowset.MTDataFilter")
        filter.AccountConditions = accFilter
    end if

    filter.AccountConditions.Add propertyName, OPERATOR_TYPE_EQUAL, propertyValue
end sub

sub IdentifySvcDefProp(filter, svcDefName, propertyName, propertyValue)
    wscript.echo "Identifying sessions with service " & svcDefName & " " & propertyName & "=" & propertyValue

    filter.AddServiceDefinitionProperty svcDefName, propertyName, propertyValue
end sub

sub IdentifyPVDefProp(filter, pvDefName, propertyName, propertyValue)
    wscript.echo "Identifying sessions with product view " & pvDefName & " " & propertyName & "=" & propertyValue

    filter.AddProductViewProperty pvDefName, propertyName, propertyValue
end sub


sub Analyze(rerunID, comment)
    wscript.echo "Analyzing rerun " & rerunID

    rerun.ID = rerunID

    rerun.Analyze comment
    wscript.echo "Done"
end sub

sub Extract(rerunID, comment)
    wscript.echo "Extracting from queues for rerun " & rerunID

    rerun.ID = rerunID

    rerun.Extract comment
    wscript.echo "Done"
end sub

sub Backout(rerunID, comment)
    wscript.echo "Backing out rerun " & rerunID

    rerun.ID = rerunID
    rerun.Synchronous = true
    rerun.Backout comment
    rerun.Abandon comment
    wscript.echo "Done"
end sub

sub BackoutDelete(rerunID, comment)
    wscript.echo "Backing and deleting rerun " & rerunID

    rerun.ID = rerunID
    rerun.Synchronous = true
    rerun.BackoutDelete comment
    rerun.Abandon comment
    
    wscript.echo "Done"
end sub


sub BackoutResubmit(rerunID, comment)
    wscript.echo "Backing out and resubmitting rerun " & rerunID

    rerun.ID = rerunID
    rerun.Synchronous = true
    rerun.BackoutResubmit comment
    rerun.Abandon comment
    
    wscript.echo "Done"
end sub

sub Delete(rerunID, comment)
    wscript.echo "Deleting backed out data for rerun " & rerunID

    rerun.ID = rerunID
    rerun.Synchronous = true
    rerun.Delete comment
    rerun.Abandon comment
    
    wscript.echo "Done"
end sub

sub Abandon(rerunID, comment)
    wscript.echo "Abandoning rerun " & rerunID

    rerun.ID = rerunID

    rerun.Abandon comment
    wscript.echo "Done"
end sub


sub Prepare(rerunID, comment)
    wscript.echo "Prepare messages for resubmit for rerun " & rerunID

    rerun.ID = rerunID

    rerun.Prepare comment
    wscript.echo "Done"
end sub

sub IsComplete(rerunID)
    wscript.echo "Checking to see if backout/rerun " & rerunID & " is complete"

    rerun.ID = rerunID
    rerun.Synchronous = false

    wscript.echo "IsComplete=" & rerun.IsComplete
    
    wscript.echo "Done"
end sub

sub GetTableName(rerunID)
	wscript.echo "Making a call to get table name for id: " & rerunID
	dim name
	
	name = rerun.GetTableName(rerunID)
	wscript.echo "table name is: " & name
	wscript.echo "DOne"
end sub	
	
sub ReRunSessions(rerunID, comment)
    ' cache big, frequently used objects
    dim queryCache
    set queryCache = CreateObject("MTQueryCache.MTQueryCache.1")

    dim enumConfig
    set enumConfig = CreateObject("Metratech.MTEnumConfig.1")

    wscript.echo "Resubmitting message for rerun " & rerunID

    rerun.ID = rerunID

    rerun.ReRun comment
    wscript.echo "Done"
end sub


sub ListReRuns()
    wscript.echo "Current re-run tasks"
    wscript.echo "---------------------"

    dim rowset
    set rowset = CreateObject("MTSqlRowset.MTSQLRowset.1")
    rowset.Init "queries\billingrerun"

    rowset.SetQueryTag("__LIST_RERUNS__")
    rowset.Execute

    dim Line

    While Not rowset.EOF
        line = ""
        Dim Count
        Count = rowset.Count
        
        Dim i
        For i = 0 To Count - 1
            Line = Line & "  " & rowset.Value(i) & "  "
        Next

        wscript.echo Line
        rowset.MoveNext
    Wend
end sub


Sub PrintUsage()
    wscript.echo "usage: billingrerun [options]"
    wscript.echo ""
    wscript.echo "-list   : display all active billing rerun entries"
    wscript.echo "-setup comment : create a new billing rerun entry"
    wscript.echo "-identify id        : identify a set of sessions.  must be followed by"
    wscript.echo "               at least one identification filter flag (see below)."
    wscript.echo "-analyze id comment : analyze sessions to see if they can be rerun"
    wscript.echo "-backout id comment : backout sessions from the database. Use only for msmq"
    wscript.echo "-prepare id comment : prepare data to be resubmitted.  Use only for msmq"
    wscript.echo "-extract id comment : remove data from queues and logs.  Use only for msmq"
    wscript.echo "-rerun id comment   : resubmit backed out data.  Use only for msmq"
    wscript.echo "-delete id comment  : delete backed out data.  Use only for msmq"
    wscript.echo "-abandon id comment : delete all record of rerun attempt"
    wscript.echo "-backoutDelete id comment : backout sessions from the database.  Delete sessions from t_svc tables.  Use only for dbqueues"
    wscript.echo "-backoutResubmit id comment: backout sessions from the database, resubmit them for processing.  Use only for dbqueues"
    wscript.echo 
    wscript.echo ""
    wscript.echo "-iscomplete id        : display if the asynchronous processing of an entry is complete"
    wscript.echo ""
    wscript.echo ""
    wscript.echo "Identification filters"
    wscript.echo "  -batch batchid             : identify a batch of session"
    wscript.echo "  -session sessionid         : identify a session"
    wscript.echo "  -daterange begin end       : identify sessions within a date range"
    wscript.echo "  -pv productview            : identify session in a product view"
    wscript.echo "  -acc propertyname value    : identify sessions metered to accounts"
    wscript.echo "  -intervalid id             : identify sessions metered to an interval"
    wscript.echo "  -svcprop svcname name val  : identify sessions that have a matching "
    wscript.echo "                               service def property value"
    wscript.echo "  -pvprop pvname name val    : identify sessions that have a matching "
    wscript.echo "                               product view prop"
    wscript.echo "  -billinggroup	         : identify sessions that were metered to a list of accounts in a particular interval,"
    wscript.echo "		         identified by the billing group id."
end Sub

' TODO: undocumented for now
'    wscript.echo "-async  : when added to any operation, invokes operation asynchronously"

Sub Main()
  if wscript.arguments.length < 1 then
    PrintUsage
    Exit Sub
  End If


  set rerun = CreateObject("MetraTech.Pipeline.ReRun.Client")
'  set rerun = CreateObject("MetraTech.MTBillingReRun")

  'Login as SU
  Dim objLoginContext


  Dim serveraccess
  Set serveraccess = CreateObject(MTPROGID_SERVERACCESS)
  serveraccess.Initialize
  Dim accessinfo
  Set accessinfo = serveraccess.FindAndReturnObject("SuperUser")
  Dim suName
  Dim suPassword
  suName = accessInfo.UserName
  suPassword = accessInfo.Password

  Set objLoginContext = CreateObject("Metratech.MTLoginContext")
  Set objSessionContext = objLoginContext.Login(suName, "system_user", suPassword)
  rerun.Login (objSessionContext)


  dim id

  dim idFilter

  dim argnum

  dim batchid, begindate, enddate, pv, sessionid, adapterName, propertyName, propertyValue
  Dim svcDefName, pvDefName, intervalID, billinggroupID
  dim comment
  argnum = 0
  dim totalArgs
  totalArgs = wscript.arguments.length

  while argnum < wscript.arguments.length

      Select Case wscript.arguments(argnum)

          ' -list
          case "-list"
              ListReRuns

          case "-async"
              rerun.Synchronous = false

              ' -setup comment
          case "-setup"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              comment = wscript.arguments(argnum)

              Setup comment

              ' -identify id
          case "-identify"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              id = wscript.arguments(argnum)

              set idFilter = CreateIdentificationFilter(id)

              ' -batch batchid
          case "-batch"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              batchid = wscript.arguments(argnum)

              IdentifyBatch idFilter, batchid

              ' -daterange begin end
          case "-daterange"
              if argnum + 2 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              begindate = wscript.arguments(argnum)

                  argnum = argnum + 1
              enddate = wscript.arguments(argnum)

              IdentifyDateRange idFilter, begindate, enddate

              ' -pv productview
          case "-pv"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              pv = wscript.arguments(argnum)

              IdentifyProductView idFilter, pv

          case "-session"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              sessionid = wscript.arguments(argnum)

              IdentifySessionID idFilter, sessionid

          case "-intervalid"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              intervalid = wscript.arguments(argnum)

              IdentifyIntervalID idFilter, intervalid

          case "-acc"
              if argnum + 1 >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              propertyName = wscript.arguments(argnum)

              argnum = argnum + 1
              propertyValue = wscript.arguments(argnum)

              IdentifyAccounts idFilter, propertyName, propertyValue

          case "-svcprop"
              if argnum + 3 >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              svcDefName = wscript.arguments(argnum)

              argnum = argnum + 1
              propertyName = wscript.arguments(argnum)

              argnum = argnum + 1
              propertyValue = wscript.arguments(argnum)

              IdentifySvcDefProp idFilter, svcDefName, propertyName, propertyValue

          case "-pvprop"
              if argnum + 3 >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              pvDefName = wscript.arguments(argnum)

              argnum = argnum + 1
              propertyName = wscript.arguments(argnum)

              argnum = argnum + 1
              propertyValue = wscript.arguments(argnum)

              IdentifyPVDefProp idFilter, pvDefName, propertyName, propertyValue
           

          case "-billinggroup"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              billinggroupID = wscript.arguments(argnum)

              IdentifyBillingGroupID idFilter, billinggroupID 
   
          case "-identifySuspendedTransactions"
                
                IdentifySuspendedTransactions idFilter              
          
          case "-identifyPendingTransactions"
                
                IdentifyPendingTransactions idFilter
                
          case "-analyze"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              Analyze id, comment

          case "-backout"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              Backout id, comment

        case "-backoutDelete"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              BackoutDelete id, comment

        case "-backoutResubmit"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              BackoutResubmit id, comment


          case "-prepare"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              Prepare id, comment

          case "-extract"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              Extract id, comment

          case "-rerun"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              ReRunSessions id, comment

          case "-delete"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              Delete id, comment

          case "-abandon"
              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              id = wscript.arguments(argnum)

              argnum = argnum + 1
              if argnum >= wscript.arguments.length Then
                  PrintUsage
                  Exit Sub
              end If

              comment = wscript.arguments(argnum)

              Abandon id, comment

          case "-iscomplete"
              if argnum + 1 >= totalArgs Then
                  PrintUsage
                  Exit Sub
              end If

              argnum = argnum + 1
              id = wscript.arguments(argnum)

              IsComplete id
          
          case "-GetTableName"
				if argnum + 1 >= totalArgs Then
					PrintUsage
					Exit Sub
				end If
				argnum = argnum +1
				id = wscript.arguments(argnum)
				
				GetTableName id	
          case Else
              PrintUsage
              exit sub

      end Select

      argnum = argnum + 1
    wend

    if IsValidObject(idFilter) Then
         Identify id, idFilter
    end if

end Sub

Main

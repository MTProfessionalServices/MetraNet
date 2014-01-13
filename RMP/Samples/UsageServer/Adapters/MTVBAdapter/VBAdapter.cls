VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "VBAdapter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements IRecurringEventAdapter

Const MTC_DT_WCHAR = 0
Const MTC_DT_CHAR = 1
Const MTC_DT_INT = 2
Const MTC_DT_FLOAT = 3
Const MTC_DT_DOUBLE = 4
Const MTC_DT_TIME = 5
Const MTC_DT_BOOL = 6
Const MTC_DT_DECIMAL = 7

' Private members
Private mSessionContext As IMTSessionContext

' Put this entry in the recurring_events.xml file
'<EndOfPeriodAdapters>
'  ...
'  <Adapter>
'    <Name>TestAdapter</Name>
'    <DisplayName>VB Test Adapter</DisplayName>
'    <ClassID>MTVBAdapter.VBAdapter</ClassID>
'    <ConfigFile>r:\extensions\SystemConfig\config\UsageServer\testadapter.xml</ConfigFile>
'    <RecurrencePattern>
'      <UsageCycleType>All</UsageCycleType>
'    </RecurrencePattern>
'  </Adapter>
'  ...
'</EndOfPeriodAdapters>
  
' Configuration
' <xmlconfig>
'   <batchcount>10</batchcount>
'   <sessioncount>10</sessioncount>
'   <errorcount>10</errorcount>
'   <sessionsetsize>10</sessionsetsize>
'   <extradelay>0</extradelay>
'   <reversemode> </reversemode>
'   <scheduled>true</scheduled>
'   <endofperiod>true</endofperiod>
'   <multiinstance>true</multiinstance>
'   <failinitialize> </failinitialize>
'   <failexecute> </failexecute>
'   <failreverse> </failreverse>
'   <failshutdown> </failshutdown>
'   <service>metratech.com/testservice</service>
'   <query>
'   <![CDATA[
'   select 'demo' as c_AccountName, 'Test service' as c_Description,
'   id_enum_data as c_Units, %%%SYSTEMDATE%%% as c_Time from t_enum_data
'   where id_enum_data >= 10 and id_enum_data < (10 + %%SUCCESS_COUNT%%)
'   Union All
'   select 'demoxx' as c_AccountName, 'Test service' as c_Description,
'   id_enum_data as c_Units, %%%SYSTEMDATE%%% as c_Time from t_enum_data
'   where id_enum_data >= 10 and id_enum_data < (10 + %%ERROR_COUNT%%)
'   ]]>
'   </query>
' </xmlconfig>
Private mSessionCount As Integer
Private mBatchCount As Integer
Private mErrorCount As Integer
Private mSessionSetSize As Integer
Private mExtraDelay As Integer
Private mReverseMode As MetraTech_UsageServer.ReverseMode
Private mScheduled As Boolean
Private mEndOfPeriod As Boolean
Private mMultiInstance As Boolean
Private mFailInitialize As Boolean
Private mFailExecute As Boolean
Private mFailReverse As Boolean
Private mFailShutdown As Boolean
Private mTag As String
Private mService As String
Private mQuery As String

' Since VB does not provide a sleep function, we have to go into this win32 call
Private Declare Sub sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Private Property Get IRecurringEventAdapter_SupportsScheduledEvents() As Boolean
  IRecurringEventAdapter_SupportsScheduledEvents = False
End Property

Private Property Get IRecurringEventAdapter_SupportsEndOfPeriodEvents() As Boolean
  IRecurringEventAdapter_SupportsEndOfPeriodEvents = True
End Property

Private Property Get IRecurringEventAdapter_Reversibility() As MetraTech_UsageServer.ReverseMode
  IRecurringEventAdapter_Reversibility = ReverseMode_Custom
End Property

Private Property Get IRecurringEventAdapter_AllowMultipleInstances() As Boolean
  IRecurringEventAdapter_AllowMultipleInstances = False
End Property

Private Sub IRecurringEventAdapter_Initialize(ByVal eventName As String, ByVal configFile As String, ByVal context As MTAUTHLib.IMTSessionContext, ByVal limitedInit As Boolean)
  TRACE PreProcess("Initializing test Adapter [0]", "0", configFile)
  
  If limitedInit = True Then
    TRACE "Limited initialization requested", , , LOG_DEBUG
  Else
    TRACE "Full initialization requested", , , LOG_DEBUG
  End If
  
  Set mSessionContext = context
  ReadConfig (configFile)

  If mFailInitialize = True Then
    Dim strError As String
    strError = mTag & "Initialize configured to fail"
    Call Err.Raise(1000 + vbObjectError, "VBAdapter", strError)
  End If

  TRACE PreProcess("[0]: Initialized", "0", mTag)
End Sub

'
'
'
Private Function IRecurringEventAdapter_Execute(ByVal context As MetraTech_UsageServer.IRecurringEventRunContext) As String
  TRACE PreProcess("[0]: Executing test adapter", "0", mTag)

  TRACE PreProcess("[0]: Event type = [1]", "0", mTag, "1", context.EventType)
  TRACE PreProcess("[0]: Run ID = [1]", "0", mTag, "0", context.RunID)
  TRACE PreProcess("[0]: Usage interval ID = [1]", "0", mTag, "1", context.UsageIntervalID)
  TRACE PreProcess("[0]: Start Date = [1]", "0", mTag, "1", context.StartDate)
  TRACE PreProcess("[0]: End Date = [1]", "0", mTag, "1", context.EndDate)

  If mFailExecute = True Then
    Dim strError As String
    strError = mTag & "Execute configured to fail"
    Call Err.Raise(1000 + vbObjectError, "VBAdapter", strError)
  End If


  Dim index As Long
  For index = 0 To mBatchCount - 1
    
    Dim mr As New METERROWSETLib.MeterRowset
    mr.InitSDK ("RecurringChargeServer")
    mr.InitForService (mService)

    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    ' the config path isn't actually used but it has to be valid
    rowset.Init ("config\\Queries\\UsageServer")

    rowset.SetQueryString (mQuery)
    rowset.AddParam "%%ERROR_COUNT%%", mErrorCount, False
    rowset.AddParam "%%SUCCESS_COUNT%%", mSessionCount - mErrorCount, False

    TRACE PreProcess("[0]: query: [1]", "0", mTag, "1", rowset.GetQueryString())

    rowset.Execute

    mr.CreateAdapterBatch context.RunID, mTag, CStr(index)
    mr.SessionSetSize = mSessionSetSize
        
    ' places the usage in the correct interval (required since the interval is soft closed)
    mr.AddCommonProperty "_IntervalId", MTC_DT_INT, context.UsageIntervalID
    mr.MeterRowset rowset
  Next

  If mExtraDelay > 0 Then
    TRACE PreProcess("Sleeping an additional [0] seconds", mExtraDelay)
    sleep mExtraDelay * 1000
  End If

  Dim detail As String
  detail = mTag & ": execute complete"
  IRecurringEventAdapter_Execute = detail
End Function

'
'
'
Private Function IRecurringEventAdapter_Reverse(ByVal context As MetraTech_UsageServer.IRecurringEventRunContext) As String
  TRACE PreProcess("[0]: Reversing test adapter", "0", mTag)

  If (mReverseMode = ReverseMode_Custom) Then
    Debug.Assert 0
  End If
    
  TRACE PreProcess("[0]: Event type = [1]", "0", mTag, "1", context.EventType)
  TRACE PreProcess("[0]: Run ID = [1]", "0", mTag, "1", context.RunID)
  TRACE PreProcess("[0]: Usage interval ID = [1]", "0", mTag, "1", context.UsageIntervalID)
  TRACE PreProcess("[0]: Start Date = [1]", "0", mTag, "1", context.StartDate)
  TRACE PreProcess("[0]: End Date = [1]", "0", mTag, "1", context.EndDate)

  If mFailReverse = True Then
    Dim strError As String
    strError = mTag & "Reverse configured to fail"
    Call Err.Raise(1000 + vbObjectError, "VBAdapter", strError)
  End If

  Dim detail As String
  detail = mTag & ": reverse complete"
  IRecurringEventAdapter_Reverse = detail
End Function

'
'
'
Private Sub IRecurringEventAdapter_Shutdown()
  TRACE PreProcess("[0]: Shutting down test adapter", "0", mTag)

  If mFailShutdown = True Then
    Dim strError As String
    strError = mTag & "Shutdown configured to fail"
    Call Err.Raise(1000 + vbObjectError, "VBAdapter", strError)
  End If
End Sub

'
'
'
Private Function ReadConfig(configFile As String) As Boolean
  Dim doc As New MetraTech_Xml.MTXmlDocument
  doc.Load (configFile)
  
  ' The _1 and _2 at the end of the methods indicate their location in the Xml.cs file.
  ' These methods are overloaded and since its not really an interface, this is the only
  ' way to get these methods working
  mTag = doc.GetNodeValueAsString_2("/xmlconfig/tag", "TestAdapter")
  mSessionCount = doc.GetNodeValueAsInt_2("/xmlconfig/sessioncount", 100)
  mBatchCount = doc.GetNodeValueAsInt_2("/xmlconfig/batchcount", 1)
  mSessionSetSize = doc.GetNodeValueAsInt_2("/xmlconfig/sessionsetsize", mSessionCount)
  mErrorCount = doc.GetNodeValueAsInt_2("/xmlconfig/errorcount", 0)
  
  Dim strReverseMode As String
  strReverseMode = doc.GetNodeValueAsString_2("/xmlconfig/reversemode", "custom")
  If strReverseMode = "Custom" Then
    mReverseMode = ReverseMode_Custom
  End If
  
  mScheduled = doc.GetNodeValueAsBool_2("/xmlconfig/scheduled", False)
  mEndOfPeriod = doc.GetNodeValueAsBool_2("/xmlconfig/endofperiod", True)
  mMultiInstance = doc.GetNodeValueAsBool_2("/xmlconfig/multiinstance", True)
  mFailInitialize = doc.GetNodeValueAsBool_2("/xmlconfig/failinitialize", False)
  mFailExecute = doc.GetNodeValueAsBool_2("/xmlconfig/failexecute", False)
  mFailReverse = doc.GetNodeValueAsBool_2("/xmlconfig/failreverse", False)
  mFailShutdown = doc.GetNodeValueAsBool_2("/xmlconfig/failshutdown", False)
  mExtraDelay = doc.GetNodeValueAsInt_2("/xmlconfig/extradelay", 0)
  
  If mSessionCount > 0 Then
    mService = doc.GetNodeValueAsString_2("/xmlconfig/service", "metratech.com/testservice")
    mQuery = doc.GetNodeValueAsString_2("/xmlconfig/query", "")
  End If
  
  ReadConfig = True
  
End Function

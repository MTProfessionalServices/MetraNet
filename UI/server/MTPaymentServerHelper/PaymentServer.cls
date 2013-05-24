VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PaymentServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Const DEFAULT_VIRTUAL_DIR = "paymentsvr"

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetPaymentServerRowset
' PARAMETERS    : QueryName, account ID, virtual directory
' DESCRIPTION   : Queries the setup payment server and returns a rowset
' RETURN        : MTXMLRowset
Public Function GetPaymentServerRowset(ByVal strQuery As String, ByVal strAccountID As String, Optional ByVal strVirtualDir As String = "paymentsvr", Optional ByVal lngTimeout As Long = -1) As MTXMLRowset
  Dim rowset     As New MTXMLRowset   ' create the XML rowset
  Dim rcd        As New MTRcd     ' create RCD
  Dim configPath As String
  
  On Error GoTo ErrMgr
   'Set required properties
   PopulateRowsetProperties rowset
  
  ' Initialize the rowset
  configPath = rcd.ExtensionDir & "\paymentsvrclient\config\PaymentServer"
  rowset.Init configPath
  
  ' Build the query
  rowset.SetQueryTag (strQuery)
  
  'Set the timeout
  rowset.Timeout = lngTimeout
  
  ' Set the virtual directory
  rowset.AddParam "%%VirtualDirectory%%", strVirtualDir
  rowset.AddParam "%%ACCOUNT_ID%%", CLng(strAccountID)
  
  ' Execute
  'On Error Resume Next
  rowset.Execute
  'If (Err.Number) Then   ' If Execute fails make sure mdac 2.5 is installed
'        LogError MTPaymentServerHelper_ERROR_02001 & GetVBErrorString(), "PaymentServer.cls", "GetPaymentServerRowset", LOG_ERROR
  'End If
  'On Error GoTo ErrMgr
  
  Set GetPaymentServerRowset = rowset
 
  Exit Function
   
ErrMgr:
  LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "GetPaymentServerRowset", LOG_ERROR
  
  Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : JoinPaymentServerRowsets
' PARAMETERS    : filename for .mdmdlg containing rowset columns, Credit card rowset, ach rowset
' DESCRIPTION   : Merges two rowsets and returns a new rowset
' RETURN        : MTSQLRowsetSimulator
' Currently used columns:
' ---------------------------------------------------------------------------------------------------------------------------------------
  'Headers
  '------------------------------------------------------------------------------------------------------------------------------------------------
  'Default_Payment      Payment_Type      Bank                  Account Type          Account_Number              Expiration         Status       Routing_Number
  '
  'Credit Card
  '------------------------------------------------------------------------------------------------------------------------------------------------
  'nm_primary          "Credit Card"      new field             id_creditcardtype    nm_lastfourdigits            nm_expdate         nm_enabled      ""
  '
  'ACH
  '------------------------------------------------------------------------------------------------------------------------------------------------
  'nm_primary          "ACH"              nm_bankname            id_accounttype      nm_lastfourdigits                ""             nm_enabled      nm_routingnumber
' ---------------------------------------------------------------------------------------------------------------------------------------
Public Function JoinPaymentServerRowsets(ByVal strPSColsXMLFileName As String, ByVal CC As MTXMLRowset, ByVal ACH As MTXMLRowset) As Variant
  
  Dim i             As Long
  Dim nRecords      As Long
  Dim strName       As String
  Dim booCreditCard As Boolean
  Dim booACH        As Boolean
  
  Dim rowset        As Object '  New MTSQLRowsetSimulator
  Dim Service       As Object ' New MSIXHandler
  
  Set rowset = CreateObject("MTMSIX.MTSQLRowsetSimulator")
  Set Service = CreateObject("MTMSIX.MSIXHandler")
  
  On Error GoTo ErrMgr
  
  
  ' Calculate the number of records
  nRecords = 0
  
  If (IsValidObject(CC)) Then
    nRecords = nRecords + CLng(CC.RecordCount)
    booCreditCard = True
  End If
  
  If (IsValidObject(ACH)) Then
    nRecords = nRecords + CLng(ACH.RecordCount)
    booACH = True
  End If
  
  If (Not Service.Initialize(strPSColsXMLFileName)) Then
        
        TRACE " ProductView.Initialize (" & strPSColsXMLFileName & ") FAILED", "PaymentServer.cls", "JoinPaymentServerRowsets", LOG_ERROR
        Exit Function
  End If
      
  rowset.InitializeWithMSIXProperties Service.Properties, nRecords + 1 ' Initialize PS rowset

  ' Paper Invoice - add it to the new payment method rowset
  '-------------------------------------------------------------------
  If (rowset.RecordCount) Then rowset.MoveFirst
  rowset.Value(0) = 0
  rowset.Value(1) = "Paper Invoice"
  
  rowset.MoveNext
  
  ' CREDIT CARD - add it to the new payment method rowset
  '-------------------------------------------------------------------
  If (booCreditCard) Then
      If (CC.RecordCount) Then CC.MoveFirst
      
      Do While Not CC.EOF() And Not rowset.EOF()
    
       For i = 0 To CC.Count - 1
           rowset.Value(i) = CC.Value(i)
       Next
    
       rowset.MoveNext
       CC.MoveNext
      Loop
  End If
  
  ' ACH - add it to the new payment method rowset
  '-------------------------------------------------------------------
  If (booACH) Then
      If (ACH.RecordCount) Then ACH.MoveFirst
      
      Do While Not ACH.EOF() And Not rowset.EOF()
    
       For i = 0 To ACH.Count - 1
           rowset.Value(i) = ACH.Value(i)
       Next
       
       rowset.MoveNext
       ACH.MoveNext
      Loop
  End If
  
  rowset.MoveFirst  ' set the rowset back to the begining before we return it!
  Set JoinPaymentServerRowsets = rowset
  
  Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "BuildMAMPaymentServerRowset", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function


' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PopulateRowsetProperties
' PARAMETERS    : MTXMLRowset object
' DESCRIPTION   : Populates the rowset with payment server information
' RETURN        : TRUE or FALSE
Private Function PopulateRowsetProperties(ByRef rowset As MTXMLRowset) As Boolean
    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    
    On Error GoTo ErrMgr
      
    PopulateRowsetProperties = False
    
    objServerAccessSet.Initialize
    Set objServerAccess = objServerAccessSet.FindAndReturnObject("paymentserver")
    Set objServerAccessSet = Nothing
        
    rowset.HostName = objServerAccess.ServerName
    rowset.UserName = objServerAccess.UserName
    rowset.Password = objServerAccess.Password
    rowset.ConnectionType = objServerAccess.Secure
    
    PopulateRowsetProperties = True
    Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "PopulateRowsetProperties", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetRowsetColumnEnumValueByID
' PARAMETERS    : MTSQLRowsetSimulator object, and col to get enum values for as long
' DESCRIPTION   : Populates the rowset with correct enum values for localization
' RETURN        : MTSQLRowsetSimulator
Public Function SetRowsetColumnEnumValueByID(ByVal r As Variant, ByVal col As Long) As Variant
  Dim i As Long
  Dim objTools As Object ' New MSIXTools
  
  Set objTools = CreateObject("MTMSIX.MSIXTools")
  
  r.MoveFirst
  
  Do While Not r.EOF()
    
       For i = 0 To r.Count - 1
           If i = col Then
              r.Value(i) = CStr(objTools.GetEnumValueByID(CLng(r.Value(i))))
           End If
       Next
       
       r.MoveNext
  Loop
  
  r.MoveFirst
  Set SetRowsetColumnEnumValueByID = r
  Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "SetRowsetColumnEnumValueByID", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetRowsetColumnEnumValueByFQN
' PARAMETERS    : MTSQLRowsetSimulator object, and col to get enum values for as long
' DESCRIPTION   : Populates the rowset with correct enum values for localization
' RETURN        : MTSQLRowsetSimulator
Public Function SetRowsetColumnEnumValueByFQN(ByVal r As Variant, ByVal col As Long) As Variant
  Dim i As Long
  Dim objTools As Object ' New MSIXTools
  Dim val As String
  
  Set objTools = CreateObject("MTMSIX.MSIXTools")
  
  r.MoveFirst
  
  Do While Not r.EOF()
    
       For i = 0 To r.Count - 1
           If i = col Then
           val = CStr(objTools.GetEnumValueByFQN(CStr(r.Value(i))))
              r.Value(i) = val
           End If
       Next
       
       r.MoveNext
  Loop
  
  r.MoveFirst
  Set SetRowsetColumnEnumValueByFQN = r
  Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "SetRowsetColumnEnumValueByFQN", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function



' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetCreditCardUpdateRowset
' PARAMETERS    : QueryName, account ID, last four digits, exp. date, virtual directory
' DESCRIPTION   : Queries the setup payment server and returns a rowset
' RETURN        : MTXMLRowset
Public Function GetCreditCardUpdateRowset(ByVal strQuery As String, ByVal strAccountID As String, ByVal strLastFourdigits As String, ByVal strCreditCardType As String, Optional ByVal strVirtualDir As String = "paymentsvr") As MTXMLRowset
  Dim rowset     As New MTXMLRowset   ' create the XML rowset
  Dim rcd        As New MTRcd     ' create RCD
  Dim configPath As String
  
  On Error GoTo ErrMgr
  
  ' Set required properties
   PopulateRowsetProperties rowset
  
  ' Initialize the rowset
  configPath = rcd.ExtensionDir & "\paymentsvrclient\config\PaymentServer"
  rowset.Init configPath
  
  ' Build the query
  rowset.SetQueryTag (strQuery)
  
  ' Set the virtual directory
  rowset.AddParam "%%VirtualDirectory%%", strVirtualDir
  rowset.AddParam "%%ACCOUNT_ID%%", CLng(strAccountID)
  rowset.AddParam "%%LAST_FOUR_DIGITS%%", CStr(strLastFourdigits)
  rowset.AddParam "%%CREDIT_CARD_TYPE%%", CStr(strCreditCardType)
    
  ' Execute
  On Error Resume Next
  rowset.Execute
  If (Err.Number) Then   ' If Execute fails make sure mdac 2.5 is installed
        LogError MTPaymentServerHelper_ERROR_02001 & GetVBErrorString(), "PaymentServer.cls", "GetCreditCardUpdateRowset", LOG_ERROR
  End If
  On Error GoTo ErrMgr
  
  Set GetCreditCardUpdateRowset = rowset
 
  Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "GetCreditCardUpdateRowset", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetPCardUpdateRowset
' PARAMETERS    : QueryName, account ID, last four digits, exp. date, virtual directory
' DESCRIPTION   : Queries the setup payment server and returns a rowset
' RETURN        : MTXMLRowset
Public Function GetPCardUpdateRowset(ByVal strQuery As String, ByVal strAccountID As String, ByVal strLastFourdigits As String, ByVal strCreditCardType As String, Optional ByVal strVirtualDir As String = "paymentsvr") As MTXMLRowset
  Dim rowset     As New MTXMLRowset   ' create the XML rowset
  Dim rcd        As New MTRcd     ' create RCD
  Dim configPath As String
  
  On Error GoTo ErrMgr
  
  ' Set required properties
   PopulateRowsetProperties rowset
  
  ' Initialize the rowset
  configPath = rcd.ExtensionDir & "\paymentsvrclient\config\PaymentServer"
  rowset.Init configPath
  
  ' Build the query
  rowset.SetQueryTag (strQuery)
  
  ' Set the virtual directory
  rowset.AddParam "%%VirtualDirectory%%", strVirtualDir
  rowset.AddParam "%%ACCOUNT_ID%%", CLng(strAccountID)
  rowset.AddParam "%%LAST_FOUR_DIGITS%%", CStr(strLastFourdigits)
  rowset.AddParam "%%CREDIT_CARD_TYPE%%", CStr(strCreditCardType)
    
  ' Execute
  On Error Resume Next
  rowset.Execute
  If (Err.Number) Then   ' If Execute fails make sure mdac 2.5 is installed
        LogError MTPaymentServerHelper_ERROR_02001 & GetVBErrorString(), "PaymentServer.cls", "GetPCardUpdateRowset", LOG_ERROR
  End If
  On Error GoTo ErrMgr
  
  Set GetPCardUpdateRowset = rowset
 
  Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "GetPCardUpdateRowset", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetACHUpdateRowset
' PARAMETERS    : QueryName, account ID, last four digits, bank account type, routing number, virtual directory
' DESCRIPTION   : Queries the setup payment server and returns a rowset
' RETURN        : MTXMLRowset
Public Function GetACHUpdateRowset(ByVal strQuery As String, ByVal strAccountID As String, ByVal strLastFourdigits As String, ByVal strBankAccountType As String, ByVal strRoutingNumber As String, Optional ByVal strVirtualDir As String = "paymentsvr") As MTXMLRowset
  Dim rowset     As New MTXMLRowset   ' create the XML rowset
  Dim rcd        As New MTRcd     ' create RCD
  Dim configPath As String
  
  On Error GoTo ErrMgr
  
  ' Set required properties
   PopulateRowsetProperties rowset
  
  ' Initialize the rowset
  configPath = rcd.ExtensionDir & "\paymentsvrclient\config\PaymentServer"
  rowset.Init configPath
  
  ' Build the query
  rowset.SetQueryTag (strQuery)
  
  ' Set the virtual directory
  rowset.AddParam "%%VirtualDirectory%%", strVirtualDir
  rowset.AddParam "%%ACCOUNT_ID%%", CLng(strAccountID)
  rowset.AddParam "%%LAST_FOUR_DIGITS%%", CStr(strLastFourdigits)
  rowset.AddParam "%%BANK_ACCOUNT_TYPE%%", CLng(strBankAccountType)
  rowset.AddParam "%%ROUTING_NUMBER%%", CStr(strRoutingNumber)
    
  ' Execute
  On Error Resume Next
  rowset.Execute
  If (Err.Number) Then   ' If Execute fails make sure mdac 2.5 is installed
        LogError MTPaymentServerHelper_ERROR_02001 & GetVBErrorString(), "PaymentServer.cls", "GetPaymentServerRowset", LOG_ERROR
  End If
  On Error GoTo ErrMgr
  
  Set GetACHUpdateRowset = rowset
 
  Exit Function
   
ErrMgr:
  
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "GetACHUpdateRowset", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetYearsArray
' PARAMETERS    :
' DESCRIPTION   : Gets a list of 10 years... starting with the current year
' RETURN        : Years as string array
Public Function GetYearsArray() As Variant
    
    Dim Years As Variant
    ReDim Years(10)
    
    Dim CurrentYear
    Dim i As Long
    
    CurrentYear = Year(Now())
    Years(0) = CurrentYear
    
    For i = 1 To 10
         Years(i) = CurrentYear + i
    Next

    GetYearsArray = Years
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetYearsArrayReverse
' PARAMETERS    :
' DESCRIPTION   : Gets a list of 10 years... starting in the past to the current year
' RETURN        : Years as string array
Public Function GetYearsArrayReverse(ByVal YearsInPast As Long) As Variant

    Dim Years As Variant
    ReDim Years(10)

    Dim CurrentYear
    Dim i As Long

    CurrentYear = Year(Now())
    ' g. cieplik 1/3/08 maestro startdate, populate the dropdown box starting at YearsInPast
    CurrentYear = CurrentYear - YearsInPast
    
    Years(0) = CurrentYear

    For i = 1 To 10
        Years(i) = CurrentYear + i
    Next

    GetYearsArrayReverse = Years
End Function


' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetPaymentServerRowset
' PARAMETERS    : QueryName, account ID, virtual directory
' DESCRIPTION   : Execute a generic remote query
' RETURN        : MTXMLRowset
Public Function GetPaymentServerGenericRowset(ByVal strQuery As String, ParamArray Parameters() As Variant) As MTXMLRowset

    Dim rowset                  As New MTXMLRowset   ' create the XML rowset
    Dim rcd                     As New MTRcd         ' create RCD
    Dim configPath              As String
    Dim booVirtualDirDefined    As Boolean
    Dim i                       As Long
    
    On Error GoTo ErrMgr
    
    PopulateRowsetProperties rowset ' Set required properties
    
    ' Initialize the rowset
    configPath = rcd.ExtensionDir & "\paymentsvrclient\config\PaymentServer"
    rowset.Init configPath
    
    ' Build the query
    rowset.SetQueryTag strQuery
    
    ' Add the parameters
    For i = 0 To UBound(Parameters) Step 2

        rowset.AddParam "%%" & Parameters(i) & "%%", "" & Parameters(i + 1)

        If (UCase(Parameters(i)) = UCase("VirtualDirectory")) Then booVirtualDirDefined = True
    Next

    If (Not booVirtualDirDefined) Then ' Set the virtual directory
    
        rowset.AddParam "%%VirtualDirectory%%", DEFAULT_VIRTUAL_DIR
    End If
    
    On Error Resume Next ' Execute
    rowset.Execute
    If (Err.Number) Then   ' If Execute fails make sure mdac 2.5 is installed
    
            LogError MTPaymentServerHelper_ERROR_02001 & GetVBErrorString(), "PaymentServer.cls", "GetPaymentServerRowset", LOG_ERROR
    End If
    On Error GoTo ErrMgr
    Set GetPaymentServerGenericRowset = rowset
    
    Exit Function
   
ErrMgr:
    LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "GetPaymentServerRowset", LOG_ERROR
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
    
    Set GetPaymentServerGenericRowset = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitializeMetering
' PARAMETERS    : servertype as string
' DESCRIPTION   : takes a servertype and initializes the metering object from the servers.xml file
' RETURN        : Meter object as variant
Public Function InitializeMetering(ByVal strServertype As String) As Variant ' Meter

    On Error GoTo ErrMgr

    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    Dim objMeter                As New Meter
        
    ' Initialize the object
    ' then search for the ServerAccess information
    ' set all the metering parameters
    TRACE "MTPaymentServerHelper --> Initialize Metering for " & strServertype
    objServerAccessSet.Initialize
    Set objServerAccess = objServerAccessSet.FindAndReturnObject(strServertype)
    Set objServerAccessSet = Nothing
    
    With objServerAccess
        objMeter.HTTPTimeout = .Timeout
        objMeter.HTTPRetries = .NumRetries
        Call objMeter.AddServer(.Priority, .ServerName, .PortNumber, .Secure, .UserName, .Password)
    End With
    
    Set objServerAccess = Nothing
    
    objMeter.Startup
    
    Set InitializeMetering = objMeter
    

    Exit Function
ErrMgr:
  LogError MTPaymentServerHelper_ERROR_02000 & GetVBErrorString(), "PaymentServer.cls", "InitializeMetering", LOG_ERROR
  
  Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
  
  Set InitializeMetering = Nothing
End Function


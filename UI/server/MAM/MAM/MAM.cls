VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MAM"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399322630054"
Option Explicit

' The MAM's object
Public Menu             As MTMSIX.XMenu
Public Dictionary       As New MTMSIX.Dictionary ' Because we load the dictionary before we call the
                                                 ' initialize method the object must self creatable
                                                 ' that's why we have the new
Public Cache            As MTMSIX.MSIXCache
Public Tools            As MTMSIX.MSIXTools
Public Subscriber       As MTMSIX.MSIXProperties ' view as a product view
Public CSR              As MTMSIX.MSIXProperties ' view as a service
Public TempAccount      As MTMSIX.MSIXProperties ' view as a service

Private m_strConfigDir  As String
Private m_strMamDir     As String
Private m_language      As String
Private m_objFind       As MTACCOUNTLib.MTAccountFinder


Private m_objSessionContext As Object
 
' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Initialize
' PARAMETERS    :
' DESCRIPTION   : In MAM V2 the dictionary is loaded before we call this method
' RETURN        :
Public Function Initialize(ByVal strMamDir As String) As Boolean

    On Error GoTo ErrMgr

    Dim booRetVal                                   As Boolean
    Dim strAccountCreationMSIXDEFFullPathFileName   As String
    
    Me.Log "MAM.Initialize() START"
    
    Set Cache = New MTMSIX.MSIXCache
    Set Tools = New MTMSIX.MSIXTools
    
    Me.Log "MAM Tools Instance ID=" & ObjPtr(Tools)
    
    Cache.Name = "MT Account Manager Cache"
    
    booRetVal = True
       
        
    m_strMamDir = strMamDir
    
    ' Check if the path is valid
    
    If (Not LoadMenu()) Then
    
        TRACE Replace(MTMAM_ERROR_01504, "[FILE]", MamDir() & "\menu.xml"), "MAM.cls", "Initialize", LOG_ERROR
        booRetVal = False
    End If
    
    Set Me.Menu.Dictionary = Dictionary ' Give the dictionary to the menu
    
    ' 1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'    Set Properties = New MTMSIX.MSIXProperties
'    InitPropertiesObject Properties, eMSIX_PROPERTIES_FLAG_SERVICE
'    If (Not Properties.LoadMSIXDEFXMLFile(MamDir() & "\default\class\MAMProperties.mdmdlg", "")) Then
'
'        booRetVal = False
'        TRACE Replace(MTMAM_ERROR_01504, "[FILE]", MamDir() & "\default\class\MAMProperties.mdmdlg"), "MAM.cls", "Initialize", LOG_ERROR
'    End If
    
    ' 2 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Set Subscriber = New MTMSIX.MSIXProperties
    InitPropertiesObject Subscriber, eMSIX_PROPERTIES_FLAG_SERVICE
                                                     ' We initialize as a service but it will be dynamically set to
                                                     ' a product view while doing the first find...Why?
                                                     ' Because account creation has no product view. But for the find returns a
                                                     ' kind of product view...
                                                     
    Me.Log "MAM Subscriber Instance ID=" & ObjPtr(Subscriber)
                                                     
    strAccountCreationMSIXDEFFullPathFileName = AccountCreationMsixdefFileName()
    Me.Tools.GetMSIXDEFFullPathName strAccountCreationMSIXDEFFullPathFileName
    
    If (Not Subscriber.LoadMSIXDEFXMLFile(strAccountCreationMSIXDEFFullPathFileName, "")) Then
    
        booRetVal = False
        TRACE Replace(MTMAM_ERROR_01504, "[FILE]", strAccountCreationMSIXDEFFullPathFileName), "MAM.cls", "Initialize", LOG_ERROR
    End If
    
    ' Add the property while waiting for the Back End Boys
    
    ' MAM 2.0 we do not need to add the currency
    'Subscriber.Add "_Currency", "string", 255, False, "USD", eMSIX_PROPERTY_FLAG_NONE    ' this property must not be meter
    
    Subscriber.Add "IntervalID", "string", 255, False, "", eMSIX_PROPERTY_FLAG_NONE ' this property must not be meter
    Subscriber.ReSetDefaults
    
'    GoTo THEEXIT
    
    ' 3 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Set CSR = New MTMSIX.MSIXProperties
    InitPropertiesObject CSR, eMSIX_PROPERTIES_FLAG_SERVICE
    If (Not CSR.LoadMSIXDEFXMLFile(strAccountCreationMSIXDEFFullPathFileName, "")) Then
    
        booRetVal = False
        TRACE Replace(MTMAM_ERROR_01504, "[FILE]", strAccountCreationMSIXDEFFullPathFileName), "MAM.cls", "Initialize", LOG_ERROR
    End If
    CSR.ReSetDefaults
    
    Me.Log "MAM CSR Instance ID=" & ObjPtr(CSR)
    
   ' CSR("TimeZoneId").Value = 18 '  Default value for BOSTON area
   ' CSR("Language").Value = "US" '  Default value for BOSTON area
   ' CSR("_AccountId") = 125
    'CSR("name_space") = "csr"
    
    
    ' MAM 3.0 -  Same as Subscriber but use for different task where we need to load, update and meter
    ' 4 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Set TempAccount = New MTMSIX.MSIXProperties
    InitPropertiesObject TempAccount, eMSIX_PROPERTIES_FLAG_SERVICE
                                                     ' We initialize as a service but it will be dynamically set to
                                                     ' a product view while doing the first find...Why?
                                                     ' Because account creation has no product view. But for the find returns a
                                                     ' kind of product view...
                                                     
    Me.Log "MAM TempAccount Instance ID=" & ObjPtr(Subscriber)
                                                     
    strAccountCreationMSIXDEFFullPathFileName = AccountCreationMsixdefFileName()
    Me.Tools.GetMSIXDEFFullPathName strAccountCreationMSIXDEFFullPathFileName
    
    If (Not TempAccount.LoadMSIXDEFXMLFile(strAccountCreationMSIXDEFFullPathFileName, "")) Then
    
        booRetVal = False
        TRACE Replace(MTMAM_ERROR_01504, "[FILE]", strAccountCreationMSIXDEFFullPathFileName), "MAM.cls", "Initialize", LOG_ERROR
    End If
    
    ' Add the property while waiting for the Back End Boys
    
    ' MAM 2.0 we do not need to add the currency
    'Subscriber.Add "_Currency", "string", 255, False, "USD", eMSIX_PROPERTY_FLAG_NONE    ' this property must not be meter
    
    TempAccount.Add "IntervalID", "string", 255, False, "", eMSIX_PROPERTY_FLAG_NONE ' this property must not be meter
    TempAccount.ReSetDefaults
    
    TRACE Replace(MTMAM_ERROR_01503, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED")), "MAM.cls", "Initialize", LOG_DEBUG
    
THEEXIT:
    
    Initialize = booRetVal
    Exit Function
    
ErrMgr:
    Initialize = False
    'SECENG: Added more info to log
    TRACE MTMAM_ERROR_01501 & " " & Err.Description, "MTMAM.MAM", "Initialize"
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function LoadMenu() As Boolean

    On Error GoTo ErrMgr

    Dim strFolder  As String
    Dim objTextFile         As New cTextFile
    
    If (Menu Is Nothing) Then
    
        Set Menu = New XMenu
        
        strFolder = MamDir() & "\default\menu" ' 1 Load the default menu folder
        
        If (Not Menu.LoadFolder(strFolder)) Then
        
            TRACE Replace(MTMAM_ERROR_01500, "[NAME]", strFolder), "MAM.Cls", "LoadMenu", LOG_ERROR
            Exit Function
        End If
        
        strFolder = MamDir() & "\custom\menu" ' 1 Load the default menu folder
        If (Not Menu.LoadFolder(strFolder)) Then

            TRACE Replace(MTMAM_ERROR_01500, "[NAME]", strFolder), "MAM.Cls", "LoadMenu", LOG_ERROR
            Exit Function
        End If
    End If
    LoadMenu = True

    Exit Function
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "LoadMenu", "MAM.cls", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get MamDir() As String

    On Error GoTo ErrMgr

    MamDir = m_strMamDir

    Exit Property
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "MamDir", "MAM.cls", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get MDMDir() As String

    On Error GoTo ErrMgr

    MDMDir = MamDir & "\asp"

    Exit Property
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "MDMDir", "MAM.cls", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get ConfigDir() As String

    On Error GoTo ErrMgr


    Dim objMSIXHandler As New MSIXHandler
    
    ConfigDir = objMSIXHandler.Tools.GetMTConfigDir()

    Exit Property
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "ConfigDir", "MAM.cls", LOG_ERROR
End Property


' -------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Log(ByVal strText As String, Optional ByVal lngLoginLevel As eLOG_TRACE_MODE = LOG_DEBUG) As Boolean

    On Error GoTo ErrMgr

    Log = TRACE("[MAM]" & strText, , , lngLoginLevel)

    Exit Function
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "Log", "MAM.cls", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    TRACE "MAM", "MAM.cls", "Class_Initialize", LOG_DEBUG
    Language = APP_START_LANGUAGE

    Exit Sub
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "Class_Initialize", "MAM.cls", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    CSR.Delete
    Subscriber.Delete
    TempAccount.Delete
    Set CSR = Nothing
    Set Subscriber = Nothing
    Set TempAccount = Nothing
    Set Menu.Dictionary = Nothing
    Set Menu = Nothing
    Set Cache = Nothing
    Set m_objFind = Nothing
    Set Tools.Cache = Nothing
    Set Tools = Nothing
    Set Dictionary = Nothing
    Set m_objSessionContext = Nothing
    
    TRACE "MAM", "MAM.cls", "Class_Terminate", LOG_DEBUG

    Exit Sub
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "Class_Terminate", "MAM.cls", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function TraceFindProperties(ByVal objFindProperties As MTACCOUNTLib.MTAccountPropertyCollection) As Boolean

    On Error GoTo ErrMgr


    Dim strS        As String
    Dim objProperty As MTACCOUNTLib.MTAccountProperty
     
    strS = "MAM FIND() "
    For Each objProperty In objFindProperties
        strS = strS & objProperty.Name & "=" & objProperty.Value & "; "
        
    Next
    Me.Log strS, LOG_DEBUG
    TraceFindProperties = True

    Exit Function
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "TraceFindProperties", "MAM.cls", LOG_ERROR
End Function


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Find
' PARAMETERS    : ByVal objFindProperties As MTACCOUNTLib.MTAccountPropertyCollection, ByRef varSubscriberFound As Variant, ByRef objMTSQLRowset As Variant
' DESCRIPTION   :
' RETURN        : TRUE or FALSE
Public Function Find(ByVal objFindProperties As MTACCOUNTLib.MTAccountPropertyCollection, ByRef varSubscriberFound As Variant, ByRef objMTSQLRowset As Variant, Optional lngMaxRow As Long = TOO_MANY_ACCOUNTS_DEFAULT_MAX_COUNT) As Boolean

    On Error GoTo ErrMgr
    
    Dim objFind                 As MTACCOUNTLib.MTAccountFinder
    Dim objResultProperties     As MTACCOUNTLib.MTSearchResultCollection
    Dim objCell                 As MTACCOUNTLib.MTAccountProperty
    Dim objRow                  As Variant
    Dim i                       As Long
    Dim lngMaxCol               As Long
    Dim strColName              As String
    Dim objProfiler             As New CProfiler
    Dim objProfiler2            As New CProfiler
        
    Set objFind = GetMTAccountFinderObject() ' get the current instance
    
    Set objMTSQLRowset = New MTSQLRowsetSimulator
    objFind.MaxRows = lngMaxRow

    varSubscriberFound = CLng(0)
    
    TraceFindProperties objFindProperties ' Log the find info
        
    objProfiler2.Start True, "MAM.cls", "FindDatabase"
    
    Set objResultProperties = objFind.Search(objFindProperties) ' Run the Find
        
    Set objProfiler2 = Nothing ' -- profiler info
    objProfiler.Start True, "MAM.cls", "Find"

    varSubscriberFound = objResultProperties.Count

    If (objResultProperties.Count) Then ' If we have data move the data from a collection of collection to a MTSQLRowset compatible object

        objMTSQLRowset.InitializeWithMSIXProperties Me.Subscriber, CLng(varSubscriberFound)     ' Initialize the rowset structure with the AccountCreation Property
        objMTSQLRowset.MoveFirst
        
        For Each objRow In objResultProperties
        
            i = 0
            For Each objCell In objRow
            
                strColName = UCase$(objCell.Name)
                If (Subscriber.Exist(strColName)) Then ' Check that the property exist in account creation service
                
                    objMTSQLRowset.Value(strColName) = objCell.Value ' Copy the property value into the rowset columns
                End If
                i = i + 1
            Next
            objMTSQLRowset.MoveNext
        Next
                
        objMTSQLRowset.MoveFirst ' -**-  LET US NOT FORGET TO RESET THE POINT AT THE BEGINING BEFORE WE RETURN THE ROWSET -**-
     
    End If
    
    Set objProfiler = Nothing ' -- profiler info
    
    'debug.print objMTSQLRowset.ToString(True, True)

    Log Replace(MTMAM_ERROR_01506, "[ROWS]", varSubscriberFound), LOG_DEBUG
    Find = UpdateRowsetValue(objMTSQLRowset)
    If (varSubscriberFound) Then
    
        Me.Log "FIND RESULT{" & vbNewLine & objMTSQLRowset.ToString(True, True) & vbNewLine & "}", LOG_DEBUG
    End If
    
    Exit Function
ErrMgr:
    If (Err.Number = TOO_MANY_ACCOUNTS) Then
            varSubscriberFound = -1
            Find = True
            objMTSQLRowset.Initialize 0, 0
            
            Exit Function
    End If
    TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "MAM.cls.cls", "Find", LOG_ERROR
End Function
  
' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function InitPropertiesObject(objProperties As MSIXProperties, eFlag As eMSIX_PROPERTIES_FLAG) As Boolean
 
    On Error GoTo ErrMgr


    objProperties.Flags = eFlag
    Set objProperties.Tools = Me.Tools
    objProperties.Language = Me.Language
    Set objProperties.Tools.Cache = Cache

    Exit Function
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "InitPropertiesObject", "MAM.cls", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Language() As String

    On Error GoTo ErrMgr

    Language = m_language

    Exit Property
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "Language", "MAM.cls", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Language(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    m_language = vNewValue

    Exit Property
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "Language", "MAM.cls", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function GetNewMTAccountPropertyCollection() As MTACCOUNTLib.MTAccountPropertyCollection

    On Error GoTo ErrMgr


    Set GetNewMTAccountPropertyCollection = New MTACCOUNTLib.MTAccountPropertyCollection

    Exit Function
ErrMgr:
        TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "GetNewMTAccountPropertyCollection", "MAM.cls", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function GetMTAccountFinderObject() As MTACCOUNTLib.MTAccountFinder

    'If (Not IsValidObject(m_objFind)) Then
    '    Set m_objFind = New MTACCOUNTLib.MTAccountFinder
    'End If
    
    ' Create a new each time for now
    Set m_objFind = New MTACCOUNTLib.MTAccountFinder
    Set GetMTAccountFinderObject = m_objFind
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : UpdateRowsetValue
' PARAMETERS    :
' DESCRIPTION   : Update the Find output rowset in the following way for every row:
'                 Enum type Language, DayOfWeek, StartMonth : Convert the enum type value into the enumerator name because the UI need it.
'                 For some other properties with oracle some long are returned as decimal so convert them into long!
'                 We use the CSR object to pull out information from account creation!
' RETURN        :
Private Function UpdateRowsetValue(objMTSQLRowset As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim i               As Long
    Dim strColName      As String
    
    
    objMTSQLRowset.MoveFirst
    Do While Not objMTSQLRowset.EOF
                                       
        For i = 0 To objMTSQLRowset.Count - 1
        
            strColName = UCase$(objMTSQLRowset.Name(i))
            Debug.Print strColName
            
            If (IsEmpty(objMTSQLRowset.Value(i))) Then
            
                Select Case strColName
                
                    Case "CONTACTTYPE"  ' If the subscriber/csr has no account type we set the property to NONE
                        objMTSQLRowset.Value(i) = CSR("CONTACTTYPE").EnumType.Entries("None").Value
                        
                End Select
            End If

            If (Not IsNull(objMTSQLRowset.Value(i))) And (Not IsEmpty(objMTSQLRowset.Value(i))) Then
            
                Select Case strColName
                
                    Case "LANGUAGE"  ' Replace the language enum type id with enum type name - because the app use the language as string us,cn. for different purpose...
                        objMTSQLRowset.Value(i) = CSR("Language").EnumType.Entries.ItemByValue(objMTSQLRowset.Value(i)).Name
                
                    Case "DAYOFWEEK"
                        objMTSQLRowset.Value(i) = CSR("DayOfWeek").EnumType.Entries.ItemByValue(objMTSQLRowset.Value(i)).Name
                        
                    Case "STARTMONTH"
                        objMTSQLRowset.Value(i) = CSR("StartMonth").EnumType.Entries.ItemByValue(objMTSQLRowset.Value(i)).Name
                        
                    Case "USAGECYCLETYPE"
                        objMTSQLRowset.Value(i) = CSR("usagecycletype").EnumType.Entries.ItemByValue(objMTSQLRowset.Value(i)).Name
                                                
                    Case "FIRSTDAYOFMONTH", "SECONDDAYOFMONTH", "STARTDAY", "STARTYEAR", "CONTACTTYPE", "ANCESTORACCOUNTID", "PAYERID"
                    
                        If (VarType(objMTSQLRowset.Value(i)) = vbDecimal) Then objMTSQLRowset.Value(i) = CLng(objMTSQLRowset.Value(i))
                End Select
            End If
        Next
        objMTSQLRowset.MoveNext
    Loop
    objMTSQLRowset.MoveFirst
    UpdateRowsetValue = True
    Exit Function
ErrMgr:
    TRACE MTMAM_ERROR_01505 & GetVBErrorString() & " Convertion name " & objMTSQLRowset.Name(i) & "=" & PrintableNULL(objMTSQLRowset.Value(i)), "UpdateRowsetValue", "MAM.cls", LOG_ERROR
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION          : mam_GetAccountCreationMsixdefFileName
' PARAMETERS        :
' DESCRIPTION   : Return the file name of the AccountCreation.msixdef file. By default the dictionary entry ACCOUNT_CREATION_MSIXDEF_FILE_NAME
'                 is empty so we will use metratech.com\AccountCreation.msixdef, which use the MSIXHandler+RCD object to retreive the metratech.com\AccountCreation.msixdef
'                 stored in core. If the entry is defined it implement a full path+ full name. The MSIXHandler will read then the file without using the RCD.
' RETURNS             :
Public Property Get AccountCreationMsixdefFileName() As String

        AccountCreationMsixdefFileName = "metratech.com\accountcreation.msixdef"
        
        If (Dictionary.Exist("ACCOUNT_CREATION_MSIXDEF_FILE_NAME")) Then
        
            If Len(Dictionary.Item("ACCOUNT_CREATION_MSIXDEF_FILE_NAME").Value) Then
            
                AccountCreationMsixdefFileName = Dictionary.Item("ACCOUNT_CREATION_MSIXDEF_FILE_NAME").Value
            End If
        End If
End Property



Public Function Find2(ByVal strUserName As String, ByVal lngAncestorID As Long, ByVal strDate As String, ByRef varSubscriberFound As Variant, ByRef objMTSQLRowset As Variant, Optional ByVal lngMaxRow As Long = TOO_MANY_ACCOUNTS_DEFAULT_MAX_COUNT) As Boolean

    On Error GoTo ErrMgr
    

'    Debug.Assert 0
    
    Dim r As MTSQLRowset, lngRecord  As Long
    Dim i As Long, strFieldName  As String, strEnumTypeValue As String, strDate2 As String
    Dim strSQL As String
    Dim objTextFile As New cTextFile
    
    Set objMTSQLRowset = New MTSQLRowsetSimulator
    
    varSubscriberFound = -1
    
    If Len(strDate) = 0 Then strDate = Now()
    
    strDate2 = Format(strDate, "dd-mmm-yy")
    
    ExecSQL "__TMP_LOOK_UP__", r, "USERNAME", strUserName, "ANCESTOR_ID", lngAncestorID, "DATE", strDate2
    
    If IsValidObject(r) Then
        
        varSubscriberFound = r.RecordCount
        
        objMTSQLRowset.InitializeWithMSIXProperties Me.Subscriber, CLng(varSubscriberFound)     ' Initialize the rowset structure with the AccountCreation Property
        
        For lngRecord = 1 To r.RecordCount
            
            For i = 0 To r.Count - 1
            
                strFieldName = r.Name(i)
                
                If InStr(UCase$(strFieldName), "C_") = 1 Then strFieldName = Mid(strFieldName, 3) ' remove the c_
                
                If (Subscriber.Exist(strFieldName)) Then ' Check that the property exist in account creation service
                    
                    If (Not IsNull(r.Value(i))) And (Not IsEmpty(r.Value(i))) Then
                         
                        If Subscriber.Item(strFieldName).PropertyType = "ENUM" Then
                        
                            If IsNumeric(r.Value(i)) Then
                                strEnumTypeValue = Subscriber.Tools.GetEnumTypeEnumeratorFromInternalDBID(r.Value(i))
                            Else
                                strEnumTypeValue = r.Value(i) ' AccountStatus
                            End If
                            
                            ' Get the enum type value
                            objMTSQLRowset.Value(strFieldName) = strEnumTypeValue
                            
                            ' for there property we need the enum type name
                            Select Case UCase$(strFieldName)
                                Case "LANGUAGE", "DAYOFWEEK", "STARTMONTH", "USAGECYCLETYPE"
                                    objMTSQLRowset.Value(strFieldName) = Subscriber(strFieldName).EnumType.Entries.ItemByValue(strEnumTypeValue).Name
                                    
                            End Select
                            
                            Debug.Print strFieldName & "=" & objMTSQLRowset.Value(strFieldName)
                            
                        Else
                        
                            objMTSQLRowset.Value(strFieldName) = r.Value(i)  ' Copy the property value into the rowset columns
                            Select Case UCase$(strFieldName)
                            
                                Case "FIRSTDAYOFMONTH", "SECONDDAYOFMONTH", "STARTDAY", "STARTYEAR"
                                
                                    If IsNumeric(objMTSQLRowset.Value(strFieldName)) Then ' Remove the decimal type
                                        objMTSQLRowset.Value(strFieldName) = CLng(objMTSQLRowset.Value(strFieldName))
                                    End If
                            End Select
                            
                            Debug.Print strFieldName & "=" & r.Value(i)
                            
                        End If
                     End If
                End If
            Next
            If Len(objMTSQLRowset.Value("CONTACTTYPE")) = 0 Then
        
                objMTSQLRowset.Value("CONTACTTYPE") = Subscriber("CONTACTTYPE").EnumType.Entries("None").Value
            End If
            objMTSQLRowset.MoveNext
        Next
        Find2 = True
    End If
    Exit Function
ErrMgr:
    'MsgBox GetVBErrorString
End Function


Private Function ExecSQL(ByVal strQueryTag As String, ByRef r As Variant, ParamArray SQLParam() As Variant) As Boolean

    On Error GoTo ErrMgr

    
    Dim i                       As Long
    Dim objMTSQLRowset As New MTSQLRowset
    
    objMTSQLRowset.Init "queries/mam/sql"
    
    objMTSQLRowset.SetQueryTag strQueryTag
    
    For i = 0 To UBound(SQLParam) Step 2
    
        objMTSQLRowset.AddParam "%%" & SQLParam(i) & "%%", "" & SQLParam(i + 1)
    Next
    
    objMTSQLRowset.Execute
    Set r = objMTSQLRowset
    ExecSQL = True

    Exit Function
ErrMgr:
  MsgBox GetVBErrorString
End Function



Public Function SQLExecute(ByVal strSQL) As MTSQLRowset

  Dim rs As New MTSQLRowset
  
  On Error GoTo ErrMgr
  
    
  rs.Init ("queries\database")
  Debug.Print strSQL
  rs.SetQueryString strSQL
  
  rs.Execute
  Set SQLExecute = rs
  Exit Function
ErrMgr:
  Set SQLExecute = Nothing
End Function

Public Function Find3(ByRef AccountCatalog As Variant, ByVal collColumns As Object, _
                        ByVal objFilter As Object, ByVal objJoinFilter As Object, _
                        ByVal strDate As String, ByRef varSubscriberFound As Variant, _
                        ByRef objMTSQLRowset As Variant, _
                        Optional ByVal lngMaxRow As Long, _
                        Optional ByRef transaction As Variant) As Boolean

    Dim moreRows        As Variant
    Dim objTmpRowSet    As MTSQLRowset
    
    
    On Error GoTo ErrMgr
    
    TraceFilter objFilter, "Filter"
    TraceFilter objJoinFilter, "JoinFilter"
    
    Set objTmpRowSet = AccountCatalog.FindAccountsAsRowset(strDate, collColumns, objFilter, objJoinFilter, Nothing, lngMaxRow, moreRows, transaction)
    varSubscriberFound = objTmpRowSet.RecordCount
    
    'If varSubscriberFound Then
    '    SetActiveSubscriberProperties objTmpRowSet
    'End If

    TRACE "MAM FIND FindAccountsAsRowset AccountFoundCounter " & varSubscriberFound
    Set objMTSQLRowset = CreateRowSetSimulator(objTmpRowSet)
    Find3 = True
    Exit Function
ErrMgr:
    If (Err.Number = TOO_MANY_ACCOUNTS) Then
            varSubscriberFound = -1
            Find3 = True
            objMTSQLRowset.Initialize 0, 0
            Exit Function
    End If
    TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "MAM.cls.cls", "Find", LOG_ERROR
End Function


Private Function CreateRowSetSimulator(r As MTSQLRowset) As MTMSIX.MTSQLRowsetSimulator

    Dim objMTSQLRowset  As New MTSQLRowsetSimulator
    Dim strFieldName    As String
    Dim lngRecord       As Long
    Dim i               As Long
    Dim varValue        As Variant
    
    On Error GoTo ErrMgr
    
    If IsValidObject(r) Then
    
        objMTSQLRowset.InitializeWithMSIXProperties Me.Subscriber, CLng(r.RecordCount)     ' Initialize the rowset structure with the AccountCreation Property
        If r.RecordCount Then
            If Subscriber.Exist("TimeZoneID") Then
              objMTSQLRowset.Value("TimeZoneID") = 18 ' Hack while the property is missing - when the property will be added by the back end the code can stay eventually
            End If
        End If
        
        For lngRecord = 1 To r.RecordCount
            
            For i = 0 To r.Count - 1
            
                strFieldName = r.Name(i)
                'Me.Log "Loading: " & strFieldName, LOG_DEBUG
                If (Subscriber.Exist(strFieldName)) Then ' Check that the property exist in account creation service
                    
                    varValue = r.Value(i)
                    'Me.Log "Value: " & varValue, LOG_DEBUG
                    If IsNull(varValue) Then varValue = Empty
                         
                    objMTSQLRowset.Value(strFieldName) = varValue  ' Copy the property value into the rowset columns
                    
                    Select Case UCase$(strFieldName)
                    
                        Case "FIRSTDAYOFMONTH", "SECONDDAYOFMONTH", "STARTDAY", "STARTYEAR"
                            If IsNumeric(objMTSQLRowset.Value(strFieldName)) Then objMTSQLRowset.Value(strFieldName) = CLng(objMTSQLRowset.Value(strFieldName)) ' Remove the decimal type
                            
                         Case "CONTACTTYPE"
                            On Error Resume Next
                            If Len(objMTSQLRowset.Value("CONTACTTYPE")) = 0 Then objMTSQLRowset.Value("CONTACTTYPE") = Subscriber("CONTACTTYPE").EnumType.Entries("None").Value
                            On Error GoTo 0
                    End Select
                    Debug.Print strFieldName & "=" & r.Value(i)
                Else
                    Debug.Print strFieldName & " not defined in accountcreation.msixdef"
                End If
            Next
            r.MoveNext
            objMTSQLRowset.MoveNext
        Next
        UpdateRowsetValue objMTSQLRowset
        
        If (r.RecordCount) Then
            Me.Log "MAM FIND Result " & vbNewLine & objMTSQLRowset.ToString(True), LOG_DEBUG
        End If
        objMTSQLRowset.MoveFirst
        Set CreateRowSetSimulator = objMTSQLRowset
    End If
    Exit Function
ErrMgr:
    TRACE MTMAM_ERROR_01505 & GetVBErrorString(), TypeName(Me), "CreateRowSetSimulator", LOG_ERROR
End Function

Private Function TraceFilter(objFilter As MTDataFilter, strText As String) As Boolean

    Dim i       As Long
    Dim strS    As String
    
    On Error GoTo ErrMgr
    
  '  strS = ""
  '  If IsValidObject(objFilter) Then
  '      For i = 0 To objFilter.Count - 1
  '
  '          strS = strS & objFilter.Item(i).FilterString & " and "
  '      Next
  '      strS = Mid(strS, 1, Len(strS) - 4)
  '  End If
  '  TRACE "MAM FIND " & strText & ":" & strS
    Exit Function
ErrMgr:
    TRACE MTMAM_ERROR_01505 & GetVBErrorString(), "MAM.cls.cls", "TraceFilter", LOG_ERROR
End Function

'''
''' Account Types
'''
Public Function SetActiveSubscriberProperties(ByVal rs As MTSQLRowset)
  On Error GoTo ErrMgr
  
    Me.Log "Setting SetActiveSubscriberProperties..."

  ' Load Subscriber object with AccountType properties
    If IsValidObject(Subscriber) Then
      Subscriber.Delete
      Set Subscriber = Nothing
    End If
    Set Subscriber = New MTMSIX.MSIXProperties
    InitPropertiesObject Subscriber, eMSIX_PROPERTIES_FLAG_SERVICE
    Subscriber.AddPropertiesFromRowset rs
    Subscriber.ReSetDefaults
    
    ' Load TempAccount object with AccountType properties
    If IsValidObject(TempAccount) Then
      TempAccount.Delete
      Set TempAccount = Nothing
    End If
    Set TempAccount = New MTMSIX.MSIXProperties
    InitPropertiesObject TempAccount, eMSIX_PROPERTIES_FLAG_SERVICE
    TempAccount.AddPropertiesFromRowset rs
    TempAccount.ReSetDefaults

    SetActiveSubscriberProperties = True
    Exit Function

ErrMgr:
    TRACE GetVBErrorString(), "MAM.cls", "SetActiveSubscriberProperties", LOG_ERROR

End Function

Public Function SetActiveCSRAccountType(ByVal strAccountType As String) As Boolean
  On Error GoTo ErrMgr
  
    Me.Log "Setting Active CSR Account Type [" & strAccountType & "]"
    
    ' Load CSR object with AccountType properties
    If IsValidObject(CSR) Then
      CSR.Delete
      Set CSR = Nothing
    End If
    Set CSR = New MTMSIX.MSIXProperties
    InitPropertiesObject CSR, eMSIX_PROPERTIES_FLAG_SERVICE
    If (Not CSR.LoadAccountType(strAccountType)) Then
        TRACE "Failed to load account type " & strAccountType, "MAM.cls", "SetActiveCSRAccountType", LOG_ERROR
    End If
    CSR.ReSetDefaults
    
    ' Load TempAccount object with AccountType properties
    If IsValidObject(TempAccount) Then
      TempAccount.Delete
      Set TempAccount = Nothing
    End If
    Set TempAccount = New MTMSIX.MSIXProperties
    InitPropertiesObject TempAccount, eMSIX_PROPERTIES_FLAG_SERVICE
    If (Not TempAccount.LoadAccountType(strAccountType)) Then
        TRACE "Failed to load account type " & strAccountType, "MAM.cls", "SetActiveCSRAccountType", LOG_ERROR
    End If
    TempAccount.ReSetDefaults

    SetActiveCSRAccountType = True
    Exit Function

ErrMgr:
    TRACE GetVBErrorString(), "MAM.cls", "SetActiveCSRAccountType", LOG_ERROR
End Function

Public Function SetActiveAccountType(ByVal strAccountType As String) As Boolean
  On Error GoTo ErrMgr
    
    Me.Log "Setting Active Account Type [" & strAccountType & "]"
    
    ' Load Subscriber object with AccountType properties
    If IsValidObject(Subscriber) Then
      Subscriber.Delete
      Set Subscriber = Nothing
    End If
    Set Subscriber = New MTMSIX.MSIXProperties
    InitPropertiesObject Subscriber, eMSIX_PROPERTIES_FLAG_SERVICE
    If (Not Subscriber.LoadAccountType(strAccountType)) Then
        TRACE "Failed to load account type " & strAccountType, "MAM.cls", "SetActiveAccountType", LOG_ERROR
    End If
    Subscriber.ReSetDefaults
    
    ' Load TempAccount object with AccountType properties
    If IsValidObject(TempAccount) Then
      TempAccount.Delete
      Set TempAccount = Nothing
    End If
    Set TempAccount = New MTMSIX.MSIXProperties
    InitPropertiesObject TempAccount, eMSIX_PROPERTIES_FLAG_SERVICE
    If (Not TempAccount.LoadAccountType(strAccountType)) Then
        TRACE "Failed to load account type " & strAccountType, "MAM.cls", "SetActiveAccountType", LOG_ERROR
    End If
    TempAccount.ReSetDefaults

    SetActiveAccountType = True
    Exit Function

ErrMgr:
    TRACE GetVBErrorString(), "MAM.cls", "SetActiveAccountType", LOG_ERROR
End Function

Public Function SetActiveTempAccountType(ByVal strAccountType As String) As Boolean
  On Error GoTo ErrMgr
    
    Me.Log "Setting Active Temp Account Type [" & strAccountType & "]"
    
    ' Load TempAccount object with AccountType properties
    If IsValidObject(TempAccount) Then
      TempAccount.Delete
      Set TempAccount = Nothing
    End If
    Set TempAccount = New MTMSIX.MSIXProperties
    InitPropertiesObject TempAccount, eMSIX_PROPERTIES_FLAG_SERVICE
    If (Not TempAccount.LoadAccountType(strAccountType)) Then
        TRACE "Failed to load account type " & strAccountType, "MAM.cls", "SetActiveTempAccountType", LOG_ERROR
    End If
    TempAccount.ReSetDefaults

    SetActiveTempAccountType = True
    Exit Function

ErrMgr:
    TRACE GetVBErrorString(), "MAM.cls", "SetActiveTempAccountType", LOG_ERROR
End Function


Public Function GetAccountTypeMsixdef(ByVal strAccountType As String, ByVal strOperation As String) As String
  On Error GoTo ErrMgr
  Dim objAccountType As New AccountType
  objAccountType.InitializeByName strAccountType
  
  Dim objRowSet As MTSQLRowset
  Set objRowSet = objAccountType.GetServiceDefinitionsAsRowset()
  Do While Not objRowSet.EOF

    ' Match operation
    If InStr(UCase$(objRowSet.Value("Operation")), UCase$(strOperation)) > 0 Then
      GetAccountTypeMsixdef = objRowSet.Value("ServiceDefinition")
      Me.Log "Using msixdef [" & GetAccountTypeMsixdef & "] for [" & objRowSet.Value("Operation") & "] for account type [" & strAccountType & "]"
      Exit Function
    End If
    
    objRowSet.MoveNext
  Loop
  Exit Function
    
ErrMgr:
    TRACE GetVBErrorString(), "MAM.cls", "GetAccountTypeMsixdef", LOG_ERROR
End Function

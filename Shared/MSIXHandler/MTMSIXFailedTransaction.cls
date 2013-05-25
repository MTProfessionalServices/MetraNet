VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXFailedTransaction"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'****************************************************************************************************************************************************
Option Explicit
Public TRACE_ID As Long

Public Enum MT_METERED_TRANSACTION_TYPE

    MT_METERED_TRANSACTION_TYPE_ERROR = 1
    MT_METERED_TRANSACTION_TYPE_PARENT = 2
    MT_METERED_TRANSACTION_TYPE_CHILD = 4
    MT_METERED_TRANSACTION_TYPE_ATOMIC = 8
End Enum
    
Public Enum MT_METERED_TRANSACTION_PROPERTY_TYPE

    SESSION_PROPERTY_TYPE_DATE = 1     ' In a metered session the type have an index, this index is not the VT_XXXX index...
    SESSION_PROPERTY_TYPE_TIME = 2
    SESSION_PROPERTY_TYPE_STRING = 3
    SESSION_PROPERTY_TYPE_LONG = 4
    SESSION_PROPERTY_TYPE_DOUBLE = 5
    SESSION_PROPERTY_TYPE_BOOLEAN = 6
    SESSION_PROPERTY_TYPE_ENUM = 7
    SESSION_PROPERTY_TYPE_DECIMAL = 8
End Enum

'  Properties
Public SessionId    As String
Public ErrorId      As String ' The error id is used only to delete a transaction. So some MeteredTransaction error id are ""
                              ' because we do not have it when we load the transaction, TRUE when we load child transaction...
Public Service      As String
Public Properties   As New CVariables
Public ObjectName   As String

' Internal properties
Public Id                   As Variant
Public Index                As Long
Public Parent               As MSIXFailedTransaction
Public Children             As MSIXFailedTransactions
Public TransactionType      As MT_METERED_TRANSACTION_TYPE

Private m_IntervalId        As Long
Private m_objSession        As IMTSession
Private m_objInitPipeLine   As MTPipeline ' This pipeline is used to load the transaction data and cannot be release until
                                          ' we have finished with transaction itself else the m_objSession become invalid...
Private m_objIMTSessionServer As IMTSessionServer



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Initialize
' DESCRIPTION   : Constructor
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Initialize()

    ' We Initialize the child collection parent though we do not know
    ' yet if this transaction is a parent transaction...
    Set Children = New MSIXFailedTransactions
    'Set Children.Parent = Me
    TransactionType = MT_METERED_TRANSACTION_TYPE_ERROR
    ObjectName = "EditedFailedTransaction" ' Default Object Name
    
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : Destructor
Private Sub Class_Terminate()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
End Sub



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PropertiesString
' DESCRIPTION   : Not used
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Property Get PopertiesString() As String
    'PropertiesString = PropertiesString & "SessionId=0;"
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString
' DESCRIPTION   : Returns the Transaction value in a string format, including the children
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Property Get ToString() As Variant

    ToString = ToString & "SessionId=" & SessionId & ";" & vbCrLf
    ToString = ToString & "Service=" & Service & ";" & vbCrLf
    ToString = ToString & "Properties:" & vbCrLf
    ToString = ToString & Properties.ToString() & vbCrLf
    
    Dim objChildTransaction As MSIXFailedTransaction
    
    For Each objChildTransaction In Children
    
        ToString = ToString & objChildTransaction.ToString() & vbCrLf
    Next
End Property



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsParent
' DESCRIPTION   : Return TRUE if the transaction is a parent transaction
' PARAMETERS    :
' RETURNS       : TRUE/FALSE
Public Function IsParent() As Boolean

    IsParent = CBool((TransactionType And MT_METERED_TRANSACTION_TYPE_PARENT) = MT_METERED_TRANSACTION_TYPE_PARENT)
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsChild
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE/FALSE
Public Function IsChild() As Boolean

    IsChild = CBool((TransactionType And MT_METERED_TRANSACTION_TYPE_CHILD) = MT_METERED_TRANSACTION_TYPE_CHILD)
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsAtomic
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE/FALSE
Public Function IsAtomic() As Boolean

    IsAtomic = CBool((TransactionType And MT_METERED_TRANSACTION_TYPE_ATOMIC) = MT_METERED_TRANSACTION_TYPE_ATOMIC)
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Meter
' DESCRIPTION   : Meter the transaction.
'                   Support metering atomic, parent and child transaction. In the case of parent the parent and the children
'                   transactions are metered. In the case of a child transaction, the parent and its child are metered...
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Function Meter(Optional booSynchronously As Boolean = False, Optional ByVal objMOMUserSessionContext As Object) As Boolean
    
    On Error GoTo ErrMgr
    
    Dim booRetVal           As Boolean
    Dim objError            As New CError
    
'    'Debug.Assert 0
    
    Meter = False
    
    TRACE "About to meter Failed Transaction SessionID=" & SessionId & " ErrorID=" & ErrorId, "MSIXFailedTransaction.cls", "Meter"
    
    Select Case TransactionType
    
        Case MT_METERED_TRANSACTION_TYPE_ATOMIC
            booRetVal = MeterTheTransactionOnly(booSynchronously, GetUserSessionContext(objMOMUserSessionContext))
            
        Case MT_METERED_TRANSACTION_TYPE_CHILD
            booRetVal = Parent.Meter(booSynchronously, objMOMUserSessionContext)
            
        Case MT_METERED_TRANSACTION_TYPE_PARENT
            booRetVal = MeterTheTransactionOnly(booSynchronously, GetUserSessionContext(objMOMUserSessionContext))
            
    End Select
    
    TRACE "   Meter SUCCEED=" & booRetVal

    
    Meter = booRetVal
    Exit Function
ErrMgr:
    TRACE " Meter FAILED ", "MSIXFailedTransaction.cls", "Meter"
'    'Debug.Assert 0
    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "Meter", , LOG_ERROR
    TRACE objError.ToString
    
    
    objError.Raise
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : MeterTheTransactionOnly
' DESCRIPTION   : This function meter only ATOMIC and PARENT transaction. A Child transaction is always remetered through its
'                 parent.
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Friend Function MeterTheTransactionOnly(Optional booSynchronously As Boolean = False, Optional objMOMUserSessionContext As Object) As Boolean
    
    On Error GoTo ErrMgr

    Dim lngRetCode                  As Long
    
    Dim objVar                      As New CVariable
    Dim objChildTransaction         As MSIXFailedTransaction
    Dim objError                    As New CError
    Dim m_PipeLine                  As CPipeLineAccess
    
    
    Set m_PipeLine = New MTMSIX.CPipeLineAccess
        
    ' Init the instance properties
    m_PipeLine.ObjectName = ObjectName
    m_PipeLine.Session = Service
    m_PipeLine.RequestResponse = booSynchronously
    
    m_PipeLine.InitializeMetering objMOMUserSessionContext
    
    ' Set the Metered property - in the case of a parent/child this are the parent property
    ' And they are only stored in a temporary CVariables object and not add to the input session object
    For Each objVar In Properties
    
        m_PipeLine.Property(objVar.Name) = objVar.Value
    Next
        
    For Each objChildTransaction In Me.Children ' Add a Child Session and fill it with every transaction child
    
        m_PipeLine.CreateChildSession objChildTransaction.Service, objChildTransaction.Properties
    Next
    
    Dim REAL_SAFE_TRANSACTION As Boolean
    REAL_SAFE_TRANSACTION = True
'    'Debug.Assert 0
    ' Meter the all thing
    MeterTheTransactionOnly = m_PipeLine.Meter(m_PipeLine.RequestResponse, objMOMUserSessionContext, , REAL_SAFE_TRANSACTION, Me.SessionId)
Exit Function
ErrMgr:

    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "MeterTheTransactionOnly", , LOG_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

' --------------------------------------------------------------------------------------------------------
' FUNCTION      : Initialize
' DESCRIPTION   : Case 1 - Atomic Transaction
'                   Load the transaction and return the instance.
'                 Case 2 - Compound Transaction, the transaction is the parent.
'                   Load the parent transaction, and load the children transaction in the
'                   collection Children and returns the parent instance.
'                 Case 3 - Compound Transaction, the transaction is one child.
'                   Find the Parent Session Id from the child session Id and load the
'                   Parent transaction and its child. Then Returns the child instance asked.
'
' RETURNS       : Return the metered transaction instance asked.
 Public Function Initialize(ByVal strSessionId As String, ByVal strParentSessionId As String, ByVal strErrorId As String, ByVal lngIntervalId As Long) As MSIXFailedTransaction
    
    On Error GoTo ErrMgr
    
    Dim objParentTransaction    As MSIXFailedTransaction
    Dim objRetTransaction       As MSIXFailedTransaction
    Dim objError                As New CError
    Dim strErrorMessage         As String
    
    'Debug.Assert 0
    
    Properties.Clear
    ErrorId = strErrorId
    m_IntervalId = lngIntervalId
    
    Set m_objInitPipeLine = New PIPELINECONTROLLib.MTPipeline
    
    Me.SessionId = strSessionId
            
    If (strSessionId = strParentSessionId) Then ' Here it can be a atomic or a parent transaction
    
        Set m_objSession = GetFailedSession(strSessionId)
        Service = GetServiceNameFromServiceId(m_objSession.ServiceID)
        
        If (m_objSession.IsParent()) Then
        
            TransactionType = MT_METERED_TRANSACTION_TYPE_PARENT
            If (InitPropertiesFromSession()) Then
            
                LoadChildren
                Set objRetTransaction = Me
            End If
        Else
            TransactionType = MT_METERED_TRANSACTION_TYPE_ATOMIC
            If (InitPropertiesFromSession()) Then
            
                Set objRetTransaction = Me
            End If
        End If
    Else
        ' Here it is a child transaction
        Set objParentTransaction = New MSIXFailedTransaction     ' Alloc a parent instance
        Set objParentTransaction = objParentTransaction.Initialize(strParentSessionId, strParentSessionId, "", m_IntervalId) ' Here the error id is set to ""
        
        ' Returns the instance required from the children collection of the parent
        ' At this moment the parent instance is only referenced by its children...
        Set objRetTransaction = objParentTransaction.Children.Item(strSessionId)
        
        objRetTransaction.ErrorId = strErrorId ' Set the error id - see error id declaration
        
        strErrorMessage = "Load the parent was ok but the child searched was not found!"
        Set objRetTransaction = objParentTransaction.Children.Item(strSessionId)
    End If
    
    ' Trace the transaction just loaded
    If (Not objRetTransaction Is Nothing) Then
    
        TRACE objRetTransaction.ToString, "MSIXFailedTransaction.cls", "Initialize"
    End If
    Set Initialize = objRetTransaction
    
    ' Just do that so I can debug it
    Set objParentTransaction = Nothing
    Set objRetTransaction = Nothing
'    'Debug.Assert 0
    Exit Function
ErrMgr:
'    'Debug.Assert 0
    objError.Save Err.Number, Err.Description, Err.Source, "SessionId=" & SessionId & "; SessionParentId=" & strParentSessionId & "; ErrorId=" & ErrorId & "; ErrorMessage=" & strErrorMessage & ";", "MSIXFailedTransaction.cls", "Initialize", , LOG_ERROR
    TRACE objError.ToString, "MSIXFailedTransaction.cls", "Initialize"
    objError.Raise
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Friend Function InitPropertiesFromSession() As Boolean

    On Error GoTo ErrMgr
    
    Dim objProperty         As Variant
    Dim strPropertyName     As String
    Dim strError            As String
    Dim objError            As New CError
    Dim objMSIXTools        As New MSIXTools
    
    Properties.Clear
    
    For Each objProperty In m_objSession
        
        strPropertyName = objProperty.Name
        
        If (Len(strPropertyName)) Then
        
            ' -- derek removed will remove this property for me  -- If (Mid(strPropertyName, 1, 1) <> "_") Or (UCase(strPropertyName) = "_ACCOUNTID") Then ' We do not reload the reserved property
            If True Then
        
                Select Case objProperty.Type
                
                    Case SESSION_PROPERTY_TYPE_DATE, SESSION_PROPERTY_TYPE_TIME
                        Properties.Add strPropertyName, m_objSession.GetOLEDateProperty(objProperty.NameID), vbDate
                        
                    Case SESSION_PROPERTY_TYPE_STRING
                        Properties.Add strPropertyName, m_objSession.GetBSTRProperty(objProperty.NameID), vbString
                            
                    Case SESSION_PROPERTY_TYPE_LONG
                        Properties.Add strPropertyName, m_objSession.GetLongProperty(objProperty.NameID), vbLong
            
                    Case SESSION_PROPERTY_TYPE_DOUBLE
                        Properties.Add strPropertyName, m_objSession.GetDoubleProperty(objProperty.NameID), vbDouble
                            
                    Case SESSION_PROPERTY_TYPE_BOOLEAN
                        Properties.Add strPropertyName, m_objSession.GetBoolProperty(objProperty.NameID), vbBoolean
                        
                    Case SESSION_PROPERTY_TYPE_DECIMAL
                        Properties.Add strPropertyName, m_objSession.GetDecimalProperty(objProperty.NameID), vbDecimal
                        
                    Case SESSION_PROPERTY_TYPE_ENUM
                        ' In the case of a enum type convert the enum type internal db id into a
                        Properties.Add strPropertyName, objMSIXTools.GetEnumValueByID(CLng(m_objSession.GetEnumProperty(objProperty.NameID))), vbString, , , MSIXDEF_TYPE_ENUM
                        
                    Case Else ' Just in case
                        strError = MTMSIX_ERROR_01077
                        strError = Replace(strError, "[PROPERTY_NAME]", strPropertyName)
                        strError = Replace(strError, "[PROPERTY_LONG_TYPE]", objProperty.Type)
                        TRACE strError, "MSIXFailedTransaction.cls", "InitPropertiesFromSession", LOG_ERROR
                        Exit Function
                End Select
            End If
        End If
    Next
    TRACE "Load Transaction " & Properties.ToString(), "MSIXFailedTransaction.cls", "InitPropertiesFromSession"
    InitPropertiesFromSession = True
    Exit Function
ErrMgr:

'    'Debug.Assert 0

    objError.Save Err.Number, Err.Description, Err.Source
    TRACE objError.ToString, "MSIXFailedTransaction.cls", "InitPropertiesFromSession"
    objError.Raise
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Function Delete() As Boolean

    On Error GoTo ErrMgr
    
    Dim mobjFailures  As Object
    Dim objError      As New CError
        
    TRACE "About to Delete Failed Transaction SessionID=" & SessionId & " ErrorID=" & ErrorId, "MSIXFailedTransaction.cls", "Delete"
    
    Set mobjFailures = CreateObject("MetraPipeline.MTSessionFailures.1")
    
    If (IsChild) Then
        ' In the case of the child the transaction stocked in the queue is the parent transaction
        mobjFailures.AbandonSession Parent.SessionId
    Else
        mobjFailures.AbandonSession SessionId
    End If

    ' We do not need to do this the AbandonSession will do it

    ' ErrorID is the database session id, sessionId is the UID!
    'If (SetTransactionDataBaseFlag("D", m_IntervalId, CLng(ErrorId))) Then
    '    TRACE "Error Delete SUCCEED SessionId="
    '    Delete = True
    'End If
    Delete = True
    Exit Function
ErrMgr:
    TRACE "   Delete FAILED"
'    'Debug.Assert 0
    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "Delete", , LOG_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   : FUNCTION NOT USED
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Private Function SetTransactionDataBaseFlag(ByVal strNewStateValue As String, ByVal lngIntervalId As Long, ByVal lngSessionId As Long) As Boolean
'
'    On Error GoTo ErrMgr
'
'    Dim objNewRowset        As New MTSQLRowset
'    Dim objSqlRowSet        As New MTSQLRowset
'    Dim objError            As New CError
'
'    Const DB_TABLESUFFIX = "TableSuffix"
'    Const MTPARAM_TABLESUFFIX = "%%TABLE_SUFFIX%%"
'    Const MTPARAM_SESSIONID = "%%SESSION_ID%%"
'    Const MTPARAM_STATE = "%%STATE%%"
'
'    ' Query 1 - get the bucket id from the interval id
'    objNewRowset.Init QueriesFolder
'    objNewRowset.SetQueryTag "__GET_BUCKETID_FROM_INTERVALID__"
'    objNewRowset.AddParam "%%INTERVAL_ID%%", lngIntervalId
'    objNewRowset.Execute
'
'    ' Query 2 update the t_pv_error_[bucket it]  table
'    objSqlRowSet.Init QueriesFolder
'    objSqlRowSet.SetQueryTag "__UPDATE_SYSTEM_FAILURES__"
'    objSqlRowSet.AddParam MTPARAM_TABLESUFFIX, CStr(objNewRowset.Value("BucketId"))
'    objSqlRowSet.AddParam MTPARAM_SESSIONID, CLng(lngSessionId)
'    objSqlRowSet.AddParam MTPARAM_STATE, CStr(strNewStateValue)
'    objSqlRowSet.Execute
'
'    SetTransactionDataBaseFlag = True
'    Exit Function
'
'ErrMgr:
'    'Debug.Assert 0
'    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "SetTransactionDataBaseFlag", , LOG_ERROR
'    TRACE objError.ToString
'    objError.Raise
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Private Function LoadChildren() As Boolean

    On Error GoTo ErrMgr
    
    Dim strChildSessionID   As String
    Dim objChildTransaction As MSIXFailedTransaction
    Dim objChildSession     As Object
    Dim objError            As New CError
    Dim lngMaxChildren      As Long
    Dim lngChildrenIndex    As Long
    
    Children.Clear
    
    lngMaxChildren = m_objSession.SessionChildren.Count
    
    For Each objChildSession In m_objSession.SessionChildren
        
        lngChildrenIndex = lngChildrenIndex + 1
    
        strChildSessionID = objChildSession.UIDAsString
        
        ' Here we directly initialize the child session
        Set objChildTransaction = New MSIXFailedTransaction ' Alloc
         
        objChildTransaction.TransactionType = MT_METERED_TRANSACTION_TYPE_CHILD ' Set VB Instance properties
        objChildTransaction.Service = GetServiceNameFromServiceId(objChildSession.ServiceID)
        Set objChildTransaction.Parent = Me
        objChildTransaction.SessionId = strChildSessionID
        Set objChildTransaction.Session = objChildSession
        
        objChildTransaction.InitPropertiesFromSession ' Load the Transaction Properties
        
        Children.Add objChildTransaction, strChildSessionID
    Next
    LoadChildren = True
    Exit Function
ErrMgr:
'    'Debug.Assert 0
    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "LoadChildren", , LOG_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Friend Property Get Session() As IMTSession
    Set Session = m_objSession
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Friend Property Set Session(ByVal vNewValue As IMTSession)
    Set m_objSession = vNewValue
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Private Function GetServiceNameFromServiceId(lngServiceId As Long) As String

    On Error GoTo ErrMgr
    
    Dim objLookUp  As Object
    Dim objError   As New CError
    
    Set objLookUp = CreateObject("MetraPipeline.MTNameID.1")
    GetServiceNameFromServiceId = objLookUp.GetName(lngServiceId)
    Exit Function
ErrMgr:
'    'Debug.Assert 0
    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "GetServiceNameFromServiceId", , LOG_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   : in MDM 3.0 we use real transaction to delete and resubmit trans!
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Function ReMeter(Optional booSynchronously As Boolean = False, Optional ByVal objMOMUserSessionContext As Object) As Boolean

'    On Error GoTo ErrMgr
'
'    Dim objError   As New CError
'
'    ''Debug.Assert 0
'
'    TRACE "About to Remeter Failed Transaction SessionID=" & SessionId & " ErrorID=" & ErrorId, "MSIXFailedTransaction.cls", "ReMeter"
'    If (Delete()) Then
'
'        ReMeter = Meter(booSynchronously, objMOMUserSessionContext)
'    End If
'    Me.Clean ' -- V2.2 -- we must clean the transaction due to the circular ref with parent/children
'
'    Exit Function
'ErrMgr:
'    TRACE "   ReMeter FAILED"
'    'Debug.Assert 0
'    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "ReMeter", , LOG_ERROR
'    TRACE objError.ToString
'
'    Me.Clean ' -- V2.2 -- we must clean the transaction due to the circular ref with parent/children
'
'    objError.Raise
    
    
 '
 ' Fix patch for 2.0 , 2.1,
 ' 2.2 was not patched
 '
 
 On Error GoTo ErrMgr
    
    Dim objError   As New CError
    Dim booOK      As Boolean
    
    'Debug.Assert 0
    
    '
    ' In 3.0 we support safe edit/resubmit fail transaction but only async
    '
    booSynchronously = False
    
    TRACE "About to Remeter Failed Transaction SessionID=" & SessionId & " ErrorID=" & ErrorId, TypeName(Me), "ReMeter", LOG_INFO
    
    On Error Resume Next
    booOK = Meter(booSynchronously, objMOMUserSessionContext)
    
    If Err.Number Then
    
        objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "ReMeter", , LOG_ERROR
        TRACE objError.ToString
        
        objError.Description = "Error in the ReMetering the transaction sessionid " & SessionId & " will not be deleted " & SessionId
        TRACE objError.Description, TypeName(Me), "Remeter", LOG_ERROR
        
        On Error GoTo 0
        GoTo CleanAndRaiseError
    Else
        ReMeter = True
    End If
    
TheExit:
    Me.Clean ' -- V2.2 -- we must clean the transaction due to the circular ref with parent/children
    Exit Function
    
CleanAndRaiseError:
    On Error GoTo 0
    Me.Clean ' -- V2.2 -- we must clean the transaction due to the circular ref with parent/children
    objError.Raise
    Exit Function
    
ErrMgr:
    'Debug.Assert 0
    objError.Save Err.Number, Err.Description, Err.Source, , TypeName(Me), "ReMeter", , LOG_ERROR
    TRACE objError.ToString
    GoTo TheExit
    objError.Raise
End Function
'
'Public Property Get QueriesFolder() As String
'    QueriesFolder = m_QueriesFolder
'End Property
'
'Public Property Let QueriesFolder(ByVal vNewValue As String)
'    m_QueriesFolder = vNewValue
'End Property


Public Function GetFailedSession(strUID As String) As IMTSession

   Dim objSessionError
   Dim objSessionFailure As MTSessionFailures
   
   Set GetFailedSession = Nothing    ' Default return value
   
   ' -- These 1 instance need to be created to deal with session --
   Set m_objIMTSessionServer = m_objInitPipeLine.SessionServer
   Set objSessionFailure = New MTSessionFailures
  
   Set objSessionError = objSessionFailure.Item(strUID)
   Set GetFailedSession = objSessionError.Session
   If (Err.Number) Then
    
      TRACE "Cannot retreive the failed session (""" & strUID & """). error=" & GetVBErrorString(), "MSIXFailedTransaction", "GetFailedSession", LOG_ERROR
      Exit Function
  End If
End Function

Public Function Clean() As Boolean

    On Error GoTo ErrMgr

    Dim objError As New CError
    
    If IsAtomic() Then
    
        Clean = CleanCurrentTransaction()
    Else
    
        If Me.IsChild Then
        
            Clean = Me.Parent.Clean()
        Else

            If IsValidObject(Children) Then
            
                If Children.Count Then
            
                    Children.Clean
                    Children.Clear
                End If
            End If
            CleanCurrentTransaction
        End If
    End If
    Exit Function
ErrMgr:
    TRACE "Clean FAILED"
    objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "Clean", , LOG_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

Friend Function CleanCurrentTransaction() As Boolean

    ' The session must be deleted before the pipline
    Set m_objSession = Nothing
    Set m_objInitPipeLine = Nothing
    Set Children = Nothing
    CleanCurrentTransaction = True
End Function

Private Function GetUserSessionContext(Optional ByVal objMOMUserSessionContext As Object) As Object

    On Error GoTo ErrMgr

    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    Dim suName                  As String
    Dim suPassword              As String
    Dim lngAccountID            As Long
    Dim objOldContext           As Object
    Dim objLogin                As Object
    Dim objAccessInfo           As Object
    Dim objSessionContext       As Object
    Dim objNewSessionContext    As Object
    Dim objError                As New CError
        
        'Debug.Assert 0
    Set GetUserSessionContext = objMOMUserSessionContext ' set the context on the session to resubmit
    Exit Function
ErrMgr:
        objError.Save Err.Number, Err.Description, Err.Source, , "MSIXFailedTransaction.cls", "GetUserSessionContext", , LOG_ERROR
        TRACE (objError.ToString)
        objError.Raise
End Function

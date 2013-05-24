VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SubscriberAcctHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  AUTHOR       : Frederic Torres
'  DATE         : 4/xx/00
'  DESCRIPTION  :
'
'***************************************************************************
Option Explicit

Private m_SubscriberAccounts            As New SubscriberAccts
Private m_AccountId                     As Long
Private mstrAccountCreationService      As String


Private m_LoginName
'Private m_objTariffs                    As MTTariffCollection

'Const SQL_SELECT_GET_TARIFF_NAME_FROM_SUBSCRIBER_ACCOUNT_ID = "select t_tariff.id_tariff,t_tariff.nm_tariff,t_account.id_payment_method from t_account,t_tariff where t_account.id_tariff=t_tariff.id_tariff and  id_acc=<ACCOUNT_ID>"
Const SQL_SELECT_GET_TARIFF_NAME_FROM_SUBSCRIBER_ACCOUNT_ID = "select t_enum_data.nm_enum_data nm_tariff from t_av_internal, t_enum_data where t_av_internal.id_acc=<ACCOUNT_ID> and t_av_internal.c_tariffID = t_enum_data.id_enum_data"
Const SQL_SELECT_GET_LANGUAGE_FROM_SUBSCRIBER_ACCOUNT_ID = "select t_localized_site.tx_lang_code from t_account_mapper,t_site_user,t_localized_site where t_account_mapper.id_acc=<ACCOUNT_ID> and t_account_mapper.nm_login=t_site_user.nm_login and t_site_user.id_site=t_localized_site.id_site"
Const SQL_SELECT_GET_PAYMENTMETHOD_FROM_SUBSCRIBER_ACCOUNT_ID = "select c_paymentmethod from t_av_internal where t_av_internal.id_acc=<ACCOUNT_ID>"

'Const SQL_SELECT_GET_CURRENCY_FROM_SUBSCRIBER_ACCOUNT_ID = "select tx_currency  from t_av_internal, t_tariff where t_av_internal.id_acc=<ACCOUNT_ID> and t_tariff.id_enum_tariff=t_av_internal.c_tariffID "
' MPS 2.0
Const SQL_SELECT_GET_CURRENCY_FROM_SUBSCRIBER_ACCOUNT_ID = "select c_currency from t_av_internal where id_acc=<ACCOUNT_ID>"


'Error message returned by account adapter if the account can't be found, which occurs
'when there is no contact information.  This value comes from mtglobal_msg.h
Const ERROR_ACCOUNT_NOT_FOUND = -509673469

Const ERROR_MESSAGE_001 = "Can't find the tariff for the account <ACCOUNT_ID>."
Const ERROR_MESSAGE_002 = "Can't find the language for the account <ACCOUNT_ID>."

Public Enum eSUBSCRIBER_ACCOUNT_OPERATION

    eSUBSCRIBER_ACCOUNT_OPERATION_ADD = 0
    eSUBSCRIBER_ACCOUNT_OPERATION_UPDATE = 1
    eSUBSCRIBER_ACCOUNT_OPERATION_DELETE = 2
End Enum

Public Enum eSUBSCRIBER_PAYMENT_METHOD

    eSUBSCRIBER_PAYMENT_METHOD_NONE = 1
    eSUBSCRIBER_PAYMENT_METHOD_CREDIT_CARD = 2
End Enum



' --------------------------------------------------------------------------------
' FUNCTION      : Initialize()
' DESCRIPTION   : Load the Credit Card Info(s)  in the collection CreditCardInfos.
' PARAMETERS    :
'                   lngAccountId - The Account Id
' RETURNS       :   Return -1 if there is an error. and raise error too.
'
Public Function Initialize(ByVal lngAccountId As Long, ByVal bBillable As Boolean, ByVal strUserName As String) As Long

    On Error GoTo ErrMgr
    
    Dim objError            As New CError
    Dim objSubscriberAcct   As SubscriberAcct
    Dim objProperty         As Variant
    Dim objProperties       As IMTAccountPropertyCollection
    Dim objFirstResult      As MTSearchResultCollection
    Dim objAdapter          As New MTAccountServer
    Dim acc_prop_coll       As New MTAccountPropertyCollection
    Dim objTools            As Object
    
    m_AccountId = lngAccountId
    Initialize = 0  ' Default Return Value

    objAdapter.Initialize "LDAP"
    
    Set objTools = CreateObject("MTMSIX.MSIXTools")
    
    acc_prop_coll.Add "c_contacttype", objTools.GetEnumIDFromValue("metratech.com/accountcreation", "contacttype", "Bill-To")
    acc_prop_coll.Add "id_acc", m_AccountId
           
    'Fix for CR: 9885 -- Eliminate the spurious warning
    On Error Resume Next
    Set objFirstResult = objAdapter.SearchData(CStr("LDAP"), acc_prop_coll)
    
    If Err Then
      If Err.Number = ERROR_ACCOUNT_NOT_FOUND Then
        Exit Function
      End If
      Call Err.Clear
    End If
    
    On Error GoTo 0
    
    If Not objFirstResult Is Nothing Then
      If (objFirstResult.Count = 1) Then
        Set objProperties = objFirstResult.Item(1)
        
        SubscriberAccounts.Clear
        
        Set objSubscriberAcct = Me.SubscriberAccounts.Add()
         
        For Each objProperty In objProperties
          On Error Resume Next
          Err.Clear
          Debug.Print objProperty.Name & "=" & objProperty.Value & ";"
          objSubscriberAcct.Property(objProperty.Name) = objProperty.Value
          Err.Clear
          On Error GoTo 0
        Next
        
        objSubscriberAcct.Property("AccountId") = lngAccountId
        objSubscriberAcct.Property("username") = strUserName
         
        'Fix for CR: Billable property should be true or false instead of Y or N
        If bBillable Then
          objSubscriberAcct.Property("billable") = True
        Else
          objSubscriberAcct.Property("billable") = False
        End If
         
        objSubscriberAcct.UpdateStuff
         
        Initialize = objProperties.Count
      End If
    End If
    Exit Function
ErrMgr:
    objError.Save , "CSubscriberAcctHandler.cls", "Initialize"
    LogError , , objError.ToString
    objError.Raise
    
End Function



Public Property Get AccountCreationService() As String
  Let AccountCreationService = mstrAccountCreationService
End Property

Public Property Let AccountCreationService(ByVal strVal As String)
  Let mstrAccountCreationService = strVal
End Property

' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Property Get SubscriberAccounts() As SubscriberAccts

    Set SubscriberAccounts = m_SubscriberAccounts
End Property

' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Sub Add(ByVal objSubscriberAcct As SubscriberAcct)
    
    On Error GoTo ErrMgr
    Exit Sub
ErrMgr:
    Debug.Assert 0
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub


' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Sub Delete(ByVal objSubscriberAcct As SubscriberAcct)
    
    On Error GoTo ErrMgr
    Exit Sub
ErrMgr:
    Debug.Assert 0
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub


' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Sub Update(ByVal objSubscriberAcct As SubscriberAcct)
    On Error GoTo ErrMgr

    Dim m_objAccountDataSession     As Session
    Dim m_objCreditCardDataSession  As Session
    Dim lngRetCode                  As Long
    Dim m_PipeLine                  As New CPipeLineAccess
    
    ' Meter to get data
    m_PipeLine.ObjectName = "AccountPipeline"
    
    'm_PipeLine.Session = "metratech.com/AccountCreation"
    m_PipeLine.Session = mstrAccountCreationService
    m_PipeLine.RequestResponse = True
    

    
    ' Add all the propertie of the instance to the session like magic
    m_PipeLine.SetPropertiesFromInstance objSubscriberAcct, objSubscriberAcct.PropertiesString
    
    m_PipeLine.Property("actiontype") = "contact"
    m_PipeLine.Property("operation") = eSUBSCRIBER_ACCOUNT_OPERATION_UPDATE
   
    ' Because VB does not support Id that start with an _. I have to do this mess...
    m_PipeLine.Properties.Remove "AccountId"
    m_PipeLine.Property("_AccountId") = objSubscriberAcct.Accountid
                       
    m_PipeLine.Meter True
    '    lngRetCode = m_PipeLine.ReturnedProperty("RetCode")
    lngRetCode = MT_SUCCESS
    
    Select Case lngRetCode
        Case MT_SUCCESS
        Case Else
            On Error GoTo 0
            ' Here lngRetCode is already a COM error code we do not need to add vbObjectError
            Err.Raise lngRetCode, App.EXEName, "CSubscriberAcctHandler.Update()"
    End Select
Exit Sub
ErrMgr:
    Debug.Assert 0
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

' --------------------------------------------------------------------------------
' FUNCTION      : NewSubscriberAcct
' DESCRIPTION   : Allocate and return a new instance of SubscriberAcct
' PARAMETERS    :
' RETURNS       :
Public Function NewSubscriberAcct() As SubscriberAcct

    Dim objSubscriberAcct As SubscriberAcct
    Set objSubscriberAcct = New SubscriberAcct
    Set NewSubscriberAcct = objSubscriberAcct
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : GetCurrency
' DESCRIPTION   : Get the curreny associated with the subcriber
' PARAMETERS    : It is not mandatory to call the Initialize method before calling GetCurrency,
'                 But if you do not you have to pass the lngAccountId...
'
' RETURNS       : Return the currency or raise an error
'
Public Function GetCurrency(Optional ByVal lngAccountId As Long = 0) As String

    On Error GoTo ErrMgr
    
    Dim strSQL              As String
    Dim objAdoRst           As MTSQLRowset
    Dim strErrorMessage     As String
    Dim strUserTariff       As String
    Dim objDBA              As New MTSQLRowset
    Dim objError            As New CError

    If (lngAccountId = 0) Then lngAccountId = m_AccountId
    
        strSQL = Replace(SQL_SELECT_GET_CURRENCY_FROM_SUBSCRIBER_ACCOUNT_ID, "<ACCOUNT_ID>", CStr(lngAccountId))
        
        Set objAdoRst = SQLRun(strSQL)
        
        If (objAdoRst.RecordCount = 0) Then
        
            strErrorMessage = ERROR_MESSAGE_001
            strErrorMessage = Replace(strErrorMessage, "<ACCOUNT_ID>", CStr(lngAccountId))
            LogError "Subcriber.cls", "GetCurrency", strErrorMessage
            Err.Raise vbObjectError + 1, App.EXEName, strErrorMessage
        Else
            GetCurrency = objAdoRst.Value("c_currency")
        End If
    Exit Function

ErrMgr:
    objError.Save , "SubcriberHandler.cls", "GetCurrency"
    LogError , , objError.ToString
    objError.Raise
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : GetTariff
' DESCRIPTION   : Return the tariff associated with the subscriber. This function does
'                 not use the current account id but the parameter lngAccountId.
' PARAMETERS    :
'                   lngAccountId.
' RETURNS       : A tariff name else raise an error
Public Function GetTariff(ByVal lngAccountId As Long) As String

    On Error GoTo ErrMgr
    Dim objError            As New CError
    Dim strSQL              As String
    Dim objAdoRst           As MTSQLRowset
    Dim strErrorMessage     As String
    Dim strUserTariff       As String
    
    
    
        strSQL = Replace(SQL_SELECT_GET_TARIFF_NAME_FROM_SUBSCRIBER_ACCOUNT_ID, "<ACCOUNT_ID>", CStr(lngAccountId))
        Set objAdoRst = SQLRun(strSQL)
        
        If (objAdoRst.RecordCount = 0) Then
        
            strErrorMessage = ERROR_MESSAGE_001
            strErrorMessage = Replace(strErrorMessage, "<ACCOUNT_ID>", CStr(lngAccountId))
            'strErrorMessage = Replace(strErrorMessage, "<SQL>", strSQL)
            LogError "Subcriber.cls", "GetCurrency", strErrorMessage
            Err.Raise vbObjectError + 1, App.EXEName, strErrorMessage
        Else
            strUserTariff = objAdoRst.Value("nm_tariff")
            TRACE "Account=" & lngAccountId & " Tariff=" & strUserTariff
            GetTariff = strUserTariff
        End If
    Exit Function
ErrMgr:
    objError.Save , "SubcriberHandler.cls", "GetTariff"
    LogError , , objError.ToString
    objError.Raise
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : Tariffs
' DESCRIPTION   : Return the tariffs collection of all the application. The Collection of
'                 data is loaded on the first call only. Then it is stored in memory.
' PARAMETERS    :
' RETURNS       : Return  a instance of MTTariffCollection.
'
' REMOVED BY DYOUNG

'Private Function Tariffs() As MTTariffCollection

'    On Error GoTo ErrMgr
    
'    Dim objError        As New CError
'    Dim objModuleReader As MTModule
'    Dim objMTConfig     As New Config
    
'    If (Not m_objTariffs Is Nothing) Then
    
'        Set Tariffs = m_objTariffs
'        Exit Function
'    End If

'    Set m_objTariffs = New MTTariffCollection
'    Set objModuleReader = New MTModule

'    objModuleReader.ModuleDataFileName = "Tariffs\AllTariffs.xml"
'    objModuleReader.Read
'    m_objTariffs.Read objModuleReader
'    Set Tariffs = m_objTariffs
'Exit Function
'ErrMgr:
'    objError.Save , "SubcriberHandler.cls", "Tariffs"
'    LogError , , objError.ToString
'    objError.Raise
'End Function


' --------------------------------------------------------------------------------
' FUNCTION      : GetName
' DESCRIPTION   : Return the name of the subscriber
'
' PARAMETERS    :
' RETURNS       :
Public Function GetFullName(Optional ByVal lngAccountId As Long = 0) As String

    On Error GoTo ErrMgr
    Dim objError            As New CError
    
    'If (lngAccountId = 0) Then lngAccountId = m_AccountId
    '
   ' If (Initialize(lngAccountId)) Then
   '
   '     GetFullName = Me.SubscriberAccounts(1).FullName
   ' End If
   ' Exit Function
    Call Err.Raise(-1, "Method GetFullName Not Implemented")
ErrMgr:
    objError.Save , "SubcriberHandler.cls", "GetFullName"
    LogError , , objError.ToString
    objError.Raise
End Function




' --------------------------------------------------------------------------------
' FUNCTION      : GetTariff
' DESCRIPTION   : Return the tariff associated with the subscriber. This function does
'                 not use the current account id but the parameter lngAccountId.
' PARAMETERS    :
'                   lngAccountId.
' RETURNS       : A tariff name else raise an error
Public Function GetLanguage(ByVal lngAccountId As Long) As String

    On Error GoTo ErrMgr
    Dim objError            As New CError
    Dim strSQL              As String
    Dim objAdoRst           As New MTSQLRowset
    Dim strErrorMessage     As String
    Dim strLanguage         As String
    
    
    strSQL = Replace(SQL_SELECT_GET_LANGUAGE_FROM_SUBSCRIBER_ACCOUNT_ID, "<ACCOUNT_ID>", CStr(lngAccountId))
    Set objAdoRst = SQLRun(strSQL)
    
    If (objAdoRst.RecordCount = 0) Then
    
        strErrorMessage = ERROR_MESSAGE_002
        strErrorMessage = Replace(strErrorMessage, "<ACCOUNT_ID>", CStr(m_AccountId))
        strErrorMessage = Replace(strErrorMessage, "<SQL>", strSQL)
        LogError "Subcriber.cls", "GetLanguage", strErrorMessage
        Err.Raise vbObjectError + 2, App.EXEName, strErrorMessage
    Else
        strLanguage = objAdoRst.Value("tx_lang_code")
        TRACE "Account=" & m_AccountId & " Language=" & strLanguage
        GetLanguage = strLanguage
    End If

    Exit Function
ErrMgr:
    objError.Save , "SubcriberHandler.cls", "GetLanguage"
    LogError , , objError.ToString
    objError.Raise
End Function



' --------------------------------------------------------------------------------
' FUNCTION      : GetPaymentMethod
' DESCRIPTION   : Returns the Payment method of lngAccountId.
'                 1-None 2-Credit Card, we read it from the table t_av_internal.
' PARAMETERS    :
' RETURNS       : Long.
'
' --------------------------------------------------------------------------------
' ---------- THIS FUNCTION IS NO LONGER USED -- Raju/Fred (1/30/02)
' --------------------------------------------------------------------------------
Public Function GetPaymentMethod(ByVal lngAccountId As Long) As Variant

    On Error GoTo ErrMgr
    
    Dim objError            As New CError
    Dim strSQL              As String
    Dim objAdoRst           As MTSQLRowset
    Dim strErrorMessage     As String
    Dim objDBA              As New MTSQLRowset
    Dim varPaymentMethod    As Variant
    
    
    
        strSQL = Replace(SQL_SELECT_GET_PAYMENTMETHOD_FROM_SUBSCRIBER_ACCOUNT_ID, "<ACCOUNT_ID>", CStr(lngAccountId))
        Set objAdoRst = SQLRun(strSQL)
        
        If (objAdoRst.RecordCount = 0) Then
        
            strErrorMessage = ERROR_MESSAGE_001
            strErrorMessage = Replace(strErrorMessage, "<ACCOUNT_ID>", CStr(lngAccountId))
            'strErrorMessage = Replace(strErrorMessage, "<SQL>", strSQL)
            LogError "Subcriber.cls", "GetPaymentMethod", strErrorMessage
            Err.Raise vbObjectError + 1, App.EXEName, strErrorMessage
        Else
            varPaymentMethod = objAdoRst.Value("c_paymentmethod")
            If (IsNull(varPaymentMethod)) Then varPaymentMethod = eSUBSCRIBER_PAYMENT_METHOD_NONE
            
            ' In ORACLE this guy is a numeric so let ut convert it now!
            GetPaymentMethod = CLng(varPaymentMethod)
            TRACE "Account=" & lngAccountId & " payment_method =" & varPaymentMethod, "SubcriberHandler.cls", "GetPaymentMethod"
        End If
    
    Exit Function
ErrMgr:
    objError.Save , "SubcriberHandler.cls", "GetPaymentMethod"
    LogError , , objError.ToString
    objError.Raise
End Function

Private Sub Class_Initialize()
  mstrAccountCreationService = "metratech.com/accountcreation"
End Sub

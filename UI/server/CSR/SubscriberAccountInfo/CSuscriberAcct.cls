VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SubscriberAcct"
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
' ------------------------------------------------------------------------------------------
' CAccount
'
' Generation date:3/31/00 2:08:55 PM
' XML File:D:\Dvt\Vb\OoVbLib6\XML2VB\accountcreation.msixdef
' ------------------------------------------------------------------------------------------

Public Enum PAYMENT_METHOD
    PAYMENT_METHOD_NONE = 1
    PAYMENT_METHOD_CREDIT_CARD = 2
End Enum

Public Enum eCONTACT_TYPE
    BILL_TO = 1
    SHIP_TO = 2
End Enum

' Private Member
Private m_city                                  As String
Private m_state                                 As String
Private m_zip                                   As String
Private m_username                              As String
Private m_billable                              As String
Private m_password                              As String
Private m_name_space                            As String
Private m_language                              As String
Private m_taxexempt                             As String
Private m_firstname                             As String
Private m_lastname                              As String
Private m_email                                 As String
Private m_phonenumber                           As String
Private m_company                               As String
Private m_address1                              As String
Private m_address2                              As String
Private m_address3                              As String
Private m_country                               As String
Private m_facsimiletelephonenumber              As String
Private m_middleinitial                         As String
Private m_usagecycletype                        As String
Private m_transactioncookie                     As String

Private m_tariffID                              As Long
Private m_dayofmonth                            As Long
Private m_ContactType                           As Long
Private m_AccountId                             As Long
Private m_timezoneID                            As Long
Private m_paymentmethod                         As Long
Private m_timezoneoffset                        As Double

Public Index As Long
Public Id    As Variant


' Private internal member
' For some reason the LDAP property of the account does not
' have the same name that the property in the service definition
' see RAGU for an explaination...
' So I add a collection that store the translation from LDAP to Service Definition
' and the use the function TransatePropertyFromLDAP2ServiceDefition
Private m_PropertyFromLDAP2ServiceDefition As New CVariables

Private Function TransatePropertyFromLDAP2ServiceDefition(strProperty As String) As String
    Dim strValue As String
    If (m_PropertyFromLDAP2ServiceDefition.Exist(strProperty)) Then
        strValue = m_PropertyFromLDAP2ServiceDefition.Item(strProperty).Value
        If (strValue = "") Then
            TransatePropertyFromLDAP2ServiceDefition = strProperty ' the name is the same
        Else
            TransatePropertyFromLDAP2ServiceDefition = strValue ' the name is the same
        End If
    Else
        ' We return the same value the Property property will fail
        TransatePropertyFromLDAP2ServiceDefition = strProperty
    End If
End Function

Private Sub Class_Initialize()

    paymentmethod = PAYMENT_METHOD.PAYMENT_METHOD_NONE
    
    m_PropertyFromLDAP2ServiceDefition.Clear
    
    ' Properties are the same in LDAP and database we set the value to ""
    m_PropertyFromLDAP2ServiceDefition.Add "address1", ""
    m_PropertyFromLDAP2ServiceDefition.Add "address2", ""
    m_PropertyFromLDAP2ServiceDefition.Add "address3", ""
    m_PropertyFromLDAP2ServiceDefition.Add "email", ""
    m_PropertyFromLDAP2ServiceDefition.Add "phonenumber", ""
    m_PropertyFromLDAP2ServiceDefition.Add "facsimiletelephonenumber", ""
    m_PropertyFromLDAP2ServiceDefition.Add "company", ""
    m_PropertyFromLDAP2ServiceDefition.Add "contacttype", ""
    m_PropertyFromLDAP2ServiceDefition.Add "tariffID", ""
    m_PropertyFromLDAP2ServiceDefition.Add "taxexempt", ""
    m_PropertyFromLDAP2ServiceDefition.Add "timezoneID", ""
    m_PropertyFromLDAP2ServiceDefition.Add "timezoneoffset", ""
    m_PropertyFromLDAP2ServiceDefition.Add "middleinitial", ""
    m_PropertyFromLDAP2ServiceDefition.Add "city", ""
    m_PropertyFromLDAP2ServiceDefition.Add "state", ""
    m_PropertyFromLDAP2ServiceDefition.Add "zip", ""
  
    ' Properties names are differents
    m_PropertyFromLDAP2ServiceDefition.Add "contactid", "AccountId"
    m_PropertyFromLDAP2ServiceDefition.Add "id_acc", "AccountId"
    m_PropertyFromLDAP2ServiceDefition.Add "cn", "UserName"
    m_PropertyFromLDAP2ServiceDefition.Add "givenname", "FirstName"
    m_PropertyFromLDAP2ServiceDefition.Add "sn", "LastName"
    m_PropertyFromLDAP2ServiceDefition.Add "c", "Country"
    
    ' Properties not used
            
'    m_PropertyFromLDAP2ServiceDefition.Add "objectclass", ""
'    m_PropertyFromLDAP2ServiceDefition.Add "geocode", "-err-"
'
'    m_PropertyFromLDAP2ServiceDefition.Add "uID", "-err-"
'    m_PropertyFromLDAP2ServiceDefition.Add "creatorsname", "-err-"
'    m_PropertyFromLDAP2ServiceDefition.Add "createtimestamp", "-err-"
'    m_PropertyFromLDAP2ServiceDefition.Add "modifiersname", "-err-"
'    m_PropertyFromLDAP2ServiceDefition.Add "modifytimestamp", "-err-"


    ' Default Value
    m_ContactType = BILL_TO
    
End Sub

Public Property Get city() As String
    city = m_city
End Property

Public Property Let city(ByVal vNewValue As String)
    m_city = vNewValue
End Property

Public Property Get state() As String
    state = m_state
End Property

Public Property Let state(ByVal vNewValue As String)
    m_state = vNewValue
End Property

Public Property Get zip() As String
    zip = m_zip
End Property

Public Property Let zip(ByVal vNewValue As String)
    m_zip = vNewValue
End Property

Public Property Get UserName() As String
    UserName = m_username
End Property

Public Property Let UserName(ByVal vNewValue As String)
    m_username = vNewValue
End Property

Public Property Get PassWord() As String
    PassWord = m_password
End Property

Public Property Let PassWord(ByVal vNewValue As String)
    m_password = vNewValue
End Property

Public Property Get name_space() As String
    name_space = m_name_space
End Property

Public Property Let name_space(ByVal vNewValue As String)
    m_name_space = vNewValue
End Property

Public Property Get language() As String
    language = m_language
End Property

Public Property Let language(ByVal vNewValue As String)
    m_language = vNewValue
End Property

Public Property Get dayofmonth() As Long
    dayofmonth = m_dayofmonth
End Property

Public Property Let dayofmonth(ByVal vNewValue As Long)
    m_dayofmonth = vNewValue
End Property

Public Property Get Contacttype() As Long
    Contacttype = m_ContactType
End Property

Public Property Let Contacttype(ByVal vNewValue As Long)
    m_ContactType = vNewValue
End Property

Public Property Get taxexempt() As String
    taxexempt = m_taxexempt
End Property

Public Property Let taxexempt(ByVal vNewValue As String)
    m_taxexempt = vNewValue
End Property

Public Property Get tariffID() As Long
    tariffID = -1
End Property

Public Property Let tariffID(ByVal vNewValue As Long)
    m_tariffID = vNewValue
End Property

Public Property Get firstname() As String
    firstname = m_firstname
End Property

Public Property Let firstname(ByVal vNewValue As String)
    m_firstname = vNewValue
End Property

Public Property Get lastname() As String
    lastname = m_lastname
End Property

Public Property Let lastname(ByVal vNewValue As String)
    m_lastname = vNewValue
End Property

Public Property Get email() As String
    email = m_email
End Property

Public Property Let email(ByVal vNewValue As String)
    m_email = vNewValue
End Property

Public Property Get phonenumber() As String
    phonenumber = m_phonenumber
End Property

Public Property Let phonenumber(ByVal vNewValue As String)
    m_phonenumber = vNewValue
End Property

Public Property Get Accountid() As Long
    Accountid = m_AccountId
End Property

Public Property Let Accountid(ByVal vNewValue As Long)
    m_AccountId = vNewValue
End Property

Public Property Get timezoneID() As Long
    timezoneID = m_timezoneID
End Property

Public Property Let timezoneID(ByVal vNewValue As Long)
    m_timezoneID = vNewValue
End Property

Public Property Get timezoneoffset() As Double
    timezoneoffset = m_timezoneoffset
End Property

Public Property Let timezoneoffset(ByVal vNewValue As Double)
    m_timezoneoffset = vNewValue
End Property

Public Property Get company() As String
    company = m_company
End Property

Public Property Let company(ByVal vNewValue As String)
    m_company = vNewValue
End Property

Public Property Get address1() As String
    address1 = m_address1
End Property

Public Property Let address1(ByVal vNewValue As String)
    m_address1 = vNewValue
End Property

Public Property Get address2() As String
    address2 = m_address2
End Property

Public Property Let address2(ByVal vNewValue As String)
    m_address2 = vNewValue
End Property

Public Property Get address3() As String
    address3 = m_address3
End Property

Public Property Let address3(ByVal vNewValue As String)
    m_address3 = vNewValue
End Property

Public Property Get country() As String
    country = m_country
End Property

Public Property Let country(ByVal vNewValue As String)
    m_country = vNewValue
End Property

Public Property Get facsimiletelephonenumber() As String
    facsimiletelephonenumber = m_facsimiletelephonenumber
End Property

Public Property Let facsimiletelephonenumber(ByVal vNewValue As String)
    m_facsimiletelephonenumber = vNewValue
End Property

Public Property Get middleinitial() As String
    middleinitial = m_middleinitial
End Property

Public Property Let middleinitial(ByVal vNewValue As String)
    m_middleinitial = vNewValue
End Property

Public Property Get usagecycletype() As String
    usagecycletype = m_usagecycletype
End Property

Public Property Let usagecycletype(ByVal vNewValue As String)
    m_usagecycletype = vNewValue
End Property

Public Property Get paymentmethod() As Long
    paymentmethod = m_paymentmethod
End Property

Public Property Let paymentmethod(ByVal vNewValue As Long)
    m_paymentmethod = vNewValue
End Property

Public Property Get transactioncookie() As String
    transactioncookie = m_transactioncookie
End Property

Public Property Let transactioncookie(ByVal vNewValue As String)
    m_transactioncookie = vNewValue
End Property

Public Property Let billable(ByVal vNewValue As String)
  m_billable = vNewValue
End Property

Public Property Get billable() As String
  billable = m_billable
End Property

' --------------------------------------------------------------------------------
' FUNCTION      : Property
' DESCRIPTION   : Translate the property into a LDAP name and ignore the error
' PARAMETERS    : The LDAP account supplie more properties that we need so we
'                 just ignore them by catching the error! And Trace It!
'                 If the property does not exist we return an empty variant!
' RETURNS       :
'
Public Property Get Property(ByVal strPropertyName As String) As Variant
    On Error Resume Next
    Err.Clear
    'Clear the c_
    If UCase(Left(strPropertyName, 2)) = "C_" Then
      strPropertyName = Mid(strPropertyName, 3)
    End If
    
    Property = CallByName(Me, strPropertyName, VbGet)
    If (Err.Number) Then
        TRACE "Property=" & strPropertyName & " not supported! That is OK! " & CStr(Err.Number) & " description=" & Err.Description & " source=" & Err.Source, "MTSubscriberAcct.SubcriberAcct", "Property Let"
        Err.Clear
    End If
End Property

' --------------------------------------------------------------------------------
' FUNCTION      : Property
' DESCRIPTION   : Translate the property into a LDAP name and ignore the error
' PARAMETERS    : The LDAP account supplie more properties that we need so we
'                 just ignore them by catching the error! And Trace It
' RETURNS       :
'
Public Property Let Property(ByVal strPropertyName As String, ByVal vNewValue As Variant)
    On Error Resume Next
    Err.Clear

    'Clear the c_
    If UCase(Left(strPropertyName, 2)) = "C_" Then
      strPropertyName = Mid(strPropertyName, 3)
    End If
    
    If IsNull(vNewValue) Or IsEmpty(vNewValue) Then
        vNewValue = ""
    End If
    
    CallByName Me, TransatePropertyFromLDAP2ServiceDefition(strPropertyName), VbLet, vNewValue
    If (Err.Number) Then
        TRACE "Property=" & strPropertyName & " not supported! That is OK! " & CStr(Err.Number) & " description=" & Err.Description & " source=" & Err.Source, "MTSubscriberAcct.SubcriberAcct", "Property Get"
        Err.Clear
    End If
End Property


' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Function ToString() As String
    
    ToString = ToString & "city=" & m_city & ";" & vbCrLf
    ToString = ToString & "state=" & m_state & ";" & vbCrLf
    ToString = ToString & "zip=" & m_zip & ";" & vbCrLf
    ToString = ToString & "username=" & m_username & ";" & vbCrLf
    ToString = ToString & "password=" & m_password & ";" & vbCrLf
    ToString = ToString & "Contacttype=" & m_ContactType & ";" & vbCrLf
    ToString = ToString & "firstname=" & m_firstname & ";" & vbCrLf
    ToString = ToString & "lastname=" & m_lastname & ";" & vbCrLf
    ToString = ToString & "email=" & m_email & ";" & vbCrLf
    ToString = ToString & "phonenumber=" & m_phonenumber & ";" & vbCrLf
    ToString = ToString & "_Accountid=" & m_AccountId & ";" & vbCrLf
    ToString = ToString & "company=" & m_company & ";" & vbCrLf
    ToString = ToString & "address1=" & m_address1 & ";" & vbCrLf
    ToString = ToString & "address2=" & m_address2 & ";" & vbCrLf
    ToString = ToString & "address3=" & m_address3 & ";" & vbCrLf
    ToString = ToString & "country=" & m_country & ";" & vbCrLf
    ToString = ToString & "facsimiletelephonenumber=" & m_facsimiletelephonenumber & ";" & vbCrLf
    ToString = ToString & "middleinitial=" & m_middleinitial & ";" & vbCrLf
End Function


' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Property Get PropertiesString() As String

    ' 3.6 - The UI defines the length
    PropertiesString = PropertiesString & "city=" & 0 & ";"
    PropertiesString = PropertiesString & "state=" & 0 & ";"
    PropertiesString = PropertiesString & "zip=" & 0 & ";"
    PropertiesString = PropertiesString & "username=" & 0 & ";"
    PropertiesString = PropertiesString & "contacttype=" & 0 & ";"
    PropertiesString = PropertiesString & "firstname=" & 0 & ";"
    PropertiesString = PropertiesString & "lastname=" & 0 & ";"
    PropertiesString = PropertiesString & "email=" & 0 & ";"
    PropertiesString = PropertiesString & "phonenumber=" & 0 & ";"
    PropertiesString = PropertiesString & "Accountid=" & 0 & ";"
    PropertiesString = PropertiesString & "company=" & 0 & ";"
    PropertiesString = PropertiesString & "address1=" & 0 & ";"
    PropertiesString = PropertiesString & "address2=" & 0 & ";"
    PropertiesString = PropertiesString & "address3=" & 0 & ";"
    PropertiesString = PropertiesString & "country=" & 0 & ";"
    PropertiesString = PropertiesString & "facsimiletelephonenumber=" & 0 & ";"
    PropertiesString = PropertiesString & "middleinitial=" & 0 & ";"
End Property

' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Function FullName() As String
    FullName = Me.firstname & " " & Me.lastname
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : CheckRequiredField
' DESCRIPTION   : Check if all the required fields are not empty.
' PARAMETERS    :
'                   strErrorPropertyName :  Contains the property that must not be empty
'                                           Must be a variant because it is a ByRef parameter
'                                           used by vbscript!
'
' RETURNS       : Return false if at least one required field is empty!
'
Public Function CheckRequiredField(strErrorPropertyName As Variant) As Boolean

    If (CheckEmptyString("firstname", strErrorPropertyName)) Then Exit Function
    If (CheckEmptyString("lastname", strErrorPropertyName)) Then Exit Function
    If (CheckEmptyString("address1", strErrorPropertyName)) Then Exit Function
    If (CheckEmptyString("city", strErrorPropertyName)) Then Exit Function
    If (CheckEmptyString("state", strErrorPropertyName)) Then Exit Function
    If (CheckEmptyString("zip", strErrorPropertyName)) Then Exit Function
    If (CheckEmptyString("country", strErrorPropertyName)) Then Exit Function
    
    CheckRequiredField = True
End Function

Private Function CheckEmptyString(strPropertyName, strErrorPropertyName) As Boolean

    If (Len(Trim(CStr(Property(strPropertyName)))) = 0) Then
    
        CheckEmptyString = True
        strErrorPropertyName = strPropertyName
    End If
End Function

Friend Function UpdateStuff() As Boolean

    Dim objEC As Object
    Set objEC = CreateObject("Metratech.MTEnumConfig.1")
    
    ' The account Type is an Internal DB enum type id ; but because I need to meter it
    ' I retreive the enum type value...
    If Len("" & Contacttype) Then
    
        Me.Contacttype = objEC.GetEnumeratorValueByID(Contacttype)
    End If
    
    If Len("" & Me.country) Then
    
        Me.country = objEC.GetEnumeratorValueByID(Me.country)
    End If
    
    UpdateStuff = True
End Function

VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CSuscriberAcct"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

' Account Table Info

Public City                         As String
Public state                        As String
Public Zip                          As String
Public UserName                     As String
Public PassWord                     As String
Public Name_Space                   As String
Public Language                     As String
Public DayofMonth                   As Long
Public AccountType                  As Long
Public TaxExempt                    As String
Public TariffId                     As Long

' LDAP Info
Public FirstName                    As String
Public LastName                     As String
Public eMail                        As String
Public PhoneNumber                  As String
Public AccountId                    As Long
Public TimeZoneId                   As Long
Public TimeZoneOffSet               As Double
Public Company                      As String
Public Address1                     As String
Public Address2                     As String
Public Address3                     As String
Public Country                      As String

Public FacSimileTelephoneNumber     As String

Public MiddleInitial                As String
Public UsageCycleType               As String
Public PayementMethod               As String

' Internal Data
Public Index                As Long
Public Id                   As String

Public Function ToString() As String

End Function

Public Property Get PropertiesString() As String
    PropertiesString = AccountTablePropertiesString() & LDAPPropertiesString()
End Property

Public Property Get Property(ByVal strPropertyName As String) As Variant

End Property

Public Property Let Property(ByVal strPropertyName As String, ByVal vNewValue As Variant)
    ' Raise an error if strPropertyName is not valid
    Debug.Print strPropertyName & " = " & vNewValue
    CallByName Me, strPropertyName, VbLet, vNewValue
End Property


Public Property Get AccountTablePropertiesString() As String
    AccountTablePropertiesString = "City=20;State=2;Zip=10;UserName=40;PassWord=65;Name_Space=40;Language=5;DayofMonth=0;AccountType=0;TaxExempt=1;TariffId=0;"
End Property

Public Property Get LDAPPropertiesString() As String
    LDAPPropertiesString = "FirstName=40;LastName=40;eMail=100;PhoneNumber=30;AccountId=0;TimeZoneId=0;TimeZoneOffSet=0;Company=50;Address1=100;Address2=100;Address3=100;FacSimileTelephoneNumber=15;MiddleInitial=1;UsageCycleType=255;PayementMethod=0;"
End Property

Public Function Update() As Boolean
    On Error GoTo ErrMgr
    Update = True
    Exit Function
ErrMgr:
    Debug.Assert 0
    Err.Raise Err.Number, Err.Source, Err.Description
End Function
'
Public Function Initialize(lngAccountId As Long) As Long

    On Error GoTo ErrMgr
    
    Me.AccountId = lngAccountId
    
    Dim objLDAP As New MTLDAPImpl
    Dim objDataSet As MTLDAPDataSet
    Dim objData   As MTLDAPData
    
    objLDAP.Initialize
    objLDAP.RetrieveContact AccountId
       
        
    MsgBox objLDAP.Count
        
    Set objDataSet = objLDAP.Item(1)
    
    For Each objData In objDataSet
    
        On Error Resume Next
        Me.Property(objData.Attribute) = objData.Value
        Err.Clear
        On Error GoTo 0
    Next
    Initialize = 1
    Exit Function
ErrMgr:
    Debug.Assert 0
    Err.Raise Err.Number, Err.Source, Err.Description
End Function

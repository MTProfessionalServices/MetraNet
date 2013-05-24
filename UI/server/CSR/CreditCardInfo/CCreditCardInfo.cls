VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CreditCardInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public AccountId            As Long
Public CustomerName         As String
Public Address              As String
Public City                 As String
Public state                As String
Public Zip                  As String
Public Country              As String
Public eMail                As String
Public CreditCardType       As String
Public CreditCardNum_       As String
Public ExpDate              As String
Public ExpDateFormat        As Long
Public StartDate            As String
Public IssuerNumber         As String
Public CardId               As String
Public CardVerifyValue      As String
Public CustomerReferenceId  As String
Public CustomerVatNumber    As String
Public CompanyAddress       As String
Public CompanyPostalCode    As String
Public CompanyPhone         As String
Public Reserved1            As String
Public Reserved2            As String
Public RetainCardInfo       As Long
Public TestSession          As Long



' Internal Data
Public Index                As Long
Public Id                   As String

Public Function ToString() As String

End Function

Public Property Get PropertiesString() As String
    PropertiesString = "_AccountId=0;CustomerName=25;Address=25;City=20;State=20;Zip=10;Country=25;eMail=256;CreditCardType=20;CreditCardNum_=20;ExpDate=20;ExpDateFormat=0;StartDate=20;IssuerNumber=2;CardId=4;CardVerifyValue=3;CustomerReferenceId=17;CustomerVatNumber=13;CompanyAddress=40;CompanyPostalCode=10;CompanyPhone=40;Reserved1=40;Reserved2=40;RetainCardInfo=0;TestSession=0;"
End Property

Public Property Get LastFourDigits() As String
    LastFourDigits = Id
End Property

Public Property Get ExpDateMonth() As Variant
    
    On Error GoTo ErrMgr
    Dim objError As New CError
       
    Select Case ExpDateFormat
        Case 3
            ExpDateMonth = Left(ExpDate, 2)
        Case Else
            ExpDateMonth = ExpDate
    End Select
Exit Property
ErrMgr:
    Exit Function
    Debug.Assert 0
    objError.Save , "CreditCardInfo.cls", "ExpDateMonth Get", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Property

Public Property Let ExpDateMonth(varV As Variant)
    On Error GoTo ErrMgr
    Dim objError As New CError
   
    CheckExpDateSize
    Select Case ExpDateFormat
        Case 3
            Mid(ExpDate, 1, 2) = Mid(CStr(varV), 1, 2)
    End Select
    Exit Property
ErrMgr:
    Debug.Assert 0
    objError.Save , "CreditCardInfo.cls", "ExpDateMonth Let", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Property

Public Property Get ExpDateYear() As Variant
    On Error GoTo ErrMgr
    Dim objError As New CError
   
    Select Case ExpDateFormat
        Case 3
            ExpDateYear = VBA.Mid(ExpDate, 3)
        Case Else
            ExpDateYear = ExpDate
    End Select
    Exit Property
ErrMgr:
    Exit Function
    Debug.Assert 0
    objError.Save , "CreditCardInfo.cls", "ExpDateYear Get", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Property

Public Property Let ExpDateYear(varV As Variant)

    On Error GoTo ErrMgr
    Dim objError As New CError
    
    CheckExpDateSize
    Select Case ExpDateFormat
        Case 3
            Mid(ExpDate, 3, 4) = Mid(CStr(varV), 1, 4)
    End Select
    Exit Property
ErrMgr:
    Debug.Assert 0
    objError.Save , "CreditCardInfo.cls", "ExpDateYear Let", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Property

Public Property Get Property(ByVal strPropertyName As String) As Variant
    Property = CallByName(Me, strPropertyName, VbGet)
End Property

Public Property Let Property(ByVal strPropertyName As String, ByVal vNewValue As Variant)
    ' Raise an error if strPropertyName is not valid
    CallByName Me, strPropertyName, VbLet, vNewValue
End Property

Private Function CheckExpDateSize() As Boolean
   
   On Error GoTo ErrMgr
   Dim objError As New CError
   
    Select Case ExpDateFormat
        Case 3
            Do While Len(ExpDate) < 6
                ExpDate = ExpDate & " "
            Loop
            ExpDate = Mid(ExpDate, 1, 6)
    End Select
    CheckExpDateSize = True
    Exit Function
ErrMgr:
    Exit Function
    Debug.Assert 0
    objError.Save , "CreditCardInfo.cls", "CheckExpDateSize", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

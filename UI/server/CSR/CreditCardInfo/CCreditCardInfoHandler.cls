VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CreditCardInfoHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private m_CreditCardInfos   As New CreditCardInfos
Private m_AccountId         As Long

' --------------------------------------------------------------------------------
' FUNCTION      : Initialize()
' DESCRIPTION   : Load the Credit Card Info(s)  in the collection CreditCardInfos.
'                 Return the number of Credit Card info loaded. For now we support
'                 only 1 Credit Card Info.
'                 We have to meter twice so we use 2 Instance of CPipeLineAccess!
' PARAMETERS    :
'                   lngAccountId - The Account Id
' RETURNS       :   Return -1 if there is an error. and raise error too.
'
Public Function Initialize(ByVal lngAccountId As Long) As Long

    On Error GoTo ErrMgr
    
    TRACE "Initialize{", "CreditCardInfoHandler.cls", "Initialize"
    
    Dim objCreditCard               As CreditCardInfo
    Dim lngRetCode                  As Long
    Dim m_PipeLine                  As New CPipeLineAccess
    Dim m_PipeLine2                 As New CPipeLineAccess
    Dim strLastFourDigit            As String
    Dim objError                    As New CError
    
    Initialize = -1 ' Default return value
    
    m_AccountId = lngAccountId
    
    ' Clear the credit card collection
    m_CreditCardInfos.Clear
    
    ' Meter data
    m_PipeLine.ObjectName = "paymentserver"
    m_PipeLine2.ObjectName = "paymentserver"
    
    m_PipeLine.Session = "metratech.com/findbyaccountid"
    m_PipeLine.RequestResponse = True
    m_PipeLine2.RequestResponse = True
    
    m_PipeLine.Properties.Clear
    m_PipeLine.Property("_AccountID") = lngAccountId
    m_PipeLine.Property("TestSession") = 0
    
    m_PipeLine2.Properties.Clear
    m_PipeLine2.Property("_AccountID") = lngAccountId
    m_PipeLine2.Property("TestSession") = 0
    
    If (m_PipeLine.Meter(True)) Then ' Raise error if fails
    
        lngRetCode = m_PipeLine.ReturnedProperty("RetCode")
        
        TRACE "Metering " & m_PipeLine.Session & " SUCCEED RetCode=" & lngRetCode, "CreditCardInfoHandler.cls", "Initialize"
        
        Select Case lngRetCode
        
            Case PAYMENT_SERVER_ERRORS.CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND
                Initialize = 0
            
            Case PAYMENT_SERVER_ERRORS.CREDITCARDACCOUNT_SUCCESS ' Let us read Credit Card Info
                ' We do not clear the properties because we keep the _AccountID and the TestSession
                m_PipeLine2.Session = "metratech.com/findbyaccountidlast4type"
                strLastFourDigit = m_PipeLine.ReturnedProperty("LastFourDigits")
                m_PipeLine2.Property("CreditCardType") = m_PipeLine.ReturnedProperty("CreditCardType")
                m_PipeLine2.Property("LastFourDigits") = strLastFourDigit
                
                If (m_PipeLine2.Meter(True)) Then
                
                    lngRetCode = m_PipeLine.ReturnedProperty("RetCode")
                    TRACE "Metering " & m_PipeLine.Session & " SUCCEED RetCode=" & lngRetCode, "CreditCardInfoHandler.cls", "Initialize"
                    
                    If (lngRetCode = PAYMENT_SERVER_ERRORS.CREDITCARDACCOUNT_SUCCESS) Then
                        
                    
                        Set objCreditCard = New CreditCardInfo
                        m_PipeLine2.SetInstanceFromSessionProperty objCreditCard, objCreditCard.PropertiesString, False
                        
                        'MsgBox m_PipeLine.InstanceToString(objCreditCard, objCreditCard.PropertiesString, False)
                        
                        ' The last 4 digit are the id of the collection of credit card for one user
                        m_CreditCardInfos.Add objCreditCard, strLastFourDigit
                        
                        Initialize = m_CreditCardInfos.Count
                    End If
                End If
                
            Case Else
            
                Err.Raise vbObjectError + lngRetCode, App.EXEName, "Payment Server Error"
        End Select
    End If
    Exit Function
ErrMgr:
    Debug.Assert 0
    objError.Save , "CreditCardInfoHandler.cls", "Initialize", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Function

' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Property Get CreditCardInfos() As CreditCardInfos

    Set CreditCardInfos = m_CreditCardInfos
End Property

' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Sub Add(ByVal objCreditCardInfo As CreditCardInfo)
    
    On Error GoTo ErrMgr

    Dim m_objAccountDataSession     As Session
    Dim m_objCreditCardDataSession  As Session
    Dim objCreditCard               As CreditCardInfo
    Dim lngRetCode                  As PAYMENT_SERVER_ERRORS
    Dim m_PipeLine                  As New CPipeLineAccess
    Dim objError                    As New CError
    Dim strError                    As String
    
    'Dim objCreditCardInfo           As CreditCardInfo
    'Set objCreditCardInfo = varCreditCardInfo

    ' Clear the credit card collection
    m_CreditCardInfos.Clear

    ' Meter to get data
    m_PipeLine.ObjectName = "paymentserver"
    
    m_PipeLine.Session = "metratech.com/addaccount"
    m_PipeLine.RequestResponse = True

    If (m_PipeLine.SetPropertiesFromInstance(objCreditCardInfo, objCreditCardInfo.PropertiesString)) Then

        m_PipeLine.Meter (True)
        lngRetCode = m_PipeLine.ReturnedProperty("RetCode")
        ' strError = m_PipeLine.ReturnedProperty("RespString")
        Select Case lngRetCode

            Case PAYMENT_SERVER_ERRORS.CREDITCARDACCOUNT_SUCCESS
            Case Else
            
                ' ATTENTION - lngRetCode is already a HRESULT so we must not add vbObjectError
                Err.Raise lngRetCode, App.EXEName, GetErrorMessage(lngRetCode) & ". " & strError
        End Select
    End If
    Exit Sub
ErrMgr:
    Debug.Assert 0
    objError.Save , "CreditCardInfoHandler.cls", "Add", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise

End Sub


' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Sub Delete(ByVal objCreditCardInfo As CreditCardInfo)
    
    On Error GoTo ErrMgr

    Dim m_objAccountDataSession     As Session
    Dim m_objCreditCardDataSession  As Session
    Dim objCreditCard               As CreditCardInfo
    Dim lngRetCode                  As PAYMENT_SERVER_ERRORS
    Dim m_PipeLine                  As New CPipeLineAccess
    Dim objError                    As New CError
    
    'Dim objCreditCardInfo           As CreditCardInfo
    'Set objCreditCardInfo = varCreditCardInfo

        
    ' Meter to get data
    m_PipeLine.ObjectName = "paymentserver"
    
    m_PipeLine.Session = "metratech.com/deleteaccount"
    m_PipeLine.RequestResponse = True
    
    m_PipeLine.Property("_AccountID") = m_AccountId
    m_PipeLine.Property("TestSession") = 0
    m_PipeLine.Property("CreditCardType") = objCreditCardInfo.CreditCardType
    m_PipeLine.Property("LastFourDigits") = objCreditCardInfo.Id ' The Id is the last 4 digit

    m_PipeLine.Meter (True)
    lngRetCode = m_PipeLine.ReturnedProperty("RetCode")
    Select Case lngRetCode
        Case PAYMENT_SERVER_ERRORS.CREDITCARDACCOUNT_SUCCESS

            m_CreditCardInfos.Remove objCreditCardInfo.Index
        Case Else
            Err.Raise vbObjectError + lngRetCode, App.EXEName, "Payment Server Error " & lngRetCode
    End Select
    
Exit Sub
ErrMgr:
    Debug.Assert 0
    objError.Save , "CreditCardInfoHandler.cls", "Delete", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Sub


' --------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
'
Public Sub Update(ByVal objCreditCardInfo As CreditCardInfo)

    On Error GoTo ErrMgr

    Dim m_objAccountDataSession     As Session
    Dim m_objCreditCardDataSession  As Session
    Dim objCreditCard               As CreditCardInfo
    Dim lngRetCode                  As PAYMENT_SERVER_ERRORS
    Dim m_PipeLine                  As New CPipeLineAccess
    Dim objError                    As New CError
    
    'Dim objCreditCardInfo           As CreditCardInfo
    'Set objCreditCardInfo = varCreditCardInfo
        
    ' Meter to get data
    m_PipeLine.ObjectName = "paymentserver"
    
    m_PipeLine.Session = "metratech.com/updateaccount"
    m_PipeLine.RequestResponse = True
    
    m_PipeLine.SetPropertiesFromInstance objCreditCardInfo, objCreditCardInfo.PropertiesString, , False
    
    m_PipeLine.Property("LastFourDigits") = objCreditCardInfo.Id ' Must be in the transaction
    m_PipeLine.Properties.Remove "CreditCardNum_" ' Must not be in the transaction
                   
    m_PipeLine.Meter True
    lngRetCode = m_PipeLine.ReturnedProperty("RetCode")
    
    Select Case lngRetCode
        Case PAYMENT_SERVER_ERRORS.CREDITCARDACCOUNT_SUCCESS
        Case Else
            On Error GoTo 0
            ' Here lngRetCode is already a COM error code we do not need to add vbObjectError
            Err.Raise lngRetCode, App.EXEName, "Payment Server Error "
    End Select
Exit Sub
ErrMgr:
    Debug.Assert 0
    objError.Save , "CreditCardInfoHandler.cls", "Update", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Sub

' --------------------------------------------------------------------------------
' FUNCTION      : NewCreditCardInfo
' DESCRIPTION   : Return a Blank Credit Card Info Instance. Default properties are set.
' PARAMETERS    :
' RETURNS       :
'
Public Function NewCreditCardInfo() As CreditCardInfo

    On Error GoTo ErrMgr
    
    Dim objCreditCardInfo As CreditCardInfo
    Dim objError          As New CError
    
    Set objCreditCardInfo = New CreditCardInfo
    
    objCreditCardInfo.ExpDateFormat = 3
    objCreditCardInfo.AccountId = m_AccountId
    objCreditCardInfo.Id = "#NewId"
    objCreditCardInfo.RetainCardInfo = 1
    objCreditCardInfo.TestSession = 0
    Set NewCreditCardInfo = objCreditCardInfo
    Exit Function
ErrMgr:
Debug.Assert 0
    objError.Save , "CreditCardInfoHandler.cls", "Add", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Function



Private Function GetErrorMessage(lngErrNumber As Long) As String

    Select Case Hex(lngErrNumber)
        Case "E18F0009" 'declined
            GetErrorMessage = "This credit card has been declined during card validation.  Please try using a different credit card."

        Case "E18F000A" 'invalid number
            GetErrorMessage = "This credit card number is not valid.  Please check the number and try again."

        Case "E18F000C" 'insufficient funds
            GetErrorMessage = "This credit card does not have sufficient funds to schedule a conference. Please try using a different credit card."

        Case "E18F000D"     'failed AVS
            GetErrorMessage = "The address entered does not match the billing address for this credit card. Please check the address and try again."

        Case Else
            GetErrorMessage = "We are currently unable to validate your credit card.  Please try again later."
    End Select
    
End Function

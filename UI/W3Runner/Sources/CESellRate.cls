VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CESellRate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 11/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private m_objESellRate As Object

Const MAX_DATE_KEYWORD = "MAXDATE:"

Const ESELLRATE_PROG_ID = "esellerate.eseller"

Const ESELLRATE_PUBLISHER_KEY_1 = "64416"
Const ESELLRATE_PUBLISHER_KEY_2 = "78866"


Public Function Validate(strSerialNumber As String, ByVal strSerialNumberName As String, booShowError As Boolean) As Boolean

    If CreateOCX() Then
    
        If Not CheckDate(strSerialNumberName, booShowError) Then
            Exit Function
        End If
        
        'This function will validate the serial number found in the registry
        If m_objESellRate.ValidateSerialNumber(strSerialNumber, strSerialNumberName, ESELLRATE_PUBLISHER_KEY_1) > 0 Then
            Validate = True
            Exit Function
        End If
        If m_objESellRate.ValidateSerialNumber(strSerialNumber, strSerialNumberName, ESELLRATE_PUBLISHER_KEY_2) > 0 Then
            Validate = True
            Exit Function
        End If
        Set m_objESellRate = Nothing
    End If
End Function

Private Function CreateOCX() As Boolean
    
    On Error Resume Next
    
    Dim strVBErrorString As String
    
    Set m_objESellRate = CreateObject(ESELLRATE_PROG_ID)  'Create the eSellerate control
    If Err.Number Then
    
        strVBErrorString = GetVBErrorString()
        FShowError PreProcess(W3RUNNER_ERROR_07042, "NAME", ESELLRATE_PROG_ID, "DETAILS", strVBErrorString, "CRLF", vbNewLine)
        FShowError W3RUNNER_ERROR_07043
    Else
        CreateOCX = True
    End If
End Function

Private Function CheckDate(strCompanyName As String, booShowError As Boolean) As Boolean

    Dim lngDatePos As String
    Dim strDate    As String
    Dim varDate    As Date
    
    Const DATE_SIZE = 8     ' "20020301"
    
    lngDatePos = InStr(UCase$(strCompanyName), MAX_DATE_KEYWORD)
    
    If lngDatePos Then
    
        strDate = Mid(strCompanyName, lngDatePos + Len(MAX_DATE_KEYWORD), DATE_SIZE)
        If Len(strDate) <> DATE_SIZE Then Exit Function ' date does not have the right size
        If TodayDate <= strDate Then
            
            CheckDate = True
        Else
            If booShowError Then FShowError W3RUNNER_ERROR_07051
        End If
    Else
        CheckDate = True ' no date every thing is fine
    End If
End Function

Public Property Get TodayDate() As String
    TodayDate = Format(Now(), "yyyymmdd")
End Property

Public Function UnitTest() As Boolean

    ' Const ESELLRATE_PUBLISHER_KEY_2 = "78866"
    'Serial Number Name: IBM - maxdate:20010131
    'Serial Number: W3RUNNE000-2E4H-3D4H-1A34-3FSR-BBD4
        
    ' Should failed - negative case
    If Validate("W3RUNNE000-2E4H-3D4H-1A34-3FSR-BBD4", "IBM - maxdate:20010131", False) <> False Then Exit Function
    If Validate("W3RUNNE000-2E4H-3D4H-1A34-3FSR-BBD4", "IBM - maxdate:20110231", False) <> False Then Exit Function
    

    'Serial Number Name: IBM - maxdate:20110231
    'Serial Number: W3RUNNE000-0W45-62HQ-G1Y0-89E9-3A72
    If Validate("W3RUNNE000-0W45-62HQ-G1Y0-89E9-3A72", "IBM - maxdate:20110231", False) <> True Then Exit Function
    
    
    'Serial Number Name: IBM
    'Serial Number:W3RUNNE000-03H2-A964-BXQ9-0X27-25F5
    
    If Validate("W3RUNNE000-03H2-A964-BXQ9-0X27-25F5", "IBM", False) <> True Then Exit Function
    
    UnitTest = True
    
End Function

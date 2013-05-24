VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Begin VB.Form frmSocket 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin MSWinsockLib.Winsock Socket 
      Left            =   480
      Top             =   2340
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
End
Attribute VB_Name = "frmSocket"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Enum CWINSOCK_STATUS
    NONE = 0
    WAITING
    OK
    FAILED
    TIME_OUT
    CONNECTION_NOT_OPENED
End Enum

Private m_booOpened     As Boolean
Private m_lngTimeOut    As Long
Private m_strData       As String
Private m_strWaitSequence As String

Public Status               As CWINSOCK_STATUS
Public ErrorCode            As Long
Public ErrorDescription     As String

Const CWINSOCK_DEFAULT_TIME_OUT = 10

Public Function Connect(ByVal strServer As String, ByVal lngPort As Long, Optional ByVal lngTimeOut As Long = CWINSOCK_DEFAULT_TIME_OUT) As Boolean
    On Error GoTo ErrMgr
    
    Dim lngTime As Long
    
    m_strData = ""
    
    Load Me
    Debug.Print "CWINSOCK.CONNECT>"
    Socket.Connect strServer, lngPort
    m_lngTimeOut = lngTimeOut
    m_booOpened = True
    Connect = True
    
    Status = WAITING
    lngTime = GetTickCount()
    Do While (state <> sckConnected) And (lngTime + (m_lngTimeOut * 1000) > GetTickCount())
        DoEvents
        Sleep 1
        Debug.Print "s=" & state & "; ";
    Loop
    Debug.Print ""
    
    If (state = sckConnected) Then
        Status = OK
    Else
        Status = TIME_OUT
    End If
    Connect = Status = OK
        
    Exit Function
ErrMgr:
    Debug.Print Err.Number & " " & Err.Description
End Function

Public Function CloseSocket() As Boolean
    On Error GoTo ErrMgr
    If (m_booOpened) Then
        Socket.Close
        
        Debug.Print "CWINSOCK.CLOSED>"
        m_booOpened = False
    End If
    Exit Function
ErrMgr:
    Debug.Print Err.Number & " " & Err.Description
End Function

Private Sub Form_Unload(Cancel As Integer)
    CloseSocket
End Sub

Public Function SendData(ByVal strInput As String, Optional ByRef varOutPut As Variant, Optional strWaitSequence As String) As CWINSOCK_STATUS

    On Error GoTo ErrMgr
    
    Dim lngTime As Long
    
    m_strData = ""
    m_strWaitSequence = strWaitSequence
    
    If (m_booOpened) Then
    
        If (Len(strInput)) Then
            Debug.Print "CWINSOCK.SEND>" & strInput
            Socket.SendData strInput
        End If
        
        If (Not IsMissing(varOutPut)) Then
        
            Status = WAITING
            lngTime = GetTickCount()
            Do While (Status = WAITING) And (lngTime + (m_lngTimeOut * 1000) > GetTickCount())
                DoEvents
            Loop
            If (Status = OK) Then
                varOutPut = m_strData
                SendData = OK
            ElseIf (Status = WAITING) Then
                SendData = TIME_OUT
            Else
                SendData = FAILED
            End If
        Else
            SendData = OK
        End If
    Else
        SendData = CONNECTION_NOT_OPENED
    End If
    Exit Function
ErrMgr:
    Debug.Print Err.Number & " " & Err.Description
End Function

Private Sub socket_DataArrival(ByVal bytesTotal As Long)

    On Error GoTo ErrMgr
    
    Debug.Print "CWINSOCK.DATAARRIVAL>State=" & Socket.state & " bytesTotal=" & bytesTotal
    Dim strTmpData As String
    
    If Socket.state = sckConnected Then
    
        Socket.GetData strTmpData
        m_strData = m_strData & strTmpData
        
        If Len(m_strWaitSequence) Then ' Wait for a specific amount of data
        
            If InStr(m_strData, m_strWaitSequence) Then
            
                Debug.Print "CWINSOCK.DATAARRIVAL>" & m_strData
                Status = OK
            End If
        Else
        
            If Len(strTmpData) = bytesTotal Then
                
                Debug.Print "CWINSOCK.DATAARRIVAL>" & m_strData
                Status = OK
            Else
                ' Wait for the rest
                Debug.Assert 0
            End If
        End If
    Else
        'On Error Resume Next
        'Socket.GetData strTmpData
        'On Error GoTo ErrMgr
        Debug.Print "CWINSOCK.DATAARRIVAL>Weird. strTmpData=" & strTmpData
    End If
    
    Exit Sub
ErrMgr:
    
    
    Debug.Print Err.Number & " " & Err.Description
    Status = FAILED
    Me.ErrorCode = Err.Number
    Me.ErrorDescription = Err.Description
End Sub

Private Sub socket_Error(ByVal Number As Integer, Description As String, ByVal Scode As Long, ByVal Source As String, ByVal helpFile As String, ByVal HelpContext As Long, CancelDisplay As Boolean)
    Status = FAILED
    ErrorDescription = Description
    ErrorCode = Number
End Sub

Public Function GetErrorCode(ByVal strString As String) As Long

    GetErrorCode = -1
    
    If IsNumeric(Mid(strString, 1, 3)) Then
    
        GetErrorCode = CLng(Mid(strString, 1, 3))
    End If
End Function

Public Property Get state() As MSWinsockLib.StateConstants
    state = Me.Socket.state
End Property

Public Property Get Data() As String
    Data = m_strData
End Property

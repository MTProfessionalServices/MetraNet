VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "POP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


'Pop Server: mail.metratech.com
'SMTP Server: mail.metratech.com
'
'smoketest.subscriber@metratech.com;
'Username: smoketest
'Password: Password
'
'qatest.subscriber@metratech.com;
'Username: qatest
'Password: Password

Const POP_OK_CODE = "+OK"
Const POP_END_OF_MESSAGE = vbNewLine & "." & vbNewLine

Public Login            As String
Public PassWord         As String
Public Server           As String
Public Port             As Long
Public TimeOut          As Long
Public ErrorCode        As Long
Public DropSize         As Long
Public EMails           As Collection

Private m_strLastCommand As String
Private m_strLastOutPut As Variant
Private m_lngCount As Long

Const EMAIL_DEFAULT_TIME_OUT = 10

Public Property Get ErrorString() As String

    ErrorString = m_strLastOutPut
End Property

Public Property Get LastCommand() As String
    LastCommand = m_strLastCommand
End Property

Public Function SaveLastCommand(strLastCommand) As String
    m_strLastCommand = strLastCommand
    SaveLastCommand = strLastCommand
End Function


Public Property Get Count() As Long
    Count = m_lngCount
End Property

Public Function Test() As Boolean

    #If BUILD_ Then
    
    #Else
    
            Const SMTP_POP_SERVER = "mail.frederictorres.com"
            Const POP_LOGIN = "moi@frederictorres.com"
            Const POP_PASSWORD = "mailfred13"
            Const RECIPIENTS = "moi@frederictorres.com"
            
            'Const SMTP_POP_SERVER = "mail.metratech.com"
            'Const POP_LOGIN = "smoketest"
            'Const POP_PASSWORD = "password"
            'Const RECIPIENTS = "smoketest.subscriber@ metratech.com"
            
            GoSub ReadEMails
            
            ' Send an HTML EMAIL
            Dim strHTML  As Variant
            Dim objEMail As W3RunnerLib.email
            
            Set objEMail = New W3RunnerLib.email
            objEMail.Server = SMTP_POP_SERVER
            objEMail.From = "freddy@frederic.com"
            objEMail.Subject = "EMail Class UnitTest"
            
            objEMail.TOs.Add RECIPIENTS
            
            If objEMail.LoadFile("w:\W3Runner.welcome.htm", strHTML) Then
            
                objEMail.HTML = strHTML
                If Not objEMail.Send Then Exit Function
            End If
                
            ' Send a text email
            Set objEMail = New W3RunnerLib.email
            objEMail.Server = SMTP_POP_SERVER
            objEMail.From = "freddy@frederic.com"
            objEMail.Subject = "EMail Class UnitTest"
            objEMail.TOs.Add RECIPIENTS
            objEMail.Text = "Hello from text"
            If Not objEMail.Send Then Exit Function
            
            Sleep 1000
            
            GoSub ReadEMails
            
            Exit Function
            
ReadEMails:
            
            ' READ an HTML EMAIL
            Server = SMTP_POP_SERVER
            Login = POP_LOGIN
            PassWord = POP_PASSWORD
            If Read() Then
                If Me.EMails.Count = 2 Then
                    Set objEMail = Me.EMails(1)
                    MsgBox objEMail.ContentType & vbNewLine & objEMail.HTML
                    Set objEMail = Me.EMails(2)
                    MsgBox objEMail.ContentType & vbNewLine & objEMail.Text
                End If
            End If
        Return
            
    #End If
End Function

Public Function TestCount()

    #If BUILD_ Then
    #Else
        
    
    ' READ an HTML EMAIL
    Server = "mail.frederictorres.com" ' Server = "smtp.ne.mediaone.net"
    Login = "moi@frederictorres.com"
    PassWord = "mailfred13"
   
    
    'Server = "mail.metratech.com"
    'Login = "smoketest"
    'PassWord = "password"
    
    If Read(, True) Then
        MsgBox Me.Count
    End If
    
    #End If
End Function

Public Function Read(Optional ByVal booRemoveMails As Boolean = True, Optional ByVal booCountEMailOnly As Boolean = False) As Boolean

    Dim f                   As frmSocket
    Dim strOutPut           As Variant
    Dim ResponseToken       As Variant
    Dim e                   As Long
    Dim objEMail            As W3RunnerLib.email
    Dim arrTemp             As Variant
    
    On Error GoTo errmgr
    
    m_lngCount = 0
    Set EMails = New Collection
    
    Set f = New frmSocket
    
    If f.Connect(Server, Port, TimeOut) Then
    
        If Len(f.Data) Then
            strOutPut = f.Data
        Else
            If f.SendData(SaveLastCommand(""), strOutPut) <> OK Then GoTo TheExit  ' Send nothing but wait for answer
        End If
        If IsERROR(strOutPut) Then GoTo TheExit
        
        If f.SendData(SaveLastCommand("USER " & Login & vbNewLine), strOutPut) <> OK Then GoTo TheExit   ' Send nothing but wait for answer
        If IsERROR(strOutPut) Then GoTo TheExit
        
        If f.SendData(SaveLastCommand("PASS " & PassWord & vbNewLine), strOutPut) <> OK Then GoTo TheExit   ' Send nothing but wait for answer
        If IsERROR(strOutPut) Then GoTo TheExit
        
        If f.SendData(SaveLastCommand("STAT" & vbNewLine), strOutPut) <> OK Then GoTo TheExit   ' Send nothing but wait for answer
        If IsERROR(strOutPut) Then GoTo TheExit
        ResponseToken = Split(strOutPut, " ")
        
        m_lngCount = ResponseToken(1)
        DropSize = ResponseToken(2)
        
        If m_lngCount = 0 Or booCountEMailOnly Then
        
            Read = True
            GoTo Quit
        End If
        ' Wait for an .
        If f.SendData(SaveLastCommand("List" & vbNewLine), strOutPut, POP_END_OF_MESSAGE) <> OK Then GoTo TheExit  ' Send nothing but wait for answer
        If IsERROR(strOutPut) Then GoTo TheExit
        ResponseToken = Split(strOutPut, vbCrLf)
        
        For e = 1 To m_lngCount
        
            Set objEMail = New W3RunnerLib.email
            EMails.Add objEMail
            'arrTemp = Split(ResponseToken(e), " ")
            'objEMail.Size = arrTemp(1)
        Next
        
        For e = 1 To m_lngCount
        
            If f.SendData(SaveLastCommand("RETR " & e & vbNewLine), strOutPut, POP_END_OF_MESSAGE) <> OK Then GoTo TheExit  ' Send nothing but wait for answer
            If IsERROR(strOutPut) Then GoTo TheExit ' Wait for the OK
            EMails.Item(e).RawText = strOutPut
            If EMails.Item(e).DecodeRawText Then
                If booRemoveMails Then
                    If f.SendData(SaveLastCommand("DELE " & e & vbNewLine), strOutPut) <> OK Then GoTo TheExit   ' Send nothing but wait for answer
                    If IsERROR(strOutPut) Then GoTo TheExit
                End If
            End If
        Next
Quit:
        If f.SendData(SaveLastCommand("QUIT" & vbNewLine), strOutPut) <> OK Then GoTo TheExit   ' Send nothing but wait for answer
        If IsERROR(strOutPut) Then GoTo TheExit
        Read = True
TheExit:
        m_strLastOutPut = strOutPut
        f.CloseSocket
        Unload f
        Set f = Nothing
    End If
    Exit Function
errmgr:

    GoTo TheExit
    Exit Function
End Function

Private Sub Class_Initialize()
    Port = 110
    TimeOut = EMAIL_DEFAULT_TIME_OUT
End Sub

Private Function IsOK(ByVal s As String) As Boolean
    IsOK = UCase(Mid(s, 1, 3) = POP_OK_CODE)
End Function

Private Function IsERROR(ByVal s As String) As Boolean
    IsERROR = Not IsOK(s)
End Function



'
'USER support@flogviewer.com
'PASS PMSWEB
'STAT
'List
'RETR 1
'DELE 1
'QUIT
'
'
'+OK <9510.1010027095@mail.register-admin.com> ' connection
'+OK ' user
'+OK ' pass word
'+OK 1 1456 ' stat
'+OK ' List
'1 1456
'.
'+OK
'Return-Path: <moi@frederictorres.com>
'Delivered-To: flogviewer.com%support@flogviewer.com
'Received: (cpmta 9416 invoked from network); 2 Jan 2002 19:04:43 -0800
'Received: from 66.31.61.166 (HELO pms)
'  by smtp.register-admin.com (209.228.32.115) with SMTP; 2 Jan 2002 19:04:43 -0800
'X-Sent: 3 Jan 2002 03:04:43 GMT
'Message-ID: <000c01c19402$8503f8c0$a63d1f42@pms>
'From: <moi@frederictorres.com>
'To: <support@flogviewer.com>
'Subject: Subject
'Date: Wed, 2 Jan 2002 21:58:27 -0500
'MIME-Version: 1.0
'Content-Type: multipart/alternative;
'    boundary = "----=_NextPart_000_0009_01C193D8.9BAEFCC0"
'X-Priority: 3
'x -MSMail - Priority: Normal
'X-Mailer: Microsoft Outlook Express 5.50.4522.1200
'X-MimeOLE: Produced By Microsoft MimeOLE V5.50.4522.1200
'Status: U
'x -UIDL: PDPKTNHkIHMk0AE
'
'This is a multi-part message in MIME format.
'
'------=_NextPart_000_0009_01C193D8.9BAEFCC0
'Content-Type: text/plain;
'    Charset = "iso-8859-1"
'Content -Transfer - Encoding: quoted -printable
'
'Text
'
'------=_NextPart_000_0009_01C193D8.9BAEFCC0
'Content-Type: text/html;
'    Charset = "iso-8859-1"
'Content -Transfer - Encoding: quoted -printable
'
'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
'<HTML><HEAD>
'<META http-equiv=3DContent-Type content=3D"text/html; =
'charset=3Diso-8859-1">
'<META content=3D"MSHTML 5.50.4134.600" name=3DGENERATOR>
'<STYLE></STYLE>
'</HEAD>
'<BODY bgColor=3D#ffffff>
'<DIV><FONT size=3D2>text</FONT></DIV></BODY></HTML>
'
'------=_NextPart_000_0009_01C193D8.9BAEFCC0--
'
'
'.
'+OK
'+OK




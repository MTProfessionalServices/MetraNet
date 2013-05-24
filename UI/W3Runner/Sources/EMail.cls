VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "EMail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public LoginHeaders     As String
Public From             As String
Public TOs              As New Collection
Public Subject          As String
Public Text             As String
Public Server           As String
Public Port             As Long
Public ContentType      As String
Public TimeOut          As Long
Private m_strHTML       As String
Public Size             As Long
Public RawText          As String
Public ErrorCode        As Long

Private m_varOutPut     As Variant
Private m_strLastCommand As String

Const EMAIL_DEFAULT_TIME_OUT = 10

Public Function TextTest() As Boolean

    #If BUILD_ Then
    
    #Else
    
        Server = "mail.frederictorres.com" ' Server = "smtp.ne.mediaone.net"
        
        TOs.Add "ftorres10@ne.mediaone.net"
        TOs.Add "moi@frederictorres.com"
        TOs.Add "frederic.torres@metratech.com"
        
        From = "freddy@frederictorres.com"
        
        Subject = "EMail Class UnitTest"
        Text = "Email Test at " & Now() & vbNewLine & "End Of Text"
        If Send() Then
            TextTest = True
        Else
            MsgBox Me.ErrorString
        End If
        
    #End If
End Function

Public Function HTMLTest() As Boolean

    #If BUILD_ Then
    
    #Else
    
        Dim strHTML  As Variant
        
        TimeOut = 11
        
        Server = "mail.frederictorres.com" ' Server = "smtp.ne.mediaone.net"
        
        From = "freddy@frederictorres.com"
        
        Subject = "EMail Class UnitTest"
        'RecipientsEMail.Add "ftorres10@ne.mediaone.net"
        'TOs.Add "moi@frederictorres.com"
        'TOs.Add "frederic.torres@metratech.com"
        TOs.Add "smoketest.subscriber@metratech.com"
        '
        If LoadFile("w:\W3Runner.welcome.htm", strHTML) Then
        
            HTML = strHTML
            If Send() Then
                HTMLTest = True
            Else
                HTMLTest = False
                MsgBox Me.ErrorString
            End If
        End If
    
    #End If
End Function

Public Function Send(Optional booConnectOnly As Boolean = False) As Boolean

    Dim f                   As frmSocket
    
    Dim strSender           As String
    Dim strRecipientEMail   As Variant
    Dim strRecipientsEMail  As String
    
    On Error GoTo errmgr
    
    Set f = New frmSocket
    
    If f.Connect(Server, Port, TimeOut) Then
    
        If f.SendData(SaveLastCommand(0, ""), m_varOutPut) <> OK Then GoTo TheExitWithError ' Send nothing but wait for answer
        If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 220 Then GoTo TheExitWithError
        If booConnectOnly Then GoTo QUIT
        
        If f.SendData(SaveLastCommand(1, "HELO U" & vbNewLine), m_varOutPut) <> OK Then GoTo TheExitWithError  ' Send nothing but wait for answer
        If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 250 Then GoTo TheExitWithError
        LoginHeaders = m_varOutPut
        
        If f.SendData(SaveLastCommand(2, "MAIL FROM:" & Trim$(From) & vbNewLine), m_varOutPut) <> OK Then GoTo TheExitWithError  ' Send nothing but wait for answer
        If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 250 Then GoTo TheExitWithError
        
        For Each strRecipientEMail In TOs
        
            If (f.SendData(SaveLastCommand(3, "RCPT TO:" & Trim$(strRecipientEMail) & vbNewLine), m_varOutPut) <> OK) Then GoTo TheExitWithError
            If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 250 Then GoTo TheExitWithError
        Next

        If (f.SendData(SaveLastCommand(4, "DATA" & Trim$("") & vbNewLine), m_varOutPut) <> OK) Then GoTo TheExitWithError
        If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 354 Then GoTo TheExitWithError
        
        ' Message id
        If (f.SendData(SaveLastCommand(5, "Message-ID: <W3RunnerLib.EMail" & GetTickCount() & ">" & vbNewLine)) <> OK) Then GoTo TheExitWithError
        ' From
        If (f.SendData(SaveLastCommand(6, "From: <" & Trim$(From) & ">" & vbNewLine)) <> OK) Then GoTo TheExitWithError
        ' Reply-to
        If (f.SendData(SaveLastCommand(7, "Reply-To: <" & Trim$(From) & ">" & vbNewLine)) <> OK) Then GoTo TheExitWithError
        
        ' To
        For Each strRecipientEMail In TOs
        
            strRecipientsEMail = strRecipientsEMail & "<" & strRecipientEMail & ">,"
        Next
        strRecipientsEMail = Mid(strRecipientsEMail, 1, Len(strRecipientsEMail) - 1)
        If (f.SendData(SaveLastCommand(8, "To: " & Trim$(strRecipientsEMail) & vbNewLine)) <> OK) Then GoTo TheExitWithError
        
        ' Subject
        If (f.SendData(SaveLastCommand(9, "Subject: " & Trim$(Subject) & vbNewLine)) <> OK) Then GoTo TheExitWithError
        
        ' Content-Type
        If Len(ContentType) Then If (f.SendData(SaveLastCommand(10, "Content-Type: " & Trim$(Me.ContentType) & vbNewLine)) <> OK) Then GoTo TheExitWithError
        
        'If (f.SendData("Date: <Fri, 28 Dec 2001 17:44:14 -0500>" & vbNewLine) <> OK) Then GoTo TheExitWithError
        
        ' Begin Text
        If (f.SendData(SaveLastCommand(11, vbNewLine)) <> OK) Then GoTo TheExitWithError
        
        If Len(Text) Then
            If (f.SendData(SaveLastCommand(12, Text)) <> OK) Then GoTo TheExitWithError
        ElseIf Len(HTML) Then
            If (f.SendData(SaveLastCommand(13, HTML)) <> OK) Then GoTo TheExitWithError
        Else
            GoTo TheExitWithError
        End If
        
        If (f.SendData(SaveLastCommand(14, vbNewLine)) <> OK) Then GoTo TheExitWithError
        
        ' End Text
        If (f.SendData(SaveLastCommand(15, "." & vbNewLine), m_varOutPut) <> OK) Then GoTo TheExitWithError
        If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 250 Then GoTo TheExitWithError
QUIT:
        ' Quit
        If (f.SendData(SaveLastCommand(16, "QUIT" & vbNewLine), m_varOutPut) <> OK) Then GoTo TheExitWithError
        If SaveErrorCode(f.GetErrorCode(m_varOutPut)) <> 221 Then GoTo TheExitWithError
        Send = True
TheExit:
        f.CloseSocket
        Unload f
        Set f = Nothing
    End If
    Exit Function
TheExitWithError:
    Debug.Assert 0
    GoTo TheExit
errmgr:
    GoTo TheExitWithError
    Exit Function
End Function

Private Sub Class_Initialize()
    Port = 25
    TimeOut = EMAIL_DEFAULT_TIME_OUT
End Sub

Private Function SaveErrorCode(ByVal lngErrorCode As Long) As Long
    ErrorCode = lngErrorCode
    SaveErrorCode = lngErrorCode
End Function

Public Property Get HTML() As String
    HTML = m_strHTML
End Property

Public Property Let HTML(ByVal vNewValue As String)
    m_strHTML = vNewValue
    If Len(HTML) Then
        Me.ContentType = "text/html;charset=iso-8859-1"
    Else
        Me.ContentType = ""
    End If
End Property


'HELO pms
'MAIL FROM: <moi@frederictorres.com>
'RCPT TO: <ftorres10@ne.mediaone.net>
'Data
'Message-ID: <000c01c18ff1$2d713a10$a63d1f42@pms>
'From: <moi@frederictorres.com>
'To: "Frederic Media One Torres" <ftorres10@ne.mediaone.net>
'Subject: Test
'Date: Fri, 28 Dec 2001 17:44:14 -0500
'MIME-Version: 1.0
'Content-Type: multipart/alternative; boundary = "----=_NextPart_000_0009_01C18FC7.44118FB0"
'X-Priority: 3
'x -MSMail - Priority: Normal
'X-Mailer: Microsoft Outlook Express 5.50.4522.1200
'X-MimeOLE: Produced By Microsoft MimeOLE V5.50.4522.1200
'
'This is a multi-part message in MIME format.
'
'------=_NextPart_000_0009_01C18FC7.44118FB0
'Content-Type: text/plain;
'    Charset = "iso-8859-1"
'Content -Transfer - Encoding: quoted -printable
'
'zizi
'
'------=_NextPart_000_0009_01C18FC7.44118FB0
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
'<DIV><FONT size=3D2>zizi</FONT></DIV></BODY></HTML>
'
'------=_NextPart_000_0009_01C18FC7.44118FB0--
'
'.
'QUIT
'**********************************************
'220 smtp.register-admin.com ESMTP CPMTA-3_6_0_4 - NO UCE
'250-smtp.register-admin.com Hi.
'250-PIPELINING
'250-AUTH=LOGIN
'250 8BITMIME
'250 ok
'250 ok
'354 go ahead
'250 ok 1009579794 qp 11230
'221 smtp.register-admin.com closing connection


Public Function LoadFile(ByVal strFileName As String, ByRef strText As Variant) As Boolean

    Dim objTextFile As New cTextFile
    Dim s           As String
    
    If objTextFile.OpenFile(strFileName) Then
    
        Do While Not objTextFile.EOF()
        
            s = objTextFile.ReadLn()
            If Len(s) Then
                If Mid(s, 1, 1) = "." Then
                    s = "." & s ' double the char . at pos 1
                End If
            End If
            strText = strText & s & vbNewLine
        Loop
        LoadFile = True
    End If
End Function
'
'+OK
'Return-Path: <freddy@frederictorres.com>
'Delivered-To: frederictorres.com%moi@frederictorres.com
'Received: (cpmta 6451 invoked from network); 2 Jan 2002 19:49:48 -0800
'Received: from 66.31.61.166 (HELO U)
'  by smtp.register-admin.com (209.228.32.114) with SMTP; 2 Jan 2002 19:49:48 -0800
'X-Sent: 3 Jan 2002 03:49:48 GMT
'Message-ID: <W3RunnerLib.EMail79972814>
'From: <freddy@frederictorres.com>
'Reply-To: <freddy@frederictorres.com>
'To: <moi@frederictorres.com>
'Subject: EMail Class UnitTest
'Content-Type: text/html;charset=iso-8859-1
'Status: RO
'x -UIDL: PDPU3NHkIHIZNwE
'
'<HEAD>
'<STYLE TYPE='text/css'>
'..Text{

Public Function DecodeRawText() As Boolean
    Dim Lines       As Variant
    Dim strTOs      As String
    Dim arrTOs      As Variant
    Dim v           As Variant
    Dim booConcat   As Boolean
    
    From = Headers("FROM")
    Subject = Headers("SUBJECT")
    ContentType = Headers("Content-Type")
    
    strTOs = Headers("TO")
    arrTOs = Split(strTOs, ",")
    Set TOs = New Collection
    For Each v In arrTOs
        TOs.Add Replace(Replace(v, "<", ""), ">", "")
    Next
    
    Lines = Split(Me.RawText, vbNewLine)
    For Each v In Lines
    
        If Len(v) = 0 Then booConcat = True ' find the start of the message
        If v = "." Then Exit For ' fin the end of the message
        If booConcat Then
            If Len(v) >= 2 Then
                If Mid(v, 1, 2) = ".." Then v = "." & Mid(v, 3) ' process the special char
            End If
            Me.Text = Me.Text & v & vbNewLine
        End If
    Next
    m_strHTML = Text
    DecodeRawText = True
End Function

Public Property Get Headers(ByVal strName As String) As Variant

    Dim lngStartPos         As Long
    Dim lngEndPos           As Long
    Dim lngPropertyNameLen  As Long
    
    lngStartPos = InStr(UCase$(Me.RawText), UCase$(vbNewLine & strName & ":"))
    
    If lngStartPos Then
    
        lngEndPos = InStr(lngStartPos + 1, UCase$(Me.RawText), vbNewLine)
        
        If lngEndPos Then
        
            lngPropertyNameLen = Len(vbNewLine & strName & ":")
            Headers = Trim(Mid(Me.RawText, lngStartPos + lngPropertyNameLen, lngEndPos - lngStartPos - lngPropertyNameLen))
        End If
    End If
End Property

Public Property Get ErrorString() As String
    ErrorString = "[" & m_strLastCommand & "][" & m_varOutPut & "]"
End Property

Public Function SaveLastCommand(lngID As Long, strLastCommand As String) As String
    Debug.Print "COMMAND-ID " & lngID
    m_strLastCommand = lngID & "-" & strLastCommand
    SaveLastCommand = strLastCommand
End Function

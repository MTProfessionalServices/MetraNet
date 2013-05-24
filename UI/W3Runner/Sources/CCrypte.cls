VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CCrypte"
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
'  DATE         : 12/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit
Private m_Base64 As New CBase64

'Const base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
'
'Public Function base64_encode(DecryptedText As String) As String
'   Dim c1, c2, c3 As Integer
'   Dim w1 As Integer
'   Dim w2 As Integer
'   Dim w3 As Integer
'   Dim w4 As Integer
'   Dim n As Integer
'   Dim retry As String
'   For n = 1 To Len(DecryptedText) Step 3
'      c1 = Asc(Mid$(DecryptedText, n, 1))
'      c2 = Asc(Mid$(DecryptedText, n + 1, 1) + Chr$(0))
'      c3 = Asc(Mid$(DecryptedText, n + 2, 1) + Chr$(0))
'      w1 = Int(c1 / 4)
'      w2 = (c1 And 3) * 16 + Int(c2 / 16)
'      If Len(DecryptedText) >= n + 1 Then w3 = (c2 And 15) * 4 + Int(c3 / 64) Else w3 = -1
'      If Len(DecryptedText) >= n + 2 Then w4 = c3 And 63 Else w4 = -1
'      retry = retry + mimeencode(w1) + mimeencode(w2) + mimeencode(w3) + mimeencode(w4)
'   Next
'   base64_encode = retry
'End Function
'
'Public Function base64_decode(a As String) As String
'   Dim w1 As Integer
'   Dim w2 As Integer
'   Dim w3 As Integer
'   Dim w4 As Integer
'   Dim n As Integer
'   Dim retry As String
'
'   For n = 1 To Len(a) Step 4
'      w1 = mimedecode(Mid$(a, n, 1))
'      w2 = mimedecode(Mid$(a, n + 1, 1))
'      w3 = mimedecode(Mid$(a, n + 2, 1))
'      w4 = mimedecode(Mid$(a, n + 3, 1))
'      If w2 >= 0 Then retry = retry + Chr$(((w1 * 4 + Int(w2 / 16)) And 255))
'      If w3 >= 0 Then retry = retry + Chr$(((w2 * 16 + Int(w3 / 4)) And 255))
'      If w4 >= 0 Then retry = retry + Chr$(((w3 * 64 + w4) And 255))
'   Next
'   base64_decode = retry
'End Function
'
'Private Function mimeencode(w As Integer) As String
'   If w >= 0 Then mimeencode = Mid$(base64, w + 1, 1) Else mimeencode = ""
'End Function
'
'Private Function mimedecode(a As String) As Integer
'   If Len(a) = 0 Then mimedecode = -1: Exit Function
'   mimedecode = InStr(base64, a) - 1
'End Function



Public Function Crypte(strKeySource As String, ByRef strKeyCrypted As String) As Boolean

    Dim i           As Long
    Dim bytChar     As Byte
    Dim lngCRC      As Long
    
    strKeyCrypted = ""
    For i = 1 To Len(strKeySource)
    
        bytChar = Asc(Mid(strKeySource, i, 1))
        If (i Mod 2) = 0 Then ' pair
            bytChar = bytChar Xor (1 + 32)
        Else
            bytChar = bytChar Xor (2 + 64)
        End If
        If bytChar <= 15 Then
            strKeyCrypted = strKeyCrypted & "0" & Hex(bytChar)
        Else
            strKeyCrypted = strKeyCrypted & Hex(bytChar)
        End If
        lngCRC = lngCRC + bytChar 'Asc(Mid(Me.KeySource, i, 1))
    Next
    strKeyCrypted = Format(Len(strKeySource) * 3, "0000") & "-" & strKeyCrypted & "-" & lngCRC
    strKeyCrypted = m_Base64.Encode(strKeyCrypted)
    Crypte = True
End Function


Public Function DeCrypte(ByVal strKeyCrypted As String, ByRef strKeyDest As String) As Boolean

    Dim i           As Long
    Dim bytChar     As Byte
    Dim bytChar2    As Byte
    Dim lngCRC      As Long
    Dim lngPos      As Long
    Dim lngPos2     As Long
    Dim lngSourceKeyLen As Long
    Dim lngStrIndex As Long
    Dim lngKeyCRC As Long

    On Error GoTo errmgr
    
    strKeyCrypted = m_Base64.Decode(strKeyCrypted)

    lngPos = InStr(strKeyCrypted, "-")
    If lngPos = 0 Then Exit Function
    
    lngSourceKeyLen = CLng(Mid(strKeyCrypted, 1, lngPos - 1)) / 3
    
    lngPos2 = InStr(lngPos + 1, strKeyCrypted, "-")
    If lngPos = 0 Then Exit Function
    lngKeyCRC = CLng(Mid(strKeyCrypted, lngPos2 + 1))
    strKeyDest = ""
    lngStrIndex = lngPos + 1
    
    For i = 1 To lngSourceKeyLen
    
        bytChar = CLng("&h" & Mid(strKeyCrypted, lngStrIndex, 2))
        bytChar2 = bytChar
        If (i Mod 2) = 0 Then ' pair
            bytChar = bytChar Xor (1 + 32)
        Else
            bytChar = bytChar Xor (2 + 64)
        End If
        strKeyDest = strKeyDest & Chr(bytChar)
        lngCRC = lngCRC + bytChar2
        lngStrIndex = lngStrIndex + 2
    Next
    DeCrypte = CBool(lngCRC = lngKeyCRC) And CBool(lngKeyCRC > 0)
    
    Exit Function
errmgr:
End Function



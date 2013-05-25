VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CUTF8"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit


Private Const m_bIsNt = True

'Private Declare Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, ByVal lpMultiByteStr As Long, ByVal cchMultiByte As Long, ByVal lpDefaultChar As Long, lpUsedDefaultChar As Long) As Long
Private Declare Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, ByRef lpMultiByteStr As Any, ByVal cchMultiByte As Long, ByVal lpDefaultChar As String, ByVal lpUsedDefaultChar As Long) As Long
'Private Declare Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, ByRef lpMultiByteStr As Any, ByVal cchMultiByte As Long, ByVal lpDefaultChar As String, ByVal lpUsedDefaultChar As Long) As Long
'Private Declare Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, ByVal lpMultiByteStr As String, ByVal cchMultiByte As Long, ByVal lpDefaultChar As String, ByVal lpUsedDefaultChar As Long) As Long

Private Declare Function GetACP Lib "kernel32" () As Long

Private UTF8_TABLE(0 To 255) As String

Private Declare Function MultiByteToWideChar Lib "kernel32" ( _
      ByVal CodePage As Long, _
      ByVal flags As Long, _
      ByVal MString As String, _
      ByVal MLength As Long, _
      ByVal WCharPtr As Long, _
      ByVal WCharCount As Long) _
  As Long
  
  Const CP_UTF8 As Long = 65001


Public Function GetASCII32To255RefString() As String

    Dim i As Long
    Dim s As String
    
    For i = 32 To 255
        s = s & GetASCIIString(i) & vbNewLine
    Next
    GetASCII32To255RefString = s
End Function


Public Function GetASCIIString(ByVal AsciiCode As Long) As String

    Dim i As Long
    
    i = AsciiCode
    GetASCIIString = Format(i, "000") & "-" & Chr(i) & vbNewLine
End Function

Private Sub Class_Initialize()

    InitializeData
End Sub

'Public Function StringToUTF8(ByVal strString As String) As String
'
'    Dim i As Long
'    Dim strTmp As String
'
'    For i = 1 To Len(strString)
'
'        strTmp = strTmp & CharToUTF8(Mid$(strString, i, 1))
'    Next
'    StringToUTF8 = strTmp
'End Function


 
' ReWritten by rudi for 3.7
Private Function StringToUTF8(ByVal strUnicode As String) As String

   Dim i                As Long
   Dim nLen             As Long
   Dim lPtr             As Long
   Dim UTF16            As Long
   Dim UTF8_EncodeLong  As String


   nLen = Len(strUnicode)

   If nLen = 0 Then

     StringToUTF8 = ""
     Exit Function
   End If


      Dim lngBufferSize    As Long
      Dim lngResult        As Long
      Dim bytUtf8()        As Byte

      'Set buffer for longest possible string.

      lngBufferSize = nLen * 3 + 1

      ReDim bytUtf8(lngBufferSize - 1)

 

      lngResult = WideCharToMultiByte(CP_UTF8, 0, StrPtr(strUnicode), nLen, bytUtf8(0), lngBufferSize, vbNullString, 0)

      If lngResult Then

         lngResult = lngResult - 1
         ReDim Preserve bytUtf8(lngResult)
         StringToUTF8 = StrConv(bytUtf8, vbUnicode)
      Else
         StringToUTF8 = "UTF8_Encode ERROR"
      End If
End Function


Private Function CharToUTF8(ByVal strChar As String) As String

    Dim lngCharASCIICode    As Long
    Dim Values              As Variant
    Dim Value               As Variant
    Dim strTmp              As String
    
    lngCharASCIICode = Asc(strChar)
    
    If (lngCharASCIICode >= 128) And (lngCharASCIICode <= 255) Then
    
        Values = Split(UTF8_TABLE(lngCharASCIICode), "-")
        For Each Value In Values
            strTmp = strTmp & Chr(CLng(Value))
        Next
        CharToUTF8 = strTmp
    Else
        CharToUTF8 = strChar
    End If
    
End Function

Private Function InitializeData()

    UTF8_TABLE(128) = "226-130-172"
    UTF8_TABLE(129) = "194-129"
    UTF8_TABLE(130) = "226-128-154"
    UTF8_TABLE(131) = "198-146"
    UTF8_TABLE(132) = "226-128-158"
    UTF8_TABLE(133) = "226-128-166"
    UTF8_TABLE(134) = "226-128-160"
    UTF8_TABLE(135) = "226-128-161"
    UTF8_TABLE(136) = "203-134"
    UTF8_TABLE(137) = "226-128-176"
    UTF8_TABLE(138) = "197-160"
    UTF8_TABLE(139) = "226-128-185"
    UTF8_TABLE(140) = "197-146"
    UTF8_TABLE(141) = "194-141"
    UTF8_TABLE(142) = "197-189"
    UTF8_TABLE(143) = "194-143"
    UTF8_TABLE(144) = "194-144"
    UTF8_TABLE(145) = "226-128-152"
    UTF8_TABLE(146) = "226-128-153"
    UTF8_TABLE(147) = "226-128-156"
    UTF8_TABLE(148) = "226-128-157"
    UTF8_TABLE(149) = "226-128-162"
    UTF8_TABLE(150) = "226-128-147"
    UTF8_TABLE(151) = "226-128-148"
    UTF8_TABLE(152) = "203-156"
    UTF8_TABLE(153) = "226-132-162"
    UTF8_TABLE(154) = "197-161"
    UTF8_TABLE(155) = "226-128-186"
    UTF8_TABLE(156) = "197-147"
    UTF8_TABLE(157) = "194-157"
    UTF8_TABLE(158) = "197-190"
    UTF8_TABLE(159) = "197-184"
    UTF8_TABLE(160) = "194-160"
    UTF8_TABLE(161) = "194-161"
    UTF8_TABLE(162) = "194-162"
    UTF8_TABLE(163) = "194-163"
    UTF8_TABLE(164) = "194-164"
    UTF8_TABLE(165) = "194-165"
    UTF8_TABLE(166) = "194-166"
    UTF8_TABLE(167) = "194-167"
    UTF8_TABLE(168) = "194-168"
    UTF8_TABLE(169) = "194-169"
    UTF8_TABLE(170) = "194-170"
    UTF8_TABLE(171) = "194-171"
    UTF8_TABLE(172) = "194-172"
    UTF8_TABLE(173) = "194-173"
    UTF8_TABLE(174) = "194-174"
    UTF8_TABLE(175) = "194-175"
    UTF8_TABLE(176) = "194-176"
    UTF8_TABLE(177) = "194-177"
    UTF8_TABLE(178) = "194-178"
    UTF8_TABLE(179) = "194-179"
    UTF8_TABLE(180) = "194-180"
    UTF8_TABLE(181) = "194-181"
    UTF8_TABLE(182) = "194-182"
    UTF8_TABLE(183) = "194-183"
    UTF8_TABLE(184) = "194-184"
    UTF8_TABLE(185) = "194-185"
    UTF8_TABLE(186) = "194-186"
    UTF8_TABLE(187) = "194-187"
    UTF8_TABLE(188) = "194-188"
    UTF8_TABLE(189) = "194-189"
    UTF8_TABLE(190) = "194-190"
    UTF8_TABLE(191) = "194-191"
    UTF8_TABLE(192) = "195-128"
    UTF8_TABLE(193) = "195-129"
    UTF8_TABLE(194) = "195-130"
    UTF8_TABLE(195) = "195-131"
    UTF8_TABLE(196) = "195-132"
    UTF8_TABLE(197) = "195-133"
    UTF8_TABLE(198) = "195-134"
    UTF8_TABLE(199) = "195-135"
    UTF8_TABLE(200) = "195-136"
    UTF8_TABLE(201) = "195-137"
    UTF8_TABLE(202) = "195-138"
    UTF8_TABLE(203) = "195-139"
    UTF8_TABLE(204) = "195-140"
    UTF8_TABLE(205) = "195-141"
    UTF8_TABLE(206) = "195-142"
    UTF8_TABLE(207) = "195-143"
    UTF8_TABLE(208) = "195-144"
    UTF8_TABLE(209) = "195-145"
    UTF8_TABLE(210) = "195-146"
    UTF8_TABLE(211) = "195-147"
    UTF8_TABLE(212) = "195-148"
    UTF8_TABLE(213) = "195-149"
    UTF8_TABLE(214) = "195-150"
    UTF8_TABLE(215) = "195-151"
    UTF8_TABLE(216) = "195-152"
    UTF8_TABLE(217) = "195-153"
    UTF8_TABLE(218) = "195-154"
    UTF8_TABLE(219) = "195-155"
    UTF8_TABLE(220) = "195-156"
    UTF8_TABLE(221) = "195-157"
    UTF8_TABLE(222) = "195-158"
    UTF8_TABLE(223) = "195-159"
    UTF8_TABLE(224) = "195-160"
    UTF8_TABLE(225) = "195-161"
    UTF8_TABLE(226) = "195-162"
    UTF8_TABLE(227) = "195-163"
    UTF8_TABLE(228) = "195-164"
    UTF8_TABLE(229) = "195-165"
    UTF8_TABLE(230) = "195-166"
    UTF8_TABLE(231) = "195-167"
    UTF8_TABLE(232) = "195-168"
    UTF8_TABLE(233) = "195-169"
    UTF8_TABLE(234) = "195-170"
    UTF8_TABLE(235) = "195-171"
    UTF8_TABLE(236) = "195-172"
    UTF8_TABLE(237) = "195-173"
    UTF8_TABLE(238) = "195-174"
    UTF8_TABLE(239) = "195-175"
    UTF8_TABLE(240) = "195-176"
    UTF8_TABLE(241) = "195-177"
    UTF8_TABLE(242) = "195-178"
    UTF8_TABLE(243) = "195-179"
    UTF8_TABLE(244) = "195-180"
    UTF8_TABLE(245) = "195-181"
    UTF8_TABLE(246) = "195-182"
    UTF8_TABLE(247) = "195-183"
    UTF8_TABLE(248) = "195-184"
    UTF8_TABLE(249) = "195-185"
    UTF8_TABLE(250) = "195-186"
    UTF8_TABLE(251) = "195-187"
    UTF8_TABLE(252) = "195-188"
    UTF8_TABLE(253) = "195-189"
    UTF8_TABLE(254) = "195-190"
    UTF8_TABLE(255) = "195-191"
End Function




'Purpose:Convert Unicode string to UTF-8.
Private Function UTF8_Encode(ByVal strUnicode As String, Optional ByVal bHTML As Boolean = True) As String
   Dim i                As Long
   Dim TLen             As Long
   Dim lPtr             As Long
   Dim UTF16            As Long
   Dim UTF8_EncodeLong  As String

   TLen = Len(strUnicode)
   If TLen = 0 Then Exit Function

   If m_bIsNt Then
      Dim lngBufferSize    As Long
      Dim lngResult        As Long
      Dim bytUtf8()        As Byte
      'Set buffer for longest possible string.
      lngBufferSize = TLen * 3 + 1
      ReDim bytUtf8(lngBufferSize - 1)
      'Translate using code page 65001(UTF-8).
      lngResult = WideCharToMultiByte(CP_UTF8, 0, StrPtr(strUnicode), _
         TLen, bytUtf8(0), lngBufferSize, vbNullString, 0)
      'Trim result to actual length.
      If lngResult Then
         lngResult = lngResult - 1
         ReDim Preserve bytUtf8(lngResult)
         'CopyMemory StrPtr(UTF8_Encode), bytUtf8(0&), lngResult
         UTF8_Encode = StrConv(bytUtf8, vbUnicode)
         ' For i = 0 To lngResult
         '    UTF8_Encode = UTF8_Encode & Chr$(bytUtf8(i))
         ' Next
      End If
   Else
      For i = 1 To TLen
         ' Get UTF-16 value of Unicode character
         lPtr = StrPtr(strUnicode) + ((i - 1) * 2)
         CopyMemory UTF16, ByVal lPtr, 2
         'Convert to UTF-8
         If UTF16 < &H80 Then                                      ' 1 UTF-8 byte
            UTF8_EncodeLong = Chr$(UTF16)
         ElseIf UTF16 < &H800 Then                                 ' 2 UTF-8 bytes
            UTF8_EncodeLong = Chr$(&H80 + (UTF16 And &H3F))              ' Least Significant 6 bits
            UTF16 = UTF16 \ &H40                                   ' Shift right 6 bits
            UTF8_EncodeLong = Chr$(&HC0 + (UTF16 And &H1F)) & UTF8_EncodeLong  ' Use 5 remaining bits
         Else                                                      ' 3 UTF-8 bytes
            UTF8_EncodeLong = Chr$(&H80 + (UTF16 And &H3F))              ' Least Significant 6 bits
            UTF16 = UTF16 \ &H40                                   ' Shift right 6 bits
            UTF8_EncodeLong = Chr$(&H80 + (UTF16 And &H3F)) & UTF8_EncodeLong  ' Use next 6 bits
            UTF16 = UTF16 \ &H40                                   ' Shift right 6 bits
            UTF8_EncodeLong = Chr$(&HE0 + (UTF16 And &HF)) & UTF8_EncodeLong   ' Use 4 remaining bits
         End If
         UTF8_Encode = UTF8_Encode & UTF8_EncodeLong
      Next
   End If

   'Substitute vbCrLf with HTML line breaks if requested.
   If bHTML Then
      UTF8_Encode = Replace$(UTF8_Encode, vbCrLf, "<br>")
   End If

End Function






Attribute VB_Name = "Module1"
Option Explicit


Public Sub Main()
    Dim C As New CCustomer
    C.Add "Serrrot", "Fred", "A", "1.2.3.4", "200 State st", "Boston", "02166", "MA", "TypeA", "US", "fred@email.com", False
End Sub


Public Function PreProcess(ByVal strMessage As String, ParamArray defines() As Variant) As String
    Dim i           As Long
    Dim ii          As Long
    Dim varValue    As Variant
    Dim lngPos      As Long
    Dim lngPosEnd   As Long
    Dim booIsDefine As Boolean
    Dim lngTmpLen   As Long
    
    Const PREPROCESS_IF = "#IF"
    Const PREPROCESS_END = "#END"
    
'    For i = 0 To UBound(defines()) Step 2
'
'        lngPos = InStr(strMessage, PREPROCESS_IF & "[" & defines(i) & "]")
'        If lngPos Then
'
'            lngPosEnd = InStr(lngPos, strMessage, PREPROCESS_END)
'            varValue = defines(i + 1)
'            If Not CBool(varValue) Then
'                ' We clear the all text
'                strMessage = DeleteString(strMessage, lngPos, lngPosEnd - lngPos + Len(PREPROCESS_END) + Len(vbNewLine))
'            Else
'                ' Clear only the #IF[] and #END
'                lngTmpLen = Len(PREPROCESS_IF) + 2 + Len(defines(i)) + Len(vbNewLine)
'                strMessage = DeleteString(strMessage, lngPos, lngTmpLen)
'                lngPosEnd = lngPosEnd - lngTmpLen ' Change the lngPOS because we deleted the #IF[]
'                strMessage = DeleteString(strMessage, lngPosEnd - 1, Len(PREPROCESS_END) + Len(vbNewLine))
'            End If
'        End If
'    Next
    
    For i = 0 To UBound(defines()) Step 2
    
        varValue = defines(i + 1)
        If IsMissing(varValue) Then
            varValue = ""
        End If
        strMessage = Replace(strMessage, "[" & defines(i) & "]", CStr(varValue))
    Next
    PreProcess = strMessage
End Function


' RETURN        :
Public Function IsValidObject(ByVal o As Object) As Boolean


    'If IsMissing(o) Then Exit Function
    'If IsEmpty(o) Then Exit Function
    If Not IsObject(o) Then Exit Function
    If o Is Nothing Then Exit Function
    IsValidObject = True

End Function

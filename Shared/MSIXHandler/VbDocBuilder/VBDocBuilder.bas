Attribute VB_Name = "Module1"
Option Explicit


Public Function ShowParsingError(strCollection As Collection, lngItemIndex As Long, strMessage As String) As Boolean

    MsgBox strMessage & vbNewLine & strCollection(lngItemIndex), vbOKOnly + vbCritical, "Parsing error"
End Function

Public Function ProcessHTML(ByVal strS As String) As String
   strS = Replace(strS, """", "&quot;")
   strS = Replace(strS, "<", "&lt;")
   strS = Replace(strS, "&", "&amp;")
   strS = Replace(strS, "'", "&lsquo;")
   strS = Replace(strS, ">", "&gt;")
   ProcessHTML = strS
End Function

Public Function IndentHTML(strS As String) As String

    Dim strHTML As String
    
'    strHTML = strHTML & "<TABLE WIDTH=""100%"" CELLPADDING=""0"" CELLSPACING=""0"" BORDER=""0"">" & vbNewLine
'    strHTML = strHTML & "<TR>" & vbNewLine
'    strHTML = strHTML & "<TD width=""24"">&nbsp;</TD>" & vbNewLine
'    strHTML = strHTML & "<TD>" & vbNewLine
'    strHTML = strHTML & strS & vbNewLine
'    strHTML = strHTML & "</TD>" & vbNewLine
'    strHTML = strHTML & "</TR>" & vbNewLine
'    strHTML = strHTML & "</TABLE>" & vbNewLine

    'strHTML = strHTML & "<P>" & strS & "</P>" & vbNewLine
    strHTML = strHTML & "<BLOCKQUOTE><P>" & strS & "</P></BLOCKQUOTE>" & vbNewLine
    
    IndentHTML = strHTML
End Function


Public Function NoWrapHTML(strS As String) As String

    Dim strHTML As String
    
    strHTML = strHTML & "<TABLE WIDTH=""100%"" CELLPADDING=""0"" CELLSPACING=""0"" BORDER=""0"">" & vbNewLine
    strHTML = strHTML & "<TR>" & vbNewLine
    strHTML = strHTML & "<TD NOWRAP>" & vbNewLine
    strHTML = strHTML & strS & vbNewLine
    strHTML = strHTML & "</TD>" & vbNewLine
    strHTML = strHTML & "</TR>" & vbNewLine
    strHTML = strHTML & "</TABLE>" & vbNewLine
    
    NoWrapHTML = strHTML
End Function

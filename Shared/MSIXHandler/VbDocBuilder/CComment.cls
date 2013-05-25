VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CComment"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum COMMENT_TYPE
    COMMENT_TYPE_CLASS = 1
    COMMENT_TYPE_PROPERTY
    COMMENT_TYPE_FUNCTION
    COMMENT_TYPE_SUB
    COMMENT_TYPE_ENUM
    COMMENT_TYPE_PUBLIC_MEMBER
End Enum

Public Enum COMMENT_SECTION
    COMMENT_SECTION_NAME = 1
    COMMENT_SECTION_PARAMETERS = 2
    COMMENT_SECTION_DESCRIPTION = 3
    COMMENT_SECTION_RETURN = 4
    COMMENT_SECTION_VERSION = 5
End Enum


Public SourceLine   As String
Public Name         As String
Public Description  As String
Public Parameters   As String
Public Returns      As String
Public Author       As String
Public CommentType  As COMMENT_TYPE
Public Index        As Long
Public ComponantName As String
Public Version      As String

Public KEY_NAMES As New CVariables

Private Const HTML_TEMPLATE_ARGUMENT = "<BLOCKQUOTE><P><SPAN STYLE=""font-style : italic;""><I>[ARGUMENT_NAME]</I></SPAN></P><BLOCKQUOTE><P>[ARGUMENT_COMMENT]</P></BLOCKQUOTE></BLOCKQUOTE>"

' -------------------------------------------------------------------------------
' FUNCTION      : ParseCommentBlock
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function ParseCommentBlock(strCommentBlock As String) As Boolean

    Dim objParser           As New CByteSyntaxAnalyser
    Dim strTok              As String
    Dim lngStartPos         As Long
    Dim strChar             As String
    Dim strCurrentBlock     As String
    Dim strCurrentBlockName As String
    Dim booInternalFormatingOrder As Boolean
    
    objParser.Init strCommentBlock
    objParser.booAcceptPointInId = False
    objParser.booAcceptMinusInId = False
    
    Do While objParser.EOS() = rFALSE
    
        objParser.PushBytesIndex
        booInternalFormatingOrder = False
        
        If (objParser.GetIdentifier(strTok, False) = rSUCCEED) Then
            
            ' Internal Formating command
            If (UCase(strTok) = "COMMENT") And (objParser.GetChar(".") = rSUCCEED) Then
                If (objParser.GetIdentifier(strTok) = rSUCCEED) Then
                    Select Case strTok
                        Case "END"
                            booInternalFormatingOrder = True
                            Exit Do
                        Case Else
                            GoSub ConcatCurrentChar
                    End Select
                End If
            End If
        
            If (Not booInternalFormatingOrder) Then
                If (KEY_NAMES.Exist(strTok)) And (objParser.GetChar(":") = rSUCCEED) Then
                
                    objParser.NextChar
                    GoSub SaveCurrentSection
                    strCurrentBlockName = strTok ' Init the next block
                Else
                    GoSub ConcatCurrentChar
                End If
            End If
        Else
            GoSub ConcatCurrentChar
        End If
    Loop
    GoSub SaveCurrentSection
    ParseCommentBlock = True
    Exit Function
    
ConcatCurrentChar:
    objParser.PopBytesIndex
    strChar = objParser.GetCChar()
    
    'If (strCurrentBlockName = "DESCRIPTION") And (strChar = "-") Then
        'strChar = "<BR>-"
    'End If
    strCurrentBlock = strCurrentBlock & strChar
    objParser.NextChar
Return

SaveCurrentSection:
    If (Len(strCurrentBlockName)) Then ' Before we start a new comment section, we save the current one we have one
        strCurrentBlockName = GetInternalSectionName(strCurrentBlockName)
        
        If (strCurrentBlockName <> "NAME") Then ' We do not store this way the property name
        
            If (strCurrentBlock = vbLf) Then
            
                strCurrentBlock = ""
            End If
            If (strCurrentBlockName = "PARAMETERS") Then
            
                strCurrentBlock = Replace(strCurrentBlock, vbNewLine, "#CR#")
                strCurrentBlock = Replace(strCurrentBlock, "#CR#", "<BR>" & vbNewLine)
            End If
            If (strCurrentBlockName = "DESCRIPTION") Then
            
                strCurrentBlock = Replace(strCurrentBlock, vbNewLine, "#CR#")
                strCurrentBlock = Replace(strCurrentBlock, "#CR#", "<BR>" & vbNewLine)
            End If
            CallByName Me, strCurrentBlockName, VbLet, strCurrentBlock
        End If
    End If
    strCurrentBlockName = ""
    strCurrentBlock = ""
Return

End Function

Public Function Load(strCollection As Collection, lngItemIndex As Long, eCommentType As COMMENT_TYPE) As Boolean

    Dim strCommentBlock     As String
    Dim booRetVal           As Boolean
    
    CommentType = eCommentType
    SourceLine = Trim(GetEndLineWithoutComment(strCollection(lngItemIndex)))
    
'    If (UCase(Name) = "RENDERHTML") Then
'        Debug.Assert 0
'    End If
            
    Select Case eCommentType
        
        Case COMMENT_TYPE_FUNCTION, COMMENT_TYPE_SUB, COMMENT_TYPE_PROPERTY
        
            If (LoadFunctionComment(strCollection, lngItemIndex - 1, strCommentBlock)) Then
            
                If (ParseCommentBlock(strCommentBlock)) Then
                
                    booRetVal = True
                End If
            End If
        
        Case COMMENT_TYPE_ENUM
        
            If (LoadEnumComment(strCollection, lngItemIndex)) Then
                    booRetVal = True
            End If
        
        Case COMMENT_TYPE_CLASS
        
            SourceLine = ""
            If (LoadModuleComment(strCollection, strCommentBlock)) Then
                If (ParseCommentBlock(strCommentBlock)) Then
                    booRetVal = True
                End If
            End If
        
        Case COMMENT_TYPE_PUBLIC_MEMBER
            Me.Description = Me.GetEndLineComment(strCollection.Item(lngItemIndex))
            booRetVal = True
    End Select
    
    If (Not booRetVal) Then GoTo ShowParseError
    
    Load = booRetVal
    
    Exit Function
ShowParseError:
    ShowParsingError strCollection, lngItemIndex, "Cannot parse the function comment"
End Function


Public Function GetEndLineComment(strLine As String) As String
    
    Dim lngPos As Long
    
    lngPos = GetEndLineSimpleCodePos(strLine)
       
    If (lngPos) Then
    
        GetEndLineComment = Mid(strLine, lngPos + 1)
    End If
End Function


Public Function GetEndLineWithoutComment(strLine As String) As String
    
    Dim lngPos As Long
    lngPos = GetEndLineSimpleCodePos(strLine)
       
    If (lngPos) Then
    
        GetEndLineWithoutComment = Mid(strLine, 1, lngPos - 1)
    Else
        GetEndLineWithoutComment = strLine
    End If
End Function


Public Function GetEndLineSimpleCodePos(strLine As String) As Long

    Dim i As Long
    
    Dim booInCote As Boolean
    
    For i = 1 To Len(strLine)
    
        Select Case Mid(strLine, i, 1)
        
            Case "'"
                If (Not booInCote) Then
                    GetEndLineSimpleCodePos = i
                    Exit Function
                End If
            Case """"
                booInCote = Not booInCote
        End Select
    Next
End Function




Private Function LoadFunctionComment(strCollection As Collection, ByVal lngItemIndex As Long, ByRef strCommentBlock As String) As Boolean
    
    Dim strS As String
    strCommentBlock = ""
    
    If (Not IsLineComment(strCollection.Item(lngItemIndex))) Then
        
        LoadFunctionComment = True
        strCommentBlock = "DESCRIPTION : No Documentation"
        Exit Function
                
    End If
    Do While IsLineComment(strCollection.Item(lngItemIndex))
    
        strS = strCollection.Item(lngItemIndex) ' Remove the '
        strS = Trim(Replace(strS, vbTab, " "))
        strS = Mid(strS, 2)
        
        If (Len(Trim(strS)) = 0) Then ' a blank line comment that we going to turn into a break line
            'strS = "<BR><BR>"
        End If
        
        strCommentBlock = strS & vbNewLine & strCommentBlock
        lngItemIndex = lngItemIndex - 1
        LoadFunctionComment = True
    Loop
End Function

Private Function IsLineComment(strLine As String) As Boolean

    IsLineComment = Mid(Trim(Replace(strLine, vbTab, " ")), 1, 1) = "'"
End Function

Function GetInternalSectionName(strName As String) As String

    Dim eSectionType As COMMENT_SECTION
    Dim objKey       As CVariable
    
    If (KEY_NAMES.Exist(strName)) Then
        eSectionType = KEY_NAMES.Item(strName).Value
        
        For Each objKey In KEY_NAMES
            If objKey.Value = eSectionType And objKey.VbType = vbLong Then
            
                GetInternalSectionName = objKey.Name
                Exit Function
            End If
        Next
    End If
End Function

Private Sub Class_Initialize()

    KEY_NAMES.Add "NAME", COMMENT_SECTION.COMMENT_SECTION_NAME, vbLong
    KEY_NAMES.Add "CLASS", COMMENT_SECTION.COMMENT_SECTION_NAME
    KEY_NAMES.Add "DIALOG", COMMENT_SECTION.COMMENT_SECTION_NAME
    KEY_NAMES.Add "FUNCTION", COMMENT_SECTION.COMMENT_SECTION_NAME
    KEY_NAMES.Add "SUB", COMMENT_SECTION.COMMENT_SECTION_NAME
    KEY_NAMES.Add "PROPERTY", COMMENT_SECTION.COMMENT_SECTION_NAME
    KEY_NAMES.Add "METHOD", COMMENT_SECTION.COMMENT_SECTION_NAME
        
    KEY_NAMES.Add "DESCRIPTION", COMMENT_SECTION.COMMENT_SECTION_DESCRIPTION, vbLong
    
    KEY_NAMES.Add "PARAMETERS", COMMENT_SECTION.COMMENT_SECTION_PARAMETERS, vbLong
    
    KEY_NAMES.Add "RETURNS", COMMENT_SECTION.COMMENT_SECTION_RETURN, vbLong
    KEY_NAMES.Add "RETURN", COMMENT_SECTION.COMMENT_SECTION_RETURN
    
    KEY_NAMES.Add "VERSION", COMMENT_SECTION.COMMENT_SECTION_VERSION, vbLong
    
End Sub


Public Function HTMLDetail(booPrintHR As Boolean, Optional booSummary As Boolean = False) As String

    Dim strHTML As String
    
    Select Case CommentType
    
        Case COMMENT_TYPE_PROPERTY, COMMENT_TYPE_FUNCTION, COMMENT_TYPE_SUB
        
            If (booSummary) Then
            
                strHTML = strHTML & "<TD WIDTH=""32%"" BGCOLOR=""#ECECEC"" VALIGN=""TOP"" Class=""Table"">" & vbNewLine
                strHTML = strHTML & "<P CLASS=""Table"">" & vbNewLine
                strHTML = strHTML & "<A HREF=""#" & Name & """ ><SPAN STYLE=""font-weight : normal;"">" & Name & "</SPAN></A>" & vbNewLine
                strHTML = strHTML & "</P" & vbNewLine
                strHTML = strHTML & "</TD>" & vbNewLine
                
            Else
                
                strHTML = strHTML & "<A NAME=""#" & Name & """></A>" & vbNewLine
                strHTML = strHTML & "<H2>" & Me.Name & "</H2>" & vbNewLine
                                
                strHTML = strHTML & (Me.Description) & vbNewLine
                
                
                strHTML = strHTML & "<H3>Visual Basic Syntax</H3>" & vbNewLine
                
                strHTML = strHTML & "<FONT Face=""Courier New"" Size=""3"">" & ProcessDataForHtmlVBSourceCode(Me.SourceLine, True) & "</FONT>" & vbNewLine
                
                If (Len(Me.Parameters)) Then
                
                    strHTML = strHTML & "<H3>Arguments</H3>" & vbNewLine
                    strHTML = strHTML & ProcessParameter(Me.Parameters) & vbNewLine
                End If
                
                If (Len(Trim(Me.Returns))) Then
                    strHTML = strHTML & "<H3>Return Value</H3>" & vbNewLine
                    strHTML = strHTML & IndentHTML(Me.Returns) & vbNewLine
                End If
            End If
            
        Case COMMENT_TYPE_ENUM
        
            If (booSummary) Then
            
                strHTML = strHTML & "<TD WIDTH=""32%"" BGCOLOR=""#ECECEC"" VALIGN=""TOP"" Class=""Table"">" & vbNewLine
                strHTML = strHTML & "<P CLASS=""Table"">" & vbNewLine
                strHTML = strHTML & "<A HREF=""#" & Name & """ ><SPAN STYLE=""font-weight : normal;"">" & Name & "</SPAN></A>" & vbNewLine
                strHTML = strHTML & "</P" & vbNewLine
                strHTML = strHTML & "</TD>" & vbNewLine
            Else
            
                strHTML = strHTML & "<A NAME=""#" & Name & """></A>" & vbNewLine
                strHTML = strHTML & "<H2>" & Me.Name & "</H2>" & vbNewLine
                                
                strHTML = strHTML & IndentHTML(Me.Description) & vbNewLine
            
            End If
            
        
        Case COMMENT_TYPE_PUBLIC_MEMBER
        
            If (booSummary) Then
            
                strHTML = strHTML & "<TD WIDTH=""32%"" BGCOLOR=""#ECECEC"" VALIGN=""TOP"" Class=""Table"">" & vbNewLine
                strHTML = strHTML & "<P CLASS=""Table"">" & vbNewLine
                strHTML = strHTML & "<A HREF=""#" & Name & """><SPAN STYLE=""font-weight : normal;"">" & Name & "</SPAN></A>" & vbNewLine
                strHTML = strHTML & "</P" & vbNewLine
                strHTML = strHTML & "</TD>" & vbNewLine
            Else
                strHTML = strHTML & "<A NAME=""#" & Name & """></A>" & vbNewLine
                strHTML = strHTML & "<H2>" & Me.Name & "</H2>" & vbNewLine
                strHTML = strHTML & (Me.Description) & vbNewLine
                strHTML = strHTML & "<H3>Visual Basic Syntax</H3>" & vbNewLine
                strHTML = strHTML & "<FONT Face=""Courier New"" Size=""3"">" & ProcessDataForHtmlVBSourceCode(Me.SourceLine, True) & "</FONT>" & vbNewLine & vbNewLine
            End If
            
        Case COMMENT_TYPE_CLASS
        
            strHTML = strHTML & "<HTML><HEAD><TITLE>" & Me.Name & "</TITLE></HEAD><BODY>"
        
            strHTML = strHTML & "<H1>" & Me.Name & "</H1>" & vbNewLine
            strHTML = strHTML & Me.Description & vbNewLine & vbNewLine
            strHTML = strHTML & "<H2>" & "Program ID" & "</H2>" & vbNewLine
            strHTML = strHTML & Me.ProgId & vbNewLine
            

    End Select
    
    If (booPrintHR) Then
        strHTML = strHTML & "<BR><HR WIDTH=""100%"" SIZE=""2"" Align=""CENTER""><BR>"
    End If
    HTMLDetail = strHTML
End Function


Private Function LoadModuleComment(strCollection As Collection, ByRef strCommentBlock As String) As Boolean
    
    Dim strS            As String
    Dim lngItemIndex    As Long
    Dim objParser       As New CByteSyntaxAnalyser
    
    lngItemIndex = 1
    
    Do
    
        If (lngItemIndex > strCollection.Count) Then
            LoadModuleComment = True
            Exit Function
        End If
        objParser.Init strCollection.Item(lngItemIndex)
        
        If (objParser.GetChar("'") = rSUCCEED) Then ' Find where the first comment start in the module
            Do
                objParser.Init strCollection.Item(lngItemIndex)
                If (objParser.GetChar("'") = rSUCCEED) Then ' Find where the first comment start in the module
                
                    lngItemIndex = lngItemIndex + 1
                Else
                    Exit Do
                End If
            Loop
            LoadModuleComment = LoadFunctionComment(strCollection, lngItemIndex - 1, strCommentBlock)
            Exit Do
        End If
        lngItemIndex = lngItemIndex + 1
    Loop
    
End Function


Public Function ProcessDataForHtmlVBSourceCode(ByVal strS As String, Optional EnhanceVBCode As Boolean = False) As String

    'strS = Replace(strS, vbNewLine & vbNewLine, "[#CR]")
    'strS = Replace(strS, "[#CR]", "<BR>" & vbNewLine)
    
    
    If (EnhanceVBCode) Then
    
        strS = Replace(strS, "Optional ", "<B><I>Optional </B></I>")
        strS = Replace(strS, "ByRef ", "<B><I>ByRef </B></I>")
        
        strS = Replace(strS, "()", "{}")
        strS = Replace(strS, ", ", ",<BR>&nbsp;&nbsp;")
        strS = Replace(strS, "(", "(<BR>&nbsp;&nbsp;")
        strS = Replace(strS, ")", "<BR>)")
        strS = Replace(strS, "{}", "()")
    End If
    ProcessDataForHtmlVBSourceCode = IndentHTML(strS)
    
    
End Function

Public Property Get ProgId() As String
    If (Len(ComponantName) = 0) Then
        ComponantName = "#COMPONANT_NAME#"
    End If
    ProgId = ComponantName & "." & Name
End Property



Private Function LoadEnumComment(strCollection As Collection, ByVal lngItemIndex As Long) As Boolean
    
    Dim strEnumItemName      As String
    Dim strEnumItemComment   As String
    Dim strComment           As String
    Dim objParser            As New CByteSyntaxAnalyser
    Dim strEnumID            As String
    Dim strTmp               As String
    
    
    strEnumItemComment = GetEndLineComment(strCollection.Item(lngItemIndex))
    If (Len(strEnumItemComment) = 0) Then
    
        strEnumItemComment = "Not Documented"
    End If
    Description = strEnumItemComment & "<BR><BR>"
    
    Description = Description & "<TABLE WIDTH=""100%"" CELLPADDING=""0"" CELLSPACING=""0"" BORDER=""0"">" & vbNewLine
    
    lngItemIndex = lngItemIndex + 1
    
    Do
        objParser.Init strCollection.Item(lngItemIndex)
        
        If (objParser.GetIdentifier(strEnumItemName, False) = rSUCCEED) Then
        
            If UCase(strEnumItemName) = "END" Then Exit Do

            Description = Description & "<TR>" & vbNewLine
    
            Description = Description & "<TD nowrap>" & vbNewLine
    
            strTmp = GetEndLineWithoutComment(strCollection.Item(lngItemIndex))
            Description = Description & "<font face=""courier new"">" & strTmp & "</font>"
            
            Description = Description & "</TD>" & vbNewLine
            Description = Description & "<TD>&nbsp;</TD>" & vbNewLine
            
            Description = Description & "<TD nowrap>" & vbNewLine
            
            Description = Description & GetEndLineComment(strCollection.Item(lngItemIndex))
            Description = Description & "</TD>" & vbNewLine
            
            Description = Description & "</TR>" & vbNewLine
        End If
        lngItemIndex = lngItemIndex + 1
    Loop
    Description = Description & "</TABLE>" & vbNewLine
    LoadEnumComment = True
        
End Function




Public Function ProcessParameter(strParameters As String) As String

    Dim strS        As String
    Dim objParser   As New CByteSyntaxAnalyser
    Dim strTok      As String
    
    
    objParser.Init strParameters
    
    Do While objParser.EOS() = rFALSE
    
        objParser.PushBytesIndex
        
        If (objParser.GetIdentifier(strTok, False) = rSUCCEED) Then
        
            If (objParser.GetChar("-") = rSUCCEED) Then
        
                If (Len(strS)) Then
                    strS = strS & "[CRLF]</P>[CRLF]</BLOCKQUOTE>[CRLF]</BLOCKQUOTE>[CRLF]"
                End If
                strS = strS & "<BLOCKQUOTE>[CRLF]<P>[CRLF]<SPAN STYLE=""font-style : italic;"">[CRLF]<I>[CRLF]" & strTok & "[CRLF]</I>[CRLF]</SPAN>[CRLF]</P>[CRLF]<BLOCKQUOTE>[CRLF]<P>[CRLF]"
                objParser.PopBytesIndex False
            Else
                objParser.PopBytesIndex
                strS = strS & objParser.GetCChar()
                objParser.NextChar
            End If
        Else
            objParser.PopBytesIndex
            strS = strS & objParser.GetCChar()
            objParser.NextChar
        End If
    Loop
    strS = strS & "[CRLF]</P>[CRLF]</BLOCKQUOTE>[CRLF]</BLOCKQUOTE>[CRLF]"
    ProcessParameter = Replace(strS, "[CRLF]", vbCrLf)
    
End Function

VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDocBuilder"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public FileName     As String
Public OutPutDir    As String
Public Comments     As New CComments
Public m_strLignes   As Collection
Public m_strHTMLDoc  As String

Public Event ProcessFile(strFileName As String)
Public Event ProcessItem(strType As String, strItem As String)
Public Event Continue(booContinue As Boolean)


Public Function BuildDocumentation(strVBFile As String, strOutPutDir As String, Optional booShow As Boolean = False) As Boolean

    Dim objTextFile As New cTextFile
    Dim strFileName As String
    Dim strOutPutFileName As String
    Dim objToOl     As New cTool
    
    strFileName = objTextFile.GetFileName(strVBFile)
    FileName = strVBFile
    OutPutDir = strOutPutDir
    
    RaiseEvent ProcessFile(strFileName)
    
    Comments.Clear
    If (Not LoadFile()) Then Exit Function
    If (Not ParseFile()) Then Exit Function
    
    strOutPutFileName = strOutPutDir & "\" & Comments.GetClassName() & ".htm"
   
    If (Comments.BuildHTMLDoc(strOutPutFileName)) And booShow Then
    
        objToOl.ExecFile strOutPutFileName
    Else
        
    End If
    BuildDocumentation = True
    
End Function

Public Function ParseFile() As Boolean
   
   Dim i            As Long
   Dim objParser    As New CByteSyntaxAnalyser
   Dim strTok       As String
   Dim objComment   As CComment
   Dim strName      As String
   Dim strPropertyType  As String
   Dim booLineDocumented As Boolean
   
   For i = 1 To m_strLignes.Count
   
        objParser.Init m_strLignes.Item(i)
        
        ' If we find in the string documented=no we skip the function,sub,property
        booLineDocumented = InStr(UCase(m_strLignes.Item(i)), "DOCUMENTED=NO") = 0
        
        If (booLineDocumented) Then
            
            If (objParser.GetIdentifier(strTok) = rSUCCEED) Then
            
                If (strTok = "ATTRIBUTE") Then
                
                    If (objParser.GetIdentifier(strTok) = rSUCCEED) Then
                    
                        If (strTok = "VB_NAME") Then
                        
                            If (objParser.GetChar("=") = rSUCCEED) Then
                            
                                If (objParser.GetString(strName) = rSUCCEED) Then
                        
                                RaiseEvent ProcessItem("Class", strName)
                                Set objComment = Comments.Add(strName)
                                objComment.Load m_strLignes, 1, COMMENT_TYPE_CLASS
                                End If
                            End If
                        End If
                    End If
                End If
                
                If (strTok = "PUBLIC") Then
                
                    If (objParser.GetIdentifier(strTok, False) = rSUCCEED) Then
                    
                        objParser.GetIdentifier strName, False
                
                        Select Case UCase(strTok)
                        
                            Case "FUNCTION"
                            
                                RaiseEvent ProcessItem("FUNCTION", strName)
                                Set objComment = Comments.Add(strName)
                                objComment.Load m_strLignes, i, COMMENT_TYPE_FUNCTION
                                
                            Case "SUB"
                            
                                RaiseEvent ProcessItem("SUB", strName)
                                Set objComment = Comments.Add(strName)
                                objComment.Load m_strLignes, i, COMMENT_TYPE_SUB
                                
                            Case "PROPERTY"
                            
                                strPropertyType = strName
                                objParser.GetIdentifier strName, False
                                
                                RaiseEvent ProcessItem("PROPERTY", strName)
                                Set objComment = Comments.Add(strName & " (" & strPropertyType & ")")
                                objComment.Load m_strLignes, i, COMMENT_TYPE_PROPERTY

                                
                            Case "ENUM"
                                RaiseEvent ProcessItem("ENUM", strName)
                                Set objComment = Comments.Add(strName)
                                objComment.Load m_strLignes, i, COMMENT_TYPE_ENUM
                            
                            
                            Case Else
                                RaiseEvent ProcessItem("MEMBER", strTok)
                                Set objComment = Comments.Add(strTok) ' special case
                                objComment.Load m_strLignes, i, COMMENT_TYPE_PUBLIC_MEMBER
                        End Select
                    End If
                End If
            End If
        End If
   Next
   ParseFile = True
End Function

Public Function LoadFile() As Boolean

    Dim objTextFile As New cTextFile
    Dim s           As String
    
    If objTextFile.OpenFile(FileName) Then
            
        Set m_strLignes = New Collection
        
        Do While Not objTextFile.EOF

            s = objTextFile.ReadLn()
            If (Len(s)) Then
                Do While Right(s, 1) = "_"
                
                    s = s & vbCrLf & objTextFile.ReadLn()
                Loop
            End If
            m_strLignes.Add s
        Loop
        objTextFile.CloseFile
        LoadFile = True
    End If
End Function


Public Function BuildDocumentations(strPATH As String, strOutPutDir As String) As Boolean

    Dim objTextFile As New cTextFile
    Dim objFiles    As New CVariables
    Dim objFile     As New CVariable
    Dim booContinue As Boolean
    
    If (objTextFile.GetFilesList(strPATH, "*.cls", objFiles)) Then
    
        For Each objFile In objFiles
        
            Me.BuildDocumentation objFile.Value, strOutPutDir
            DoEvents
            RaiseEvent Continue(booContinue)
            If (Not booContinue) Then
                MsgBox "Processing stopped by the user..."
                Exit Function
            End If
        Next
    End If
End Function

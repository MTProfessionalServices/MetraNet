VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CComments"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Copyright 1998-2000 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 09/30/200
'  Description  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Private mCol                    As Collection


Public Property Get Item(vntKey As Variant) As CComment
Attribute Item.VB_UserMemId = 0
   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(CLng(vntKey))
   Else
        Set Item = mCol(UCase(vntKey))
   End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

Public Sub Remove(vntKey As Variant)
    On Error GoTo ErrMgr
    
    If IsNumeric(vntKey) Then
         mCol.Remove vntKey
    Else
        mCol.Remove UCase(vntKey)
    End If
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Property Get Count() As Long
    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()
    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()
    On Error GoTo ErrMgr
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Sub Clear()
    On Error GoTo ErrMgr
    Do While Count > 0
        Remove 1
    Loop
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Function GetLastIndex(eType As COMMENT_TYPE) As Long
    Dim objComment      As CComment
    Dim objLastComment  As CComment
        
    For Each objComment In Me
        If (objComment.CommentType = eType) Then
            Set objLastComment = objComment
        End If
    Next
    If (Not objLastComment Is Nothing) Then
        GetLastIndex = objLastComment.Index
    End If
End Function

Public Function GetClassName() As String

    Dim objComment      As CComment
    
    For Each objComment In Me
    
        If (objComment.CommentType = COMMENT_TYPE_CLASS) Then
        
            GetClassName = objComment.Name
        End If
    Next
End Function


Public Function Add(strName As String) As CComment

    On Error GoTo ErrMgr
      
    Dim clsV As CComment
    
    Set clsV = New CComment
    
    If (Exist(strName)) Then Me.Remove strName ' Remove the instance if already exist...
    
    clsV.Name = strName
    
    mCol.Add clsV, UCase(strName)
    clsV.Index = mCol.Count
    Set Add = clsV
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function




Public Property Get Exist(vntKey As Variant) As Boolean
   On Error GoTo ErrMgr
   Dim Itm As CComment
   Set Itm = Me.Item(vntKey)
   Exist = Not (Itm Is Nothing)
   Exit Property
ErrMgr:
   Err.Clear
End Property

Public Function BuildHTMLDoc(strOutPutFile As String) As Boolean

    Dim objComment As CComment
    Dim strHTML    As String
    Dim objTextFile As New cTextFile
    Dim objMainComment As CComment
    
    
    ' Class Info
    For Each objComment In Me

        If (objComment.CommentType = COMMENT_TYPE_CLASS) Then
        
            strHTML = strHTML & objComment.HTMLDetail(False)
            Set objMainComment = objComment
        End If
    Next
    
    
    ' EnumType List
    strHTML = strHTML & "<BR><H2>" & objMainComment.Name & " Enum Type</H2>" & vbNewLine
    strHTML = strHTML & "<TABLE WIDTH=""100%"" CELLPADDING=""3"" CELLSPACING=""2"" BORDER=""1"">" & vbNewLine
    For Each objComment In Me
        
        If (objComment.CommentType = COMMENT_TYPE_ENUM) Then
        
            strHTML = strHTML & "<TR>" & vbNewLine
            strHTML = strHTML & objComment.HTMLDetail(False, True)
            strHTML = strHTML & "</TR>" & vbNewLine
        End If
    Next
    strHTML = strHTML & "</TABLE>" & vbNewLine
    
    
    ' Methods List
    strHTML = strHTML & "<BR><H2>" & objMainComment.Name & " Methods</H2>" & vbNewLine
    strHTML = strHTML & "<TABLE WIDTH=""100%"" CELLPADDING=""3"" CELLSPACING=""2"" BORDER=""1"">" & vbNewLine
    For Each objComment In Me
        
        If (objComment.CommentType = COMMENT_TYPE_FUNCTION) Or (objComment.CommentType = COMMENT_TYPE_SUB) Then
        
            strHTML = strHTML & "<TR>" & vbNewLine
            strHTML = strHTML & objComment.HTMLDetail(False, True)
            strHTML = strHTML & "</TR>" & vbNewLine
        End If
    Next
    strHTML = strHTML & "</TABLE>" & vbNewLine
    
    ' Properties List
    strHTML = strHTML & "<BR><H2>" & objMainComment.Name & " Properties</H2>" & vbNewLine
    strHTML = strHTML & "<TABLE WIDTH=""100%"" CELLPADDING=""3"" CELLSPACING=""2"" BORDER=""1"">" & vbNewLine
    For Each objComment In Me
        
        If (objComment.CommentType = COMMENT_TYPE_PUBLIC_MEMBER) Or (objComment.CommentType = COMMENT_TYPE_PROPERTY) Then
        
            strHTML = strHTML & "<TR>" & vbNewLine
            strHTML = strHTML & objComment.HTMLDetail(False, True)
            strHTML = strHTML & "</TR>" & vbNewLine
        End If
    Next
    strHTML = strHTML & "</TABLE>" & vbNewLine
        
    
    ' Enum Type details
    strHTML = strHTML & "<BR><BR><H1>Enum Type Detail</H1>" & vbNewLine
    strHTML = strHTML & "<HR WIDTH=""100%"" SIZE=""2"" Align=""CENTER"">" & vbNewLine
    For Each objComment In Me
    
        If (objComment.CommentType = COMMENT_TYPE_ENUM) Then
        
            strHTML = strHTML & objComment.HTMLDetail(True, False)
        End If
    Next
    
    
    
    ' Method details
    strHTML = strHTML & "<BR><BR><H1>Method Detail</H1>" & vbNewLine
    strHTML = strHTML & "<HR WIDTH=""100%"" SIZE=""2"" Align=""CENTER"">" & vbNewLine
    For Each objComment In Me
    
        If (objComment.CommentType = COMMENT_TYPE_FUNCTION) Or (objComment.CommentType = COMMENT_TYPE_SUB) Then
        
            strHTML = strHTML & objComment.HTMLDetail(objComment.Index < GetLastIndex(COMMENT_TYPE_FUNCTION) Or objComment.Index < GetLastIndex(COMMENT_TYPE_SUB))
        End If
    Next
    
    ' Property details
    strHTML = strHTML & "<BR><BR><H1>Property Detail</H1>" & vbNewLine
    strHTML = strHTML & "<HR WIDTH=""100%"" SIZE=""2"" Align=""CENTER"">" & vbNewLine
    For Each objComment In Me
    
        If (objComment.CommentType = COMMENT_TYPE_PUBLIC_MEMBER) Or (objComment.CommentType = COMMENT_TYPE_PROPERTY) Then
        
            strHTML = strHTML & objComment.HTMLDetail(objComment.Index < GetLastIndex(COMMENT_TYPE_PUBLIC_MEMBER) Or objComment.Index < GetLastIndex(COMMENT_TYPE_PROPERTY)) & vbNewLine
        End If
    Next
    
    
    strHTML = strHTML & "</BODY></HTML>"
    
    
    Dim objVBCommentMacroProcessor As New CPreProcessor
    objVBCommentMacroProcessor.Add "code", "<font face='courier new' size='2'>"
    objVBCommentMacroProcessor.Add "/code", "</font>"
    
    objTextFile.LogFile strOutPutFile, objVBCommentMacroProcessor.process(strHTML, "<", ">"), True
    BuildHTMLDoc = True
    
End Function

 

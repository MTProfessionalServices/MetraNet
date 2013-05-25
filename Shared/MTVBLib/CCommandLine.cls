VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CCommandLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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
'  DATE         : 09/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private mCol                        As Collection

Public CommandString            As String

Public Property Get Item(vntKey As Long) As String
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   
   
   Dim i As Long
   
   If (IsNumeric(vntKey)) Then
        Item = mCol(vntKey)
   Else
        
   End If
   Exit Property
ErrMgr:
   Item = Empty
End Property

Public Sub Remove(vntKey As Variant)
    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Exit Sub
ErrMgr:

End Sub

Public Property Get Count() As Long
   Count = mCol.Count
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
   Set NewEnum = mCol.[_NewEnum]
End Property

Private Sub Class_Initialize()
    Set mCol = New Collection
End Sub

Private Sub Class_Terminate()
    Clear
    Set mCol = Nothing
End Sub

Public Sub Clear()
    Do While Count > 0
        Remove 1
    Loop
End Sub

Public Function Add(ByVal s As String) As Variant
    
    On Error GoTo ErrMgr
    mCol.Add s
    Add = s
    Exit Function
ErrMgr:
    Add = Empty
End Function


Public Function Init(ByVal strCommand As String) As Boolean
    Dim l       As New CByteSyntaxAnalyser
    Dim tok     As String
    
    CommandString = strCommand
    l.Init strCommand
    
    Do
        l.PushBytesIndex
        
        ' Test if we have a string
        If (l.GetChar("""") = rSUCCEED) Then
            l.PopBytesIndex
            If l.GetString(tok) = rFAILED Then Exit Function
        Else
            If l.GetUpToChar(" ", tok) = rFAILED Then Exit Function
            'l.PopBytesIndex
        End If
        If (Len(tok)) Then
            Me.Add tok
        Else
            Exit Do
        End If
        l.KillSpace
        If (l.EOS() = rSUCCEED) Then Exit Do
    Loop
    Init = True
    
End Function


Public Function Exist(vntKey As Variant) As Boolean

   On Error GoTo ErrMgr
   
    Dim s As String
    Dim i As Long
    
    If (IsNumeric(vntKey)) Then
    
        s = mCol(vntKey) ' if no error
        Exist = CLng(vntKey)
    Else
    
        For i = 1 To Me.Count
        
            If UCase(Item(i)) = UCase(vntKey) Then
            
                Exist = CBool(i)
                Exit Function
            End If
        Next
    End If
    Exit Function
ErrMgr:

End Function


Public Function GetValue(ByVal vntKey As Variant, Optional ByVal vntDefaultValue As Variant) As Variant
   GetValue = Arguments(vntKey, vntDefaultValue)
End Function


Public Function Arguments(ByVal strName As String, Optional ByVal varDefaultValue As Variant) As Variant

    Dim i As Long
    
    For i = 1 To Count
    
        If UCase$(Item(i)) = UCase$(strName) Then
            
            Arguments = Item(i + 1)
            Exit Function
        End If
    Next
    If IsMissing(varDefaultValue) Then varDefaultValue = Empty ' because MISSING is not supported by VBScript
    Arguments = varDefaultValue
End Function



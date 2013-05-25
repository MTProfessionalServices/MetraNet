VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CVariantStack"
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
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private Size        As Long
Private Sp          As Long
Private Stack()     As Variant

Public Sub Init(Size As Long)
    Size = Size
    Erase Stack()
    ReDim Stack(Size)
    Sp = 0
End Sub

Public Sub Done()
    Erase Stack()
End Sub

Public Function Push(v1 As Variant) As Boolean
    On Error GoTo ErrMgr
    
    Sp = Sp + 1
    If IsObject(v1) Then
        Set Stack(Sp) = v1
    Else
        Stack(Sp) = v1
    End If
    Push = True
    Exit Function
    
ErrMgr:
    Err.Raise vbObjectError + 1, App.EXEName & ".CVariantStack", "Stack error on Push(). Stack overflow!"
End Function

Public Function Peek(Optional DoSet As Boolean = False) As Variant
    If DoSet Then
        Set Peek = Pop()
    Else
        Peek = Pop()
    End If
    Sp = Sp + 1
End Function

Public Function Pop() As Variant
    On Error GoTo ErrMgr
    If IsObject(Stack(Sp)) Then
        Set Pop = Stack(Sp)
    Else
        Pop = Stack(Sp)
    End If
    Sp = Sp - 1
    Exit Function
ErrMgr:
    Err.Raise vbObjectError + 2, App.EXEName & ".CVariantStack", "Stack error on Pop(). No more data!"
End Function

Public Function StringInfo() As String
    StringInfo = "size:" & Size & " sp:" & Sp & " free:" & 100 - CInt(Sp / Size * 100) & "%"
End Function

Public Function ToString() As String
    Dim s As String
    Dim i As Long
    
    For i = 1 To Sp
        If IsObject(Stack(i)) Then
            s = s & Format(i, "000") & "-" & Stack(i) & ";"
        Else
            s = s & Format(i, "000") & "-" & Stack(i) & ";"
        End If
    Next
    ToString = s
End Function

Public Function EOS() As Boolean
    EOS = CBool(Sp = 0)
End Function
 
Private Sub Class_Initialize()
    Init 1024
End Sub

Public Sub Clear()
    Sp = 0
End Sub

VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cIniFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
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
'  CLASS        : CPipeLineAccess
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
'**************************************************************************
Option Explicit

Public iniFileName As String

#If Win16 Then
    Private Declare Function GetPrivateProfileString% Lib "kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpDefault$, ByVal lpReturnedString$, ByVal nSize%, ByVal lpFileName$)
    Private Declare Function WritePrivateProfileString% Lib "kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpString$, ByVal lpFileName$)
#Else
    Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
    Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
#End If



  
    
    
 
 
Public Function Init(fileName_ As String) As Boolean
  iniFileName = fileName_
  Init = True
End Function

Public Function getVar(ByVal Section As String, ByVal Var As String, Optional ByVal strDefaultValue As String, Optional lngMaxStringSize = 4096) As String
'
' COMMENT   : Return the value of the var Var from the section Section
'
' IN        : Section, Var
'
' OUT       :
'
' RETURN    : The var value or "" if an error occurs.
'
    
    Dim buffer  As String
    Dim errCode As Integer
    Dim strVal  As String
    
    On Error GoTo ErrMgr
    
    buffer = String$(lngMaxStringSize, " ")
    errCode = GetPrivateProfileString(Section, Var, "", buffer, lngMaxStringSize, iniFileName)
    If (errCode) Then
        buffer = Trim(buffer)
        strVal = Mid(buffer, 1, Len(buffer) - 1)
    End If
    If (Len(strVal) = 0) Then
        strVal = strDefaultValue
    End If
    getVar = strVal
    Exit Function
ErrMgr:
    strVal = strDefaultValue
 End Function
Public Function Var(Section As String, vName As String, Optional Value As Variant) As Variant
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    If IsMissing(Value) Then
        ' Do a read
        Var = Me.getVar(Section, vName)
    Else
        ' Do a write
        Var = True
        Me.setVar Section, vName, Value
    End If
End Function
Public Sub setVar(ByVal Section As String, ByVal Var As String, ByVal Value As String)
'
' COMMENT   : Set the value of the ini variable Var from the section Section
'
' IN        : Section, Var, Value.
'
' OUT       :
'
' RETURN    :
'
   Dim r As Long
   r = WritePrivateProfileString(Section, Var, Value, iniFileName)
End Sub



Public Sub Done()
'
' COMMENT   : Close the inifile session
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
'  setVar "CLASS", "TClassIniFile", "No"
'  setVar "CLASS", "LastDone", Date & " " & Time$
End Sub


 
Public Sub getForm(w As Object)

'
' COMMENT   : Read and set from the ini file the values of the controls of the form w.
'           This sub and setForm must be used to manage application config dialog.
'           They automatically read and write control value of a form.
'           Only 4 controls are included : TextBox, CheckBox, OptionButton, ComboBox.
'           OptionButton must be an array in a group.
' IN        : w
'
' OUT       :
'
' RETURN    :
'
    Dim x   As Variant
    Dim v   As Integer
    Dim s   As String
    
    ' Set in the inifile the last date-time the form controls was read.
    setVar w.Name, "GetForm.Date", Date$ & " " & time$
    
    For Each x In w.Controls
    
        If TypeOf x Is TextBox Then
        
            If (CtrlHasIndex(x)) Then
                s = getVar(w.Name, x.Name & "(" & x.Index & ")")
            Else
                s = getVar(w.Name, x.Name)
            End If
            If (Len(s)) Then x.Text = s
        End If
        
        If TypeOf x Is CheckBox Then
        
            If (CtrlHasIndex(x)) Then
                s = getVar(w.Name, x.Name & "(" & x.Index & ")")
            Else
                s = getVar(w.Name, x.Name)
            End If
            If (Len(s)) Then x.Value = Val(s)
        End If
        
        If TypeOf x Is OptionButton Then
            
            s = getVar(w.Name, x.Name)
            If (Len(s)) Then
                v = Val(s)
                If v = x.Index Then x.Value = True
            End If
        End If
        
        If TypeOf x Is ComboBox Then
        
            v = 1: s = "$"
            Do While s <> ""
                s = getVar(w.Name, x.Name & "(" & v & ")")
                If s <> "" Then x.AddItem s
                v = v + 1
            Loop
            s = getVar(w.Name, x.Name & ".Selected ")
            If (Len(s)) Then
                v = Val(s)
                x.ListIndex = v - 1
            End If
        End If
    Next
End Sub
 

Public Sub setForm(w As Object)
 
'
' COMMENT   : Save to the ini file the values of the controls of the form w.
'           This sub and setForm must be used to manage application config dialog.
'           They automatically read and write control value of a form.
'           Only 4 controls are included : TextBox, CheckBox, OptionButton, ComboBox.
'           OptionButton must be an array in a group.
' IN        : w
'
' OUT       :
'
' RETURN    :
'
    Dim x As Variant
    
    ' Set in the inifile the last date-time the form controls was modified
    setVar w.Name, "SetForm.Date", Date$ & " " & time$
    For Each x In w.Controls
    
        If TypeOf x Is TextBox Then
            If (CtrlHasIndex(x)) Then
                setVar w.Name, x.Name & "(" & x.Index & ")", x.Text
            Else
                setVar w.Name, x.Name, x.Text
            End If
        End If
        
        If TypeOf x Is CheckBox Then
        
            If (CtrlHasIndex(x)) Then
                setVar w.Name, x.Name & "(" & x.Index & ")", x.Value
            Else
                setVar w.Name, x.Name, x.Value
            End If
        End If
        
        If TypeOf x Is OptionButton Then
            If x.Value Then
                setVar w.Name, x.Name, "" & x.Index
            End If
        End If
        
        If TypeOf x Is ComboBox Then
            setVar w.Name, x.Name & ".selected", "" & x.ListIndex + 1
        End If
    Next
End Sub


 

 
 
 

Public Function InitAutomatic(appp As Object) As Boolean
'
' COMMENT   : Open the ini file according to the name of the application
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Init appp.path & "\" & appp.EXEName & ".ini"
    InitAutomatic = True
End Function

 


Public Function FormSaveRestore(f As Object, doSave As Boolean, Optional setSize As Boolean = False, Optional configName As String) As Boolean

    On Error GoTo ErrMgr
    
    If doSave Then
        If f.WindowState = 0 Then
            Me.setVar f.Name & "." & configName, "LEFT", f.Left
            Me.setVar f.Name & "." & configName, "TOP", f.Top
            Me.setVar f.Name & "." & configName, "WIDTH", f.Width
            Me.setVar f.Name & "." & configName, "HEIGHT", f.Height
            Me.setVar f.Name & "." & configName, "SET", "YES"
        End If
        
    Else
        If Me.getVar(f.Name & "." & configName, "SET") = "YES" Then
            f.Left = Me.getVar(f.Name & "." & configName, "LEFT")
            f.Top = Me.getVar(f.Name & "." & configName, "TOP")
            If setSize Then
                f.Width = Me.getVar(f.Name & "." & configName, "WIDTH")
                f.Height = Me.getVar(f.Name & "." & configName, "HEIGHT")
            End If
        End If
    End If
    FormSaveRestore = True
    Exit Function
ErrMgr:
End Function






Public Function FontSaveRestore(strFontId As String, clsFont As StdFont, booSave As Boolean) As Boolean
    On Error GoTo ErrMgr
    
    If (booSave) Then
        Me.setVar strFontId, strFontId & ".Name", clsFont.Name
        Me.setVar strFontId, strFontId & ".Bold", clsFont.Bold
        Me.setVar strFontId, strFontId & ".Italic", clsFont.Italic
        Me.setVar strFontId, strFontId & ".Size", clsFont.Size
        Me.setVar strFontId, strFontId & ".Strikethrough", clsFont.Strikethrough
        Me.setVar strFontId, strFontId & ".Underline", clsFont.Underline
        Me.setVar strFontId, strFontId & ".Weight", clsFont.Weight
    Else
        clsFont.Name = Me.getVar(strFontId, strFontId & ".Name")
        clsFont.Bold = Me.getVar(strFontId, strFontId & ".Bold")
        clsFont.Italic = Me.getVar(strFontId, strFontId & ".Italic")
        clsFont.Size = Me.getVar(strFontId, strFontId & ".Size")
        clsFont.Strikethrough = Me.getVar(strFontId, strFontId & ".Strikethrough")
        clsFont.Underline = Me.getVar(strFontId, strFontId & ".Underline")
        clsFont.Weight = Me.getVar(strFontId, strFontId & ".Weight")
    End If
    FontSaveRestore = True
    Exit Function
ErrMgr:
End Function


Private Function CtrlHasIndex(ctrl As Variant) As Boolean

    Dim v As Variant
    
    On Error GoTo ErrMgr
    
    v = ctrl.Index
    CtrlHasIndex = True
    Exit Function
ErrMgr:
    Err.Clear
End Function

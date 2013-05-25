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
' PREVIOUS HISTORY
' ****************************************************************************************************************************************************
'
'                                           OoVbLib5
'
'                               Object Oriented Visual Basic Library
'
'                                     Visual Basic Version 5
'
'                                TORRES Frederic 1995,1996,1997
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' History :
'
'  From VbLib3 for Visual basic 3
'  From OoVbLib4 For Visual Basic 16b/32b
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME      : CIniFile.cls
'
' FULLNAME  : Class iniFile.
'
' VERSION   :
'
' COMMENT   : Gestion des fichiers fichiers ini.
'           Introduction en 09/97 de la notion de macro dans les fichiers ini qui est un concept
'           deposé.
'
'           19/11/97 Sophia - add language management 19/11/97
'
'           21/11/98 Boston, suppression de la notion de langue qui d'ailleurs a echoue...
'                    Supprime le concept de macro. Que je remettrai un jour si j'en ai besoim
'                    Mais en utilisant la classe CStringReplacer...
' ******************************************************************************************************

Option Explicit

Public iniFileName As String

#If Win16 Then
    Private Declare Function GetPrivateProfileString% Lib "kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpDefault$, ByVal lpReturnedString$, ByVal nSize%, ByVal lpFileName$)
    Private Declare Function WritePrivateProfileString% Lib "kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpString$, ByVal lpFileName$)
#Else
    Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
    Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
#End If



  
    
    
 
 
Public Function Init(ByVal fileName_ As String) As Boolean
'
' COMMENT   : Initialize the instance.
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
  Dim f As New cTextFile
  
  iniFileName = fileName_
  Init = f.ExistFile(iniFileName)
 
  
'  setVar "CLASS", "TClassIniFile", "Yes"
'  setVar "CLASS", "LastInit", Date & " " & Time$
  
  
  
   
  
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
    
    Dim Buffer  As String
    Dim errCode As Integer
    Dim strVal  As String
    
    On Error GoTo ErrMgr
    
    Buffer = String$(lngMaxStringSize, " ")
    errCode = GetPrivateProfileString(Section, Var, "", Buffer, lngMaxStringSize, iniFileName)
    If (errCode) Then
        Buffer = Trim(Buffer)
        strVal = Mid(Buffer, 1, Len(Buffer) - 1)
    End If
    If (Len(strVal) = 0) Then
        strVal = strDefaultValue
    End If
    getVar = strVal
    Exit Function
ErrMgr:
    strVal = strDefaultValue
 End Function
Public Function Var(ByVal Section As String, ByVal vName As String, Optional Value As Variant) As Variant
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
        Me.SetVar Section, vName, Value
    End If
End Function
Public Sub SetVar(ByVal Section As String, ByVal Var As String, ByVal Value As String)
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
    SetVar w.Name, "GetForm.Date", Date$ & " " & Time$
    
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
    SetVar w.Name, "SetForm.Date", Date$ & " " & Time$
    For Each x In w.Controls
    
        If TypeOf x Is TextBox Then
            If (CtrlHasIndex(x)) Then
                SetVar w.Name, x.Name & "(" & x.Index & ")", x.Text
            Else
                SetVar w.Name, x.Name, x.Text
            End If
        End If
        
        If TypeOf x Is CheckBox Then
        
            If (CtrlHasIndex(x)) Then
                SetVar w.Name, x.Name & "(" & x.Index & ")", x.Value
            Else
                SetVar w.Name, x.Name, x.Value
            End If
        End If
        
        If TypeOf x Is OptionButton Then
            If x.Value Then
                SetVar w.Name, x.Name, "" & x.Index
            End If
        End If
        
        If TypeOf x Is ComboBox Then
            SetVar w.Name, x.Name & ".selected", "" & x.ListIndex + 1
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

 


Public Function FormSaveRestore(f As Object, ByVal doSave As Boolean, Optional ByVal setSize As Boolean = False, Optional ByVal configName As String) As Boolean


    On Error GoTo ErrMgr
    
    If doSave Then
        
        ' save only if normal or maximized not minimized
        If f.WindowState = 0 Or f.WindowState = 2 Then
        
            Me.SetVar f.Name & "." & configName, "LEFT", f.Left
            Me.SetVar f.Name & "." & configName, "TOP", f.Top
            Me.SetVar f.Name & "." & configName, "WIDTH", f.Width
            Me.SetVar f.Name & "." & configName, "HEIGHT", f.Height
            Me.SetVar f.Name & "." & configName, "WindowState", f.WindowState
            Me.SetVar f.Name & "." & configName, "SET", "YES"
        End If
    Else
        If Me.getVar(f.Name & "." & configName, "SET") = "YES" Then
        
            f.Left = Abs(Me.getVar(f.Name & "." & configName, "LEFT", f.Left))
            
            f.Top = Abs(Me.getVar(f.Name & "." & configName, "TOP", f.Top))
            
            f.WindowState = Me.getVar(f.Name & "." & configName, "WindowState", f.WindowState)
            
            If setSize Then
                f.Width = Abs(Me.getVar(f.Name & "." & configName, "WIDTH", f.Width))
                f.Height = Abs(Me.getVar(f.Name & "." & configName, "HEIGHT", f.Height))
            End If
        End If
    End If
    FormSaveRestore = True
    Exit Function
ErrMgr:
End Function




Public Function FontSaveRestore(ByVal strFontId As String, clsFont As StdFont, booSave As Boolean) As Boolean
    On Error GoTo ErrMgr
    
    If (booSave) Then
        Me.SetVar strFontId, strFontId & ".Name", clsFont.Name
        Me.SetVar strFontId, strFontId & ".Bold", clsFont.Bold
        Me.SetVar strFontId, strFontId & ".Italic", clsFont.Italic
        Me.SetVar strFontId, strFontId & ".Size", clsFont.Size
        Me.SetVar strFontId, strFontId & ".Strikethrough", clsFont.Strikethrough
        Me.SetVar strFontId, strFontId & ".Underline", clsFont.Underline
        Me.SetVar strFontId, strFontId & ".Weight", clsFont.Weight
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

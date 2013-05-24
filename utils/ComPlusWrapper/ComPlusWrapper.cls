VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 2  'RequiresTransaction
END
Attribute VB_Name = "ExecVBScript"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'******************************************************************************
'* Copyright 2000 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'******************************************************************************

Option Explicit

Private mWscriptObj As Object


'****************************************************************************

Public Function ExecSource(source As String, commit As Boolean)

Dim controller As New ScriptControl
Dim objectcontext As objectcontext
Set objectcontext = GetObjectContext

' pre-emptively make sure that the COM+ does not inadvertantly
' commit the transaction
If commit Then
  objectcontext.EnableCommit
Else
  objectcontext.DisableCommit
End If

controller.AllowUI = False
controller.Language = "VBScript"
controller.AddObject "wscript", mWscriptObj
'On Error Resume Next
Call controller.ExecuteStatement(source)
'On Error GoTo 0




If commit Then
  objectcontext.SetComplete
Else
  objectcontext.SetAbort
End If

If controller.Error.Number <> 0 Then
  With controller.Error
    Call Err.Raise(.Number, .source, .Description, .HelpFile, .HelpContext)
  End With
End If


End Function

'****************************************************************************

Public Function ExecFile(sourcefile As String, commit As Boolean, scriptObj As Object)

Dim oFS, oFile
Dim scriptSource As String

Set mWscriptObj = scriptObj

Set oFS = CreateObject("Scripting.FileSystemObject")
Set oFile = oFS.OpenTextFile(sourcefile)
scriptSource = oFile.ReadAll()
oFile.Close

Call ExecSource(scriptSource, commit)

End Function

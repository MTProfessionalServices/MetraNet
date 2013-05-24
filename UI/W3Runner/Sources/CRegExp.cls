VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CRegExp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 01/xx/2002
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit


Private Const W3BUGTRACKER_ERROR_1000 = "Cannot create activex [PROGID]"

Private Const REG_EXP_PROG_ID = "VBScript.RegExp"

Private m_objRegExp As Object

Public Function Execute(strSource As String) As Boolean
    Dim Matches As Object
 
    Set Matches = m_objRegExp.Execute(strSource) ' Execute search.
    Execute = CBool(Matches.Count)
End Function

Public Property Get IgnoreCase() As Boolean
    IgnoreCase = m_objRegExp.IgnoreCase
End Property

Public Property Let IgnoreCase(ByVal vNewValue As Boolean)
    m_objRegExp.IgnoreCase = vNewValue
End Property

Public Property Get reGlobal() As Boolean
    reGlobal = m_objRegExp.Global
End Property

Public Property Let reGlobal(ByVal vNewValue As Boolean)
    m_objRegExp.Global = vNewValue
End Property

Public Property Get Pattern() As String
    Pattern = m_objRegExp.Pattern
End Property

Public Property Let Pattern(ByVal vNewValue As String)
    m_objRegExp.Pattern = vNewValue
End Property

Private Function CreateRegExpObject() As Boolean

    On Error Resume Next
    Set m_objRegExp = CreateObject(REG_EXP_PROG_ID)
    If Err.Number Then
        FShowError PreProcess(W3BUGTRACKER_ERROR_1000, "PROGID", REG_EXP_PROG_ID)
        On Error GoTo 0
        Err.Raise Err.Number, TypeName(Me), PreProcess(W3BUGTRACKER_ERROR_1000, "PROGID", REG_EXP_PROG_ID)
    Else
        CreateRegExpObject = True
        IgnoreCase = True
        Me.reGlobal = False
    End If
End Function

Private Sub Class_Initialize()
    CreateRegExpObject
End Sub

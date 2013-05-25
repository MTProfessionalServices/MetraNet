Attribute VB_Name = "PCViewMOdule"
Option Explicit

Public g_objIniFile As New cIniFile

Public Sub main()
    
    g_objIniFile.InitAutomatic App
    frmView.Show
End Sub


Public Function MakeID(ByVal varID As String) As String
    If IsNumeric(varID) Then
        MakeID = "ID:" & varID
    Else
        MakeID = varID
    End If
End Function

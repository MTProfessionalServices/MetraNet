VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CParamTableChk"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Name         As String
Public CheckSum     As String
Public ID           As Long

Public Function LoadCheckSum() As Boolean

    Dim r As IMTRowSet
    Set r = ExecuteQuery("__GET_CHECK_SUM__", "ID", Me.ID)
    If IsValidObject(r) Then
        If r.RecordCount = 1 Then
            CheckSum = r.value("tx_checksum")
            LoadCheckSum = True
        Else
            Err.Raise 1025, TypeName(Me), PreProcess(MTPCImportExport_ERROR_1025, "PT", Name)
        End If
    Else
        Err.Raise 1025, TypeName(Me), PreProcess(MTPCImportExport_ERROR_1025, "PT", Name)
    End If
    
End Function

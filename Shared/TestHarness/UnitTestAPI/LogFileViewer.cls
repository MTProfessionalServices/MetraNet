VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "LogFileViewer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit


Public FileName As String

Private m_ctlListBox As ListBox

Public Function Initialize(ByVal strFileName As String, ctlListBox As Variant) As Boolean

    FileName = strFileName
    Set m_ctlListBox = ctlListBox
    Initialize = True
End Function

Public Function Length() As Long
    Length = FileLen(FileName)
End Function


Public Function FillListBox() As Boolean
    Dim objTextFile As New cTextFile
    
    m_ctlListBox.Clear
    
    If (objTextFile.OpenFile(FileName)) Then
    
        Do While Not objTextFile.EOF()
        
            m_ctlListBox.AddItem objTextFile.ReadLn()
        Loop
        objTextFile.CloseFile
        m_ctlListBox.ListIndex = m_ctlListBox.ListCount - 1
        m_ctlListBox.Refresh
    End If
End Function

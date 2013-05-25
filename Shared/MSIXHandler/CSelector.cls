VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CSelector"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' IMPORTANT IMPLEMENTATION DETAILS
'
' I only implemented the mode that store the selected item. CSELECTOR_MODE_STORE_SELECTED
' The mode that store only the non selected item has not been implemented.
' The performance with 10000 failed transactions are ok.
'
' This class was changed to use a case insensitive dictionary instead of a case sensitive
' collection on 2/18/2005
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Enum CSELECTOR_MODE
    CSELECTOR_MODE_STORE_SELECTED = 1
    CSELECTOR_MODE_STORE_UNSELECTED = 2
End Enum

Private m_enmMode As CSELECTOR_MODE
Private m_objDict As Scripting.Dictionary
Public ColumnID   As String

Public Function SelectItem(ByVal strItem As String) As Boolean
    SelectItem = AddToCollection(strItem)
End Function

Public Function UnSelectItem(ByVal strItem As String) As Boolean
    UnSelectItem = RemoveFromCollection(strItem)
End Function

Private Function GetColumnIndex(ByVal r As Variant, ByVal strColumName As String) As Long
    Dim i As Long
  
    GetColumnIndex = -1
    strColumName = UCase$(strColumName)
    
    For i = 0 To r.Count - 1
    
        If UCase$(r.Name(CLng(i))) = strColumName Then
        
          GetColumnIndex = i
          Exit Function
        End If
    Next
End Function

Public Function GetAllSelectedItemFromRowSetAsCSVString(ByVal r As Variant, ByVal strColumName As String) As String
    Dim c   As GENERICCOLLECTIONLib.MTCollection
    Dim v   As Variant
    Dim s   As New cStringConcat
    Dim ss  As String
    
    Set c = GetAllSelectedItemFromRowSet(r, strColumName)
    s.Init 16384
    For Each v In c
      If Len(Trim(CStr(v))) Then
        s.Concat CStr(v)
        s.Concat ","
      End If
    Next
    ss = s.GetString()
    If Len(ss) Then
      ss = Mid(ss, 1, Len(ss) - 1) ' remove the last command
    End If
    GetAllSelectedItemFromRowSetAsCSVString = ss
End Function

Public Function GetAllSelectedItemFromRowSet(ByVal r As Variant, ByVal strColumName As String) As GENERICCOLLECTIONLib.MTCollection
    Dim c As New GENERICCOLLECTIONLib.MTCollection
    Dim v As Variant
    
    For Each v In m_objDict
      c.Add v
    Next
    Set GetAllSelectedItemFromRowSet = c
End Function

Public Function IsItemSelected(ByVal strItem As String) As Boolean
    IsItemSelected = m_objDict.Exists(strItem)
End Function

Public Function SelecteItemsFromCSVString(ByVal strCSVString As String) As Boolean
    Dim arr As Variant
    Dim s   As Variant
    Dim t   As New MSIXTools

    arr = t.SplitTrim(strCSVString, ",")
    For Each s In arr
      Me.SelectItem s
    Next
End Function

Public Function UnSelecteItemsFromCSVString(ByVal strCSVString As String) As Boolean
    Dim arr As Variant
    Dim s   As Variant
    Dim t   As New MSIXTools
    
    arr = t.SplitTrim(strCSVString, ",")
    For Each s In arr
      Me.UnSelectItem s
    Next
End Function

Public Function Clear() As Boolean
    m_objDict.RemoveAll
    Clear = True
End Function

Private Sub Class_Initialize()
    Set m_objDict = New Scripting.Dictionary
    Clear
    m_enmMode = CSELECTOR_MODE_STORE_SELECTED
End Sub

Private Sub Class_Terminate()
    Clear
End Sub

Private Function RemoveFromCollection(strItem As String) As Boolean
    On Error Resume Next
    RemoveFromCollection = False
    
    m_objDict.Remove strItem
    If Err.Number <> 0 Then
      Err.Clear
      Exit Function
    End If
    
    RemoveFromCollection = True
    On Error GoTo 0
End Function

Private Function AddToCollection(strItem As String) As Boolean
    On Error Resume Next
    AddToCollection = False
    
    If (Len(Trim(strItem)) > 0) Then
      m_objDict.Add strItem, strItem
      If Err.Number <> 0 Then
        Err.Clear
        Exit Function
      End If
      AddToCollection = True
    End If
    
    On Error GoTo 0
End Function

Public Function ToString() As String
    Dim s As Variant
    Dim strR As String
    
    For Each s In m_objDict
      strR = strR & s & "; "
    Next
    strR = "Selected:" & strR
    
    ToString = strR
End Function

Public Property Get Count() As Long
    Count = m_objDict.Count
End Property

Public Function SelectAllFromRowSet(ByVal r As Variant, ByVal strColumnName As String) As Boolean
    Dim lngColIndex As Long

    lngColIndex = GetColumnIndex(r, strColumnName)
    
    If (lngColIndex = -1) Then Exit Function
    
    r.MoveFirst
    Do While Not r.EOF
      Me.SelectItem "" & r.Value(CLng(lngColIndex))
      r.MoveNext
    Loop
    SelectAllFromRowSet = True
End Function

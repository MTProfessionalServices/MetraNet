VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CChart"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_objMSChart    As MSChart
Private m_DataCol       As Collection
Private m_LabelCol      As Collection


Public Function Initialize(objMSChart As MSChart) As Boolean
    Set m_objMSChart = objMSChart
    Clear
End Function

Public Function AddData(ByVal x As Double, Optional ByVal strLabel As String) As Boolean

        m_DataCol.Add x
        m_LabelCol.Add strLabel
End Function

Public Function Clear() As Boolean
    Set m_DataCol = New Collection
    Set m_LabelCol = New Collection
End Function

Public Function Draw() As Boolean

    Dim lngArray()
    Dim i           As Long
    If m_DataCol.Count = 0 Then Exit Function
    
    ReDim lngArray(m_DataCol.Count - 1, 1)
    
    For i = 1 To m_DataCol.Count
    
        lngArray(i - 1, 0) = m_LabelCol(i)
        lngArray(i - 1, 1) = CDbl(m_DataCol(i))
        
        'm_objMSChart.ColumnLabel = i
    Next
    m_objMSChart.ChartData = lngArray
End Function

Public Property Get Title() As Variant
    Title = m_objMSChart.Title
End Property

Public Property Let Title(ByVal v As Variant)
    m_objMSChart.Title = v
End Property


Public Property Get Label() As Variant
    Label = m_objMSChart.ColumnLabel
End Property

Public Property Let Label(ByVal v As Variant)
    m_objMSChart.ColumnLabel = v
End Property

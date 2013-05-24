VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CChartClient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private m_objChart As CChart
Private m_frmChart As frmChart

Public Function Initialize(Optional ByVal strTitle As String, Optional ByVal lngWidth As Long = 300, Optional ByVal lngHeight As Long = 250) As Boolean
    Initialize = True
    Set m_objChart = New CChart
    Set m_frmChart = New frmChart
    m_objChart.Initialize m_frmChart.Chart
    'm_frmChart.Show
    m_frmChart.Chart.Width = (lngWidth * Screen.TwipsPerPixelX)
    m_frmChart.Chart.Height = (lngHeight * Screen.TwipsPerPixelX)


    m_objChart.Title = strTitle

    Initialize = True
End Function

Public Function AddData(ByVal x As Double, Optional ByVal strLabel As String) As Boolean
    AddData = m_objChart.AddData(x, strLabel)
End Function

Public Function Save(ByVal strFileName As String) As Boolean

    m_objChart.Draw
    Save = m_objChart.Save(strFileName)


End Function


Private Sub Class_Terminate()

    If Not m_objChart Is Nothing Then

        Unload m_frmChart
        Set m_frmChart = Nothing
        Set m_objChart = Nothing
    End If
End Sub



Public Property Let Color(ByVal vNewValue As Long)
    m_objChart.Color = vNewValue
End Property

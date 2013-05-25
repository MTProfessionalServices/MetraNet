VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPerformanceViewer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_objDB As CDB

Const MPV_SQL_1000 = "select * from t_perfresults"
'Const MPV_SQL_1000 = "select * from t_account_mapper"

    Const MPFM_RESULT_FILE_LOCAL_END_TIME = 1
    Const MPFM_RESULT_FILE_LOCAL_START_TIME = 1
    Const MPFM_RESULT_FILE_END_TIME = 4
    Const MPFM_RESULT_FILE_START_TIME = 5
    Const MPFM_RESULT_FILE_TRANSACTION_COUNT = 6
    Const MPFM_RESULT_FILE_TRANSACTION_PER_SECOND_INDEX = 9


Const CPERFORMANCE_VIEWER_ERROR_1000 = "Invalid value read in csv file [FILE], Line [LINE], Column [COLUMN]"


Public Function ResultFileName() As String

    ResultFileName = Environ("TEMP") & "\mpfm.result.csv"
End Function

Public Function DisplayTransactionPerHourGraph(objTrsPerSec As MSChart, objTrs As MSChart) As Boolean

    Dim objTransactionPerSecondChart    As New CChart
    Dim objTransactionChart             As New CChart
    Dim objTextFile As New cTextFile
    Dim Values      As Variant
    Dim lngLine     As Long
    Dim strS        As String
    
    objTransactionPerSecondChart.Initialize objTrsPerSec
    objTransactionChart.Initialize objTrs
    
    If objTextFile.OpenFile(ResultFileName()) Then
    
        Do While Not objTextFile.EOF()
        
            lngLine = lngLine + 1
            strS = Trim(objTextFile.ReadLn())
            If Len(strS) Then
                Values = Split(strS, ",")
                
                ' Chart Transaction Per Second
                If IsNumeric(Values(MPFM_RESULT_FILE_TRANSACTION_PER_SECOND_INDEX)) Then
                    objTransactionPerSecondChart.AddData CDbl(Values(MPFM_RESULT_FILE_TRANSACTION_PER_SECOND_INDEX)), Values(MPFM_RESULT_FILE_LOCAL_START_TIME)
                Else
                    objTransactionPerSecondChart.AddData -1, Values(MPFM_RESULT_FILE_LOCAL_START_TIME)
                    Me.TRACE PreProcess(CPERFORMANCE_VIEWER_ERROR_1000, "FILE", ResultFileName(), "LINE", lngLine, "COLUMN", MPFM_RESULT_FILE_TRANSACTION_PER_SECOND_INDEX), mpvERROR
                End If
                
                ' Chart Transaction
                If IsNumeric(Values(MPFM_RESULT_FILE_TRANSACTION_COUNT)) Then
                    objTransactionChart.AddData CDbl(Values(MPFM_RESULT_FILE_TRANSACTION_COUNT)) / 1000, Values(MPFM_RESULT_FILE_LOCAL_START_TIME)
                Else
                    objTransactionChart.AddData -1, Values(MPFM_RESULT_FILE_LOCAL_START_TIME)
                    Me.TRACE PreProcess(CPERFORMANCE_VIEWER_ERROR_1000, "FILE", ResultFileName(), "LINE", lngLine, "COLUMN", MPFM_RESULT_FILE_TRANSACTION_PER_SECOND_INDEX), mpvERROR
                End If
            End If
        Loop
        objTextFile.CloseFile
        
        
        objTransactionPerSecondChart.Draw
        objTransactionChart.Draw
        objTransactionPerSecondChart.Title = "Transaction Per Seconds"
        objTransactionChart.Title = "Transaction Counters (Unit is K)"
        objTransactionChart.Label = ""
        objTransactionPerSecondChart.Label = ""
    End If
End Function


Public Function TRACE(ByVal strMessage As String, Optional eMode As MPV_TRACE_MODE = mpvINFO) As Boolean
    TRACE = frmMain.TRACE(strMessage, eMode)
End Function

Public Function OpenDB() As Boolean

    Set m_objDB = New CDB

    m_objDB.Server = AppOptions("SQLServer")
    m_objDB.Database = AppOptions("SQLDatabase")
    m_objDB.Login = AppOptions("SQLLogin")
    m_objDB.PassWord = AppOptions("SQLPassWord")

    If m_objDB.OpenDB() Then
        OpenDB = True
    Else
        TRACE MPV_ERROR_1003, mpvERROR
    End If
End Function

Public Function CloseDB() As Boolean

    CloseDB = m_objDB.CloseDB()
End Function

 Public Function ExportDataFromDB() As Boolean

      Dim strSQL As String
      Dim i As Long
      Dim objRST As New ADODB.Recordset
            
      If Not OpenDB() Then Exit Function
      
      strSQL = MPV_SQL_1000
    
      Set objRST = m_objDB.SqlRun(strSQL, m_objDB.NewRecordset())
      If IsValidObject(objRST) Then
      
        ExportDataFromDB = ExportRecordSetAsCSVFile(Me.ResultFileName(), objRST)
      End If
End Function

Public Function ExportRecordSetAsCSVFile(strFileName As String, objRST) As Boolean

    Dim strS            As String
    Dim i               As Long
    Dim objTextFile     As New cTextFile
    
    Do While Not objRST.EOF

         For i = 0 To objRST.Fields.Count - 1

             strS = strS & objRST.Fields(i).Value & ","
         Next
         strS = strS & vbNewLine
         objRST.MoveNext
      Loop
      objTextFile.LogFile strFileName, strS, True
      ExportRecordSetAsCSVFile = True
End Function

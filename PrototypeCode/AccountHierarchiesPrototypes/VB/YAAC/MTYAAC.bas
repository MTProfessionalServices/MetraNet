Attribute VB_Name = "Module2"
Option Explicit

Public Const DATABASE_DATE_TIME_FORMAT = "mm/dd/yyyy hh:mi:ss AM"
Public Const DATABASE_DATE_FORMAT = "mm/dd/yyyy"

Public Function SQLExecute(ByVal strSQL) As MTSQLRowset

  Dim rs As New MTSQLRowset
  
  On Error GoTo ErrMgr
  
    
  rs.Init ("queries\database")
  Debug.Print strSQL
  rs.SetQueryString strSQL
  
  rs.Execute
  Set SQLExecute = rs
  Exit Function
ErrMgr:
  Set SQLExecute = Nothing
End Function

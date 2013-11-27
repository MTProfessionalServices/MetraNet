Attribute VB_Name = "Module1"
Option Explicit

'API declares:
Declare Function PutFocus Lib "user32" Alias "SetFocus" (ByVal hwnd As Long) As Long
Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Integer, ByVal lParam As Long) As Long


Public Const INPUT_PARAM = &H0
Public Const OUTPUT_PARAM = &H1
Public Const IN_OUT_PARAM = &H2
Public Const RETVAL_PARAM = &H3

Public Const MTTYPE_SMALL_INT = &H0
Public Const MTTYPE_INTEGER = &H1
Public Const MTTYPE_FLOAT = &H2
Public Const MTTYPE_DOUBLE = &H3
Public Const MTTYPE_VARCHAR = &H4
Public Const MTTYPE_VARBINARY = &H5
Public Const MTTYPE_DATE = &H6
Public Const MTTYPE_NULL = &H7
Public Const MTTYPE_DECIMAL = &H8
Public Const MTTYPE_W_VARCHAR = &H9

' couple objects we need
Public factory As Object
Public LoginObj As Object
Public myCTX As Object
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddAccountByName(ByVal strName As String, ByVal strParent As String, Optional ByVal strNamespace = "mt")
  Dim t As New cTool
  Dim cYAAC As Object
      
  ' Get login context once
  If factory Is Nothing Then
    Set factory = CreateObject("MTYAAC.YAACFactory")
  End If
  If LoginObj Is Nothing Then
    Set LoginObj = CreateObject("MTAuthProto.MTLoginContext")
  End If
  If myCTX Is Nothing Then
    Set myCTX = LoginObj.login("su", "csr", "su123")
  End If
  
  ' No funny stuff in name!
  strName = Replace(strName, " ", "")
  strName = Replace(strName, "&", "")
  strName = Replace(strName, ".", "")
  strName = Replace(strName, "_", "")
  strName = Replace(strName, "-", "")
  strName = Replace(strName, """", "")
  strName = Replace(strName, "'", "")
  strName = Replace(strName, "(", "")
  strName = Replace(strName, ")", "")
  strParent = Replace(strParent, " ", "")
  strParent = Replace(strParent, "&", "")
  strParent = Replace(strParent, ".", "")
  strParent = Replace(strParent, "_", "")
  strParent = Replace(strParent, "-", "")
  strParent = Replace(strParent, """", "")
  strParent = Replace(strParent, "'", "")
  strParent = Replace(strParent, "(", "")
  strParent = Replace(strParent, ")", "")
  
  Form1.Text6 = "Adding:  " & strName
  Form1.Text6.Refresh
  DoEvents
  
  ' Add account to system
  Call t.execPrgSyncrone("AddDefaultAccounts.exe -u " & strName & " -p " & strName & " -n " & strNamespace & " -l US", "", vbHide)
  Call t.execPrgSyncrone("testaccount -t test2 -id_acc " & CStr(getAccountID(strName)), "", vbHide)
  
  ' Add account to hierarcy
  Set cYAAC = factory.CreateActorYAAC(myCTX)
  cYAAC.GetAncestorMgr().AddToHierarchy getAccountID(strParent), getAccountID(strName), Date, CDate("1/1/9999")
 
End Function
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getAccountName(ByVal lngAccountId As Long) As String
  Dim rs As New MTSQLRowset
  
  rs.Init "queries\audit"
  rs.SetQueryString "select * from t_account_mapper where id_acc = " & lngAccountId
  rs.Execute
    
  If rs.EOF Then
    getAccountName = "not found"
    Exit Function
  End If
  
  rs.MoveFirst
    
  ' just take the first one for now... who cares about the namespace
  getAccountName = rs.Value("nm_login")
  
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getAccountID(ByVal strName As String) As String
  Dim rs As New MTSQLRowset
  
  rs.Init "queries\audit"
  rs.SetQueryString "select * from t_account_mapper where nm_login = '" & strName & "'"
  rs.Execute
    
  If rs.EOF Then
    getAccountID = "1" ' synthetic node
    Exit Function
  End If
  
  rs.MoveFirst
    
  ' just take the first one for now... who cares about the namespace
  getAccountID = rs.Value("id_acc")
  Set rs = Nothing
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getNumberOfChildren(ByVal lngAccountId As Long, ByVal snapShot As Date) As Long

  Dim rs As New MTSQLRowset
  
  rs.Init "queries\audit"
  rs.SetQueryString "select num_children = count(*)-1 from t_account_ancestor where id_ancestor=" & lngAccountId & " and vt_start <= '" & snapShot & "' and '" & snapShot & "' < vt_end"

  rs.Execute

  rs.MoveFirst
    
  getNumberOfChildren = rs.Value("num_children")
  
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getParentID(ByVal lngAccountId As Long, ByVal snapShot As Date) As Long

  Dim rs As New MTSQLRowset
  
  rs.Init "queries\audit"
  rs.SetQueryString "select id_ancestor from t_account_ancestor where id_descendent=" & lngAccountId & " and id_ancestor=1 and and vt_start <= '" & snapShot & "' and '" & snapShot & "' < vt_end"

  rs.Execute
    
  If rs.EOF Then
    getParentID = 0
    Exit Function
  End If
  
  rs.MoveFirst
    
  getParentID = rs.Value("id_ancestor")
  
End Function


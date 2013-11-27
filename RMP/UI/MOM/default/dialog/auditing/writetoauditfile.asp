<%
'----------------------------------------------------------------------------
'   Name: WriteToAuditFile
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Sub WriteToAuditFile(icstrMessage)
    Dim strConfigDir   ' As String
    Dim objLogger      ' As object
    
  '  response.write "<br><b>" & icstrMessage & "</b><br>"

    'create logging obj
    Set objLogger = Server.CreateObject("MTLogger.MTLogger.1")
    if err then
      response.write err.description
      exit sub
    end if
    
    strConfigDir = "logging\AdminAudit"

    ' initialize logger
    Call objLogger.Init(strConfigDir, "[MTOPS]")
    if err then
      response.write err.description 
      exit sub
    end if
 
    ' log info
    Call objLogger.LogThis(4, "User: " & request.ServerVariables("LOGON_USER") & " " & icstrMessage)
   ' response.write "Finished!<br>"
    if err then
      response.write err.description
      exit sub
    end if
    
    Set objLogger = Nothing
End Sub
%>
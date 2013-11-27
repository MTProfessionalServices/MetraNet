<%@ LANGUAGE="VBSCRIPT" %>
<!-- #//include file="auth.asp" -->
<!-- #//include file="..\..\include\utilError.asp" -->

<%
'On Error Resume Next   

sub writeReportingErrorMessage(strOptionalAdditionalMessage)
  ' // Present error message to user
  Response.Write "An Error has occured on the server in attempting to access the report." & "<BR>"
  Response.Write strOptionalAdditionalMessage & "<BR>"
end sub

if request.QueryString("ReportID") = "" then
  response.write("No report id was passed<BR>")
  reponse.end
end if

if request.QueryString("FolderID") = "" then
  response.write("No folder id was passed<BR>")
  reponse.end
end if

dim intReportID
dim strFolderID
dim strReportType
dim strReportName
dim strSelectionCriteria

strReportType = "Management"

strFolderID = request.QueryString("FolderID")
intReportID = int(request.QueryString("ReportID"))
' // response.write("The report to display is Folder[" & strFolderID & "] Report[" & intReportID & "]<BR>")

dim objReportConfig
set objReportConfig = session("SESSOBJ_REPORTCONFIG")

dim objReportList
set objReportList = objReportConfig.GetReportList(strFolderID)

dim i
for i=0 to intReportID-1
  'response.write("Calling Move next<BR>")
  objReportList.MoveNext
next

strAccountID = session("REPORTING_ACCOUNTID")
strReportName = objReportList.Value("name")

strReportName = objReportConfig.BaseDirectory
strReportName = strReportName & "\extracts\" & objReportConfig.Namespace & "\" & strReportType & "\" & strFolderID & "\" & objReportList.Value("name")

' // Need to build a selection clause using the grouping formula (gf) and then replacing the various parameters
' // with the corresponding values.
' // For subscriber reports we are only concerned about account id currently.

strSelectionCriteria = objReportList.Value("groupselectionformula")
' //response.write("strSelectionCriteria [" & strSelectionCriteria & "]<BR>")

' // It is very important that an Account Id is part of the selection criteria so that we
' // display only data for this account
if strReportType="Subscriber" and (len(strSelectionCriteria)=0 or InStr(strSelectionCriteria, "%%ACCOUNT_ID%%")=0) then
  '// Error: Our selection criteria does not contain ACCOUNT_ID
  'writeSystemLog "Error displaying Seagate Report: Selection criteria for report does not contain %%ACCOUNT_ID%%.",LOG_ERROR
  'writeSystemLog "Report Name [" & strReportName & "]", LOG_ERROR  
  'writeSystemLog "Selection Criteria [" & strSelectionCriteria & "]", LOG_ERROR  
  
  writeReportingErrorMessage "Subscriber Report does not have selection criteria for account."
  response.end
  
end if

strSelectionCriteria = Replace(strSelectionCriteria,"%%ACCOUNT_ID%%", strAccountID)

'//response.write("Report Name [" & strReportName & "]<BR>")
'//response.write("objReportConfig.Namespace [" & objReportConfig.Namespace & "]<BR>")
'//response.write("objReportConfig.ReportType [" & objReportConfig.ReportType & "]<BR>")
'//response.write("strSelectionCriteria [" & strSelectionCriteria & "]<BR>")
'//response.end

' // CREATE THE APPLICATION OBJECT                                                                     
If Not IsObject (session("oApp")) Then                              
  Set session("oApp") = Server.CreateObject("CrystalRuntime.Application")
End If                                                               

                                                                      
' // CREATE THE REPORT OBJECT                                     
' // The Report object is created by calling the Application object's OpenReport method.

' // OPEN THE REPORT (but destroy any previous one first)                                                     
If IsObject(session("oRpt")) then
	Set session("oRpt") = nothing
End if


Set session("oRpt") = session("oApp").OpenReport(strReportName, 1)
session("oRpt").MorePrintEngineErrorMessages = False
session("oRpt").EnableParameterPrompting = False
'session("oRpt").GroupSelectionFormula = strSelectionCriteria
session("oRpt").ReadRecords                                           

If Err.Number <> 0 Then                                               

 ' // Write error information to the log
  dim strErrorMessage
  strErrorMessage = getLastErrorString
  
  'writeSystemLog "Error displaying Seagate Report",LOG_ERROR
  'writeSystemLog "Account ID [" & strAccountID & "]", LOG_ERROR
  'writeSystemLog "Report Name [" & strReportName & "]", LOG_ERROR  
  'writeSystemLog "Selection Criteria [" & strSelectionCriteria & "]", LOG_ERROR  
  'writeSystemLog strErrorMessage, LOG_ERROR
  
  writeReportingErrorMessage ""
  Response.End
End If

If IsObject(session("oPageEngine")) Then                              
  set session("oPageEngine") = nothing
End If
  
set session("oPageEngine") = session("oRpt").PageEngine

'// Need to specify the type of report viewer
'// Currently we only use Java viewer

viewer = "Java using Browser JVM"

If cstr(viewer) = "ActiveX" then
%>
<!-- #include file="SmartViewerActiveX.asp" -->
<%
ElseIf cstr(viewer) = "Netscape Plug-in" then
%>
<!-- #include file="ActiveXPluginViewer.asp" -->
<%
ElseIf cstr(viewer) = "Java using Browser JVM" then
%>
<!-- #include file="SmartViewerJava.asp" -->
<%
ElseIf cstr(viewer) = "Java using Java Plug-in" then
%>
<!-- #include file="JavaPluginViewer.asp" -->
<%
ElseIf cstr(viewer) = "HTML Frame" then
	Response.Redirect("htmstart.asp")
Else
 	Response.Redirect("rptserver.asp")
End If
%>

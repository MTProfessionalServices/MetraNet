<%
' //==========================================================================
' // @doc $Workfile: f:\development\UI\client\sites\mt\us\genReportList.asp$
' //
' // Copyright 1998 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' // Created by: Rudi Perkins
' //
' // $Date: 5/5/00 11:16:42 AM$
' // $Author: Frederic Torres$
' // $Revision: 21$
' //==========================================================================

OPTION EXPLICIT
%>
<!-- #INCLUDE FILE="../includeLocalizedSite.asp" -->
<!-- #INCLUDE FILE="../../include/includeStandardPage.asp" -->
<!-- #INCLUDE FILE="../../include/utilGenGroup.asp" -->
<!-- #INCLUDE FILE="../../include/utilUsageInterval.asp" -->
<!-- #INCLUDE FILE="../../include/utilProductView.asp" -->
<!-- #INCLUDE FILE="../../include/formatProperties.asp" -->
<!-- #INCLUDE FILE="../../include/utilGenProduct.asp" -->

<HTML>

<%

' // +----------------------------------------------------------------
' //
' //
dim g_RS ' as object
dim g_rowNum ' as integer

g_rowNum = 1

sub writeReportListHeader(strDisplayName)
	writeResponse("<BR>")  
	writeBeginGridTABLE "50%"
	writeResponse("<TR>")
	writeGridHdrTD strDisplayName,"100%", "LEFT", "", ""
	writeResponse("</TR></TABLE>")
end sub

sub writeReportList(objReportList, strFolderID)

  writeBeginGridTABLE "50%"
  
  dim reportID
  reportID=0
  
  dim strLink
  dim strGetReportURL
  strGetReportURL = "getreport.asp?folderid=" & Server.UrlEncode(strFolderID)
	Do While Not objReportList.EOF
		strLink = "<A href='" & strGetReportURL & "&reportid=" & server.UrlEncode(reportID) & "'>"
    strLink =  strLink & "<IMG BORDER=0  SRC='" & ag_genericProductGif & "'>"
    strLink =  strLink & objReportList.Value("Description") &"</a>"
    writeResponse("<TR>")
    writeTD strLink, "", "LEFT", 1
    writeResponse("</TR>")
	  objReportList.MoveNext
    reportID=reportID+1
	Loop
  
  writeResponse("</TABLE>")

end sub

' // Clear out the drill down level
setNavigationLinks 0, 0, ""

' //
' // write out header as a separate form
' //
writeResponse("<FORM NAME=""genSelectUI"" ACTION=""" & request.serverVariables("SCRIPT_NAME") & """ METHOD=""GET"">")
writeBodyAndPageBanner "&nbsp;" & TEXT_REPORTS, ""
writeWhiteSpace 3


dim objReportConfig
dim objReportFolderList
dim objReportList
dim strFolderID

set objReportConfig = CreateObject("MetraTech.MTReportConfig.1")

objReportConfig.Initialize

objReportConfig.ReportType = "Management"
objReportConfig.Namespace = "MT" 'session("NAMESPACE")

set session("SESSOBJ_REPORTCONFIG") = objReportConfig
session("REPORTING_ACCOUNTID") = session("ACCOUNTID")

'//response.write("Report List File Path [" & objReportConfig.ReportListFilePath & "]<BR>")

' // Because this is a subscriber based list, we know that the folder names equate to usage intervals
' // We will get the usage intervals so we can display the usage interval text as opposed to the usage
' // interval id.
'dim objUsageIntervalList
'set objUsageIntervalList = session(SESSOBJ_DATA_ACCESSOR).getUsageInterval()

dim strFolderDisplayName
set objReportFolderList = objReportConfig.GetReportFolderList

'if objReportFolderList.EOF then
  '// There are not reports to display
  'writeNoRowsBlock "<BR><BR><B>&nbsp;&nbsp;" & TEXT_REPORTS_NOREPORTSAVAILABLE & "</B><BR>"
'else
  '// Print the list of report folders and the list of reports for each
  do while not objReportFolderList.EOF
    strFolderID = objReportFolderList.value("folderid")
    strFolderDisplayName = strFolderID 'getUsageIntervalTextFromID(objUsageIntervalList,int(strFolderID))
    response.write(strFolderID)
    set objReportList = objReportConfig.GetReportList(strFolderID)
    writeReportListHeader strFolderDisplayName
    writeReportList objReportList, strFolderID
    objReportFolderList.MoveNext
  loop
'end if 
	
writeEndBody

%>

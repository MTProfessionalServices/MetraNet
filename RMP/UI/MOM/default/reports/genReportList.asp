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
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../lib/momLibrary.asp"                   -->

<!-- #//INCLUDE FILE="../includeLocalizedSite.asp" -->
<!-- #//INCLUDE FILE="../../include/includeStandardPage.asp" -->
<!-- #//INCLUDE FILE="../../include/utilGenGroup.asp" -->
<!-- #//INCLUDE FILE="../../include/utilUsageInterval.asp" -->
<!-- #//INCLUDE FILE="../../include/utilProductView.asp" -->
<!-- #//INCLUDE FILE="../../include/formatProperties.asp" -->
<!-- #//INCLUDE FILE="../../include/utilGenProduct.asp" -->


<HTML>
 <HEAD>
  <LINK rel="STYLESHEET" type="text/css" href="/mom/default/localized/en-us/styles/Styles.css">  
 </HEAD>

<%

sub writeReportListHeader(strDisplayName,lngCount)
  If(lngCount)Then
    	response.write("<HR>")
  End If
	response.write("<IMG BORDER=0  SRC='" & "/mom/default/localized/en-us/images/menu/menu_folder_closed.gif" & "' align='middle'>" )
	response.write "<FONT Class='clsStandardTitle'>" & strDisplayName & "</FONT><BR>"
end sub

PRIVATE FUNCTION GetWithStdFont(strText)
    GetWithStdFont  = "<FONT Class='clsStandardText'>" & strText & "</FONT>"
END FUNCTION

Sub writeReportList(objReportList, strFolderID)

  Dim reportID
  Dim strLink
  Dim strGetReportURL
  
  reportID          = 0
  strGetReportURL   = "getreport.asp?folderid=" & Server.UrlEncode(strFolderID)
  
  If(objReportList.EOF)Then
  
      response.write   GetWithStdFont("No reports available") & "<BR>"
  Else
  	  Do While Not objReportList.EOF
    		strLink = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A href='" & strGetReportURL & "&reportid=" & server.UrlEncode(reportID) & "' target='_blank'>"
        strLink =  strLink & "<IMG BORDER=0  SRC='" & "/mom/default/localized/en-us/images/menu/menu_link_default.gif" & "' align='middle'>"
        strLink =  strLink & objReportList.Value("Description") &"</a>"
        
  	    response.write  GetWithStdFont(strLink) & "<BR>"
        
    	  objReportList.MoveNext
        reportID  = reportID  + 1
    	Loop
  End If

End Sub

'function getFolderNameFromFolderId(strFolderId)

'  dim objUsageIntervalList
'  set objUsageIntervalList = session(SESSOBJ_DATA_ACCESSOR).getUsageInterval()

'  dim index
'  index=0
'  do while not Cbool(objUsageIntervalList.EOF)
	  
    'response.write("[" & objUsageIntervalList.value(PROP_INTERVALID) & "][" & strFolderId & "]<BR>")
'		if (cstr(objUsageIntervalList.value(PROP_INTERVALID))=cstr(strFolderId)) then 
      'response.write("Found it")
'	    getFolderNameFromFolderId=getUsageIntervalText(objUsageIntervalList, index)
'      exit do
'	  end if	
'		index=index+1
'		objUsageIntervalList.moveNext
'	loop
'end function




dim objReportConfig
dim objReportFolderList
dim objReportList
dim strFolderID
Dim lngCounter

set objReportConfig = CreateObject("MetraTech.MTReportConfig.1")

On Error Resume Next

objReportConfig.Initialize

If(Err.number)Then

    EventArg.Error.Number = Err.Number
    EventArg.Error.Description = "There is a possible configuration issue with MTReportConfig.xml.<BR>" & Err.Description
    Form_DisplayErrorMessage EventArg

    'response.write "<BR>"    
    'response.write "There is a possible configuration issue with MTReportConfig.xml.<BR>"
    'response.write Err.Description & "<BR>"
    response.end    
End If

On Error Goto 0

objReportConfig.ReportType = "Management"
objReportConfig.Namespace = Request.QueryString("NameSpace")  ' session("NAMESPACE")
If(objReportConfig.Namespace="")Then

    response.write "<BR>"    
    response.write "No namespace was passed.<BR>"
    response.write Err.Description & "<BR>"
    response.end      
End If

set session("SESSOBJ_REPORTCONFIG") = objReportConfig
'session("REPORTING_ACCOUNTID") = session("ACCOUNTID")

'//response.write("Report List File Path [" & objReportConfig.ReportListFilePath & "]<BR>")

' // Because this is a subscriber based list, we know that the folder names equate to usage intervals
' // We will get the usage intervals so we can display the usage interval text as opposed to the usage
' // interval id.

dim strFolderDisplayName
set objReportFolderList = objReportConfig.GetReportFolderList

if objReportFolderList.EOF then
  '// There are not reports to display
  'writeNoRowsBlock "<BR><BR><B>&nbsp;&nbsp;" & TEXT_REPORTS_NOREPORTSAVAILABLE & "</B><BR>"
  response.write("No report folders available<BR>")
else  
    lngCounter = 0
    Do While Not objReportFolderList.EOF ' Print the list of report folders and the list of reports for each
    
      strFolderID           = objReportFolderList.value("FolderID")
      strFolderDisplayName  = strFolderID 'getFolderNameFromFolderId(strFolderID)     
      Set objReportList     = objReportConfig.GetReportList(strFolderID)
      
      writeReportListHeader strFolderDisplayName,lngCounter
      writeReportList       objReportList, strFolderID
      
      objReportFolderList.MoveNext
      lngCounter            = lngCounter + 1
    Loop
  
End If
	

%>

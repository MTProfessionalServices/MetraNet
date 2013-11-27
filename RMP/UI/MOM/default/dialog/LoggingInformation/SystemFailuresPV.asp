<%
' //==========================================================================
' // @doc $Workfile$
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
' // Created by: Philip Kenny
' //
' // $Date$
' // $Author$
' // $Revision$
' //==========================================================================

OPTION EXPLICIT
session("isAuthenticated") = true
%>
<!-- #INCLUDE VIRTUAL="/presserver/mt/us/ExternalText.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/prod_incs.asp" -->
<%


sub writeProductDetailRowHeader

	writeBeginGridTABLE "100%"

	writeResponse("<TR>")

	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "", "LEFT", "", ""
	writeGridHdrTD createSortHref("Service Name", "c_FailureServiceName"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Account ID", "c_PossibleAccountID"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Session ID", "c_FailureID"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Compound ID", "c_FailureCompoundID"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Host", "c_Sender"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Metered Time", "c_MeteredTime"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Error Code", "c_Code"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Error Description", "c_ErrorMessage"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Stage", "c_StageName"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Plugin", "c_PlugIn"), "", "LEFT", "", ""

	writeResponse("</TR>")

end sub



sub writeDetailRow(aBolded, aHrefLinkURLString)
	on error resume next
	
	dim boldOn, boldOff
	dim adjustedDateTime
	adjustedDateTime = getUserAdjustedDT(g_RS.value("c_MeteredTime"))
	if aBolded then
		boldOn = "<B>"
		boldOff = "</B>"
	end if

	writeResponse("<TR>")
	writeTD aHrefLinkURLString, "2", "LEFT", g_rowNum
	
	writeTD "<input type=""checkbox"" name=""ckbItems"" value=""" & _
			 "errorID:" & g_RS.value("c_FailureCompoundID") & _
			 "sessionID:" & g_RS.value("SessionID") & """>", _
			 "", "LEFT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_FailureServiceName", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_PossibleAccountID", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_FailureID", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_FailureCompoundID", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_Sender", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getLocaleDate(adjustedDateTime) & _
					"&nbsp;" & getLocaleTime(adjustedDateTime) & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD "0x" & Hex(clng(g_RS.value("c_Code"))), "", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_ErrorMessage", "N/A") & "&nbsp;" & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_StageName", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_PlugIn", "N/A") & boldOff, _
					"10", "LEFT", g_rowNum

	' finish the row
	writeResponse("</TR>")
end sub

sub writeProductDetailHdrItems(aBgColor, aFontColor)

	dim adjustedDateTimeMetered
	dim adjustedDateTimeFailure
	adjustedDateTimeMetered = getUserAdjustedDT(g_RS.value("c_MeteredTime"))
	adjustedDateTimeFailure = getUserAdjustedDT(g_RS.value("c_FailureTime"))

	writeResponse("<TABLE WIDTH=""100%"" BORDER=0 CELLSPACING=""2"" CELLPADDING=""1"" HSPACE=""0"" VSPACE=""0"">")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<A HREF=""exportError.asp?errorID=" & Server.URLEncode(g_RS.value("c_FailureCompoundID")) & """>Export this session</A>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<A HREF=""errorActions.asp?action=restart&errorID=" & Server.URLEncode(g_RS.value("c_FailureCompoundID")) & "&sessionId=" & Server.URLEncode(g_RS.value("SessionID")) & """>Resubmit this session</A>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<A HREF=""errorActions.asp?action=delete&errorID=" & Server.URLEncode(g_RS.value("c_FailureCompoundID")) & "&sessionId=" & Server.URLEncode(g_RS.value("SessionID")) & """>Delete this session</A>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""	
	writeProductDetailTD "", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Service Name:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	
	' Here I add a Hidden field that stored the service name, because I need it to re meter the data... FTORRES.
	Dim strServiceNameHiddenFieldHtml ' As String
	Dim strServiceName 				  ' As String
	strServiceName = getOptionalResultSetField(g_RS, "c_FailureServiceName", "N/A")	
	strServiceNameHiddenFieldHtml =	strServiceName & "<input type=hidden name=PropertyServiceName value='" & strServiceName & "'>"	
	writeProductDetailTD  strServiceNameHiddenFieldHtml, "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	
	writeProductDetailTD "&nbsp;<B>Account ID:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_PossibleAccountID", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Metered Timestamp:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getLocaleDate(adjustedDateTimeMetered) & "&nbsp;" & getLocaleTime(adjustedDateTimeMetered), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Session ID:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_FailureID", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Failure Timestamp:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getLocaleDate(adjustedDateTimeFailure) & "&nbsp;" & getLocaleTime(adjustedDateTimeFailure), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Compound ID:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_FailureCompoundID", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Host:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_Sender", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Stage:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_StageName", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Plugin:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_PlugIn", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Module:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_Module", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Method:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_Method", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Error Code:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "0x" & Hex(clng(g_RS.value("c_Code"))), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>Line:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_Line", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")
	
	
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Error Description:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "c_ErrorMessage", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"3", ""
	writeResponse("</TR>")
	
	
	
	writeResponse("</TABLE>")
	
end sub

sub writeErrorDetails (aResultSet, aProductViewID, aHdrCellColor, 	aHdrFontColor, aDetailCellColor, aDetailFontColor)

	on error resume next
		
    Const SESS_PROP_TYPE_DATE = 1
    Const SESS_PROP_TYPE_TIME = 2
    Const SESS_PROP_TYPE_STRING = 3
    Const SESS_PROP_TYPE_LONG = 4
    Const SESS_PROP_TYPE_DOUBLE = 5
    Const SESS_PROP_TYPE_BOOL = 6

	dim i 					' as integer
	dim fieldDisplayName 	' as string
	dim strType 			' as string
	dim strValue 			' as string
	
	dim objPipeline 		' as object
	dim objSession 			' as object
  	dim objTempSession		' as object
  	dim objSessionSet   
	dim objProperty 		' as object
  	dim strSessionID    	' as string
	
	Dim strBuildEditBox		' as String
	Dim lngPropertyCounter  ' as long
	lngPropertyCounter=0
	
  	strSessionID = g_RS.value("c_FailureID")
	set objPipeline = server.CreateObject("MetraPipeline.MTPipeline.1")
  
  '--------------------------------------------------------------------------
  ' Do a little magic here
  ' The ExamineMeteredSession only works with the compound ID, so pass that in
  ' The Session that is returned is the parent session, but we need to display
  ' the properties for the child.  So, loop until the child is found
  '--------------------------------------------------------------------------
	set objSession = objPipeline.ExamineMeteredSession(g_RS.value("c_FailureCompoundID")) 

  if not objSession.UIDAsString = strSessionID then
    set objSessionSet = objSession.SessionChildren
    for each objTempSession in objSessionSet
      if objTempSession.UIDAsString = strSessionID then
        set objSession = objTempSession
        exit for
      end if
    next    
    set objTempSession = nothing
    set objSessionSet = nothing
  end if
  
	if err then
		writeBeginTABLE "0", "", ag_prodDetNameValHdrColor, "1", "1"
		writeResponse("<TR>")
		writeProductDetailTD "An error occurred while trying to read this session.  It may have been removed from the routing queue.", "", "LEFT", g_rowNum, aDetailCellColor, aDetailFontColor, "", ""
		writeResponse("</TR></TABLE>")	
		err.clear	
		exit sub
	end if
	
	writeBeginTABLE "0", "100%", ag_prodDetNameValHdrColor, "1", "1"
	writeResponse("<TR>")
	writeGridHdrTD "<B>Property Name</B>", "33%", "CENTER" , aHdrCellColor, aHdrFontColor
	writeGridHdrTD "<B>Type</B>", "33%", "CENTER" , aHdrCellColor, aHdrFontColor
	writeGridHdrTD "<B>Value</B>", "33%", "CENTER", aHdrCellColor, aHdrFontColor
	writeResponse("</TR>") & Chr(13) & Chr(10)
	
	Response.write "<input type=hidden name=PropertySessionID value='" 			& g_RS.value("c_FailureID") 		&  "'>" & Chr(13) & Chr(10)
	Response.write "<input type=hidden name=PropertyErrorID value='" 			& g_RS.value("SessionID") 			&  "'>" & Chr(13) & Chr(10)
	Response.write "<input type=hidden name=PropertyParentSessionID value='" 	& g_RS.value("c_FailureCompoundID") &  "'>" & Chr(13) & Chr(10)
	
	for each objProperty in objSession
		
		Select Case objProperty.Type
        
            Case SESS_PROP_TYPE_DATE, SESS_PROP_TYPE_TIME
                strType = "DATE/TIME"
                strValue = objSession.getOLEDateProperty(objProperty.NameID) ' Display the date and time
                    
            Case SESS_PROP_TYPE_STRING
                strType = "STRING"
                strValue = objSession.getBSTRProperty(objProperty.NameID)
                    
            Case SESS_PROP_TYPE_LONG
                strType = "LONG"
                strValue = CStr(objSession.getLongProperty(objProperty.NameID))
    
            Case SESS_PROP_TYPE_DOUBLE
                strType = "DOUBLE"
                strValue = CStr(objSession.GetDoubleProperty(objProperty.NameID))
                    
            Case SESS_PROP_TYPE_BOOL
                strType = "BOOLEAN"
                If objSession.GetBoolProperty(objProperty.NameID) = True Then
                    strValue = "True"
                Else
                    strValue = "False"
                End If
        End Select
		
		writeResponse("<TR>")
		writeProductDetailTD "" & lcase(objProperty.Name), "30%", "LEFT", g_rowNum, aDetailCellColor, aDetailFontColor, "", ""
		writeProductDetailTD "" & strType, "30%", "LEFT", g_rowNum, aDetailCellColor, aDetailFontColor, "", ""
		
		lngPropertyCounter 	= 	lngPropertyCounter + 1
		strBuildEditBox		=	"" & Chr(13) & Chr(10)
		strBuildEditBox		=	strBuildEditBox & "<input type=text   name=PropertyValue" & lngPropertyCounter & " value='" & strValue 			&  "'  style='font-family: arial; font-size: 8pt' >" & Chr(13) & Chr(10)
		strBuildEditBox		=	strBuildEditBox & "<input type=hidden name=PropertyName"  & lngPropertyCounter & " value='" & objProperty.Name 	&  "'>" 		& Chr(13) & Chr(10)
		strBuildEditBox		=	strBuildEditBox & "<input type=hidden name=PropertyType"  & lngPropertyCounter & " value='" & strType 			&  "'>" 		& Chr(13) & Chr(10)	
				
		writeProductDetailTD strBuildEditBox, "30%", "LEFT", g_rowNum, aDetailCellColor, aDetailFontColor, "", ""
		writeResponse("</TR>")
	next

	' finish the name-value pair grid
	writeResponse("</TABLE>")
	writeResponse("<BR><input type=""submit"" name=""btnReMeter"" value=""ReMeter"">")
	
	
	set objPipeline = nothing
	set objSession = nothing
	'set objServer = nothing

end sub



sub writeDetailPanel

	dim fieldDisplayName ' from locale object: what we display to the user, if at all
	dim compoundDispLink ' link to the generic compound page

	' Open the panel so that it fits between the 1st and last columns of the
	' standard product detail row.
	writeResponse("<TR>")
	writeResponse("<TD COLSPAN=""1"" BGCOLOR=""" & ag_productDetailBgColor & """>&nbsp;</TD>")
	writeResponse("<TD COLSPAN=""20"" BGCOLOR=""" & ag_productDetailBgColor & """>")

	'=========================================================
	' write the attributes table: which consists of name/value pairs
	writeBeginPanel "20%", _
									"", _
									"THISTLE", "BLACK", _
									 ag_productDetailBgColor, ag_productDetailTabColor


	writeResponse("<TR><TD ALIGN=""LEFT"">")

	' =================================
	' Write out the header items like
	' the ref ID, account ID, etc
	' =================================
	writeProductDetailHdrItems ag_productDetailTabColor, ""
	' =================================

	' =================================
	' Write out the the property grid of
	' name-value pairs
	' =================================
	writeErrorDetails g_RS, g_pViewID, _
											 ag_prodDetNameValHdrColor, ag_prodDetNameValHdrFontColor, _
											 ag_prodDetNameValDetColor, ag_prodDetNameValDetFontColor
	
	' =================================

	' // if the transaction is a compound then write the children out
	'debugWriteWithLevel "session type is: " & g_RS.value("sessionType"), 5
	'if g_RS.value("sessionType") = ag_SESSION_TYPE_COMPOUND then
	'	writeProductChildrenSummary  g_RS.value("sessionID"), g_pViewID, g_drillDownLevel
	'end if

	' End the properties and attributes grid
	writeResponse("</TD></TR>")
	' finish the panel
	writeEndPanel
	'=========================================================

	' Close the panel so that it fits between the 1st and last columns of the
	' standard product detail row. End the row here.
	writeResponse("</TR>")

end sub



' ////////////////////////////////////////////////////////////////////////
' // Start of Product Page
' ////////////////////////////////////////////////////////////////////////


' // Need to specify the default sort order for the page or else it defaults to PROP_TIMESTAMP
dim defaultSortProperty
defaultSortProperty = PROP_TIMESTAMP
dim defaultSortOrder
defaultSortOrder = "ASC"

'// Retrieve the product view rowset as g_RS based on query string parameters
getProductRS defaultSortProperty, defaultSortOrder



%>

<script language="JavaScript">
<!--
var bolAllOn = false;

function CheckAll()
  {
  bolAllOn = !bolAllOn;
  for (var i=0;i<document.frmItems.elements.length;i++)	
      document.frmItems.elements[i].checked = bolAllOn;
	 }
//-->
</script>

<%

' //
' // write out the default product banner page
' //
writeBodyAndProductPageBanner g_pViewID, _															
															request.queryString(QUERY_PVIEWAMOUNT), _
															request.queryString(QUERY_PVIEWAMOUNTUOM), _
															session(SESSVAR_SELECTED_USAGE_INTERVAL_TEXT), _
															"help/errorloghelp.asp" 
															
response.write "<form name=""frmItems"" method=""post"" action=""errorActions.asp"">"
response.write "<INPUT TYPE=""hidden"" name=""batch"" value=""Y"">"															



' // if there are no rows in the result set; stop processing
if g_RS is nothing then
	writeNoRowsBlock "<BR><BR><B>&nbsp;&nbsp;No transactions found</B><BR>"
	response.end
elseif g_RS.EOF then
	writeNoRowsBlock "<BR><BR><B>&nbsp;&nbsp;No transactions found</B><BR>"
	response.end
end if


' // Write the details banner
writeProductDetailRowHeader

' // Output a page of results
for g_recordCounter = 1 to session(SESSVAR_PRODUCT_RS_PAGE_SIZE)

	' // Set up the gif to display on the item -- open or closed
	' // and set up the link (URL) with the correct params for the
	' // next time thru. This function sets:
	' //    g_thisClickedOnState,
	' //    g_iconGif
	' // page-global vars.
	' //
	g_clickedOnParam = setGifAndLinkGlobals(g_RS, g_clickedOnID, _
																					g_clickedOnState, _
																					g_thisClickedOnState, _
																					g_iconGif)

	' // set the href link string to the appropriate value
	' // based on the  current row and it's display state
	g_hrefLinkURLString = "<A HREF=""" & g_thisScriptName & _
												 g_clickedOnParam & g_linkParams & _
												 """><IMG BORDER=0 SRC=""" & _
												 g_iconGif & _
												 """></A>"

	' // Before we move on.....
	' // if this item is open, insert a new row with one column that spans
	' // all the cells in the grid table. In this new row, we place a new
	' // table with all the details of this item
	if g_thisClickedOnState = "O" then
		' // Write out the standard detail row (true = bolded)
		writeDetailRow true, g_hrefLinkURLString
		' // Write out the drill-down detail panel
		writeDetailPanel
	else
		' // Just write out the standard detail row (false = unbolded)
		writeDetailRow false, g_hrefLinkURLString
	end if

	g_RS.MoveNext
	' // If this is the last record, exit the for loop
	if g_RS.EOF then exit for

	' // Increment the row counter if that global setting is
	' // enabled. This is used to give the even/odd row
	' // alternate coloring effect.
	if ag_rowOddEvenColorChange then
		g_rowNum = g_rowNum + 1
	end if

next

' // Close the table -> data grid from: writeProductDetailRowHeader
writeResponse("</TABLE>")
writeResponse("<BR><INPUT TYPE=""submit"" value=""Check All"" onClick=""CheckAll(); return false;"">")
writeResponse("<input type=""submit"" name=""btnDelete"" value=""Delete Items"">")
writeResponse("<input type=""submit"" name=""btnResubmit"" value=""Resubmit Items"">")


' //
' // write closing line
' //
' //writeGridTrailingLine

%>
</Form>
</FONT>
</BODY>
</HTML>



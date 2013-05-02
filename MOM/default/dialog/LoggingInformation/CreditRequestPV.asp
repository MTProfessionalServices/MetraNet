<%
' //==========================================================================
' // @doc $Workfile: CreditRequestPV.asp$
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
' // $Date: 5/9/00 6:48:07 PM$
' // $Author: Frederic Torres$
' // $Revision: 9$
' //==========================================================================

OPTION EXPLICIT
'Session(SESSOBJ_DATA_ACCESSOR).accountID 	= -1 ' Process all the subscriber
%>

<!-- #INCLUDE VIRTUAL="/presserver/mt/us/ExternalText.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/prod_incs.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/utilGenProduct.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/utilExportCSV.asp" -->
<!-- #INCLUDE FILE="../FTemporaryLib.asp" -->

<%

CONST ACCOUNT_CREDIT_REQUEST_STATUS_PENDING		=	"PENDING"

sub writeProductDetailRowHeader

	writeBeginGridTABLE "100%"

	writeResponse("<TR>")
	
	writeGridHdrTD "&nbsp;", "4%", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "4%", "LEFT", "", ""
	writeGridHdrTD createSortHref(TEXT_DATETIME, PROP_TIMESTAMP)		, "20%", "LEFT", "", ""
	writeGridHdrTD "&nbsp;"												, "2%", "RIGHT", "", ""	
	writeGridHdrTD createSortHref(TEXT_ACCOUNTID, "SubscriberAccountID"), "10%", "LEFT", "", ""	
	writeGridHdrTD createSortHref(TEXT_DESCRIPTION, "description")		, "30%", "LEFT", "", ""
	writeGridHdrTD createSortHref("Status", "Status")					, "10%", "LEFT", "", ""
	writeGridHdrTD createSortHref(TEXT_REQUESTED_AMOUNT, PROP_AMOUNT)	, "10%", "RIGHT", "", ""
	writeGridHdrTD createSortHref(TEXT_CREDITED_AMOUNT , "CreditAmount"), "10%", "RIGHT", "", ""

	writeResponse("</TR>")

end sub



Sub writeDetailRow(aBolded, aHrefLinkURLString)

	dim boldOn, boldOff
	dim adjustedDateTime
	dim currentAmount
    dim strIconPath
	
	adjustedDateTime = getUserAdjustedDT(g_RS.value(PROP_TIMESTAMP))
	if aBolded then
		boldOn = "<B>"
		boldOff = "</B>"
	end if

	writeResponse("<TR>")
	
	' Define the link for each credit request to be edited
		
	Dim strAspParameter		'	As String
	strAspParameter 	=  		""
	strAspParameter 	=		strAspParameter  & "pSID=" 			& g_RS.value("sessionID") & "&"
	strAspParameter 	=		strAspParameter  & "parentViewID=" 	&  "&"
	strAspParameter 	=		strAspParameter  & "ddl=" 			& 2 & "&"
	strAspParameter 	=		strAspParameter  & "pViewID=" 		& g_pViewId & "&"
				
	If (g_RS.value("Status")=ACCOUNT_CREDIT_REQUEST_STATUS_PENDING) Then
	
		strIconPath = session(SESSVAR_APP_TOP_IMAGE_URL) & "images/icons/edit_pencil.gif"
	    writeTD "<a href='accountCreditRequest.asp?" & strAspParameter & "'><img border=0 src='" & strIconPath & "'></a>", "4%", "LEFT", g_rowNum
	Else
		writeTD "&nbsp;", "4%", "LEFT", g_rowNum
	End If

	writeTD aHrefLinkURLString, "4%", "LEFT", g_rowNum
	writeTD boldOn & getLocaleDate(adjustedDateTime) & " &nbsp;&nbsp;&nbsp; " & getLocaleTime(adjustedDateTime) & boldOff, "20%", "LEFT", g_rowNum
					
	writeTD "&nbsp;", "2%", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "SubscriberAccountID", "N/A") & boldOff						, "10%", "LEFT", g_rowNum
	writeTD boldOn & getOptionalResultSetField(g_RS, "description", "N/A") & boldOff					, "59%", "LEFT", g_rowNum						
	writeTD boldOn & LocalizeAccountCreditRequestStatus(g_RS.Value("status")) & boldOff					, "10%", "LEFT", g_rowNum
					
	' // VAT needs to include tax in displayed amounts
	If(session(SESSVAR_TAX_TYPE)=TAX_TYPE_VAT)Then
		currentAmount = CDBL(g_RS.value(PROP_AMOUNT)) + CDBL(g_RS.value(PROP_TAXAMOUNT))
	Else
		currentAmount = g_RS.value(PROP_AMOUNT)
	End if
	writeTD boldOn & getLocaleCurrency(currentAmount				, g_RS.value(PROP_UOM)) & boldOff	, "10%", "RIGHT", g_rowNum				
	writeTD boldOn & getLocaleCurrency(g_RS.value("CreditAmount")	, g_RS.value(PROP_UOM)) & boldOff	, "10%", "RIGHT", g_rowNum	
	
	' finish the row
	writeResponse("</TR>")
end sub

sub writeProductDetailHdrItems(aBgColor, aFontColor)

	dim adjustedDateTime
	adjustedDateTime = getUserAdjustedDT(g_RS.value(PROP_TIMESTAMP))

	writeResponse("<TABLE WIDTH=""100%"" BORDER=0 CELLSPACING=""2"" CELLPADDING=""1"" HSPACE=""0"" VSPACE=""0"">")
	' First line -- date, time and amount -- 6 fields
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>Date:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getLocaleDate(adjustedDateTime), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "<B>Time:</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getLocaleTime(adjustedDateTime), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "<B>" & TEXT_AMOUNT & ":</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "<B>" & getLocaleCurrency(g_RS.value(PROP_AMOUNT), g_RS.value(PROP_UOM)) & "</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeResponse("</TR>")

	' Next line -- description -- 2 fields
	writeResponse("<TR>")
	writeProductDetailTD "<B>&nbsp;" & TEXT_DESCRIPTION & ":</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getOptionalResultSetField(g_RS, "description", "N/A"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"5", ""
	writeResponse("</TR>")

	' Next line -- accountID, RefID, pViewID -- 6 fields
	writeResponse("<TR>")
	writeProductDetailTD "&nbsp;<B>" & TEXT_ACCOUNTID & ":</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD g_RS.value("accountID"), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;<B>" & TEXT_REFERENCEID & "</B>", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD getFormattedSessionID(g_RS.value("sessionID")), "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;", "", "LEFT", g_rowNum, aBgColor, aFontColor,"", ""
	writeProductDetailTD "&nbsp;", "", "LEFT", _
											 g_rowNum, aBgColor, aFontColor,"", ""
'g_RS.value(PROP_VIEW_ID), "", "LEFT", _
	writeResponse("</TR>")
	writeResponse("</TABLE>")

end sub

sub writeDetailPanel

	dim fieldDisplayName ' from locale object: what we display to the user, if at all
	dim compoundDispLink ' link to the generic compound page

	' Open the panel so that it fits between the 1st and last columns of the
	' standard product detail row.
	writeResponse("<TR>")
	writeResponse("<TD COLSPAN=""1"" BGCOLOR=""" & ag_productDetailBgColor & """>&nbsp;</TD>")
	writeResponse("<TD COLSPAN=""7"" BGCOLOR=""" & ag_productDetailBgColor & """>")

	'=========================================================
	' write the attributes table: which consists of name/value pairs
	writeBeginPanel "20%", "", "THISTLE", "BLACK", ag_productDetailBgColor, ag_productDetailTabColor

	writeResponse("<TR><TD ALIGN=""LEFT"">")

	' Write out the header items like the ref ID, account ID, etc
	writeProductDetailHdrItems ag_productDetailTabColor, ""


	' Write out the the property grid of name-value pairs
	writeProdDetNameVals g_RS, g_pViewID, false, ag_prodDetNameValHdrColor, ag_prodDetNameValHdrFontColor, ag_prodDetNameValDetColor, ag_prodDetNameValDetFontColor

	' End the properties and attributes grid
	writeResponse("</TD></TR>")
	
	' finish the panel
	writeEndPanel

	' Close the panel so that it fits between the 1st and last columns of the standard product detail row. End the row here.
	writeResponse("</TR>")
end sub



Function CSRUseAllSubscriber(booUseAllSubscriber) ' As Boolean

	writeSystemLog "[Asp=CreditRequestPV.asp][Function=CSRUseAllSubscriber]" &  "CSRUseAllSubscriber " & booUseAllSubscriber,LOG_DEBUG ' #mark 4/14/00 10:56:50 AM
	
	If(booUseAllSubscriber)Then 
		Session(SESSOBJ_DATA_ACCESSOR).accountID 	= -1 ' Process all the subscriber
	Else		
		Session(SESSOBJ_DATA_ACCESSOR).accountID 	= Session("accountID") ' Restore the current subscriber
	End if
	CSRUseAllSubscriber = TRUE
End Function

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

' //
' // write out the default product banner page
' //
writeBodyAndProductPageBanner g_pViewID, request.queryString(QUERY_PVIEWAMOUNT), _
                              request.queryString(QUERY_PVIEWAMOUNTUOM), session(SESSVAR_SELECTED_USAGE_INTERVAL_TEXT), ""

If(g_RS is nothing)Then
	writeNoRowsBlock "<BR><BR><B>&nbsp;&nbsp;" & getLastErrorString() & "</B><BR>"

	response.end
end if
' // if there are no rows in the result set; stop processing
If(CBool(g_RS.EOF))Then
	writeNoRowsBlock "<BR><BR><B>&nbsp;&nbsp;" & TEXT_NOTRANSACTIONSFOUND & "</B><BR>"

	response.end
End If

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
	g_clickedOnParam = setGifAndLinkGlobals(g_RS, g_clickedOnID, g_clickedOnState,g_thisClickedOnState,g_iconGif)

	' // set the href link string to the appropriate value
	' // based on the  current row and it's display state
	g_hrefLinkURLString = "<A HREF=""" & g_thisScriptName & g_clickedOnParam & g_linkParams & """><IMG BORDER=0 SRC=""" & g_iconGif & """></A>"

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
	If(g_RS.EOF)then exit for

	' // Increment the row counter if that global setting is
	' // enabled. This is used to give the even/odd row
	' // alternate coloring effect.
	if ag_rowOddEvenColorChange then
		g_rowNum = g_rowNum + 1
	end if

Next

' // Close the table -> data grid from: writeProductDetailRowHeader
writeResponse("</TABLE>")

response.write "</FONT></BODY></HTML>"

' // Close the result set
set g_RS = nothing



%>

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

session(SESSOBJ_DATA_ACCESSOR).accountID = -1

%>
<!-- #INCLUDE VIRTUAL="/presserver/mt/us/ExternalText.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/prod_incs.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/utilgenproduct.asp" -->
<%


' functions here

sub writeProductDetailRowHeader

	writeBeginGridTABLE "100%"

	writeResponse("<TR>")

	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Date Time", PROP_TIMESTAMP), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Original Account", "c_originalaccountid"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Transaction", "c_TransactionID"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("Amount", "Amount"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("AuthCode", "c_AuthCode"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("RespString", "c_RespString"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("CreditCardType", "c_CreditCardType"), "", "LEFT", "", ""
	writeGridHdrTD "&nbsp;", "2", "LEFT", "", ""
	writeGridHdrTD createSortHref("LastFourDigits", "c_LastFourDigits"), "", "LEFT", "", ""

	writeResponse("</TR>")

end sub

sub writeDetailRow(aBolded, aHrefLinkURLString)
	dim boldOn, boldOff
	dim adjustedDateTime
	adjustedDateTime = getUserAdjustedDT(g_RS.value(PROP_TIMESTAMP))
	if aBolded then
		boldOn = "<B>"
		boldOff = "</B>"
	end if


	writeResponse("<TR>")
	writeTD aHrefLinkURLString, "2", "LEFT", g_rowNum
	
	writeTD boldOn & getLocaleDate(adjustedDateTime) & _
					"&nbsp;" & getLocaleTime(adjustedDateTime) & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_originalaccountid", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_TransactionID", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "Amount", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_AuthCode", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum

	writeTD boldOn & getOptionalResultSetField(g_RS, "c_RespString", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_CreditCardType", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	
	
	writeTD boldOn & getOptionalResultSetField(g_RS, "c_LastFourDigits", "N/A") & boldOff, _
					"", "LEFT", g_rowNum
	writeTD "&nbsp;", "2", "RIGHT", g_rowNum
	

	' finish the row
	writeResponse("</TR>")
end sub




sub writeDetailPanel

	dim fieldDisplayName ' from locale object: what we display to the user, if at all
	dim compoundDispLink ' link to the generic compound page

	' Open the panel so that it fits between the 1st and last columns of the
	' standard product detail row.
	writeResponse("<TR>")
	writeResponse("<TD COLSPAN=""1"" BGCOLOR=""" & ag_productDetailBgColor & """>&nbsp;</TD>")
	writeResponse("<TD COLSPAN=""19"" BGCOLOR=""" & ag_productDetailBgColor & """>")

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
	
	'writeProductDetailHdrItems ag_productDetailTabColor, ""
	
	' =================================

	' =================================
	' Write out the the property grid of
	' name-value pairs
	' =================================
	writeProdDetNameVals g_RS, g_pViewID, true, _
											 ag_prodDetNameValHdrColor, ag_prodDetNameValHdrFontColor, _
											 ag_prodDetNameValDetColor, ag_prodDetNameValDetFontColor
	

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

session(SESSOBJ_DATA_ACCESSOR).accountID = session("accountID")


writeBodyAndProductPageBanner g_pViewID, _															
															request.queryString(QUERY_PVIEWAMOUNT), _
															request.queryString(QUERY_PVIEWAMOUNTUOM), _
															session(SESSVAR_SELECTED_USAGE_INTERVAL_TEXT), _
															"../help/errorloghelp.asp" 
															

' // if there are no rows in the result set; stop processing
if cbool(g_RS.EOF) then
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


' //
' // write closing line
' //
' //writeGridTrailingLine

%>

</FONT>
</BODY>
</HTML>

<%
' // Close the result set
set g_RS = nothing

%>

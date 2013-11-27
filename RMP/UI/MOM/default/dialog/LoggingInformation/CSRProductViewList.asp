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
%>

<!-- #INCLUDE VIRTUAL="/presserver/mt/us/ExternalText.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/prod_incs.asp" -->
<!-- #INCLUDE VIRTUAL="/mtinclude/utilGenGroup.asp" -->

<HTML>
<%
g_rowNum = 1



' //
' // display headers for summary view
' //
sub writeGroupHdr
	writeBeginGridTABLE "100%"
	response.write("<TR>")
	writeGridHdrTD "Logs", "100%", "LEFT", "", ""
	response.write("</TR></TABLE>")
end sub

sub writeProductViewItem(aDisplayName,aURL,aViewID)

	dim cellText
	
	writeResponse("<TR>")
	cellText = "<A class=linkOff onmouseover=""this.className='linkOn'""" & _
						" onmouseout=""this.className='linkOff'"""						
	cellText =  cellText & " HREF=""" & aURL & "?pViewID=" & aViewID & _
							"&ddl=1&pViewAmount=60&pViewAmountUOM=USD"
	cellText = cellText &  """>"
	cellText = cellText & "<IMG BORDER=0  SRC=""" & g_iconGif & """>"
	cellText = cellText & aDisplayName
	writeTD cellText, "100%", "LEFT", 1
	writeResponse("</TR>")
end sub


dim formAction ' as string
dim summaryViewRS ' as string

'formAction = "/netmeter/msix.asp" ' Used for testing purposes to see all form variables
formAction = "CSRProductViewList.asp" 'genGroup.asp"

dim selectString ' as string
dim selectedUI ' as integer
dim currUIText ' as string
dim selectedUIText ' as string
dim usageIntervalRS ' as object
dim recCount ' as integer

' // Get the selected usage interval from the query string
selectedUI = request.queryString(QUERY_USAGE_INTERVALID)
'call writeResponse("THE INTERVALID:""" & selectedUI & """")

if trim(selectedUI) <> "" then
	' // if a Usage Interval has been selected; then
	' // make sure that we are on it
	session(SESSVAR_SELECTED_USAGE_INTERVAL) = Clng(selectedUI)
	session(SESSOBJ_DATA_ACCESSOR).intervalID = session(SESSVAR_SELECTED_USAGE_INTERVAL)
end if

set usageIntervalRS = session(SESSOBJ_DATA_ACCESSOR).getUsageInterval()

selectString = "</B><SELECT NAME=""" & QUERY_USAGE_INTERVALID & _
	""" onChange=""genSelectUI.submit()"" SIZE=""1"" style=""font-family: arial; font-size: 8pt"">"

currUIText = ""
recCount = 0
do while not Cbool(usageIntervalRS.EOF)

	selectString = selectString & "<OPTION VALUE=""" & usageIntervalRS.value(PROP_INTERVALID) & """"

	selectedUIText = getUsageIntervalText(usageIntervalRS, recCount)
	recCount = recCount + 1

	if CLng(usageIntervalRS.value(PROP_INTERVALID)) = CLng(session(SESSVAR_SELECTED_USAGE_INTERVAL)) then

		selectString = selectString & " SELECTED"
		currUIText = selectedUIText
		session(SESSVAR_SELECTED_USAGE_INTERVAL_TEXT) = currUIText
	end if

	selectString = selectString & ">"
	selectString = selectString & selectedUIText
	usageIntervalRS.moveNext
loop

selectString = selectString & "</SELECT>"
selectString = selectString & "</FONT>"

' // Clear out the drill down level
setNavigationLinks 0, 0, ""


' //
' // write out header as a separate form
' //
writeResponse("<FORM NAME=""genSelectUI"" ACTION=""" & formAction & """ METHOD=""GET"">")
writeBodyAndPageBanner "&nbsp;" & "System Logs", "help/errorloghelp.asp"
writeWhiteSpace 3

' // Write usage interval SELECT without History screen link
writeUsageIntervalSelectTable selectString,false
writeResponse("</FORM>")

' //
' // clear the product result level set session var
' // and do some clean up for navigation purposes
' //
session(SESSVAR_PRODUCT_RS_LEVEL) = 0
session(SESSVAR_NAVIGATION_LINKS).removeAll

session(SESSVAR_USING_SUMMARY_VIEW)=true
%>

<FORM NAME="genGroup" ACTION="<%=formAction%>" METHOD="GET">

<%

' //
' // start the ball rolling by getting the top level summary view
' //


	' // write the header data
	writeGroupHdr
	
	writeBeginGridTABLE "100%"
	dim cellText ' as string
	
			writeResponse("<TR>") ' start a new row
				g_iconGif = ag_genericProductGif
	
	dim objNameLookup ' as object
	set objNameLookup = server.createobject("MetraPipeline.MTNameID.1")
	
	session(FILTER_HIDDEN_EXTENSION & objNameLookup.getNameID("pipeline/error")) = " and pv.c_state = 'N' "
		
	writeProductViewItem "System Failures","SystemFailuresPV.asp",getViewIdFromViewName("pipeline/error")
	writeProductViewItem "Credit Request","CreditRequestPV.asp",getViewIdFromViewName("metratech.com/AccountCreditRequest")
  
  if IsPaymentServerInstalled then
  	writeProductViewItem "Preauthorization Success","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/preauthsuccess")		
  	writeProductViewItem "Preauthorization Failures","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/preauthfailure")			
  	writeProductViewItem "Postauthorization Success","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/postauthsuccess")		
  	writeProductViewItem "Postauthorization Failures","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/postauthfailure")			
  '	writeProductViewItem "Settle Success","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/settlesuccess")		
  '	writeProductViewItem "Settle Failures","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/settlefailure")			
  	writeProductViewItem "Credit Success","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/creditsuccess")			
  	writeProductViewItem "Credit Failures","PaymentServerLogsPV.asp",objNameLookup.getNameID("metratech.com/creditfailure")			
  end if
  
  set objNameLookup = nothing
	' // Open the table

	'writeView summaryViewRS,	-1

	' // Close the table
	response.write("</TD></TR></TABLE>")
%>


</FORM>
<%

writeEndBody

%>

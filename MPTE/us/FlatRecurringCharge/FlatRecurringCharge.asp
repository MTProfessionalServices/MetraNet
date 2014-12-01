<%
' //==========================================================================
' // @doc $Workfile: FlatRecurringCharge.asp
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
' // Created by: Fabricio Pettena
' //
' // $Date: 05/18/01
' // $Author: Fabricio Pettena
' // $Revision: 1$
' //
' // This file is used to handle, in a custom way, the edition of the flatrecurring charge
' // parameter table.
' //
' //
' //==========================================================================


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Constants 		                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Const g_str_OPEN_TABLE_TAG_PARAMS =  "border=""0"" cellspacing=""1"" cellpadding=""1"" "


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Product Catalog Variables
dim objMTRateSched ' As MTRateSchedule
dim objMTParamTableDef ' As MTParamTableDef
dim objMTProductCatalog   ' as MTProductCatalog
dim objMTRuleset
dim objTRReader	' As TabRulesetReader

dim bolEditCharge ' Boolean that flags whether we should display the page in edit mode or not
dim bolSaveChanges ' Boolean that flags whether we should save the changes or not
dim strAmount	   ' holds the amount typed on the textfield
dim strError 

dim strImg
dim strButtonCaption

'---------------------------------------------------------------------
' FUNCTIONS
'---------------------------------------------------------------------

'---------------------------------------------------------------------
' FUNCTION ValidateAmount
' DESCRIPTION : Make sure that the ammount entered by the user is valid
' INPUT : Amount as a string
' OUTPUT : TRUE or FALSE
'---------------------------------------------------------------------
FUNCTION ValidateAmount(sAmount)
	if IsNumeric(sAmount) then
		ValidateAmount = TRUE
	else
		ValidateAmount = FALSE
	end if
END FUNCTION

'//-------------------------------------------------------------
'// PAGE PROCESSING STARTS
'//-------------------------------------------------------------

'// Check whether we have newer arguments before we load the objects
'// All querystring vars are stored in the session under the prefix "RATES_"
call LoadQueryString()

'// Are we supposed to draw the textarea in edit mode?
'// The only detail is that if we are not in EDITMODE, then we override the parameter above
bolEditCharge = true '(UCase(Request.Form("FormAction")) = "TRUE")

'// If the condition below is true, it means that the user just clicked on the Save image,
'// and we will have to validate & save the newly typed value. 
if UCase(Request.Form("FormAction")) = "FALSE" then
	bolSaveChanges = true
else
	bolSaveChanges = false
end if

'// If we are not in edit mode, saving or editing makes no sense, therefore we will unset these flags
if UCase(session("RATES_EDITMODE")) = "FALSE" then
	bolSaveChanges = false
	bolEditCharge = false
end if

'// Now we are reloading objects. Get the Product Catalog first
'//set objMTProductCatalog = Server.CreateObject("MetraTech.MTProductCatalog")
Set objMTProductCatalog = GetProductCatalogObject

'// We are retrieving the objects we need all the way up to the Ruleset
'// so we can get the rule that contains the charge we want to edit  
set objMTParamTableDef = objMTProductCatalog.GetParamTableDefinition(Clng(session("RATES_PARAMTABLE_ID")))
set objMTRateSched = objMTParamTableDef.GetRateSchedule(Clng(session("RATES_RATESCHEDULE_ID")))
set objMTRuleset = objMTRateSched.RuleSet ' get the ruleset from the RateSchedule.

'// Set warning message off
strWarning = ""

'// If the DefaultActions are not configured yet, then we will create a new action set and assign to it.
if objMTRuleset.DefaultActions Is Nothing then
	strWarning = FrameWork.GetDictionary("TEXT_MPTE_WARNING_NORATE_CONFIGURED")
end if


'// If we are supposed to save the changes, then we will do so here:
if bolSaveChanges then
	strAmount = Request.Form("Amount")
	if validateAmount(strAmount) then
	  
		'// If the DefaultActions are not configured yet, then we will create a new action set and assign to it.
		if objMTRuleset.DefaultActions Is Nothing then
			objMTRuleset.DefaultActions = CreateActionSet(objMTParamTableDef)
		end if
		
	  ' // Now we set the value in the appropiate spot on the actionset
	  call SetRSActionValue(objMTRuleset.DefaultActions(1), strAmount)
	  
	  ' // Commit the changes to the database	  
	  objMTRateSched.SaveWithRules
	  bolSaveChanges = false
	  '// After 'Ok' click and save, we'll return
	  response.Redirect session("ownerapp_return_page")
	else
	 ' ERROR STRING
	 bolEditCharge = not bolEditCharge
	 strError = FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_AMOUNT")
	end if	
end if

%>
<html>
  <head>
    <title><%=FrameWork.GetDictionary("TEXT_SET_CHARGE_AMOUNT")%></title>
		<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
	
	<script language="JavaScript" src="/mpte/shared/browsercheck.js"></script>
	<script language="JavaScript" src="/mpte/shared/PopupEdit.js"></script>    	
	<script LANGUAGE="JavaScript1.2">	
	var UnsavedChanges = false;
	
	// This function makes us return to the page that first called this MPTE application
	// For that, we need that page call to be stored in the session
	// This can't be in an include file because we need to write asp in it
	function returnToCallerApp()
	{	
		if (UnsavedChanges) //!document.main.Amount.disabled)
		{
			if (!confirm(<% response.write "'" & FrameWork.GetDictionary("TEXT_MPTE_UNSAVED_CHANGES") & "'"%>))
				return;
		}
		<%
		Dim strURL
		strURL = "'" & session("ownerapp_return_page") & "';"					 
		%>
		<%
		Response.Write("document.location.href =" & strURL)
		%>
	}	
	
	function SubmitForm(istrAction)
    {
      document.main.FormAction.value = istrAction;
      document.main.submit();
    }
	
	</script>
  </head>

  <body <% 'if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then response.write("class=""clsTabBody""") end if%> >
  
  <form name="main" action="gotoFlatRecurringCharge.asp" method="POST">
  <input TYPE="Hidden" name="FormAction" value="">
  <% 
  	' If the owner is MCM, we will draw the POBased or PLBased tabs. Then we will close the table at the end of this page
 	'if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then 
	'  call Tab_Initialize()
	'end if
	
  ' For this custom page, we will display the complete Title Bar, with description and effective dates
	call DisplayTitle(objMTParamTableDef.DisplayName, "CaptionBar", objMTRateSched, (UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM")) 'We are displaying complex data
  'call DisplaySimpleTitle(objMTRateSched, "CaptionBar")
  %>
  	
	<% if len(objMTParamTableDef.HelpURL) > 0 then
		response.write "<DIV class=""clsInfoURL""><IMG border=0 align=middle SRC=""/mpte/us/images/infoSmall.gif""><A HREF=""javascript:OpenDialogWindow('" & objMTParamTableDef.HelpURL & "','height=600, width=800, resizable=yes,scrollbars=yes');"">" & FrameWork.GetDictionary("TEXT_MPTE_MOREINFO") & "</A></DIV>"
	end if %>
	  
  <table <%=g_str_OPEN_TABLE_TAG_PARAMS%> align="center">
  <tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr>
	<tr>
  <td align="center" class="captionNSRequired"><%=FrameWork.GetDictionary("TEXT_MPTE_RECURRING_CHARGE_AMOUNT")%>:&nbsp;</td>
  <td align="center"> 
  	<input type="text" class="fieldNumericRequired" onKeyDown="UnsavedChanges=true;" name="Amount" maxlength="12" value="<% if Not objMTRuleset.DefaultActions Is Nothing then response.write(objMTRuleset.DefaultActions(1).PropertyValue) end if%>" <% if not bolEditCharge then response.write(" disabled") %>>
  </td>
  <td align="center">
	<%
	'if bolEditCharge then
	  'strImg = "/mpte/us/images/save.gif"
	'	strButtonCaption = FrameWork.GetDictionary("TEXT_MPTE_SAVE_BTN")
	'else
	  'strImg = "/mpte/us/images/edit.gif"
	'	strButtonCaption = FrameWork.GetDictionary("TEXT_MPTE_EDIT_BTN")
	'end if
	
		
	'if Ucase(session("RATES_EDITMODE")) = "TRUE" then
	'	Response.Write("<input name='butEditSave' class='clsButtonBlueSmall' value='" & strButtonCaption & "'  type='button' onClick=""javascript:SubmitForm('" & CStr(not bolEditCharge) & "');"">")
	'end if
	
	%>
  </td>
	<td align="center">&nbsp;</td>
	<td class="clsCustomErrorMessage"><% if len(strError) > 0 then response.write(strError) end if%></td>
	<td align="center">&nbsp;</td>
	<td align="center"><%Response.Write(strWarning)%></td>
  </tr>
  <!-- /table -->
  <tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr>
  <!-- table <%=g_str_OPEN_TABLE_TAG_PARAMS%> align="center" -->
  <tr>
  <td colspan="4" align="center"> 
  <%
  	if Ucase(session("RATES_EDITMODE")) = "TRUE" then
		Response.Write("<input name='butEditSave' class='clsButtonSmall' value='" & FrameWork.GetDictionary("TEXT_OK") & "'  type='button' onClick=""javascript:SubmitForm('" & CStr(not bolEditCharge) & "');"" ID='Button1'>")
	end if
  %>
	<input type="button" class="clsButtonSmall" name="Close" value="<%= FrameWork.GetDictionary("TEXT_CANCEL") %>" onClick="javascript:returnToCallerApp();">
  </td>
  </tr>
  </table>
  <% if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then 'We check what application called the MPTE - if it was MCM, we will close the tabs table %>
  	</tr>
  	</table>
  <%end if%>
  </form>
  <script>if (!document.forms[0].Amount.disabled) document.forms[0].Amount.focus();</script>
  </body>
</html>
    

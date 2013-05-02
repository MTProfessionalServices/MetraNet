
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->

<body>
<form>
<%
  dim bDebug
  bDebug = false
  on error resume next
  
  dim sErrorMessage
	dim vData
	vData = Request.BinaryRead(Request.TotalBytes)
  
  if err then
    sErrorMessage = "Unable to read the buffer containing the uploaded file. This can possibly be caused by the incoming request buffer being too small for the size of the file. The size of the current request buffer is " & Request.TotalBytes & " bytes. Please have your system administrator check to make sure the IIS configuration setting AspMaxRequestEntityAllowed is at least this size."
    response.redirect "BillingGroupPullListFromFile.asp?ImportError=" & Server.UrlEncode(sErrorMessage)
    response.end
  end if
  
  if bDebug then
    response.write("Request BinaryRead: <textarea cols=80 rows=100 name='BinaryRead'>" & DebugConvertArrayToString(vData) & "</textarea><BR>")
    response.end
  end if
  
  dim objContent
  set objContent = CreateObject("MetraTech.UI.Utility.Content")

  dim sBuffer
  sBuffer = objContent.Retrieve("upfile",(vData))
  'response.write("Reponse from Content: <textarea cols=80 rows=100 name='test'>" & objContent.Retrieve("upfile",(vData)) & "</textarea><BR>")
  
  if false then
    response.write("Request size[" & Request.TotalBytes & "]<BR>")
    response.write("Reponse from Content: <textarea cols=80 rows=100 name='test'>" & sBuffer & "</textarea><BR>")
  end if
  
  'response.End
  
  if false then
  if arrErrors.Count > 0 or objRuleset.Count=0 then
   '//There were errors
   if arrErrors.Count = 0 and objRuleset.Count=0 then
     '//Special case where no error was returned but no rules were returned either
     '//Undetected/reported error or the Excel spreadsheet had no rules
     sErrorMessage = "No rules were found in the imported ruleset<BR>"
   end if
   dim i
   for i=0 to arrErrors.Count-1
     sErrorMessage = sErrorMessage & arrErrors(i) & "<BR>"
   next
   response.redirect "gotoPopup.asp?loadpage=GenericTabRuleSetExportImportExcel.asp&ImportError=" & Server.UrlEncode(sErrorMessage)
   response.end
  else
    '//No errors
		  ' Note that this is a workaround to copy the rules
		  ' Ideally, we would need a method on ProductCatalog or rate schedule to be able to 'set' a new ruleset
		  Set objMTRateSched = session("CurrMTRateSchedule")
      '//DEBUG: objRuleSet.write "c:\import_ruleset.xml"

		  Set propset   = objRuleset.WriteToSet
		  Set newrules  = objMTRateSched.RuleSet
		  propset.Reset
		  newrules.ReadFromSet propset
			
		  Set session("RuleSet") = objMTRateSched.Ruleset

end if
  end if
  
    session("PullListFromFileBuffer") = sBuffer

  Dim objUSM, materializationID
  Set objUSM = mom_GetUsageServerClientObject()

'This screen handles file support for creating user defined billing groups and pull lists
'Which type of creation are we doing
dim bCreatingUserDefinedBillGroup
if len(Session("PULL_LIST_FROM_FILE_BILLINGGROUP_ID"))=0 then
	bCreatingUserDefinedBillGroup = true
else
	bCreatingUserDefinedBillGroup = false
end if


if bCreatingUserDefinedBillGroup then
	materializationID = objUSM.CreateUserDefinedBillingGroupFromAccounts(CLng(Session("PULL_LIST_FROM_FILE_INTERVAL_ID")), Session("PULL_LIST_FROM_FILE_NAME"), Session("PULL_LIST_FROM_FILE_DESCRIPTION"), sBuffer)
else
	materializationID = objUSM.StartChildGroupCreationFromAccounts(Session("PULL_LIST_FROM_FILE_NAME"), Session("PULL_LIST_FROM_FILE_DESCRIPTION"), Session("PULL_LIST_FROM_FILE_BILLINGGROUP_ID"), sBuffer, needsExtraAccounts)
	 
	if err.number<>0 then
		'response.Write ("ERROR:" & err.Description & "<BR>")
		response.redirect "BillingGroupPullListFromFile.asp?ImportError=" & Server.UrlEncode(err.Description)
	else
		Dim billingGroupID
		billingGroupID = objUSM.FinishChildGroupCreation(materializationID)  
	    
		'If(CBool(Err.Number <> 0)) Then
		'  EventArg.Error.Save Err 
		'  OK_Click = FALSE   
		'  Exit Function
		'End If
		response.Write("Created billing group with id [" & billingGroupID & "] Materialization[" & materializationID & "] Needs extra accounts [" & needsExtraAccounts & "]<BR>")
		response.write "<script> window.opener.location = 'IntervalManagement.ViewEdit.asp?BillingGroupID=" & Session("PULL_LIST_FROM_FILE_BILLINGGROUP_ID") & "&ID=" & Session("PULL_LIST_FROM_FILE_INTERVAL_ID") & "&mdmReload=FALSE&mdmRefreshFromPopUpDialog=TRUE&MDMAction=REFRESH';window.close();</script>"
	end if
	response.end
end if

  
  Function DebugConvertArrayToString(vArray)
		Dim sString
		Dim iPos
		
		iPos = 1
		sString = ""
		Do While iPos <= LenB(vArray)
			sString = sString & Chr(AscB(MidB(vArray, iPos, 1)))
			iPos = iPos + 1
		Loop
		
		fnConvertArrayToString = sString
	End Function

%>
</body>
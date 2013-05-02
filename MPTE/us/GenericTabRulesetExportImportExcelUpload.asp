
<body>
<form>
<%

Session.CodePage = 65001
Response.CharSet = "utf-8"


  dim bDebug
  bDebug = false
  on error resume next
  
  dim sErrorMessage
	dim vData
	vData = Request.BinaryRead(Request.TotalBytes)
  
  if err then
    sErrorMessage = "Unable to read the buffer containing the uploaded file. This can possibly be caused by the incoming request buffer being too small for the size of the file. The size of the current request buffer is " & Request.TotalBytes & " bytes. Please have your system administrator check to make sure the IIS configuration setting AspMaxRequestEntityAllowed is at least this size."
    response.redirect "gotoPopup.asp?loadpage=GenericTabRuleSetExportImportExcel.asp&ImportError=" & Server.UrlEncode(sErrorMessage)
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
  
  if bDebug then
    response.write("Request size[" & Request.TotalBytes & "]<BR>")
    response.write("Reponse from Content: <textarea cols=80 rows=100 name='test'>" & sBuffer & "</textarea><BR>")
  end if
  
  dim objRulesetConverter
  set objRulesetConverter = CreateObject("MetraTech.UI.Utility.RuleSetImportExport")
  
  dim objRuleset
  dim arrErrors
  set objRuleset = CreateObject("MTRuleSet.MTRuleSet.1")
  set arrErrors = objRulesetConverter.ImportFromExcel(sBuffer,(objRuleset))

  if bDebug then
    response.write "Imported ruleset contains " & objRuleset.Count & " rules<BR>"
    response.write "Import had " & arrErrors.Count & " errors<BR>"
  'response.end
  end if
  dim rulecount
  if (objRuleset.DefaultAcounts is nothing) then
	rulecount = objRuleset.Count
  else
	rulecount = objRuleset.Count + objRuleset.DefaultActions.Count
  end if
  
  'ESR-5228 - Can't import from excel file 
  'Added check if some default rules were imported
  if arrErrors.Count > 0 or rulecount=0 then
   '//There were errors
   if arrErrors.Count = 0 and rulecount = 0 then
     '//Special case where no error was returned but no rules were returned either
     '//Undetected/reported error or the Excel spreadsheet had no rules
     sErrorMessage = "No rules were found in the imported ruleset<BR>"
   end if
   dim i
   dim sError
   for i=0 to arrErrors.Count-1
     'SECENG: reduce a length of text passed via Query string
     sError = SafeForHtml(arrErrors(i)) & "<BR>"
	 if (Len(sErrorMessage) + Len(sError)) < 2000 then
       sErrorMessage = sErrorMessage & sError
	 end if
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

    session("UnsavedChanges") = true
    '//This refresh will also close our popup window
  	response.write("<script LANGUAGE=""JavaScript1.2"">window.opener.location=""gotoRuleEditor.asp?AfterEdit=TRUE&page=1"";</script>")
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
<%
response.buffer=false
%>
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->

<HTML>
<HEAD>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/Grid.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/menu.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/MenuStyles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/NavStyles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/oldmenu.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/RuleEditor_styles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/styles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/Tab.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/tab_styles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/wizard_styles.css'>

<!-- Meta Tag from dictionary -->
<meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=UTF-8">

  <LINK rel="STYLESHEET" type="text/css" href="/mcm/default/localized/en-us/styles/styles.css">
  <title><%=FrameWork.GetDictionary("TEXT_RULESET_CHANGES")%></title>                 
</HEAD>
<body>
<FORM Method="post" Action="/mcm/default/dialog/AuditLog.List.asp"  name='mdm'>
<!-- MDM Client Side -->
<!--  MDM Client Side JavaScript -->
<SCRIPT language="JavaScript" src="/mpte/shared/browsercheck.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/mdm/internal/mdm.JavaScript.lib.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2">
// MetraTech Dialog Manager Client Side. This JavaScript was generated.
var DECIMAL_SEPARATOR	                                        =	".";  // Should be replaced by . or ,
var THOUSAND_SEPARATOR	                                      =	",";	// Should be replaced by . or ,
var DECIMAL_DIGIT_BEFORE                                      =  12;
var DECIMAL_DIGIT_AFTER                                       =  10;
var MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY                         =  false; // PVB Does not support enter key and escape key
var MDM_TYPE_TIMESTAMP_CHARS                                  =  "0123456789/: APMapm";
var MDM_TYPE_STRINGID_CHARS                                   =  "_ ABCDEFGHIJKLMNOPQRSTVWUXYZabcdefghijklmnopqrstvwuxyz0123456789";
var MDM_CALL_PARENT_POPUP_WITH_NO_URL_PARAMETERS              =  false;

var MDM_VALID_CHARS_FOR_LONG                                  = "0123456789-";
var MDM_VALID_CHARS_FOR_DECIMAL                               = "0123456789-";

var MDM_PICKER_PARAMETER_VALUE                                = "[MDM_PICKER_PARAMETER_VALUE]"; // MDM V2 Picker Support
var MDM_PICKER_NEXT_PAGE                                      = "[MDM_PICKER_NEXT_PAGE]";
var MDM_ENTER_KEY_PRESSED                                     = false; // Monitor the status of the enter key to avoid to send it twice

var MDM_PVB_CHECKBOX_PREFIX                                   = "MDM_CB_"; // CONST 
//var MDM_PVB_SELECTED_ROW_ROWID                                = null;
//var MDM_PVB_SELECTED_ROW_TR                                   = null;
//var MDM_PVB_SELECTED_ROW_CLASS                                = null;
//var MDM_PVB_SELECTED_ROW_ID                                   = null;

function GetMaxLength(strName){
    if(strName){
    }
    return 0;
}
function GetDataType(strName){
    if(strName){
    }
	  return "STRING";
}
HookNewEvents();
function mdm_Initialize(){ // Some Customizable Javascript associate to the form Form.JavaScriptInitialize    
    
    return true;
}
mdm_Initialize();
</SCRIPT>
<INPUT Name="mdmAction" Type="Hidden" Value="">
<INPUT Name="mdmProperty" Type="Hidden" Value="">
<INPUT Name="mdmUserCustom" Type="Hidden" Value="">
<INPUT Name="mdmPvbRowsetRecordCount" Type="Hidden" Value="543">

<INPUT Name="mdmSelectedIDs" Type="Hidden" Value="">
<INPUT Name="mdmUnSelectedIDs" Type="Hidden" Value="">
<INPUT Name="mdmPageIndex" Type="Hidden" Value=""><!-- the javascript mdm_PVBPageEventRaiser() use this hidden field, the HTML tool bar pass the value via the querystring -->
<INPUT Name="mdmPageAction" Type="Hidden" Value="">
<INPUT Name="mdmPVBSelectedRowID" Type="Hidden" Value="">
<!--  MDM Client Side JavaScript -->

<%
      dim mDebug '//global value to quickly turn on debugging/troubleshooting messages
      mDebug=false 
      
      '//Retrieve the parameters passed to the page for doing the ruleset comparison
      '//RS_STARTDATE_1 = the datetime for the ruleset to look at it (most likely the datetime an update was made)
      '//RS_STARTDATE_2 = the datetime for the previous version of the ruleset to compare against (optional... if not passed then we compare the ruleset against the version
      '//                 that was valid 1 second before RS_STARTDATE_1
      '//PT_ID          = the id of the parameter table
      '//RS_ID_1        = the id of the rateschedule
      
      dim dtRuleSet1, dtRuleSet2, sPageTitle
      dim idPT, idRateSchedule1
      dim bViewChangeFromApproval
      bViewChangeFromApproval = false

      dim sRulesetBuffer

      if len(request("APPROVAL_ID"))>0 then
        bViewChangeFromApproval= true

        '//Lookup the rateschedule from the approval
        dim idApproval
        idApproval = CLng(request("APPROVAL_ID"))

        dim objApprovals
        set objApprovals = InitializeApprovalsClient
        dim changeDetails
        changeDetails = objApprovals.GetChangeDetails(idApproval)

        dim objChangeSummary
        set objChangeSummary = objApprovals.GetChangeSummary(idApproval)
        
        dim bApprovalChangeIsPending
        dim iApprovalCurrentState
        iApprovalCurrentState = objChangeSummary.CurrentState
        if iApprovalCurrentState = 0 then
          bApprovalChangeIsPending = true
        else
          bApprovalChangeIsPending = false
        end if

        dim dtApprovalChangeSubmittedDate
        dtApprovalChangeSubmittedDate = objChangeSummary.SubmittedDate 'CDate("4/23/2012")

        dim objChangeDetailsHelper
        set objChangeDetailsHelper = CreateObject("MetraTech.Approvals.ChangeDetailsHelper")
        objChangeDetailsHelper.FromBuffer(changeDetails)


        idPT = objChangeDetailsHelper("ParameterTableId")
        idRateSchedule1 = objChangeDetailsHelper("RateScheduleId")

        'dim objConfigSet
        'set objConfigSet = objMTRateSched.RuleSet.WriteToSet
        'objChangeDetailsHelper("UpdatedRuleSet") = objConfigSet.WriteToBuffer
        

        sRulesetBuffer = objChangeDetailsHelper("UpdatedRuleSet")

        writeDebugMessage("Approvals sRulesetBuffer[" & sRulesetBuffer & "]<BR>")
       


        
      else if len(request("AUDIT_ID"))>0 then
      '//We will need to retrieve all the params we need from just the audit id
        idRateSchedule1 = Clng(request("RS_ID_1"))
        
        dim sModifiedBy
        dim rowset
        set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
        rowset.Init "queries\audit"
        rowset.SetQueryTag("__GET_PARAMTABLE_ID_AND_TABLENAME_FOR_RATE_SCHEDULE__")
        rowset.AddParam "%%RS_ID%%", idRateSchedule1
        rowset.Execute
        
        idPT = Clng(rowset.value("id_paramtable"))
        dim sPT
        sPT = rowset.Value("nm_instance_tablename")
        
        rowset.SetQueryTag("__SELECT_SINGLE_AUDIT_ENTRY_FOR_RULESET_UPDATE_ON_RATE_SCHEDULE__")
        rowset.AddParam "%%AUDIT_ID%%", Clng(request("AUDIT_ID"))
        rowset.AddParam "%%PARAM_TABLE_ID%%", idPT
        rowset.AddParam "%%PARAM_TABLE_DB_NAME%%", sPT
        rowset.Execute   
            
        dtRuleSet1 = CDate(rowset.value("RuleSetStartDate"))

        
        sModifiedBy = rowset.value("username")

        rowset.SetQueryTag("__SELECT_RATE_SCHEDULE_DISPLAY_INFORMATION__")
        rowset.AddParam "%%RS_ID%%", idRateSchedule1
        rowset.AddParam "%%TX_LANG_CODE%%", GetFrameworkAppLanguageFromPageLanguage(Session("FRAMEWORK_APP_LANGUAGE"))
        rowset.Execute
        
        dim sPriceListName
        if len(rowset.value("PriceListName"))>0 then
          sPriceListName = rowset.value("PriceListName")
        else
          '//If the pricelist name is blank, we infer it must be an ICB pricelist
          sPriceListName = FrameWork.GetDictionary("TEXT_ICB_PRICELIST_DISPLAY_NAME")
        end if
        
        sPageTitle = "Pricelist <strong>" & sPriceListName & "</strong><br>modified by <strong>" & sModifiedBy & "</strong> at <strong>" & dtRuleSet1 & "</strong>"

      else
        dtRuleSet1 = request("RS_STARTDATE_1")
        idPT = Clng(request("PT_ID"))
        idRateSchedule1 = Clng(request("RS_ID_1"))
        sPageTitle = request("Title")
      end if
      end if

      writeTimedMessage "Page Start"

      if not bViewChangeFromApproval then
        '//If we were passed the other valid date of the ruleset to compare against, use it
        '//otherwise compare against the time period just before the first date passed
        if len(request("RS_STARTDATE_2"))>0 then
          dtRuleSet2 = request("RS_STARTDATE_2")
        else
          dtRuleSet2 = DateAdd("s",-1,CDate(dtRuleSet1))
        end if


        writeDebugMessage("RuleSetStartDate[" & CDate(dtRuleSet1) & "]<BR>")
        writeDebugMessage("RuleSetStartDate2[" & CDate(dtRuleSet2) & "]<BR>")
      end if

      '//Load relevant product catalog and meta data objects
      		  Set objMTProductCatalog = GetProductCatalogObject
      			call WriteRunTimeError("Product Catalog" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_CREATE_OBJ"), false)
      					  
      		  Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(idPT)
      			call WriteRunTimeError(FrameWork.GetDictionary("TEXT_KEYTERM_PARAMETER_TABLE") & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_FOUND") & "&nbps;" & "ID=" & session("RATES_PARAMTABLE_ID"), false)
      			
      		  Set objMTRateSched = objParamTableDef.GetRateSchedule(idRateSchedule1)
      			call WriteRunTimeError(FrameWork.GetDictionary("TEXT_KEYTERM_RATE_SCHEDULE") & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_FOUND") & "&nbps;" & session("RATES_RATESCHEDULE_ID"), false)
      
      		  ' Get the Metadata from the parameter table
      		  Set mobjTRReader = Server.CreateObject("MTTabRulesetReader.RulesetHandler")
      			call WriteRunTimeError("Tabular Ruleset Reader" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_CREATE_OBJ"), false)
      			
      		  call mobjTRReader.InitializeFromProdCat(objParamTableDef.Id)
      			call WriteRunTimeError("Tabular Ruleset Reader" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_INITIALIZE_OBJ"), false)
      
            writeTimedMessage "Retrieved Product Catalog objects"
      
      		  ' Load enum types for this parameter table 
      		  call mobjTRReader.LoadEnums("US")
      			call WriteRunTimeError("Tabular Ruleset Reader" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_LOAD_ENUMTYPES"), false)
      
            writeTimedMessage "Loaded Enums"
      			
			On Error Goto 0

      '//Retrieve text constants we use over and over just once
      dim mTextForNullValue
      mTextForNullValue = FrameWork.GetDictionary("TEXT_MPTE_DIFF_DISPLAY_NULLVALUE")
      dim mTextDeleted
      mTextDeleted = FrameWork.GetDictionary("TEXT_MPTE_DIFF_DISPLAY_DELETED")
      dim mTextUpdated
      mTextUpdated = FrameWork.GetDictionary("TEXT_MPTE_DIFF_DISPLAY_UPDATED")
      dim mTextAdded
      mTextAdded = FrameWork.GetDictionary("TEXT_MPTE_DIFF_DISPLAY_ADDED")
      dim mTextNoChange
      mTextNoChange = FrameWork.GetDictionary("TEXT_MPTE_DIFF_DISPLAY_NOCHANGE")
      
      dim sImageHTML, sCaption
      sImageHTML = "<img src='" &  mdm_GetIconUrlForParameterTable(Cstr(objParamTableDef.Name)) & "' border='0'>"
      if bViewChangeFromApproval then
        sCaption =  mobjTRReader.Caption & "&nbsp;" & FrameWork.GetDictionary("TEXT_APPROVALS_RATE_SCHEDULE_RULES_WERE_UPDATED")  '/" rating rules were updated"
      else
        sCaption = mobjTRReader.Caption 
      end if 

      writePageStart sImageHTML & "&nbsp;" & sCaption
           
      response.write("<div class='clsStandardText' style='padding-left:20px;vertical-align:middle;'>" & sPageTitle & "</div><BR>")
      
      writeTimedMessage "Ruleset START"


      if bViewChangeFromApproval then
        '//Load the ruleset from the proposed change
        dim objTempRuleSet
        set objTempRuleSet = objMTRateSched.RuleSet
  
        dim objTempConfig
        dim objTempConfigPropSet
        set objTempConfig = CreateObject("MetraTech.MTConfig.1")
  
        'on error resume next
        set objTempConfigPropSet = objTempConfig.ReadConfigurationFromString(sRulesetBuffer, false)
  
        if err then
          sErrorMessage = "Unable to read configuration from input. Error returned is:<BR>[" & Hex(err.number) & "] " & err.description
        else
          objTempRuleSet.ReadFromSet objTempConfigPropSet
          if err then
            sErrorMessage = "Unable to create ruleset from propset object. Error returned is:<BR>[" & Hex(err.number) & "] " & err.description
          else
            '//Success
            Set mobjRuleset1=objTempRuleSet
          end if
        end if

        '//Load the ruleset to compare against, either the current one or the one when the change was submitted
        if bApprovalChangeIsPending then
         Set mobjRuleset2 = objMTRateSched.GetDatedRuleSet(Null)
        else
         Set mobjRuleset2 = objMTRateSched.GetDatedRuleSet(dtApprovalChangeSubmittedDate)
        end if
 
         '//Write extra information describing the ruleset
         dim sRateScheduleDescription
         sRateScheduleDescription = GetEffectiveDateTextByType(objMTRateSched.EffectiveDate.StartDateType, objMTRateSched.EffectiveDate.StartDate, objMTRateSched.EffectiveDate.StartOffset, true)
         sRateScheduleDescription = sRateScheduleDescription & " - " & GetEffectiveDateTextByType(objMTRateSched.EffectiveDate.EndDateType, objMTRateSched.EffectiveDate.EndDate, objMTRateSched.EffectiveDate.EndOffset, false)

        set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
        rowset.Init "queries\audit"
        rowset.SetQueryTag("__SELECT_RATE_SCHEDULE_DISPLAY_INFORMATION__")
        rowset.AddParam "%%RS_ID%%", objMTRateSched.Id
        rowset.AddParam "%%TX_LANG_CODE%%", GetFrameworkAppLanguageFromPageLanguage(Session("FRAMEWORK_APP_LANGUAGE"))
        rowset.Execute
        
        if len(rowset.value("PriceListName"))>0 then
          sPriceListName = rowset.value("PriceListName")
        else
          '//If the pricelist name is blank, we infer it must be an ICB pricelist
          sPriceListName = FrameWork.GetDictionary("TEXT_ICB_PRICELIST_DISPLAY_NAME")

          '//Retrieve subscription information for display
          rowset.SetQueryTag("__GET_SUBSCRIPTION_INFORMATION_FOR_RATE_SCHEDULE__")
          rowset.AddParam "%%RS_ID%%", objMTRateSched.Id
          rowset.Execute

          dim sSubscriptionInformation
          if IsNull(rowset.value("IndividualSubscriptionName")) then
            sSubscriptionInformation = rowset.value("GroupSubscriptionName") & "&nbsp;-&nbsp;" & rowset.value("GroupSubscriptionCorporateAccountName") & "&nbsp;(" & rowset.value("GroupSubscriptionCorporateAccountId") & ")"
          else
            sSubscriptionInformation = rowset.value("IndividualSubscriptionName")  & "&nbsp;(" & rowset.value("IndividualSubscriptionAccountId") & ")"
          end if

          sSubscriptionInformation = sSubscriptionInformation & "<br><b>Product Offering:&nbsp;</b>" & rowset.value("ProductOfferingDisplayName")
          sSubscriptionInformation = sSubscriptionInformation & "<br><b>Priceable Item:&nbsp;</b>" & rowset.value("PriceableItemName")
          sPriceListName = sPriceListName & ":&nbsp;" & sSubscriptionInformation

        end if

        '//Write out the information with more detail as to what was modified
        response.write("<div style='font-size:11px;'>")
        response.write("<b>Pricelist:&nbsp;</b>" & sPriceListName &  "<br><b>Parameter Table:&nbsp;</b> " & mobjTRReader.Caption & "&nbsp;(" & objParamTableDef.Name & ")<br><b>Rate Schedule:&nbsp;</b>" & objMTRateSched.Description & "&nbsp;&nbsp;<b>Effective:&nbsp;</b>" & sRateScheduleDescription & "<br/>")
        response.write("<br></div>")

      else
        '//Load the two rulsets to be compared
		    Set mobjRuleset1 = objMTRateSched.GetDatedRuleSet(CDate(dtRuleSet1)) ' get the ruleset from the RateSchedule.
        writeTimedMessage "Loaded Ruleset 1"
		    Set mobjRuleset2 = objMTRateSched.GetDatedRuleSet(CDate(dtRuleSet2)) ' get the ruleset from the RateSchedule.
        writeTimedMessage "Loaded Ruleset 2"
        'mobjRuleset1.write "c:\ruleset.xml"
      end if

      
      '//Write out our page
        response.write("<div align='center'>")
        writeNoChangeMessage
        
        writeParamTableHeaders mobjTRReader
        writeRulesetDiffSpan mobjRuleset2, mobjRuleset1
        
        if not bViewChangeFromApproval then
          writePageEnd
        end if
      
      '//For debugging purposes, write out the xml versions of the rulesets      
      if mDebug then
        response.write("<b>Displaying XML versions:<BR>Ruleset 1 has " & mobjRuleset1.count & " rows and Ruleset 2 has " & mobjRuleset2.count & " rows<BR></b>")
        writeXML
      end if
      

      
'// writeNoChangeMessage
'// Displays the 'No Differences Found' message which is always written and then hidden or displayed as needed
sub writeNoChangeMessage
    response.write"<div id='NoChangesDetectedMessage' style='display: none;'><span style='background-color:#efefef;width:350px;border:solid #848284 1px;padding:5px;text-align: center; white-space:nowrap; '>"
    response.write"<table><tr><td valign=top><img align='absmiddle' src='/MCM/default/localized/en-us/images/icons/infosmall.gif' alt='' width='16' height='16' border='0'>"
    response.write"</td><td>" & FrameWork.GetDictionary("TEXT_MPTE_DIFF_DISPLAY_NOCHANGE_MESSAGE")
    response.write"</td></tr></table></span><BR><BR></div>"
end sub
sub showNoChangeMessage
  response.write"<script>document.all('NoChangesDetectedMessage').style.display = '';</script>"
end sub


'// writeRulesetDiffSpan
'// This is the heart of the diff display. Given two rulesets it determines the differences and writes out each line
sub writeRulesetDiffSpan(objPreviousRuleset,objNewerRuleset)

  dim objDiffGenerator
  dim objDiff

  writeTimedMessage "Ruleset Diff START"  
  set objDiffGenerator = Server.CreateObject("MetraTech.UI.DifferenceViewer.RulesetDifferenceGenerator")
  set objDiff = objDiffGenerator.GetDifference((objPreviousRuleset),(objNewerRuleset))
  writeTimedMessage "Ruleset Diff End"  
  
  writeDebugMessage("There are " & objDiff.GetDifferenceSpanCount & " difference spans") & "<BR>"

  
  dim i
  for i=0 to objDiff.GetDifferenceSpanCount-1
        	writeDebugMessage "Span [" & i & "]=========================================================" 
          writeDebugMessage "The status of span " & i & " is [" & objDiff.GetDifferenceSpanStatus(i) & "]" 
          writeDebugMessage "The span has a length of " & objDiff.GetDifferenceSpanLength(i) 
          writeDebugMessage "The source index is " & objDiff.GetDifferenceSpanSourceIndex(i)
          writeDebugMessage "The destination index is " & objDiff.GetDifferenceSpanDestinationIndex(i)
  
  dim j
	select case objDiff.GetDifferenceSpanStatus(i)
	  case "AddDestination":
		writeDebugMessage "The following lines were added:"

		for j=0 to objDiff.GetDifferenceSpanLength(i)-1
			set rule = objDiff.GetDestinationItem(objDiff.GetDifferenceSpanDestinationIndex(i)+j)
	    writeRulesetRule rule,nothing,mobjTRReader,"AddDestination"
		next
    
	  case "NoChange":
		writeDebugMessage "The following lines were not changed:"

		for j=0 to objDiff.GetDifferenceSpanLength(i)-1
			set rule = objDiff.GetDestinationItem(objDiff.GetDifferenceSpanDestinationIndex(i)+j)
	    writeRulesetRule rule,nothing,mobjTRReader,"NoChange"
		next
    
	  case "Replace":
		writeDebugMessage "The following lines were changed:"

		for j=0 to objDiff.GetDifferenceSpanLength(i)-1
			set rule = objDiff.GetDestinationItem(objDiff.GetDifferenceSpanDestinationIndex(i)+j)
			set srcRule = objDiff.GetSourceItem(objDiff.GetDifferenceSpanSourceIndex(i)+j)
	    writeRulesetRule rule,srcRule,mobjTRReader,"Replace"
		next

	  case "DeleteSource":
		writeDebugMessage "The following lines were deleted:"

		for j=0 to objDiff.GetDifferenceSpanLength(i)-1
			'set rule = objDiff.GetDestinationItem(objDiff.GetDifferenceSpanDestinationIndex(i)+j)
			set srcRule = objDiff.GetSourceItem(objDiff.GetDifferenceSpanSourceIndex(i)+j)
	    writeRulesetRule srcRule,srcRule,mobjTRReader,"DeleteSource"
		next
    
  end select

  next	

  writeTimedMessage "Write Rules END"  

  '//Now write default rule diff
  dim sDefaultRuleDifference
  sDefaultRuleDifference = writeRulesetDefaultRuleDiff(objPreviousRuleset, objNewerRuleset, mobjTRReader)

  writeTimedMessage "Write Default Rule END"  

  if (sDefaultRuleDifference = "NoChange" or sDefaultRuleDifference= "NoDefaultRuleNoChange") and objDiff.GetDifferenceSpanCount<=1 then
    if objDiff.GetDifferenceSpanCount=1 then
      if objDiff.GetDifferenceSpanStatus(0)="NoChange" then
        'response.write "No modifications were found<BR>"
        showNoChangeMessage
      end if
    else
      showNoChangeMessage
    end if
  end if
    
  writeDebugMessage("DONE writeRulesetDiffSpan")
  
end sub


'// writeRulesetDefaultRuleDiff
'// Routine to determine differences between the default rule and display them
function writeRulesetDefaultRuleDiff(objPreviousRuleset, objNewerRuleset, mobjTRReader)

    dim sInfoStyle
    dim sInfoText
    
    dim sDifference
    sDifference = "Replace"
    
    if objNewerRuleset.DefaultActions is nothing then
      if objPreviousRuleset.DefaultActions is nothing then
        writeRulesetDefaultRuleDiff = "NoDefaultRuleNoChange"
        exit function
      else
        sDifference = "DeleteSource"
      end if
    else
      if objPreviousRuleset.DefaultActions is nothing then
        sDifference = "AddDestination"
      else
        if getDifferenceBetweenActions(objNewerRuleset.DefaultActions,objPreviousRuleset.DefaultActions) then
          sDifference = "Replace"
        else
          sDifference = "NoChange"
        end if
      end if
    end if

    writeRulesetDefaultRuleDiff = sDifference
    
    strClassName = "RuleEditorTableCell"

    setDiffStylesAndMessage sDifference, sInfoStyle, sInfotext, strClassName    

    dim objRSActionSet 
    set objRSActionSet = objNewerRuleset.DefaultActions
         
    response.write("<TR>" & vbNewLine)
    response.write("<TD " & sInfoStyle & " >" & sInfoText & "</TD>")

    ' write the condition section for default rule
    if mobjTRReader.ConditionDatas.count > 0 then
  		if not objRSActionSet is nothing then
        response.write("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & "if" & "</TD>" & vbNewLine) 
  		else
  			response.write("<TD class=""" & strClassName & "Special"">&nbsp;</TD>")
  		end if
      
      response.write("    <TD COLSPAN=""" & mobjTRReader.ConditionDatas.count & """ NOWRAP ALIGN=""center"" class=""" & strClassName & """>")

      response.write(FrameWork.GetDictionary("TEXT_MPTE_DEFAULTRULE"))
      
      response.write("</TD>")
    end if  
          
        
    ' write the actions for the default rule
    if mobjTRReader.ActionDatas.count > 0 then
        if mobjTRReader.ConditionDatas.Count > 0 then       ' If we only have a single action row, no conditions, we don't need to display this
            response.write("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & "then" & "</TD>" & vbNewLine)
        end if
        
        'AddDebugMessage "Starting to loop through the actions"
        
        '-----------------------------------------------------------------------
        ' We don't have any guarantee that the actions in the ruleset match the order
        ' of the actions diplayed.  So, for each action column, we have to
        ' loop through all the actions in the rule and try to find a match    
        '----------------------------------------------------------------------- 
        for each objActionData in mobjTRReader.ActionDatas        
            'AddDebugMessage "looking for action: <B>" & objActionData.DisplayName & "</B>"
            
            ' test to see if this condition is just a label
            if ucase(objActionData.ColumnType) = "LABEL" then
                'AddDebugMessage "It is a label, so just output that"
                response.write("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>")
                response.write(objActionData.DisplayName)          
                
            else ' not a label, so find if we have an action in the file for it
                response.write("    <TD NOWRAP ALIGN=""" & AlignString(objActionData.PType) & """ class=""" & strClassName & """>")
                'response.write("    <TD NOWRAP ALIGN=""" & "right" & """ class=""" & strClassName & """>")
                'AddDebugMessage "looking for the matching ruleset action"

                boolmatched = false ' Flag to test whether rule was matched or not
                
                if not objRSActionSet is nothing then
                for each objRSAction in objRSActionSet
                    
                    'AddDebugMessage "ruleset action: " & objRSAction.PropertyName
                    
                    if ucase(objRSAction.PropertyName) = ucase(objActionData.PropertyName) then
                        'AddDebugMessage "matched condition"      
                        'AddDebugMessage "action ptype: " & objActionData.PType
                        'AddDebugMessage "action value: " & objRSAction.PropertyValue
                        
                        if sInfoText = "Modified" then
                          previousValue = getActionValueFromRulePreviousVersion(objPreviousRuleset.DefaultActions,objActionData.PropertyName)
                        else
                          previousValue = cstr(objRSAction.PropertyValue)
                        end if
                        
										    boolmatched = true
                        
                        if previousValue<>cstr(objRSAction.PropertyValue) then
                          writeChangedValue FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName), FormatString(objActionData.PType, previousValue, objRSAction.PropertyName)
                          'response.write("<strong><font size='8px' color='red'>Changed From " & FormatString(objActionData.PType, previousValue, objRSAction.PropertyName) & " to </font><BR>" & FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName) & "</strong>")
                        else
										
                        if CLng(objActionData.PTYPE) = PROP_TYPE_ENUM then
                            set arrstrValues = objActionData.EnumValues
                            set arrstrText = objActionData.EnumStrings
                            
                            j = 1
                            for each strTemp in arrstrValues
                                if strTemp = objRSAction.PropertyValue then
                                    response.write(arrstrText(j))
                                    exit for
                                end if
                                j = j + 1
                            next
                            
                            if j > arrstrValues.count then
                                response.write(ConvertValueToEnumerator(objActionData.EnumSpace, objActionData.EnumType, objRSAction.PropertyValue))
                                'response.write(objRSAction.PropertyValue)
                            end if
                            
                        else
                            response.write(FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName))
                            'response.write(objRSAction.PropertyValue)
                        end if
                        end if
                       
                        exit for
                    end if
                next
						else
              '//Current default rule doesn't exist (was deleted) so just write the previous value
              response.write getActionValueFromRulePreviousVersion(objPreviousRuleset.DefaultActions,objActionData.PropertyName)
            end if
                
						if not boolmatched then ' If the ruleset doesn't have this property, we will add a blank space to it
							response.write(FormatString(PROP_TYPE_STRING, "", objActionData.PropertyName))
							'response.write(objActionData.PropertyName)
						end if
						
            end if ' end test of the column type    
            
            response.write("&nbsp;</TD>" & vbNewLine)
            
        next ' loop on ActionData
  
    end if ' end test on whether there are any actions to display
    
end function

'//writeRulesetRule
'//for a given rule and its previous version, writes out the rule, properly formatted
sub writeRulesetRule(objRule,objRulePreviousVersion,mobjTRReader,sDifference)

    Set objRSConditionSet = objRule.Conditions
    Set objRSActionSet = objRule.Actions

    ' do the row coloring
    bolOdd = not bolOdd
    if bolOdd then
        strClassName = "RuleEditorTableCell"
    else
        strClassName = "RuleEditorTableCellAlt"
    end if
    
    setDiffStylesAndMessage sDifference, sInfoStyle, sInfotext, strClassName    
        
        response.write("<TR>" & vbNewLine)
        response.write("<TD " & sInfoStyle & " >" & sInfoText & "</TD>")
    
        ' write the conditions
        if mobjTRReader.ConditionDatas.count > 0 then
            response.write("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & "if" & "</TD>" & vbNewLine) 
            
            '-----------------------------------------------------------------------
            ' We don't have any guarantee that the conditions in the ruleset match the order
            ' of the conditions diplayed.  So, for each condition column, we have to
            ' loop through all the conditions in the rule and try to find a match
            '-----------------------------------------------------------------------
            'AddDebugMessage "Starting to loop through the conditions"
            
            for each objConditionData in mobjTRReader.ConditionDatas
                'AddDebugMessage "looking for condition: <B>" & objConditionData.DisplayName & "</B> - Column Type = " & objConditionData.ColumnType          
                
                ' test to see if this condition is just a label
                if ucase(objConditionData.ColumnType) = "LABEL" then
                    response.write("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>")
                    response.write(objConditionData.DisplayName)
                    
                else ' not a label, so find if we have a condition in the file for it
                    'response.write("    <TD NOWRAP ALIGN=""" & AlignString(objConditionData.PType) & """ class=""" & strClassName & """>")
                    response.write("    <TD NOWRAP ALIGN=""" & objConditionData.PType & """ class=""" & strClassName & """>")
                    ' if we are to display the operator, put it here now
            
                    'AddDebugMessage "looking for the matching ruleset condition"
                    for each objRSCondition in objRSConditionSet
                        'AddDebugMessage "ruleset condition: " & objRSCondition.PropertyName
                        
                        '----------------------------------------------------------------------- 
                        ' We need to suppport having multiple conditions with the same name.
                        ' However, the name and operator pair must be unique if the operator is
                        ' specified.  If the operator is unspecified, we can only match on the name
                        '-----------------------------------------------------------------------
                           
                        if ((objConditionData.EditOperator) and (ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName))) or _
                           ((ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName))  ) then ' and (Clng(objConditionData.Operator) = TestToOperatorType(objRSCondition.Test))) then
                            'AddDebugMessage "matched condition"
                            
                            'dim previousValue
                            if sDifference = "Replace" then
                              previousValue = getConditionValueFromRulePreviousVersion(objRulePreviousVersion,objConditionData.PropertyName, objRSCondition.Test, previousTestValue)
                            else
                              previousTestValue = objRSCondition.Test
                              previousValue = objRSCondition.Value
                            end if
                            
                            dim bConditionChanged
                            if ucase(objConditionData.DisplayOperator) = "ROW" or objConditionData.EditOperator then
                                'response.write(TestToSymbolHTML(objRSCondition.Test) & "&nbsp;")
                                if previousTestValue<>objRSCondition.Test then
                                  bConditionChanged = true
                                  writeChangedValue  TestToSymbolHTML(objRSCondition.Test), TestToSymbolHTML(previousTestValue)
                                  'response.write("<strong><font size='1' color='red'>Changed From " & TestToSymbolHTML(previousTestValue) & "&nbsp;" & " to </font><BR>" & TestToSymbolHTML(objRSCondition.Test) & "</strong>&nbsp;")
                                else
                                  bConditionChanged = false
                                  response.write(TestToSymbolHTML(objRSCondition.Test) & "&nbsp;")
                                end if
                            end if
                            
                            if Cstr(previousValue)<>cstr(objRSCondition.Value) then
                              if bConditionChanged then
                                response.write("<strong><font size='1' color='red'>,</font></strong>")
                              end if
                              
                              writeChangedValue objRSCondition.Value, previousValue
                              'response.write("<strong><font size='1' color='red'>&nbsp;Changed From " & previousValue & " to </font><BR>" & objRSCondition.Value & "</strong>")
                            else
                            
                            'AddDebugMessage "condition ptype: " & objConditionData.PType
                            'AddDebugMessage "condition value: " & objRSCondition.Value
                            
                            if CLng(objConditionData.PTYPE) = PROP_TYPE_ENUM then
                                set arrstrValues = objConditionData.EnumValues
                                set arrstrText = objConditionData.EnumStrings
                                
                                j = 1
                                'AddDebugMessage "EnumType - looking for : " & objRSCondition.Value
                                
                                for each strTemp in arrstrValues
                                    'AddDebugMessage "Looking to match: " & strTemp
                                    if strTemp = objRSCondition.Value then
                                        response.write(arrstrText(j))
                                        exit for
                                    end if
                                    j = j + 1
                                next
                                
                                if j > arrstrValues.count then
                                    'response.write(ConvertValueToEnumerator(objConditionData.EnumSpace, objConditionData.EnumType, objRSCondition.Value))
                                    response.write( objRSCondition.Value)
                                end if
                            else
                                'response.write(FormatString(objConditionData.PType, objRSCondition.Value, objRSCondition.PropertyName))
                                response.write(objRSCondition.Value)
                                'response.write(objRSCondition.Value & "[" & previousValue & "]")
                            end if
                            end if
                            
                            exit for
                        else ' If condition did not match
												end if ' End of test to see if name and operator matched
                    next
                    
                end if ' end test of the column type    
                
                response.write("&nbsp;</TD>" & vbNewLine)
                
            next ' loop on ConditionData
            
        end if ' end test on whether there are any conditions to display


        ' write the actions
        if mobjTRReader.ActionDatas.count > 0 then
            if mobjTRReader.ConditionDatas.Count > 0 then       ' If we only have a single action row, no conditions, we don't need to display this
                response.write("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & "then" & "</TD>" & vbNewLine)
            end if
            
            'AddDebugMessage "Starting to loop through the actions"
            
            '-----------------------------------------------------------------------
            ' We don't have any guarantee that the actions in the ruleset match the order
            ' of the actions diplayed.  So, for each action column, we have to
            ' loop through all the actions in the rule and try to find a match    
            '----------------------------------------------------------------------- 
            for each objActionData in mobjTRReader.ActionDatas        
                'AddDebugMessage "looking for action: <B>" & objActionData.DisplayName & "</B>"
                
                ' test to see if this condition is just a label
                if ucase(objActionData.ColumnType) = "LABEL" then
                    'AddDebugMessage "It is a label, so just output that"
                    response.write("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>")
                    response.write(objActionData.DisplayName)          
                    
                else ' not a label, so find if we have an action in the file for it
                    response.write("    <TD NOWRAP ALIGN=""" & AlignString(objActionData.PType) & """ class=""" & strClassName & """>")
                    'response.write("    <TD NOWRAP ALIGN=""" & "right" & """ class=""" & strClassName & """>")
                    'AddDebugMessage "looking for the matching ruleset action"

                    boolmatched = false ' Flag to test whether rule was matched or not
                    for each objRSAction in objRSActionSet
                        
                        'AddDebugMessage "ruleset action: " & objRSAction.PropertyName
                        
                        if ucase(objRSAction.PropertyName) = ucase(objActionData.PropertyName) then
                            'AddDebugMessage "matched condition"      
                            'AddDebugMessage "action ptype: " & objActionData.PType
                            'AddDebugMessage "action value: " & objRSAction.PropertyValue
                            
                            if sDifference = "Replace" then
                              previousValue = getActionValueFromRulePreviousVersion(objRulePreviousVersion.Actions,objActionData.PropertyName)
                            else
                              previousValue = cstr(objRSAction.PropertyValue)
                            end if
                            
                            'response.write("typename " & typename(previousValue) & "  type " & typename(objRSAction.PropertyValue))
                            'response.end
                            
                            
														boolmatched = true
                            
                            if previousValue<>cstr(objRSAction.PropertyValue) then
                              writeChangedValue FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName), FormatString(objActionData.PType, previousValue, objRSAction.PropertyName)
                              'response.write("<font color='red' style='font-size:10px'>Changed From <strong>" & FormatString(objActionData.PType, previousValue, objRSAction.PropertyName) & "</strong> to </font><BR>" & FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName) & "")
                            else
														
                            if CLng(objActionData.PTYPE) = PROP_TYPE_ENUM then
                                set arrstrValues = objActionData.EnumValues
                                set arrstrText = objActionData.EnumStrings
                                
                                j = 1
                                for each strTemp in arrstrValues
                                    if strTemp = objRSAction.PropertyValue then
                                        response.write(arrstrText(j))
                                        exit for
                                    end if
                                    j = j + 1
                                next
                                
                                if j > arrstrValues.count then
                                    response.write(ConvertValueToEnumerator(objActionData.EnumSpace, objActionData.EnumType, objRSAction.PropertyValue))
                                    'response.write(objRSAction.PropertyValue)
                                end if
                                
                            else
                                response.write(FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName))
                                'response.write(objRSAction.PropertyValue)
                            end if
                            end if
                           
                            exit for
                        end if
                    next
										
										if not boolmatched then ' If the ruleset doesn't have this property, we will add a blank space to it
											response.write(FormatString(PROP_TYPE_STRING, "", objActionData.PropertyName))
											'response.write(objActionData.PropertyName)
										end if
										
                end if ' end test of the column type    
                
                response.write("&nbsp;</TD>" & vbNewLine)
                
            next ' loop on ActionData
      
        end if ' end test on whether there are any actions to display
        
        response.write("</TR>" & vbNewLine)
end sub      

'//writeParamTableHeaders
'//Routine to write out the param table headers using the meta data object
sub writeParamTableHeaders(mobjTRReader)
  dim strTableHeader ' as a Stylesheet Class
  
  strTableHeader = "RuleEditorTableHeader"
	response.write "<table width='100%' border='0' cellspacing='1' cellpadding='2' bgcolor='#999999'>"
  response.write "<tr>" 
  ' write the conditions header - add extra column for "if"
  if mobjTRReader.ConditionDatas.count > 0 then
    response.write(" <TD class="& strTableHeader &" COLSPAN=""" & _
                        mobjTRReader.ConditionDatas.count + 2 & _
                        """>" & mobjTRReader.ConditionsHeader & "</TD>" & vbNewLine)
  end if

  ' write the actions header - add extra column for "then"
  if mobjTRReader.ActionDatas.count > 0 then
    response.write("    <TD class="& strTableHeader &" COLSPAN=""" & _
                        mobjTRReader.ActionDatas.count + 1 & _
                        """>" & mobjTRReader.ActionsHeader & "</TD>" & vbNewLine)
  end if
  
  response.write "<tr>"
  response.write "    <TD WIDTH=""10"" class=" & strTableHeader & ">&nbsp;</TD>" & vbNewLine

  ' write all the conditions - add extra column for "if"
  if mobjTRReader.ConditionDatas.count > 0 then
    response.write("    <TD WIDTH=""5"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)

		' We will use this variable to check whether all conditions are optional. This is needed so we know whether to allow a default rule or not
    mbolAllConditionsOpt = true
		
		for each objCondition in mobjTRReader.ConditionDatas

			if objCondition.Required then
				mbolAllConditionsOpt = false
			end if

      response.write("    <TD class="& strTableHeader &">")
  
      ' Handle the case of a label first - check to see if it should be displayed
      if ucase(objCondition.ColumnType) = "LABEL" then
        response.write("&nbsp;")      
      else 
        ' it is not a label - so display the name of the property
        response.write(objCondition.DisplayName)
        
        ' Now handle the case of displaying the operator
        if ucase(objCondition.DisplayOperator) = "COLUMN" and not objCondition.EditOperator then
        	response.write("&nbsp;(" & OperatorTranslate(objCondition.Operator) & ")")
        end if
         
      end if
      response.write("</TD>" & vbNewLine)
    next
  end if

  ' write all the actions - add extra column for "then"
  if mobjTRReader.ActionDatas.count > 0 then
  	if mobjTRReader.ConditionDatas.Count > 0 then   ' If we only have a single action row, no conditions, we don't need to display this
      response.write("    <TD WIDTH=""5"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)
    end if
    for each objAction in mobjTRReader.ActionDatas
      response.write("    <TD class="& strTableHeader &">")
    
      ' Handle the case of a label first - check to see if it should be displayed
      if ucase(objAction.ColumnType) = "LABEL" then
        response.write("&nbsp;")
      else 
        response.write(objAction.DisplayName)
      end if
      
      response.write("</TD>" & vbNewLine)
    next
  end if
  
end sub

'//getDifferenceBetweenActions
'//routine compares actions from a rule and returns a boolean indicating if they are identical or not
function getDifferenceBetweenActions(objRuleNewerVersionActions,objRulePreviousVersionActions)
  getDifferenceBetweenActions = false
  
  dim objRSAction, objPreviousVersionRSAction
  for each objRSAction in objRuleNewerVersionActions
    if Cstr(objRSAction.PropertyValue)<>getActionValueFromRulePreviousVersion(objRulePreviousVersionActions,objRSAction.PropertyName) then
      'response.write(objRSAction.PropertyName & " value " & objRSAction.PropertyValue & " does not equal " & getActionValueFromRulePreviousVersion(objRulePreviousVersionActions,objRSAction.PropertyName) & "<BR>")
      getDifferenceBetweenActions = true
      exit for
    end if
  next
  
  'response.write("getDifferenceBetweenActions [" & getDifferenceBetweenActions & "]<BR>")
  'response.end
end function

'//getActionValueFromRulePreviousVersion
'//Slightly ugly routine to iterate over the Actions of the previous version to find the correct action and return its value.
'//Caused by the collection nature of our ruleset storage without being able to index actions directly by propertyname
function getActionValueFromRulePreviousVersion(objRulePreviousVersionActions,sPropertyName)
  getActionValueFromRulePreviousVersion = mTextForNullValue
  
  if not objRulePreviousVersionActions is nothing then  
    Set objTempRSActionSet = objRulePreviousVersionActions
    for each objTempRSAction in objTempRSActionSet
      'response.write("checking " & objTempRSAction.PropertyName & " against " & sPropertyName)
      if ucase(objTempRSAction.PropertyName) = ucase(sPropertyName) then
        getActionValueFromRulePreviousVersion = cStr(objTempRSAction.PropertyValue)
        'response.write " matched value is " & getActionValueFromRulePreviousVersion & "<BR>"
        exit for
      else
        'response.write " Didn't match<BR>"
      end if
    next
  else
    'response.write("objRulePreviousVersionActions is NOTHING<BR>")
  end if
end function

'//getConditionValueFromRulePreviousVersion
'//Slightly ugly routine to iterate over the Conditions of the previous version to find the correct condition and return its value
'//and the operator/test value.
'//Caused by the collection nature of our ruleset storage without being able to index actions directly by propertyname
function getConditionValueFromRulePreviousVersion(objRulePreviousVersion,sPropertyName,sPropertyTest,sPreviousTestValue)
    getConditionValueFromRulePreviousVersion = mTextForNullValue
    sPreviousTestValue = mTextForNullValue
    
    Set objTempRSConditionSet = objRulePreviousVersion.Conditions
    'Set objTempRSActionSet = objRulePreviousVersion.Actions

    for each objTempRSCondition in objTempRSConditionSet
      if ucase(objTempRSCondition.PropertyName) = ucase(sPropertyName) then
        getConditionValueFromRulePreviousVersion = cStr(objTempRSCondition.Value)
        sPreviousTestValue= objTempRSCondition.Test
        exit for
      end if
    next
end function

'//writeXML
'//Debugging routine to display text boxes with the XML dump of both rowsets
sub writeXML      
      dim objConfigPropSet
      dim sBuffer1,sBuffer2
      if IsObject(mobjRuleset1) then
        'response.write("We HAVE the rule set<BR>")
        set objConfigPropSet = mobjRuleset1.WriteToSet
        if IsObject(objConfigPropSet) then
          'response.write("We HAVE the config prop set<BR>")
          sBuffer1 = objConfigPropSet.WriteToBuffer
         end if
      else
        'response.write("We DO NOT have the the rule set<BR>")
      end if

      if IsObject(mobjRuleset2) then
        'response.write("We HAVE the rule set<BR>")
        set objConfigPropSet = mobjRuleset2.WriteToSet
        if IsObject(objConfigPropSet) then
          'response.write("We HAVE the config prop set<BR>")
          sBuffer2 = objConfigPropSet.WriteToBuffer
         end if
      else
        'response.write("We DO NOT have the the rule set<BR>")
      end if
      
%>
<table>
<tr>
<td>Ruleset 1<BR>
<textarea cols='100' rows='35' name='RulesXML1'><%=sBuffer1%></textarea>
</td>
<td>Ruleset 2<BR>
<textarea cols='100' rows='35' name='RulesXML2'><%=sBuffer2%></textarea>
</td></tr></table>
<%
end sub

'//Routines for writing the start and end of the page
sub writePageStart(sPageTitle)
%>
<TABLE border="0" cellpadding="1" cellspacing="0" width="100%">
<tr><td Class='CaptionBar' nowrap><%=sPageTitle%><font class="clsLargeText"></font></td></tr>
</TABLE>
<br>
<%
end sub

sub writePageEnd()
  response.write "</table></div>"
  response.write "<br><br><br><div align='center'><button Class='clsOKButton' name='CANCEL' onclick='window.close();'>Close</button>"
  response.write "</div><BR><BR>"
  response.write "</FORM></BODY></HTML>"
end sub

'//setDiffStylesAndMessage
'//Get the text to display and the coloring to use based on the status of the line
sub setDiffStylesAndMessage(sDifference,sInfoStyle,sInfotext,strClassName)
        select case sDifference
        case "DeleteSource":
          sInfoStyle = "style='BACKGROUND-COLOR: #E00000;'"
          sInfoText = mTextDeleted
          strClassName=strClassName & "Deleted"
        case "Replace"
          sInfoStyle = "style='BACKGROUND-COLOR: yellow;'"
          sInfoText = mTextUpdated
          strClassName=strClassName & "Modified"
        case "NoChange"
          sInfoStyle = "style='BACKGROUND-COLOR: white;'"
          sInfoText = mTextNoChange
        case "AddDestination"
          sInfoStyle = "style='BACKGROUND-COLOR: green;'"
          sInfoText = mTextAdded
          strClassName=strClassName & "Added"
        end select
end sub

'//writeChangedValue
'//Format the message indicating that a value has changed
sub writeChangedValue(sNewValue, sPreviousValue)
  response.write("<font color='red' style='font-size:10px'>Changed From <strong>" & sPreviousValue & "</strong> to </font><BR><strong>" & sNewValue & "</strong>")
end sub

'//Routines for writing debugging and timing messages to the screen
sub writeTimedMessage(sMessage)
   if mDebug then
    response.write("Timing [" & Now & "]:" & sMessage & "<BR>" & vbNewLine)
   end if
end sub

sub writeDebugMessage(sMessage)
   if mDebug then
     response.write("<TR><TD colspan=5>" & sMessage & "&nbsp;</TD></TR>" & vbNewLine)
   end if
end sub

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetEffectiveDateTextByType
' PARAMETERS		:
' DESCRIPTION 	: 
' RETURNS			  :
PUBLIC FUNCTION GetEffectiveDateTextByType(a_type, dt_date, int_offset, bStart)
  Dim strText
  strText = ""
  
  Select Case Clng(a_type)
  Case PCDATE_TYPE_NULL
    if bStart then
      strText = strText & FrameWork.GetDictionary("TEXT_NULL_START_DATE_TYPE")
    else
  	  strText = strText & FrameWork.GetDictionary("TEXT_NULL_END_DATE_TYPE")
    end if
  Case PCDATE_TYPE_ABSOLUTE
  	strText = strText & FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & " " & dt_date
  Case PCDATE_TYPE_SUBSCRIPTION
  	strText = strText & CStr(int_offset) & " " & FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE")
  Case PCDATE_TYPE_BILLCYCLE
  	strText = strText & FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE") & " " & dt_date
  End Select
  
  GetEffectiveDateTextByType = strText
  
END FUNCTION

PUBLIC FUNCTION GetFrameworkAppLanguageFromPageLanguage(strPageLanguage)
  IF (LCASE(strPageLanguage) = "pt-br" OR LCASE(strPageLanguage) = "es-mx") THEN
    GetFrameworkAppLanguageFromPageLanguage = strPageLanguage
  END IF
  Dim dashIndex 
  dashIndex = INSTR(strPageLanguage,"-")
  IF ( dashIndex > 0)  THEN
    GetFrameworkAppLanguageFromPageLanguage = CSTR(MID(strPageLanguage, dashIndex + 1, LEN(strPageLanguage)))
  ELSE
    GetFrameworkAppLanguageFromPageLanguage = strPageLanguage
  END IF
END FUNCTION

%>

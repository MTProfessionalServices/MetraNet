<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: GroupAdd.asp$
' 
'  Copyright 1998,2000 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
' 
'  Created by: Kevin A. Boucher
' 
'  $Date: 11/19/2002 2:08:15 PM$
'  $Author: Kevin Boucher$
'  $Revision: 33$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

const DISCOUNT_DIST_ONEACCOUNT   = 0
const DISCOUNT_DIST_PROPORTIONAL = 1

const SUPPORT_GROUP_OPS   	= 0
const NOT_SUPPORT_GROUP_OPS = 1


' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
session("UDRC_CANCEL_ROUTETO") = request.serverVariables("URL") & "?" & request.serverVariables("QUERY_STRING")
Form.RouteTo     = mam_GetDictionary("GROUP_MEMBER_ADD_DIALOG") & "?MDMRELOAD=TRUE&Action=AddToNewGSub"
mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim objProductOffering, objMTProductCatalog, objGroupSubscription 

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too
	
  ' Add dialog properties
  mdm_GetDictionary().Add "WARNING_EBCR", false

  Service.Properties.Add "Description",           "STRING",    510, FALSE, ""
  Service.Properties.Add "Name",             			"STRING",    510, TRUE, ""
	Service.Properties.Add "StartDate",        			"TIMESTAMP", 0,   TRUE, Empty
	Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
  Service.Properties.Add "EndDate",          			"TIMESTAMP", 0,   FALSE, Empty
	Service.Properties.Add "GroupOpsOption", 				"INT32",   0, 	FALSE, ""
	
 	Service.Properties.Add "UsageCycleType",        "STRING",  0, 	TRUE, ""
	Service("UsageCycleType").SetPropertyType "ENUM", "metratech.com/BillingCycle", "UsageCycleType"
	
	Service.Properties.Add "DiscountDistType",  		"INT32",   0, 	FALSE, ""
	Service.Properties.Add "DiscountAccount", 			"STRING",  255, FALSE, ""
	Service.Properties.Add "DiscountAccountID", 		"INT32",  255, FALSE, ""

	'Properties for Usage Cycle templates		
	Service.Properties.Add "dayofmonth",						"INT32",	0, FALSE, ""
	'Service.Properties.Add "dayofweek",							"INT32",	0, FALSE, ""
	Service.Properties.Add "dayofweek",							"STRING",	255, FALSE, ""
	Service.Properties.Add "firstdayofmonth",				"INT32",	0, FALSE, ""
	Service.Properties.Add "seconddayofmonth",			"INT32",	0, FALSE, ""
	Service.Properties.Add "BiWeeklyLabelInfo", 		"STRING", 255, FALSE, Empty
	
	' Start Month is special. We want to load the enum type from Global so it knows we want it to be an enum type,
	' but then we want to clear the values and load the actuall months from another object later.
	Service.Properties.Add "startmonth",						"STRING",	0, FALSE, ""
 	Service("startmonth").SetPropertyType "ENUM", "Global", "MonthOfTheYear"
	Service("startmonth").EnumType.Entries.Clear
	
	Service.Properties.Add "startday",							"INT32",	0, FALSE, ""
	Service.Properties.Add "startyear",							"INT32",	0, FALSE, ""
	
	Service.Properties.Add "ProductOfferingID",			"INT32", 0, FALSE, ""
	Service.Properties.Add "ProductOffering",				"STRING", 255, FALSE, ""
	Service.Properties.Add "CorpAccountID",					"INT32", 0, FALSE, ""
 	Service.Properties.Add "CorpAccount",           "STRING", 255,  TRUE, ""
	Service.Properties.Add "CopyCycleFromTemplate", "INT32", 0,  TRUE, ""
 
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
	
	mam_Account_SetBiWeeklyLabelInfo ' Init the field 
	mam_Account_SetGoodEnumTypeValueToUsageCycleType ' Re populate the enum type according the definition BillngCycle.xml

	' This is the selected product offering. If we are editing properties, this is blank
	if Len(Request.QueryString("IDS")) > 0 then
		Service.Properties("ProductOfferingID").Value = Request.QueryString("IDS")
	end if

	if Len(Request.QueryString("CorpAccID")) > 0 then
		Service.Properties("CorpAccountID").Value = Request.QueryString("CorpAccID")
	end if

	if Len(Request.QueryString("Action")) > 0 then
		Session("ACTION")					= Request.QueryString("ACTION")
	End If
		
	if Len(Request.QueryString("ID")) > 0 Then	
		Session("EDIT_ID")				= Request.QueryString("ID")	
	End If
	
	' Localize captions
  Service.Properties("Description").Caption            = mam_GetDictionary("TEXT_DESCRIPTION")
  Service.Properties("Name").Caption 									 = mam_GetDictionary("TEXT_NAME")
	
	'----- POPULATE THE DIALOG ------'
	Set objMTProductCatalog = GetProductCatalogObject
	
	'---- Now if we are editing this Group Subscription ------'
	if UCase(Session("ACTION")) = "EDIT" then
		
		Set objGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Session("EDIT_ID")) ' Change to get it by ID whenever possible
		Set Form("objPO") = objMTProductCatalog.GetProductOffering(objGroupSubscription.ProductOfferingID)
		
		Service.Properties("Description").value = objGroupSubscription.Description 						'1
		Service.Properties("Name").value = objGroupSubscription.Name													'2

                if objGroupSubscription.WarnOnEBCRStartDateChange then 
                  mdm_GetDictionary().Add "WARNING_EBCR", true
                else
                  mdm_GetDictionary().Add "WARNING_EBCR", false
                end if

		Service.Properties("StartDate").value = objGroupSubscription.EffectiveDate.StartDate	'3
		
		Service.Properties("EndDate").value = objGroupSubscription.EffectiveDate.EndDate			'4
		If FrameWork.IsInfinity(Service.Properties("EndDate").Value) Then
			Service.Properties("EndDate").Value = Null
		End If
		
		Service.Properties("CorpAccountID").value = objGroupSubscription.CorporateAccount			'5

		If (objGroupSubscription.SupportGroupOps) Then																				'6
			Service.Properties("GroupOpsOption").Value = SUPPORT_GROUP_OPS
		Else
			Service.Properties("GroupOpsOption").Value = NOT_SUPPORT_GROUP_OPS
		End if
		
		'Discount Distribution Config
		If (objGroupSubscription.ProportionalDistribution) Then
			Service.Properties("DiscountDistType").Value = DISCOUNT_DIST_PROPORTIONAL						'7
		Else
			Service.Properties("DiscountDistType").Value = DISCOUNT_DIST_ONEACCOUNT
			Service.Properties("DiscountAccount").Value = mam_GetFieldIDFromAccountID(objGroupSubscription.DistributionAccount)
		End if

		' Call function to configure Usage Cycle Initially
		ConfigureDialogFromCycle(objGroupSubscription.Cycle)
		
		Service.Properties("ProductOfferingID").value = objGroupSubscription.ProductOfferingID
		Service.Properties("CopyCycleFromTemplate").enabled = false
		Service.Properties("CopyCycleFromTemplate").value = 0
		
		' Configure the behavior of the page for EDIT MODE
		mdm_GetDictionary.Add "GSUB_EDIT_MODE", true
		
		' In edit mode, all we have is a cycle, we don't know if it was chosen or imported from template - so we don't display the radiobuttons, just the cycle
		mdm_GetDictionary.Add "SHOWCOPYCYCLECHOICES", false
		mdm_GetDictionary.Add "SHOWENFORCECYCLEOPTION", false
	
		call DisableForEditMode(true, true)
		
		Form.RouteTo = mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG")
		
	Else

		Set Form("objPO") = objMTProductCatalog.GetProductOffering(Service.Properties("ProductOfferingID").value)
    
		' Configure the behavior of the page for NEW MODE

		' By default, we want to show the "import from template" and "other" choices
		mdm_GetDictionary.Add "SHOWCOPYCYCLECHOICES", true
		mdm_GetDictionary.Add "SHOWENFORCECYCLEOPTION", false

		If Form("objPO").GetConstrainedCycleType > 0 then
			Service.Properties("CopyCycleFromTemplate").value = 3
			Service.Properties("CopyCycleFromTemplate").enabled = false
			Service.Properties("UsageCycleType").Value = GetNumberFromEnumSecondaryValue("metratech.com/BillingCycle", "UsageCycleType", Form("objPO").GetConstrainedCycleType)
			Service.Properties("UsageCycleType").enabled = false
						
			' But if we have to enforce a cycle type, show only that option
			mdm_GetDictionary.Add "SHOWCOPYCYCLECHOICES", false
			mdm_GetDictionary.Add "SHOWENFORCECYCLEOPTION", true
		Else
			Service.Properties("CopyCycleFromTemplate").value = 2
			Service.Properties("CopyCycleFromTemplate").enabled = false
		End If

		Dim cyclePickValue
		cyclePickValue = Service.Properties("CopyCycleFromTemplate").value
		If cyclePickValue = Empty or cyclePickValue = 1 then
			Service.Properties("CopyCycleFromTemplate").value = 1
			call DisableForEditMode(true, true)
		Else
			call DisableForEditMode(false, true)
		End If

		Service.Properties("DiscountDistType").Value = DISCOUNT_DIST_PROPORTIONAL
		
		Service.Properties("GroupOpsOption").Value = SUPPORT_GROUP_OPS		
		
		mdm_GetDictionary.Add "GSUB_EDIT_MODE" , false
		Form.RouteTo = mam_GetDictionary("GROUP_MEMBER_ADD_DIALOG") & "?MDMRELOAD=TRUE&Action=AddToNewGSub"
    
	end if
	
	' Figure out wheather to show cycle selection or not
	If not Form("objPO").GroupSubscriptionRequiresCycle and Form("objPO").GetConstrainedCycleType = 0 then
		mdm_GetDictionary.Add "SHOWCYCLECONFIG" , false
		mdm_GetDictionary.Add "SHOWENFORCECYCLEOPTION", false
		mdm_GetDictionary.Add "SHOWCOPYCYCLECHOICES", false
	Else
		mdm_GetDictionary.Add "SHOWCYCLECONFIG" , true
	End If
	
	' Fix select box for billing cycle enum type
	mam_Account_SetBillingCycleEnumType
	
	' Configure Corp Account
	Service.Properties("CorpAccount").value = mam_GetFieldIDFromAccountID(Service.Properties("CorpAccountID").value)
	
	' Configure Discount Account elements to appear according to type allowed
	DiscountDistType_Click(EventArg)

	GroupOpsOption_Click(EventArg)
  	
  ' Include Calendar javascript    
  mam_IncludeCalendar

	Form_Initialize = Form_Refresh(EventArg) 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicTemplate
' PARAMETERS:  EventArg
' DESCRIPTION:  This function determines what should be placed in the dynamic template based on the UDRCs and per-subscription charges found
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicTemplate(EventArg)
  Dim objMTProductCatalog
  Dim objAccount
  Dim objSubscription
  Dim strHTML
  
  Set objMTProductCatalog = GetProductCatalogObject()
    	
  if UCase(Session("ACTION")) = "EDIT" then
'    ' In edit mode display grid of existing UDRCs
  	Set objAccount = objMTProductCatalog.GetAccount(Service.Properties("CorpAccountID").Value)
	  Set objSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Session("EDIT_ID"))
    Form.Grids.Add "UDRCGrid", "UDRCGrid"
    Set Form.Grids("UDRCGrid").Rowset = objSubscription.GetRecurringChargeUnitValuesAsRowset()
    Form.Grids("UDRCGrid").Width = "100%"	
    Form.Grids("UDRCGrid").Properties.ClearSelection
	'  Form.Grids("UDRCGrid").Properties.SelectAll 

    Form.Grids("UDRCGrid").Properties("id_prop").Selected       = 1
    Form.Grids("UDRCGrid").Properties("vt_start").Selected      = 2
	  Form.Grids("UDRCGrid").Properties("vt_end").Selected 	      = 3
    Form.Grids("UDRCGrid").Properties("nm_unit_name").Selected  = 4     
    Form.Grids("UDRCGrid").Properties("n_value").Selected       = 5
'    Form.Grids("UDRCGrid").Properties("nm_charge_account").Selected       = 6    
   
   	Form.Grids("UDRCGrid").Properties("id_prop").Caption 	    = "&nbsp;" 
  	Form.Grids("UDRCGrid").Properties("vt_start").Caption     = mam_GetDictionary("TEXT_START_DATE")
    Form.Grids("UDRCGrid").Properties("vt_end").Caption 	    = mam_GetDictionary("TEXT_END_DATE")
    Form.Grids("UDRCGrid").Properties("nm_unit_name").Caption = "Name"
    Form.Grids("UDRCGrid").Properties("n_value").Caption 	    = "Value"
'   Form.Grids("UDRCGrid").Properties("nm_charge_account").Caption 	    = "Charge Account"    

    If Form.Grids("UDRCGrid").Rowset.RecordCount > 0 Then
      strHTML = strHTML & "<tr><td colspan='2'><MDMGRID name='UDRCGrid'></MDMGRID><br></td></tr>"
    End If
      
    ' Per-subscription rc accounts
    Form.Grids.Add "RCGrid", "RCGrid"
    Set Form.Grids("RCGrid").Rowset = objSubscription.GetRecurringChargeAccounts(mam_GetHierarchyDate())
    Form.Grids("RCGrid").Width = "100%"	
    Form.Grids("RCGrid").Properties.ClearSelection
'	  Form.Grids("RCGrid").Properties.SelectAll 

    Form.Grids("RCGrid").Properties("id_prop").Selected           = 1
    Form.Grids("RCGrid").Properties("nm_display_name").Selected   = 2
    Form.Grids("RCGrid").Properties("vt_start").Selected          = 3
	  Form.Grids("RCGrid").Properties("vt_end").Selected 	          = 4
    Form.Grids("RCGrid").Properties("id_acc").Selected            = 5     
   
   	Form.Grids("RCGrid").Properties("id_prop").Caption 	          = "&nbsp;" 
    Form.Grids("RCGrid").Properties("nm_display_name").Caption    = "Charge Name"    
  	Form.Grids("RCGrid").Properties("vt_start").Caption           = mam_GetDictionary("TEXT_START_DATE")
    Form.Grids("RCGrid").Properties("vt_end").Caption 	          = mam_GetDictionary("TEXT_END_DATE")
    Form.Grids("RCGrid").Properties("id_acc").Caption            = "Charge Account"

    If Form.Grids("RCGrid").Rowset.RecordCount > 0 Then
      strHTML = strHTML & "<tr><td class='clsStandardTitle' colspan='2'><br>Charge Account Configuration<hr size='1'></td></tr>"
      strHTML = strHTML & "<tr><td colspan='2'><MDMGRID name='RCGrid'></MDMGRID><br></td></tr>"
    End If

  Else
    ' Template for unit dependent recurring charges
    'Dim udrcType
    'Set udrcType = objMTProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge")
    Dim po
    Set po = objMTProductCatalog.GetProductOffering(Service.Properties("ProductOfferingID").value)
    
    dim objPriceableItems
    set objPriceableItems = po.GetPriceableItems
    
    'Dim udrcInstances
    'Set udrcInstances = po.GetPriceableItemsOfType(udrcType.ID)
    Dim udrcInstance
    Dim nCount
    nCount = 0
    Dim enums
    
    dim objPI
    for each objPI in objPriceableItems
    'For Each udrcInstance In udrcInstances
      If IsTypeUDRC(objPI.PriceAbleItemType) then
        set udrcInstance = objPi
        Service.Properties.Add "UDRCInstanceId" & nCount, "INT32", 0, TRUE, EMPTY
        Service.Properties("UDRCInstanceId" & nCount).Value = udrcInstance.ID
        Service.Properties.Add "ChargePerParticipant" & nCount, "Boolean", 0, TRUE, EMPTY
        Service.Properties("ChargePerParticipant" & nCount).Value = udrcInstance.ChargePerParticipant

        Set enums = udrcInstance.GetUnitValueEnumerations()
        If enums.Count > 0 Then
           Dim e, objDyn
           Set objDyn = mdm_CreateObject(CVariables)    
           For Each e In enums
             objDyn.Add e, e, , ,e
           Next
           Service.Properties.Add "UDRCValue" & nCount, "STRING", 255, TRUE, EMPTY
           Service.Properties("UDRCValue" & nCount).Caption = udrcInstance.UnitName
           Service.Properties("UDRCValue" & nCount).AddValidListOfValues objDyn
           strHTML = strHTML & "   <tr>"
   		     strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='UDRCValue" & nCount & "' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
           strHTML = strHTML & "     <td class='clsStandardText'><select class='fieldRequired' name='UDRCValue" & nCount & "'></select></td>"
 		     If Not CBool(udrcInstance.ChargePerParticipant) Then
             Service.Properties.Add "UDRCChargeAccount" & nCount, "string", 255, TRUE, ""
             Service.Properties("UDRCChargeAccount" & nCount).Caption = "Charge Account"
     	  	   strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='UDRCChargeAccount" & nCount & "' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
     	       strHTML = strHTML & "     <td class='clsStandardText'><input id='UDRCChargeAccount" & nCount & "' name='UDRCChargeAccount" & nCount & "' type='text' size='20'><a href=""JavaScript:getFrameMetraNet().getSelection('setSelection','UDRCChargeAccount" & nCount & "');"" name='selUDRCChargeAccount" & nCount & "' id='selUDRCChargeAccount" & nCount & "'><img src='/Res/Images/icons/find.png' alt='Select Account' border='0' /></a></td>"       
           End If        
 		     strHTML = strHTML & "   </tr>"
        Else
           If CBool(udrcInstance.IntegerUnitValue) Then
             Service.Properties.Add "UDRCValue" & nCount, "INT32", 0, TRUE, udrcInstance.MinUnitValue
           Else
             Service.Properties.Add "UDRCValue" & nCount, "DECIMAL", 0, TRUE, udrcInstance.MinUnitValue
           End If
           Service.Properties("UDRCValue" & nCount).Caption = udrcInstance.UnitName
      	   strHTML = strHTML & "   <tr>"
     		   strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='UDRCValue" & nCount & "' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
           strHTML = strHTML & "     <td class='clsStandardText'><input class='fieldRequired' size='10' type='text' value='" & Service.Properties("UDRCValue" & nCount) & "' name='UDRCValue" & nCount & "'></td>"
           strHTML = strHTML & "   </tr>"
    		  If Not CBool(udrcInstance.ChargePerParticipant) Then
            Service.Properties.Add "UDRCChargeAccount" & nCount, "string", 255, TRUE, ""
            Service.Properties("UDRCChargeAccount" & nCount).Caption = "Charge Account"
            strHTML = strHTML & "   <tr>"
    	  	  strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='UDRCChargeAccount" & nCount & "' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
  	  	    strHTML = strHTML & "     <td class='clsStandardText'><input id='UDRCChargeAccount" & nCount & "' name='UDRCChargeAccount" & nCount & "' type='text' size='20'><a href=""JavaScript:getFrameMetraNet().getSelection('setSelection','UDRCChargeAccount" & nCount & "');"" name='selUDRCChargeAccount" & nCount & "' id='selUDRCChargeAccount" & nCount & "'><img src='/Res/Images/icons/find.png' alt='Select Account' border='0' /></a></td>"       
  	  	    strHTML = strHTML & "   </tr>"
           End If        
    		  
         End If  
         nCount = nCount + 1
       End If
    Next

  Service.Properties.Add "UDRCValueCount", "INT32", 0, TRUE, EMPTY
  Service.Properties("UDRCValueCount").Value = nCount
    
    ' PER-SUBSCRIPTION:  charge account value template
    ' 1.  Get all priceable items of type recurring charge
     Dim RCs
     Dim rcType
     Set rcType = objMTProductCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge")
     Set RCs = po.GetPriceableItemsOfType(rcType.ID) 
     nCount = 0
     Dim RC
     For Each RC in RCs
      ' 2. Check to make sure the charge is NOT per participant
       If Not CBool(RC.ChargePerParticipant) Then
         Service.Properties.Add "RCChargeAccount" & nCount, "string", 255, TRUE, ""
         Service.Properties("RCChargeAccount" & nCount).Caption = RC.DisplayName & " Account"
      	 strHTML = strHTML & "   <tr>"
   	  	 strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='RCChargeAccount" & nCount & "' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
         strHTML = strHTML & "     <td class='clsStandardText'><input id='RCChargeAccount" & nCount & "' name='RCChargeAccount" & nCount & "' type='text' size='20'><a href=""JavaScript:getFrameMetraNet().getSelection('setSelection','RCChargeAccount" & nCount & "');"" name='selRCChargeAccount" & nCount & "' id='selRCChargeAccount" & nCount & "'><img src='/Res/Images/icons/find.png' alt='Select Account' border='0' /></a></td>"       
  	  	 strHTML = strHTML & "   </tr>"
         nCount = nCount + 1
       End If
     Next
  
  End If
  
  If Len(strHTML) > 0  Then
    strHTML = "<tr><td class='clsStandardTitle' colspan='2'>Recurring Charge Configuration<hr size='1'></td></tr>" & strHTML
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_UDRC_TEMPLATE />", strHTML)
  Else  
	  Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_UDRC_TEMPLATE />", strHTML)
  End IF
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  

  DynamicTemplate = TRUE
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : CopyCyclePropertiesFromTemplate
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION CopyCyclePropertiesFromTemplate(MSIXAccTemplate)
	Dim AccTemplate
	
	CopyCyclePropertiesFromTemplate = FALSE

	Set AccTemplate = MSIXAccTemplate.AccountTemplate	
	Service.Properties("UsageCycleType").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("usagecycletype")).value
	
	Select Case GetNumberFromEnumValue("metratech.com/BillingCycle", "UsageCycleType", Service.Properties("UsageCycleType").Value)
		Case 1
			Service.Properties("dayofmonth").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("dayofmonth")).value
		Case 2, 3 ' On demand  & Daily - do nothing
		Case 4 ' Weekly
			Service.Properties("dayofweek").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("dayofweek")).value
		Case 5 ' Bi-weekly - A little extra work here
			Service.Properties("StartDay").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("StartDay")).value
			Service.Properties("startmonth").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("startmonth")).value
			Service.Properties("StartYear").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("StartYear")).value
		Case 6 ' Semi-monthly
			Service.Properties("firstdayofmonth").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("firstdayofmonth")).value
			Service.Properties("seconddayofmonth").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("seconddayofmonth")).value
		Case 7,8 ' Quarterly & Annually
			Service.Properties("StartDay").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("StartDay")).value
			Service.Properties("startmonth").Value = AccTemplate.Properties(MSIXAccTemplate.GetPropertiesIndex("dayofmonth")).value
	End Select
	
	CopyCyclePropertiesFromTemplate = TRUE
	
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : DiscountDistType_Click
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
PUBLIC FUNCTION DiscountDistType_Click(EventArg)

	Service.Properties("ProductOffering").Value = Form("objPO").Name
	
	Select Case Form("objPO").GetDistributionRequirement
		Case DISTRIBUTION_REQUIREMENT_TYPE_NONE
			mdm_GetDictionary.Add "DISCOUNT_DISTRIBUTION", false
			mdm_GetDictionary.Add "DISCOUNT_ACCOUNT", false
			mdm_GetDictionary.Add "PROPORTIONAL_ALLOWED", ""
		Case DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT
			Service.Properties("DiscountDistType").value = DISCOUNT_DIST_ONEACCOUNT
			mdm_GetDictionary.Add "DISCOUNT_DISTRIBUTION", true
			mdm_GetDictionary.Add "DISCOUNT_ACCOUNT", true
			mdm_GetDictionary.Add "PROPORTIONAL_ALLOWED", "disabled"
		Case DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT_OR_PROPORTIONAL
			mdm_GetDictionary.Add "DISCOUNT_DISTRIBUTION", true
			mdm_GetDictionary.Add "DISCOUNT_ACCOUNT", true
			mdm_GetDictionary.Add "PROPORTIONAL_ALLOWED", ""
			If Service.Properties("DiscountDistType").Value = "1" Then
				mdm_GetDictionary.Add "DISCOUNT_ACCOUNT" , false
			Else
				mdm_GetDictionary.Add "DISCOUNT_ACCOUNT" , true
			End If
	End Select

  ' if there is no discount - then we do not show them    
  Set Form("colPI") = Form("objPO").GetPriceableItems()
  Dim pi
  Dim bHasNoDiscount
  bHasNoDiscount = true
  For Each pi in Form("colPI")
    If pi.Kind = PI_TYPE_DISCOUNT Then
      bHasNoDiscount = false
      exit for
    End If
  Next
  If bHasNoDiscount Then
      mdm_GetDictionary.Add "DISCOUNT_DISTRIBUTION", false
      mdm_GetDictionary.Add "DISCOUNT_ACCOUNT", false        
  End If
    
  DiscountDistType_Click = TRUE
END FUNCTION

PUBLIC FUNCTION GroupOpsOption_Click(EventArg)
	If Service.Properties("GroupOpsOption").value = 1 Then
		mdm_GetDictionary.Add "DISCOUNT_DISTRIBUTION", false
		mdm_GetDictionary.Add "DISCOUNT_ACCOUNT", false
		mdm_GetDictionary.Add "PROPORTIONAL_ALLOWED", ""
	Else
		DiscountDistType_Click(EventArg)
	End If
	GroupOpsOption_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Refresh
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

	Dim cyclePickValue
	cyclePickValue = Service.Properties("CopyCycleFromTemplate").value
	If cyclePickValue = Empty or cyclePickValue = 1 then
		Service.Properties("CopyCycleFromTemplate").value = 1
		call DisableForEditMode(true, true)
	Elseif cyclePickValue = 3 then
		call DisableForEditMode(false, true)
	Else
		call DisableForEditMode(false, false)
	End If

	'LocalizeBillingCycleProperties
  mam_Account_SetBillingCycleEnumType
  
  Form_Refresh = DynamicTemplate(EventArg) ' Load the correct template for the dynmaic UDRCs
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Paint
' PARAMETERS		  :
' DESCRIPTION 		: We need to override this method in this page to make the cycle selection work
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Paint(EventArg) ' As Boolean
	Form_Paint = AddUpdateAccount_FormPaint(EventArg) ' Share this event with DefaultDialogUpdateAccount.asp - see accountlib.asp
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
	On Error Resume Next
  
	Dim objMTProductCatalog, objNewGroupSubscription, objEffDate, objCycle
	mam_Account_UpdateBiWeeklyProperties
	
	' Here we will create the group subscription
	Set objMTProductCatalog = GetProductCatalogObject
	if UCase(Session("ACTION")) = "EDIT" then
		Set objNewGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Session("EDIT_ID"))
		Set objEffDate = objNewGroupSubscription.EffectiveDate
	else
	 	Set objNewGroupSubscription = objMTProductCatalog.CreateGroupSubscription
		Set objEffDate = Server.CreateObject("Metratech.MTPCTimeSpan.1")
		objNewGroupSubscription.EffectiveDate = objEffDate
		objNewGroupSubscription.ProductOfferingID = CLng(Service.Properties("ProductOfferingID").value)
	end if
	
	'---------- Configure Discount Distribution -----------'
	objNewGroupSubscription.ProportionalDistribution = CBool(CLng(Service.Properties("DiscountDistType").Value) = DISCOUNT_DIST_PROPORTIONAL)
	
	if mam_GetDictionary("DISCOUNT_ACCOUNT") then
		' If it is 100% to 1 account, configure the account
		if not objNewGroupSubscription.ProportionalDistribution then
			if len(trim(Service.Properties("DiscountAccount").Value)) > 0 then
				If Not FrameWork.DecodeFieldIDInMSIXProperty(Service("DiscountAccount"), Service("DiscountAccountID")) Then
					EventArg.Error.number = 1030
					EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1030")
					OK_Click = FALSE
					Set Session(mdm_EVENT_ARG_ERROR) = EventArg
					Exit Function
				End If
				objNewGroupSubscription.DistributionAccount = CLng(Service.Properties("DiscountAccountID").Value)
			else
	      EventArg.Error.number = 1026
	      EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1026")
	      OK_Click = FALSE
	      Set Session(mdm_EVENT_ARG_ERROR) = EventArg
	      Exit Function
			end if
		end if
	else 'it is ok, there is no discount to be configured in this GroupSub
		objNewGroupSubscription.ProportionalDistribution = true
	end if
		
	'Configure Group Subscription properties based on this dialog
	objNewGroupSubscription.Name = Service.Properties("Name").Value
	objNewGroupSubscription.Description = Service.Properties("Description").Value
	
	objNewGroupSubscription.SupportGroupOps = (Service.Properties("GroupOpsOption").value = SUPPORT_GROUP_OPS)
	
	if not UCase(Session("ACTION")) = "EDIT" then
		objNewGroupSubscription.CorporateAccount = CLng(Service.Properties("CorpAccountID").Value)
	end if
	
	'Effective Dates
	objEffDate.StartDate = CDate(Service.Properties("StartDate").Value)
	if len(TRIM(Request.Form("EndDate"))) > 0 then
		objEffDate.EndDate = CDate(Service.Properties("EndDate").Value)
	else
		objEffDate.EndDate = FrameWork.RCD().GetMaxDate()
	end if
	
	if not UCase(Session("ACTION")) = "EDIT" then		
		'---------- Configure Cycle Type ---------------------------------------'
		Set objCycle = Server.CreateObject("Metratech.MTPCCycle.1")
		objCycle.CycleTypeID = CLng(GetNumberFromEnumValue("metratech.com/BillingCycle", "UsageCycleType", Service.Properties("UsageCycleType").Value))
		call ConfigureCycle(objCycle)
		objNewGroupSubscription.Cycle = objCycle
		'-----------------------------------------------------------------------'
	end if

    If not UCase(Session("ACTION")) = "EDIT" Then
      Dim nID
      ' Set unit values on unit dependent recurring charges
      dim nCount
      nCount = Service.Properties("UDRCValueCount").Value
      dim i
      for i = 0 to nCount-1
        MAM().Log "MAM:  Setting UDRC instance: " & Service.Properties("UDRCInstanceId" & i).Value & " value: " & Service.Properties("UDRCValue" & i).Value
        Call objNewGroupSubscription.SetRecurringChargeUnitValue(Service.Properties("UDRCInstanceId" & i).Value, Service.Properties("UDRCValue" & i).Value, CDate(0), CDate(0))
        If(Err.Number <> 0) Then
          Session("OverrrideGroupSubscriptionDate") = false
          EventArg.Error.Save Err
          OK_Click = FALSE
          Exit Function
        End If
        If Not CBool(Service.Properties("ChargePerParticipant" & i)) Then 
          MAM().Log "Setting UDRC Charge Account: " & Service.Properties("UDRCChargeAccount" & i)
          If FrameWork.DecodeFieldID(Service.Properties("UDRCChargeAccount" & i), nID) Then
            Call objNewGroupSubscription.SetChargeAccount(Service.Properties("UDRCInstanceId" & i).Value, nID, CDate(0), CDate(0))
            If Err.Number <> 0 Then
          		Session("OverrrideGroupSubscriptionDate") = false
          		EventArg.Error.Save Err 
          		OK_Click = FALSE
              Exit Function
            End If            
          End If  
        End If
      Next
      
     Dim po
     Set po = objMTProductCatalog.GetProductOffering(Service.Properties("ProductOfferingID").value)

     ' Flat Rate Recurring Charge Per-Subscription
     Dim RCs
     Dim rcType
     Set rcType = objMTProductCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge")
     Set RCs = po.GetPriceableItemsOfType(rcType.ID) 
     nCount = 0
     Dim RC
     For Each RC in RCs
       If Not CBool(RC.ChargePerParticipant) Then
         MAM().Log "Setting RC instance: " & RC.ID & " Charge Account: " & Service.Properties("RCChargeAccount" & nCount)
         If FrameWork.DecodeFieldID(Service.Properties("RCChargeAccount" & nCount), nID) Then
           Call objNewGroupSubscription.SetChargeAccount(RC.ID, nID, CDate(0), CDate(0))
           If Err.Number <> 0 Then
          		Session("OverrrideGroupSubscriptionDate") = false
          		EventArg.Error.Save Err 
          		OK_Click = FALSE
              Exit Function
           End If           
         End IF
         nCount = nCount + 1
       End If
     Next

  End If
  
	Session("OverrrideGroupSubscriptionDate") = objNewGroupSubscription.Save

	If (CBool(Err.Number = 0)) then
		Session("GROUP_ID") = objNewGroupSubscription.GroupID
	  On Error Goto 0
		OK_Click = TRUE
	Else        
		Session("OverrrideGroupSubscriptionDate") = false
		EventArg.Error.Save Err 
		OK_Click = FALSE
	End If
	  
	if UCase(Session("ACTION")) = "EDIT" then
		Form.RouteTo = mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG")
	end if
	  
	  'Err.Clear
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Cancel_Click = TRUE
	Form.RouteTo = mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : UDRCGrid_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION UDRCGrid_DisplayCell(EventArg) ' As Boolean

  Select Case lcase(EventArg.Grid.SelectedProperty.Name)

  	Case "id_prop"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<a href='UDRCUpdate.asp?id_prop=" & EventArg.Grid.Rowset.Value("id_prop") & "&id_sub=" & EventArg.Grid.Rowset.Value("id_sub") & "&StartDate=" & EventArg.Grid.Rowset.Value("vt_start") & "&EndDate=" & EventArg.Grid.Rowset.Value("vt_end") & "&Value=" & EventArg.Grid.Rowset.Value("n_value") & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></a>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			UDRCGrid_DisplayCell = TRUE
		
		Case "n_value" 
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='right'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & EventArg.Grid.Rowset.Value("n_value")
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			UDRCGrid_DisplayCell = TRUE    

		Case "vt_start"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("vt_start"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			UDRCGrid_DisplayCell = TRUE 

		Case "vt_end"        
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("vt_end"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			UDRCGrid_DisplayCell = TRUE 

		Case else
			UDRCGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")

	End Select
	 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : RCGrid_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION RCGrid_DisplayCell(EventArg) ' As Boolean

  Select Case lcase(EventArg.Grid.SelectedProperty.Name)

  	Case "id_prop"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<a href='ChargeAccountUpdate.asp?name=" & server.URLEncode(EventArg.Grid.Rowset.Value("nm_display_name")) & "&id_prop=" & EventArg.Grid.Rowset.Value("id_prop") & "&StartDate=" & EventArg.Grid.Rowset.Value("vt_start") & "&EndDate=" & EventArg.Grid.Rowset.Value("vt_end") & "&id_acc=" & EventArg.Grid.Rowset.Value("id_acc") & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></a>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			RCGrid_DisplayCell = TRUE
		
		Case "id_acc" 
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='right'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetFieldIDFromAccountID(EventArg.Grid.Rowset.Value("id_acc"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			RCGrid_DisplayCell = TRUE    

		Case "vt_start"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("vt_start"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			RCGrid_DisplayCell = TRUE 

		Case "vt_end"        
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("vt_end"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			RCGrid_DisplayCell = TRUE 

		Case else
			RCGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")

	End Select
	 
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' NON-MDM DIALOG FUNCTIONS
' ---------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : GetNumberFromEnumValue
' PARAMETERS  :
' DESCRIPTION : 
' RETURNS     : Return GetEnumeratorValueByID from strvalue id
FUNCTION GetNumberFromEnumValue(enumspace, enumtype, strvalue)
	dim enumConfig, intMonthEnumID
	set enumConfig = Server.CreateObject("Metratech.MTEnumConfig")
	intMonthEnumID = enumConfig.GetID(enumspace, enumtype, strvalue)
	GetNumberFromEnumValue = enumConfig.GetEnumeratorValueByID(intMonthEnumID)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : GetNumberFromEnumSecondaryValue
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return secondary GetEnumeratorValueByID from intvalue id
FUNCTION GetNumberFromEnumSecondaryValue(enumspace, enumtype, intvalue)
	dim enumConfig, intMonthEnumID
	set enumConfig = Server.CreateObject("Metratech.MTEnumConfig")
	intMonthEnumID = enumConfig.GetID(enumspace, enumtype, intvalue)
	GetNumberFromEnumSecondaryValue = enumConfig.GetEnumeratorByID(intMonthEnumID)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : ConfigureCycle
' PARAMETERS  :
' DESCRIPTION : Configure cycle from Service Properties
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION ConfigureCycle(objCycle)
	
	ConfigureCycle = FALSE
	objCycle.Relative = False
	
	Select Case objCycle.CycleTypeID
		Case 1
			objCycle.EndDayOfMonth = Service.Properties("dayofmonth").Value
		Case 2,3 ' On demand  & Daily - do nothing
		Case 4 ' Weekly
			objCycle.EndDayOfWeek = CLng(GetNumberFromEnumValue("Global", "DayOfTheWeek", Service.Properties("dayofweek").Value))
		Case 5 ' Bi-weekly - A little extra work here
			objCycle.StartDay = Service.Properties("StartDay").Value
			objCycle.StartMonth = CLng(GetNumberFromEnumValue("Global", "MonthOfTheYear", Service.Properties("startmonth").Value))
			objCycle.StartYear = Service.Properties("StartYear").Value
		Case 6 ' Semi-monthly
			objCycle.EndDayOfMonth = CLng(Service.Properties("firstdayofmonth").Value)
			objCycle.EndDayOfMonth2 = CLng(Service.Properties("seconddayofmonth").Value)
		Case 7,8 ' Quarterly & Annually
			objCycle.StartDay = Service.Properties("StartDay").Value
			objCycle.StartMonth = CLng(GetNumberFromEnumValue("Global", "MonthOfTheYear", Service.Properties("startmonth").Value))
	End Select
	ConfigureCycle = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : ConfigureDialogFromCycle
' PARAMETERS  :
' DESCRIPTION : Configure Service Properties from Cycle
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION ConfigureDialogFromCycle(objCycle)
	ConfigureDialogFromCycle = FALSE
	Service.Properties("UsageCycleType").Value = GetNumberFromEnumSecondaryValue("metratech.com/BillingCycle", "UsageCycleType", objCycle.CycleTypeID)
	Select Case objCycle.CycleTypeID
		Case 1
			Service.Properties("dayofmonth").Value = objCycle.EndDayOfMonth
		Case 2,3 ' On demand  & Daily - do nothing
		Case 4 ' Weekly
			Service.Properties("dayofweek").Value = GetNumberFromEnumSecondaryValue("Global", "DayOfTheWeek", objCycle.EndDayOfWeek)
		Case 5 ' Bi-weekly - A little extra work here
			Service.Properties("StartDay").Value = objCycle.StartDay
			Service.Properties("startmonth").Value = GetNumberFromEnumSecondaryValue("Global", "MonthOfTheYear", objCycle.StartMonth)
			Service.Properties("StartYear").Value = objCycle.StartYear
		Case 6 ' Semi-monthly
			Service.Properties("firstdayofmonth").Value = objCycle.EndDayOfMonth
			Service.Properties("seconddayofmonth").Value = objCycle.EndDayOfMonth2
		Case 7,8 ' Quarterly & Annually
			Service.Properties("StartDay").Value = objCycle.StartDay
			Service.Properties("startmonth").Value = GetNumberFromEnumSecondaryValue("Global", "MonthOfTheYear", objCycle.StartMonth)
	End Select
	ConfigureDialogFromCycle = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : DisableForEditMode
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
PUBLIC FUNCTION DisableForEditMode(bDisable, bDisableCycleTypeChoice)
	Service.Properties("dayofmonth").enabled = not bDisable
	Service.Properties("dayofweek").enabled = not bDisable
	Service.Properties("firstdayofmonth").enabled = not bDisable
	Service.Properties("seconddayofmonth").enabled = not bDisable
	Service.Properties("BiWeeklyLabelInfo").enabled = not bDisable
	Service.Properties("startmonth").enabled = not bDisable
	Service.Properties("startday").enabled = not bDisable
	Service.Properties("startyear").enabled = not bDisable
	Service.Properties("CorpAccount").enabled = not bDisable
	Service.Properties("UsageCycleType").enabled = not bDisableCycleTypeChoice
	
END FUNCTION
%>


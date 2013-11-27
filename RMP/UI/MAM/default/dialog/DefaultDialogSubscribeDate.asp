<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultDialogSubscribeDate.asp$
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
'  $Date: 11/19/2002 2:08:14 PM$
'  $Author: Kevin Boucher$
'  $Revision: 44$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.RouteTo = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")
Form.ErrorHandler  = FALSE
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: Check if the time for the end date was set if not we set 23:59:59.
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
      Inherited("Form_Populate") ' First Let us call the inherited event
      mam_CheckEndDate EventArg, "SubscriptionEndDate"
      Form_Populate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = session("SUBS_DATE_CANCEL_ROUTETO")
  Cancel_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  session("UDRC_CANCEL_ROUTETO") = request.serverVariables("URL") & "?" & request.serverVariables("QUERY_STRING")

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  mdm_GetDictionary().Add "WARNING_EBCR", false
  
  Service.Properties.Add "SubscriptionID",        "Long",        0, TRUE,  -1                   
  Service.Properties.Add "Subscription",          "String",    256, TRUE,  "" 
  Service.Properties.Add "SubscriptionStartDate", "TIMESTAMP",   0, TRUE,  Empty    
  Service.Properties.Add "SubscriptionEndDate",   "TIMESTAMP",   0, FALSE, Empty  
  Service.Properties.Add "StartNextBillingPeriod","boolean",     0, FALSE, FALSE
	Service.Properties.Add "EndNextBillingPeriod",  "boolean",     0, FALSE, FALSE
  Service.Properties.Add "POEffectiveStartDate",  "TIMESTAMP",   0, FALSE, Empty  
	Service.Properties.Add "GroupID",								"Long",				 0, FALSE, -1
  
	' Use the service to store the mode of this page 
  Service.Properties.Add "EditMode",  						"BOOLEAN",   0, FALSE, Empty
	Service.Properties.Add "EditSubscriptionID",  	"Long",        0, TRUE,  -1
	Service.Properties.Add "Unsubscribe",  					"BOOLEAN",   0, FALSE, Empty
	    
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

   
  Service.Properties("SubscriptionID")         = Request.QueryString("IDS")  
  Service.Properties("Subscription")           = Request.QueryString("OPTIONALVALUES")
	
	Service.Properties("EditMode")				 			 = (UCase(Request.QueryString("EditMode")) = "TRUE")
	Service.Properties("Unsubscribe")				 		 = (UCase(Request.QueryString("Unsubscribe")) = "TRUE")
	Service.Properties("EditSubscriptionID")		 = Clng(Request.QueryString("EditSubID"))
	Service.Properties("GroupID")		 						 = Request.QueryString("id_group")
	
  ''''
  ' Get PO startDate... if it is in the future pre-populate the start date otherwise set it to empty
  ''''
  Dim objMTProductCatalog, objSubscription, objAccount
  
  Set objMTProductCatalog = GetProductCatalogObject
	
	Service.Properties("POEffectiveStartDate")  = CDate(Service.Tools.ConvertFromGMT(objMTProductCatalog.GetProductOffering(CLng(Service.Properties("SubscriptionID"))).EffectiveDate.StartDate)) 

  ' The blue delete button and message that used to live on this screen are now permanently hidden - the delete action
  ' is now on the previous screen.
  mdm_GetDictionary().Add "DELETE_MODE", false
  
	' This dialog has the NEW and EDIT modes - prepopulate each element accordingly
	if Service.Properties("EditMode") then ' EDIT

		' Show delete subscription button
		mdm_GetDictionary().Add "EDIT_MODE", true
	
		Set objAccount = objMTProductCatalog.GetAccount(mam_GetSubscriberAccountID())
		Set objSubscription = objAccount.GetSubscription(CLng(Service.Properties("EditSubscriptionID")))
		
                if objSubscription.WarnOnEBCRStartDateChange then 
                  mdm_GetDictionary().Add "WARNING_EBCR", true
                else
                  mdm_GetDictionary().Add "WARNING_EBCR", false
                end if

		Service.Properties("SubscriptionStartDate") = objSubscription.EffectiveDate.StartDate
		
		Service.Properties("SubscriptionEndDate") = objSubscription.EffectiveDate.EndDate
	  If FrameWork.IsInfinity(Service.Properties("SubscriptionEndDate")) Then
			Service.Properties("SubscriptionEndDate") = Null
		End If
		
		Service.Properties("StartNextBillingPeriod") = (objSubscription.EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE)
	  Service.Properties("EndNextBillingPeriod") = (objSubscription.EffectiveDate.EndDateType = PCDATE_TYPE_BILLCYCLE)

		if Service.Properties("Unsubscribe") Then
			mdm_GetDictionary().Add "DIALOG_TITLE", mam_GetDictionary("TEXT_PRODUCT_OFFERING_UNSUBSCRIBE")
			Service.Properties("SubscriptionStartDate").Enabled = false
			Service.Properties("StartNextBillingPeriod").Enabled = false
			Service.Properties("SubscriptionEndDate").Value = Null
			mdm_GetDictionary().Add "EDIT_MODE", false
			mdm_GetDictionary().Add "UNSUB_MODE", true
		else
			mdm_GetDictionary().Add "DIALOG_TITLE", mam_GetDictionary("TEXT_SUBSCRIPTION_DATE_EDIT")
			mdm_GetDictionary().Add "EDIT_MODE", true
			mdm_GetDictionary().Add "UNSUB_MODE", false
		end if

		mdm_GetDictionary.Add "REMOVE_GROUP_ID", Service.Properties("GroupID")
		mdm_GetDictionary.Add "REMOVE_ACC_ID", mam_GetSubscriberAccountID()
		mdm_GetDictionary.Add "REMOVE_SUB_ID", objSubscription.ID
	
	else ' NEW
		mdm_GetDictionary().Add "DIALOG_TITLE", mam_GetDictionary("TEXT_SUBSCRIPTION_DATE")
		
		' Show delete subscription button
		mdm_GetDictionary().Add "EDIT_MODE", false	
	
	  If (CDate(FrameWork.MetraTimeGMTNow()) > CDate(Service.Properties("POEffectiveStartDate"))) Then
	    Service.Properties("SubscriptionStartDate") = Empty
	  Else
	    Service.Properties("SubscriptionStartDate")  = Service.Properties("POEffectiveStartDate")
	  End IF
	  ''''
	  Service.Properties("SubscriptionEndDate")    = Empty
	  Service.Properties("StartNextBillingPeriod") = FALSE
	  Service.Properties("EndNextBillingPeriod")   = FALSE
		
		mdm_GetDictionary().Add "UNSUB_MODE", false
  end if
	  
	Service.Properties("SubscriptionStartDate").Required  = TRUE
    
	Service.Properties("SubscriptionID").Caption         = mam_GetDictionary("TEXT_SUBSCRIPTION_ID")
	Service.Properties("Subscription").Caption           = mam_GetDictionary("TEXT_SUBSCRIPTION")
	Service.Properties("SubscriptionStartDate").Caption  = mam_GetDictionary("TEXT_SUBSCRIPTION_START_DATE")  
	Service.Properties("SubscriptionEndDate").Caption    = mam_GetDictionary("TEXT_SUBSCRIPTION_END_DATE")
  Service.Properties("StartNextBillingPeriod").Caption = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_START")  
  Service.Properties("EndNextBillingPeriod").Caption   = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_END")  
    
  mam_IncludeCalendar
        
	Form_Initialize = DynamicTemplate(EventArg) ' Load the correct template for the dynmaic UDRCs
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  
  
  Form("WarningStartDateInThePastSeen") = FALSE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicTemplate
' PARAMETERS:  EventArg
' DESCRIPTION:  This function determines what should be placed in the dynamic template based on the UDRCs found
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicTemplate(EventArg)
  Dim objMTProductCatalog
  Dim objAccount
  Dim objSubscription
  Dim strHTML
  
  Set objMTProductCatalog = GetProductCatalogObject()
    	
  If Service.Properties("EditMode") Then ' EDIT
    ' In edit mode display grid of existing UDRCs
  	Set objAccount = objMTProductCatalog.GetAccount(mam_GetSubscriberAccountID())
	  Set objSubscription = objAccount.GetSubscription(CLng(Service.Properties("EditSubscriptionID")))
    Form.Grids.Add "UDRCGrid", "UDRCGrid"
    Set Form.Grids("UDRCGrid").Rowset = objSubscription.GetRecurringChargeUnitValuesAsRowset()
    Form.Grids("UDRCGrid").Width = "100%"	
    Form.Grids("UDRCGrid").Properties.ClearSelection
	  'Form.Grids("UDRCGrid").Properties.SelectAll 

    Form.Grids("UDRCGrid").Properties("id_prop").Selected       = 1
    Form.Grids("UDRCGrid").Properties("vt_start").Selected      = 2
	  Form.Grids("UDRCGrid").Properties("vt_end").Selected 	      = 3
    Form.Grids("UDRCGrid").Properties("nm_unit_name").Selected  = 4     
    Form.Grids("UDRCGrid").Properties("n_value").Selected       = 5
   ' Form.Grids("UDRCGrid").Properties("id_sub").Selected       = 6
   
   	Form.Grids("UDRCGrid").Properties("id_prop").Caption 	    = "&nbsp;" 
  	Form.Grids("UDRCGrid").Properties("vt_start").Caption     = mam_GetDictionary("TEXT_START_DATE")
    Form.Grids("UDRCGrid").Properties("vt_end").Caption 	    = mam_GetDictionary("TEXT_END_DATE")
    Form.Grids("UDRCGrid").Properties("nm_unit_name").Caption = "Name"
    Form.Grids("UDRCGrid").Properties("n_value").Caption 	    = "Value"
'    Form.Grids("UDRCGrid").Properties("id_sub").Caption 	    = ""

    If Form.Grids("UDRCGrid").Rowset.RecordCount > 0 Then
      strHTML = strHTML & "<tr><td colspan='2'><div class='sectionCaptionBar'>Unit Dependent Recurring Charges</div><MDMGRID name='UDRCGrid'></MDMGRID>"
      strHTML = strHTML & "<br>"
      ' we don't need add button:  <button onclick='mdm_RefreshDialog(this)' name='AddUDRC' Class='clsButtonBlueMedium'>Add Value</button><br>"    
      strHTML = strHTML & "</td></tr>"
    End If
    

  Else
    ' Template for unit dependent recurring charges
    'Dim udrcType
    'Set udrcType = objMTProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge")
    Dim po
    Set po = objMTProductCatalog.GetProductOffering(Service.Properties("SubscriptionID"))
    
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
         End If  
         nCount = nCount + 1
       End If
    Next

  Service.Properties.Add "UDRCValueCount", "INT32", 0, TRUE, EMPTY
  Service.Properties("UDRCValueCount").Value = nCount
    
  End If
    
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_UDRC_TEMPLATE />", strHTML)
  
  DynamicTemplate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicTemplate for the UDRCs
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicTemplate(EventArg)
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
      ' The conversion logic here is messed up because, the conversion code uses a time_t and therefore
			' doesn't handle dates < 1970 (in particular MTMinDate())! A bug has been logged to create an function mam_GetDisplayStartDate that
      ' uses a nice infinity icon and stuff; in the meantime, don't do the timezone conversion since MAM users
			' are in GMT anyway.
			'EventArg.HTMLRendered = EventArg.HTMLRendered & Service.Tools.ConvertFromGMT(EventArg.Grid.Rowset.Value("vt_start"), MAM().CSR("TimeZoneId")) 
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
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    On Error Resume Next
    Dim acctID
    Dim MTAccountReference
		Dim objSubscription
    Dim objMTProductCatalog
    Dim effDate ' As New MTTimeSpan 
  
    Set objMTProductCatalog = GetProductCatalogObject
    
    ' Make sure subscription start date is after po effective start date
    If (CDate(Service.Properties("SubscriptionStartDate")) < CDate(Service.Properties("POEffectiveStartDate"))) Then
    	EventArg.Error.Number= 1
    	EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_5005") & " [" & CDate(Service.Properties("POEffectiveStartDate")) & "]."
    	OK_Click = FALSE
      Err.Clear
      Exit Function
    End If
    
    acctID = mam_GetSubscriberAccountID()
  
    ' Get effective date
    Set effDate = Server.CreateObject(MTTimeSpan)  

   ' Check if Start Date is defined and in the past if yes ISSUE a WARNING... Note that if we are unsubscribing, then it is ok
   If Len(Service.Properties("SubscriptionStartDate")) and not Service.Properties("Unsubscribe") Then  
   			If DateDiff("d", FrameWork.MetraTimeGMTNow(), CDate(Service.Properties("SubscriptionStartDate"))) < 0 Then
            If Not Form("WarningStartDateInThePastSeen") Then
              EventArg.Error.Number = 1
              EventArg.Error.Description = mam_GetDictionary("MAM_WARNING_8000") 
              OK_Click = FALSE
              Form("WarningStartDateInThePastSeen") = TRUE
              Exit Function
            End If
       End If
   End If

    ' Check Effective Dates
    Dim strErrorMessage
    If Not CheckEffectiveDates(Service.Properties("SubscriptionStartDate"),Service.Properties("SubscriptionEndDate"), strErrorMessage, TRUE) Then
    	EventArg.Error.Number= 1
      EventArg.Error.Description = strErrorMessage
      OK_Click = FALSE
      Err.Clear
      Exit Function
    End If
    		      
    effDate.StartDate = CDate(Service.Tools.ConvertToGMT(Service.Properties("SubscriptionStartDate"), MAM().CSR("TimeZoneId")))
    If Len(Service.Properties("SubscriptionEndDate")) Then
      effDate.EndDate = CDate(Service.Tools.ConvertToGMT(Service.Properties("SubscriptionEndDate"), MAM().CSR("TimeZoneId")))
      If Service("EndNextBillingPeriod") Then 
        effDate.EndDateType = PCDATE_TYPE_BILLCYCLE 
      Else
        effDate.EndDateType = PCDATE_TYPE_ABSOLUTE
      End IF
    Else
      effDate.SetEndDateNull
    End If
     
    If Service("StartNextBillingPeriod") Then 
      effDate.StartDateType = PCDATE_TYPE_BILLCYCLE 
    Else
      effDate.StartDateType = PCDATE_TYPE_ABSOLUTE 
    End If

		'Get account reference
		Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)
		
		If Not CheckCycleAvailability(effDate, MTAccountReference, EventArg) Then
			OK_Click = FALSE
			Session("DateOverride") = false			
			Exit Function
		End If
		
  	if Service.Properties("EditMode") then
			Set objSubscription = MTAccountReference.GetSubscription(CLng(Service.Properties("EditSubscriptionID")))
			objSubscription.EffectiveDate = effDate
			Session("DateOverride") = objSubscription.Save
		else		
    	' Subscribe
      Set objSubscription = MTAccountReference.CreateSubscription(Service.Properties("SubscriptionID"), effDate)

      ' UDRC: Set unit values on unit dependent recurring charges, use eff date interval
      ' [0,0] to indicate that the effective date should be -infinity to +infinity.
      'Dim udrcType
      'Set udrcType = objMTProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge")
      'Dim po
      'Set po = objMTProductCatalog.GetProductOffering(Service.Properties("SubscriptionID"))
      'Dim udrcInstances
      'Set udrcInstances = po.GetPriceableItemsOfType(udrcType.ID)
      'Dim udrcInstance
      dim nCount
      nCount = Service.Properties("UDRCValueCount").Value
      dim i
      for i = 0 to nCount-1
        MAM().Log "MAM:  Setting UDRC instance: " & Service.Properties("UDRCInstanceId" & i).Value & " value: " & Service.Properties("UDRCValue" & i).Value
        Call objSubscription.SetRecurringChargeUnitValue(Service.Properties("UDRCInstanceId" & i).Value, Service.Properties("UDRCValue" & i).Value, CDate(0), CDate(0))
        If(Err.Number <> 0) Then
          Session("DateOverride") = false
          EventArg.Error.Save Err
          OK_Click = FALSE
          Exit Function
        End If
      Next
      
      'For Each udrcInstance In udrcInstances
        'MAM().Log "MAM:  Setting UDRC instance: " & udrcInstance.ID & " value: " & Service.Properties("UDRCValue" & nCount).Value
      '  Call objSubscription.SetRecurringChargeUnitValue(udrcInstance.ID, Service.Properties("UDRCValue" & nCount).Value, CDate(0), CDate(0))
      '  If(Err.Number <> 0) Then
      '    Session("DateOverride") = false
      '    EventArg.Error.Save Err
      '    OK_Click = FALSE
      '    Exit Function
      '  End If
      '  nCount = nCount + 1
      'Next
          
			Session("DateOverride") = objSubscription.Save
		end if
      
    If(CBool(Err.Number = 0)) then
	    On Error Goto 0
  		'AUDIT
			'mam_Audit mam_GetDictionary("AUDIT_SUBSCRIBE") & Service.Properties("Subscription"), 0
			OK_Click = TRUE
    Else        
			Session("DateOverride") = false
      EventArg.Error.Save Err  
      OK_Click = FALSE
    End If
    Err.Clear      
END FUNCTION


Function CheckCycleAvailability(effDate, objAccount, EventArg)

	CheckCycleAvailability = TRUE

	If effDate.StartDateType = PCDATE_TYPE_BILLCYCLE Then
		If IsNull(objAccount.GetNextBillingIntervalEndDate(effDate.StartDate)) Then
    	EventArg.Error.Number= 1
    	EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_5006")
			CheckCycleAvailability = FALSE
			Exit Function
		End If
	End If
	
	If Len(Trim(effDate.EndDate)) Then
		If effDate.EndDateType = PCDATE_TYPE_BILLCYCLE Then
			If IsNull(objAccount.GetNextBillingIntervalEndDate(effDate.EndDate)) Then
	    	EventArg.Error.Number= 1
	    	EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_5007")
				CheckCycleAvailability = FALSE
				Exit Function
			End If
		End If
	End If

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Error
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Error(EventArg) ' As Boolean

    Select Case  EventArg.Error.Number
        Case 738197503
           EventArg.Error.Number= 7004
           EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_7004") 
    End Select

    Form_Error = TRUE
END FUNCTION
%>


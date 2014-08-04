<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	: THIS DIALOG IS USED ONLY TO MOVE AN ACCOUNT...
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/CAccountTemplateHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

' Mandatory
Form.ServiceMsixdefFileName 	    = mam_GetAccountCreationMsixdefFileName()
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Dim strPropertiesHTMLDif
		Dim MSIXAccountTemplate, objPropertiesAdvicesRowSet

		Form("AncestorAccountID") = Request.QueryString("AncestorAccountID")
		Form("AccountID") 				= Request.QueryString("AccountID")
    Form("MoveStartDate") 		= Request.QueryString("MoveStartDate")
    
    SetUserNameAndNameSpaceInForm ' Get and set 

		' Load the Subscriber Properties
		mam_LoadTempAccount Form("AccountID")
				
		' Intialize the template helper
    Call AccountTemplateHelper.Initialize(Form("AncestorAccountID"))
    
    'Load the template
    if not AccountTemplateHelper.LoadTemplate then
      exit function
    end if
    
    'Determine if there is no template, if not, go to the account moved confirmation

    'Init dynamic properties (date, etc)
    if not InitSubscriptionsDynamicProperties() then
      exit function
    end if

    'Load the suggested subscriptions
    if not LoadSuggestedSubscriptionsGrid() then
      exit function
    end if

	  ' -- Suggested Properties Changes in a grid --
		Form.Grids.Add "PropertiesGrid"
						
	 	Set Form.Grids("PropertiesGrid").RowSet = AccountTemplateHelper.GetPropertiesDiffAsRowset(MAM().TempAccount)		
	 
	  If Form.Grids("PropertiesGrid").Rowset.RecordCount = 0 Then
		
	   			Form.Grids("PropertiesGrid").Visible = FALSE
		Else
					Form.Grids("PropertiesGrid").Properties.ClearSelection 
					Form.Grids("PropertiesGrid").Properties.SelectAll
					
					Form.Grids("PropertiesGrid").Properties("Reserved").Selected 			  = 1
					Form.Grids("PropertiesGrid").Properties("Name").Selected 					  = 2
					Form.Grids("PropertiesGrid").Properties("TemplateValue").Selected 	= 3
					Form.Grids("PropertiesGrid").Properties("MSIXValue").Selected 		  = 4					
				
					Form.Grids("PropertiesGrid").Properties("Reserved").Caption					= " "
					Form.Grids("PropertiesGrid").Properties("Name").Caption							= mdm_GetDictionaryValue("TEXT_ACCOUNT_TEMPLATE_PROPERTY_NAME","")
					Form.Grids("PropertiesGrid").Properties("TemplateValue").Caption		= mdm_GetDictionaryValue("TEXT_ACCOUNT_TEMPLATE_TEMPLATE_VALUE","")
					Form.Grids("PropertiesGrid").Properties("MSIXValue").Caption				= mdm_GetDictionaryValue("TEXT_ACCOUNT_TEMPLATE_ACCOUNT_VALUE","")
					Form.Grids("PropertiesGrid").Visible = TRUE
	  End If
    
    mam_IncludeCalendar
		CancelRequiredProperties		
		Form_Initialize = TRUE
END FUNCTION
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadSuggestedSubscriptionsGrid()                            '
' Description : Load the grid for the suggested subscriptions.  Currently   '
'             : returns all subscriptions, with no checks for users that    '
'             : may already have the subscription.                          '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadSuggestedSubscriptionsGrid()

  LoadSuggestedSubscriptionsGrid = false
  
  'Add the grid if necessary
  if not Form.Grids.Exist("SubscriptionsGrid") then
    Call Form.Grids.Add("SubscriptionsGrid")
  end if

  'Get the subscriptions from the MSIX account template
  Set Form.Grids("SubscriptionsGrid").Rowset = AccountTemplateHelper.GetSubscriptionsAsRowset()
  
  'Add property to display/hide subscriptions
  
   'personalization
   if Not FrameWork.CheckCoarseCapability("Create subscription") then   
      Form.Grids("SubscriptionsGrid").Visible = false
      Call mdm_GetDictionary.Add("bSubscriptions", false)
      LoadSuggestedSubscriptionsGrid  = true          
      Exit Function
   end if 

  
  'If there are no subscriptions, hide the grid
  if Form.Grids("SubscriptionsGrid").Rowset.RecordCount = 0 then
    Form.Grids("SubscriptionsGrid").Visible = false
		Call mdm_GetDictionary.Add("bSubscriptions", false)
  else
    'Setup the grid
		Call mdm_GetDictionary.Add("bSubscriptions", true)
    Call Form.Grids("SubscriptionsGrid").Properties.ClearSelection()
    
    'Order
		Form.Grids("SubscriptionsGrid").Properties("ID_PO").Selected 					  = 1
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Selected 	= 2
    Form.Grids("SubscriptionsGrid").Properties("B_GROUP").Selected 					= 3
    Form.Grids("SubscriptionsGrid").Properties("NM_GROUPSUBNAME").Selected  = 4
'		Form.Grids("SubscriptionsGrid").Properties("VT_START").Selected 				= 3
'		Form.Grids("SubscriptionsGrid").Properties("VT_END").Selected 					= 4

    'Captions
		Form.Grids("SubscriptionsGrid").Properties("ID_PO").Caption							= " " ' Must be blank - Place Holder
		Form.Grids("SubscriptionsGrid").Properties("B_GROUP").Caption 					= mam_GetDictionary("TEXT_GROUP_SUBSCRIPTION")
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Caption 	= mam_GetDictionary("TEXT_SUBSCRIPTION_NAME")
'		Form.Grids("SubscriptionsGrid").Properties("VT_START").Caption 					= mam_GetDictionary("TEXT_START_DATE")
'		Form.Grids("SubscriptionsGrid").Properties("VT_END").Caption 					  = mam_GetDictionary("TEXT_END_DATE")
		Form.Grids("SubscriptionsGrid").Properties("NM_GROUPSUBNAME").Caption   = mam_GetDictionary("TEXT_SUBSCRIPTION_TEMPLATE_GROUP_SUB_NAME")

    'Other info
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Sorted    = MTSORT_ORDER_ASCENDING		 
'		Form.Grids("SubscriptionsGrid").Width   = "100%"
		Form.Grids("SubscriptionsGrid").Visible = true
  end if
  
  LoadSuggestedSubscriptionsGrid  = true

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : InitSubscriptionsDynamicProperties()                        '
' Description : Initialize the dynamic properties, such as dates, for       '
'             : subscriptions.                                              '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function InitSubscriptionsDynamicProperties()
  InitSubscriptionsDynamicProperties = false
  
  'Add properties
  Call Service.Properties.Add("Subscribe_EffectiveStartDate" 								, "TimeStamp" , 0, false,  Empty)
  Call Service.Properties.Add("Subscribe_EffectiveEndDate" 									, "TimeStamp" , 0, false,  Empty)
  Call Service.Properties.Add("StartNextBillingPeriod", "Boolean"   , 0, false,  Empty)
  Call Service.Properties.Add("EndNextBillingPeriod", "Boolean"   , 0, false,  Empty)  
 
  'Set values
  Service.Properties("Subscribe_EffectiveStartDate").Value   								= CDate(Form("MoveStartDate"))
  Service.Properties("Subscribe_EffectiveEndDate").Value     								= Empty
  Service.Properties("StartNextBillingPeriod").Value =	FALSE
  Service.Properties("EndNextBillingPeriod").Value = FALSE

  'Set captions
  Service.Properties("Subscribe_EffectiveStartDate").Caption 								= mam_GetDictionary("TEXT_APPLY_TEMPLATE_SUBSCRIPTIONS_EFFECTIVE_START_DATE")
  Service.Properties("Subscribe_EffectiveEndDate").Caption 								  = mam_GetDictionary("TEXT_APPLY_TEMPLATE_SUBSCRIPTIONS_EFFECTIVE_END_DATE")
  Service.Properties("StartNextBillingPeriod").Caption = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_START")  
  Service.Properties("EndNextBillingPeriod").Caption = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_END")  
       
  InitSubscriptionsDynamicProperties = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SubscriptionsGrid_DisplayCell(EventArg)                     '
' Description : Custom to handle check box for bGroup                       '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function SubscriptionsGrid_DisplayCell(EventArg) ' As Boolean
  'Checkbox for group
  if UCase(EventArg.Grid.SelectedProperty.Name) = "B_GROUP" then
    if EventArg.Grid.Properties("B_GROUP") then
      EventArg.HTMLRendered =  "<td class=" & EventArg.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
      SubscriptionsGrid_DisplayCell = true
    else
      EventArg.HTMLRendered =  "<td class=" & EventArg.Grid.CellClass & " align='center'>--&nbsp;</td>"
      SubscriptionsGrid_DisplayCell = true
    end If
  
  
  'Checkbox to apply subscription
  elseif UCase(EventArg.Grid.SelectedProperty.Name) = "ID_PO" then
    EventArg.HTMLRendered = "<td class=" & EventArg.Grid.CellClass & "><input name=""_ATHS_|" & EventArg.Grid.SelectedProperty.Value & "|" & EventArg.Grid.Properties("B_GROUP") & """ type=""checkbox"" checked></td>"

  else
    SubscriptionsGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
  end if
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION CANCEL_Click(EventArg)		
    Form.RouteTo = mam_getDictionary("WELCOME_DIALOG")
		CANCEL_Click = true
END FUNCTION		

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION OK_Click(EventArg)		
  On Error Resume Next

	Dim v, arrVar, objUIItems
	
	OK_Click = FALSE
  
  If Not UpdateAccountProperties() Then
   EventArg.Error.Save Err  
	 Exit Function
  End If
	  
	If Not UpdateAccountWithSubscriptions(EventArg) Then
    EventArg.Error.Save Err  	
	 Exit Function  
  End If
	
  Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_APPLY_TEMPLATE_TO_MOVED_ACCOUNT"), mam_GetDictionary("TEXT_INFO_SUCCEFULLY_UPDATED"), Form.RouteTo)

  If(CBool(Err.Number = 0)) then
      On Error Goto 0
      OK_Click = TRUE
  Else        
      EventArg.Error.Save Err  
      OK_Click = FALSE
  End If

END FUNCTION


PRIVATE FUNCTION CancelRequiredProperties() ' As Boolean

	Dim p
	For Each p in Service.Properties
	
		p.Required = FALSE
	Next
	CancelRequiredProperties = TRUE
END FUNCTION

'
' Here we update the properties of an account by using accountcreation in update mode...
'
PRIVATE FUNCTION UpdateAccountProperties()

	Dim booOK, v, arrVar, objUIItems
  UpdateAccountProperties = FALSE

  'mam_PrepareServiceForQuickUpdateAccount	
  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
  

  ' Reload all the data of the current subscriber
  mam_LoadTempAccount Form("AccountID")
  MAM().TempAccount.CopyTo Service.Properties
    
    
  ' Apply Properties from the screen    
	For Each v In objUIItems
	
			arrVar = Split(v.name,"|")			
			Select Case arrVar(0)
			
					Case "_ATHP_"
              If UCase(arrVar(1)) = "PAYERID" Then
                Service.Properties("payment_startdate").Value = Form("MoveStartDate")
              end If
 							Service.Properties(arrVar(1)).Value = arrVar(2)
			End Select
	Next
	Service.Properties("ActionType").value   = Service.Properties("ActionType").EnumType.Entries("Both").Value
	Service.Properties("Operation").Value    = Service.Properties("Operation").EnumType.Entries("Update").Value
  
  Service.Properties("pricelist").Value = empty

  ' make sure we do not meter the default for enum types if they are empty
  Call mam_AccountEnumTypeSupportEmpty(Service.Properties)
  
  mam_Account_DoNotMeterAccountStateInfo service
    
  On Error Resume Next
	booOK = Service.Meter(True)
	If Err.Number = 0 Then
			UpdateAccountProperties = TRUE
	Else
			EventArg.Error.Save Err
	End If
END FUNCTION


PRIVATE FUNCTION SetUserNameAndNameSpaceInForm()

    SetUserNameAndNameSpaceInForm = FALSE
    
    If mam_LoadTempAccount(Form("AccountID")) Then
    
      Form("BillAble")                = MAM().TempAccount("BillAble").Value
      Form("UserName")                = MAM().TempAccount("UserName").Value
      Form("name_space")              = MAM().TempAccount("name_space").Value
      
      Set MAM().TempAccount.RowSet    = Nothing      
      SetUserNameAndNameSpaceInForm   = TRUE
      
    End If
END FUNCTION


%>


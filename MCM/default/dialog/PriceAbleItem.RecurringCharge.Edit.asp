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
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : Srinivasa Kolla
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
'Form.RouteTo        = FrameWork.GetDictionary("SERVICE_CHARGES_RECURRING_VIEW_EDIT_DIALOG") 

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog, objRecurringCharge
	Dim strTabs
	
	Form("POBASED") = Request.QueryString("POBASED")
  
	'Building Dynamic Body tag ,because to differentiate the Tabs  to display in Service Charges
	Service.Properties.Add "Body", "String",  256, FALSE, TRUE 
	Service.Properties("Body") = "<BODY>"
  Form.Modal = TRUE
	Set objMTProductCatalog = GetProductCatalogObject
  
    ' Find the PriceableItem and store it into the MDM COM Object
  Set objRecurringCharge = objMTProductCatalog.GetPriceableItem(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service
  Set COMObject.Instance = objRecurringCharge

	'============== FOR Temporary fix and i have to remove these two lines after database fixed.====
	'ComObject.Properties("PriceableItemType__ProductView").Required = FALSE
	'ComObject.Properties("PriceableItemType__ServiceDefinition").Required = FALSE
	'ComObject.Properties("Category").Required = FALSE
	'ComObject.Properties("Creation").Required = FALSE
	'ComObject.Properties("discountable").Required = FALSE
	'ComObject.Properties("glcode").Required = FALSE
	'ComObject.Properties("taxexempt").Required = FALSE
	'==============================================================================
        
    ' Create and define the Extended Properties Grid
    Form.Grids.Add "ExtendedProperties"
    Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
    Form.Grids("ExtendedProperties").Properties.ClearSelection
    Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
    Form.Grids("ExtendedProperties").ShowHeaders=False
    Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
    Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"

    'Can't edit cycle on instance
    If Form("POBASED") <> "TRUE" Then
      ProductCatalogBillingCycle.Form_Initialize Form
    Else
      ProductCatalogBillingCycle.ClearInsertTag Form
    End If
  
    ' Set some dynamic enum types...
    SetMSIXPropertyTypeToPriceableItemEnumType  COMObject.Properties("Kind")
    SetMSIXPropertyTypeToChargeInEnumType       COMObject.Properties("ChargeInAdvance")
    SetMSIXPropertyTypeToProrationLengthOnEnumType COMObject.Properties("FixedProrationLength")
  	''SetMSIXPropertyTypeToProrateOnEnumType      COMObject.Properties("ProrationType")   
      
'    mcm_IncludeCalendar ' Support calendar
    Form_Refresh EventArg
    Form_Initialize = TRUE
'   disable the cycle at instance level
   ProductCatalogHelper.CheckAttributesForUI COMObject, COMObject.Instance, Form("POBased")="True" , Empty

END FUNCTION


PUBLIC FUNCTION Form_Refresh(EventArg)
    Form_Refresh = ProductCatalogHelper.CheckAndInitializeForUDRC(TRUE)  ' -- UDRC Support --   
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Ok_Click = FALSE
    If Form("POBASED") <> "TRUE" Then
      	If(Not ProductCatalogBillingCycle.UpdateProperties())Then Exit Function
    End If
     On Error Resume Next

    dim sUsersCurrentLanguageCode
    sUsersCurrentLanguageCode = Framework.GetLanguageCodeForCurrentUser()

    'if Descriptions have been added/edited, build and save the multi language values
    ' First, we need to get the value set for the description text for the language the logged in user is using. This is the value we will save globally in COMObject.Instance
    dim desc
    for each desc in COMObject.Instance.DisplayDescriptions
      if desc.LanguageCode=sUsersCurrentLanguageCode then
        ' Set localized Description label
        ' We need to do this in a separate loop because the sUsersCurrentLanguageCode is not necessarely the first desc in the COMObject.Instance.DisplayDescriptions
        COMObject.Instance.Description = desc.Value
      end if
    next

    for each desc in COMObject.Instance.DisplayDescriptions
      if desc.LanguageCode=sUsersCurrentLanguageCode then
        'User specified this language
        COMObject.Instance.DisplayDescriptions.SetMapping desc.LanguageCode, desc.Value
      else
        if desc.Value = "" then
          'Set the default for other language as what the user specified plus the language code
          COMObject.Instance.DisplayDescriptions.SetMapping desc.LanguageCode, COMObject.Instance.Description & " {" & desc.LanguageCode & "}"
        else
          'Don't change the value if it was not empty and if it does not contain the language code inside {}'s
          if InStr(1, desc.Value, " {" & desc.LanguageCode & "}") > 0 then
            'We found {LanguageCode} in desc.Value, so set the default value for this language
            COMObject.Instance.DisplayDescriptions.SetMapping desc.LanguageCode, COMObject.Instance.Description & " {" & desc.LanguageCode & "}"
          else
            'We didn't find {LanguageCode} in desc.Value, so leave the value as is for this language and don't overwrite it with the default value
            COMObject.Instance.DisplayDescriptions.SetMapping desc.LanguageCode, desc.Value
          end if
        end if
      end if
    next
   On Error Resume Next
   COMObject.Instance.Save
    If(Err.Number)Then
    
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
	    OK_Click = TRUE
    End If    
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ChargeInAdvance_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Sets currency code after selection
PRIVATE FUNCTION ChargeInAdvance_Click(EventArg) ' As Boolean

    On Error Resume Next
    If(Err.Number)Then
        EventArg.Error.Save Err
		ChargeInAdvance_Click = FALSE
        Err.Clear
    Else
		' Set currency to be COMObject.Properties("ChargeInAdvance").value
		ChargeInAdvance_Click = TRUE
    End If    
END FUNCTION
%>

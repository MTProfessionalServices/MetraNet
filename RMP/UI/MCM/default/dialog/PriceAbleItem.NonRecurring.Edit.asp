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
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Dim objMTProductCatalog  
	Dim strTabs
	FORM("POID") = Request.QueryString("POID")
	Form("POBased") = UCase(Request.QueryString("POBased"))
	
	Service.Properties.Add "Body", "String",  256, FALSE, TRUE 
	Service.Properties("Body") = "<BODY>"
	Form.Modal = TRUE
	
    Set objMTProductCatalog = GetProductCatalogObject
    
	
	 mdm_GetDictionary().Add "CURRENT_RECURRING_ITEM_ID",Request.QueryString("ID")
	 
    ' Find the PriceableItem and store it into the MDM COM Object
    Set COMObject.Instance = objMTProductCatalog.GetPriceableItem(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service

    'COMObject.Instance.ChargeInAdvance
    ' Create and define the Extended Properties Grid
    Form.Grids.Add "ExtendedProperties"
    Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
    Form.Grids("ExtendedProperties").Properties.ClearSelection
    Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
	
    Form.Grids("ExtendedProperties").ShowHeaders=False
    Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
    Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"
	
   ' COMObject.Properties.Enabled              = FALSE ' Every control is grayed
   ' Form.Grids("ExtendedProperties").Enabled  = FALSE
   
    SetMSIXPropertyTypeToPriceableItemEnumType COMObject.Properties("Kind")
    SetMSIXPropertyTypeToRecurringChargeEnumType COMObject.Properties("NonRecurringChargeEvent")
    mcm_IncludeCalendar
    
	  Form_Initialize = TRUE
    ProductCatalogHelper.CheckAttributesForUI COMObject, COMObject.Instance, Form("POBased")="True" , Empty
	  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

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

    COMObject.Instance.Save
    If(Err.Number)Then
    
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        OK_Click = TRUE
    End If 
	
	'SetRouteToPage
	   
END FUNCTION
%>

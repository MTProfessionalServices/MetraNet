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
Form.ErrorHandler   = FALSE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  If (Not IsEmpty(Request.QueryString("ID"))) Then
    Form("ID") = CLng(Request.QueryString("ID"))
  End if
  
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

  GetProductOffering TRUE
  
  Dim objMTProductCatalog, objMTProductOffering
  'SECENG: Fixing problems with output encoding  
  Service.Properties.Add "disp_name", "String",  1024, FALSE, TRUE
  Service.Properties("disp_name") = SafeForHtml(COMObject.Instance.Name)
  
  Set objMTProductCatalog                         = GetProductCatalogObject
  'Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
  
  ' Save the id so we can use it on links in the page	
  mdm_GetDictionary().Add "CURRENT_PRODUCTOFFERING_ITEM_ID",Request.QueryString("ID")
  
  ' Find the ProductOffering and store it into the MDM COM Object, this will take care of the sub object like EffectiveDate  
  'response.write("PO Properties count [" & objMTProductOffering.Properties.count &"]<BR>")
  'response.write("MDM Properties count [" & COMObject.Properties.count &"]<BR>")
  'response.end
  
  COMObject.Properties.Add "EffDate_StartDate",  "String", 0,   FALSE, Empty    
  COMObject.Properties.Add "EffDate_EndDate",  "String", 0,   FALSE, Empty    
  COMObject.Properties.Add "AvDate_StartDate",  "String", 0,   FALSE, Empty    
  COMObject.Properties.Add "AvDate_EndDate",  "String", 0,   FALSE, Empty    
  COMObject.Properties.Add "CURRENCYCODE", "String",  256, FALSE, TRUE
  COMObject.Properties.Add "POPartitionId", "String",  256, FALSE, TRUE

  COMObject.Properties("SelfUnSubscribable").Caption        = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_SELFUNSUBSCRIBABLE")
  COMObject.Properties("SelfSubscribable").Caption          = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_SELFSUBSCRIBABLE")
  COMObject.Properties("EffDate_StartDate") = mdm_format(COMObject.Properties("EffectiveDate__StartDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
  COMObject.Properties("EffDate_EndDate") = mdm_format(COMObject.Properties("EffectiveDate__EndDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
  COMObject.Properties("AvDate_StartDate") = mdm_format(COMObject.Properties("AvailabilityDate__StartDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
  COMObject.Properties("AvDate_EndDate") = mdm_format(COMObject.Properties("AvailabilityDate__EndDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
  COMObject.Properties("CURRENCYCODE") = COMObject.Instance.GetCurrencyCode()
  COMObject.Properties("POPartitionId") = "100"//COMObject.Instance.GetCurrencyCode()


  ' Create and define the Extended Properties Grid
  Form.Grids.Add "ExtendedProperties", "Extended Properties"
  Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties

  Form.Grids("ExtendedProperties").Properties.ClearSelection
  Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
  Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
  
  Form.Grids("ExtendedProperties").ShowHeaders=False
  Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
  Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"
  COMObject.Properties.Enabled              = FALSE ' Every control is grayed
  Form.Grids.Enabled                        = FALSE ' All Grid are not enabled    

  ' Dynamically Add Tabs to template
  Dim strTabs  
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_GENERAL_TAB"), "/mcm/default/dialog/ProductOffering.ViewEdit.asp?ID=" & FORM("ID") & "&Tab=0"

  If Not(Session("isPartitionUser")) Then
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_PROPERTIES_TAB"), "/mcm/default/dialog/ProductOffering.Properties.asp?ID=" & FORM("ID")  & "&Tab=1"
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_INCLUDED_ITEMS_TAB"), "/mcm/default/dialog/ProductOffering.ViewEdit.Items.asp?ID=" & FORM("ID")  & "&Tab=2"
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_SUBSCRIPTION_RESTRICTIONS_TAB"), "/mcm/default/dialog/ProductOffering.ViewEdit.SubscriptionRestrictions.asp?ID=" & FORM("ID")  & "&Tab=3"
  End If    
  gObjMTTabs.Tab          = Clng(Request.QueryString("Tab"))		  
  strTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
  
  Form_Initialize = Form_Refresh(EventArg)

END FUNCTION


PRIVATE FUNCTION GetProductOffering(booFromInitializeEvent) ' As Boolean

    Dim objMTProductCatalog, objMTProductOffering
  
    Set objMTProductCatalog                         = GetProductCatalogObject
    Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
    Set COMObject.Instance(booFromInitializeEvent)  = objMTProductOffering
    GetProductOffering                              = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    
    GetProductOffering FALSE ' False called from refresh event...

    If COMObject.Instance.Hidden Then
      Response.redirect Form.RouteTo
    End If
    
    ' Check to see if this PO can be modified, if not display a warning  
    If Not CBool(COMObject.Instance.CanBeModified()) Then
      mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "TRUE"
    Else
      mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "FALSE"  
    End If


  'display warning at top and disable OK if pending...
  dim objApprovals, bApprovalsEnabled, bAllowMoreThanOnePendingChange, bProductOfferingHasPendingChange, tmpSessionContext
  bApprovalsEnabled = false
  bAllowMoreThanOnePendingChange = true
  bProductOfferingHasPendingChange = false

  set objApprovals = CreateObject("MetraTech.Approvals.SimplifiedClient")
  set tmpSessionContext = Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)
  set objApprovals.SessionContext = tmpSessionContext
  bApprovalsEnabled = objApprovals.ApprovalsEnabled("ProductOfferingUpdate")

  if bApprovalsEnabled then
    bProductOfferingHasPendingChange = objApprovals.HasPendingChange("ProductOfferingUpdate", COMObject.Instance.ID)
  end if

  if bProductOfferingHasPendingChange then
    dim strPendingChangeWarning
    strPendingChangeWarning =  FrameWork.GetDictionary("TEXT_APPROVALS_PRODUCTOFFERING_ALREADY_HAS_PENDING_CHANGE")
    strPendingChangeWarning = strPendingChangeWarning & "<br>Pending Change: ApprovalsEnabled [" & bApprovalsEnabled & "] Allow Multiple Pending Changes [" & bAllowMoreThanOnePendingChange & "]"
    mdm_GetDictionary().Add "HAS_BLOCKING_CHANGES", "TRUE"
  else
    mdm_GetDictionary().Add "HAS_BLOCKING_CHANGES", "FALSE"
  end if

    ' Check to see if this PO can be modified, if not display a warning  
    If len(Request("UpdateNav"))>0 Then
      mcmTriggerUpdateOfPONavigationPane
    End If

     
    Dim objMTProductCatalog, objMTPriceableItem
    

    ' See if we need to Add a recurring charge
    If len(Request("AddItem")) <> 0 Then
        'response.write("Adding recurring charge<BR>")
        dim intRecurringChargeId
        intRecurringChargeId = Clng(Request("AddItem"))
        
  
        Set objMTProductCatalog = GetProductCatalogObject
        Set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(intRecurringChargeId)
        
        COMObject.Instance.AddPriceableItem objMTPriceableItem
        COMObject.Instance.Save
        
        'COMObject.Instance.SetPriceListMapping Clng(Request("PARAMTABLEID")), Clng(Request("PICKERIDS"))
    End If
 
  
    If len(Request("PICKERIDS")) <> 0 Then
    
        'Dim objMTProductCatalog, objMTPriceableItem
  
        Set objMTProductCatalog = GetProductCatalogObject

        dim strPickerIDs, arrPickerIDs
        strPickerIDs = request("PICKERIDS")
        arrPickerIDs = Split(strPickerIDs, ",", -1, 1)
        
        ' "Picker returned [" & strPickerIDs & "]<BR>"
        
        dim intPriceableItemId
        dim i
        for i=0 to ubound(arrPickerIDs)
          intPriceableItemId = CLng(arrPickerIDs(i))
          'response.write("Adding PI [" & intPriceableItemId & "]<BR>")
          set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(intPriceableItemId)
          COMObject.Instance.AddPriceableItem objMTPriceableItem
        next
        
        COMObject.Instance.Save
        
    End If
    
    COMObject.Properties("EffDate_StartDate") = mdm_format(COMObject.Properties("EffectiveDate__StartDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
    COMObject.Properties("EffDate_EndDate") = mdm_format(COMObject.Properties("EffectiveDate__EndDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
    COMObject.Properties("AvDate_StartDate") = mdm_format(COMObject.Properties("AvailabilityDate__StartDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
    COMObject.Properties("AvDate_EndDate") = mdm_format(COMObject.Properties("AvailabilityDate__EndDate").Value, mdm_GetDictionary().GetValue("DATE_FORMAT"))
  
    Form_Refresh = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

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
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean

    Service.Properties.Enabled                = Not Service.Properties.Enabled 
    Form.Grids("ExtendedProperties").Enabled  = Service.Properties.Enabled
    Edit_Click = TRUE
END FUNCTION

PRIVATE FUNCTION RemovePriceableItem_Click(EventArg)

	If(Len(mdm_UIValue("mdmUserCustom")))Then
	
		If(IsNumeric(mdm_UIValue("mdmUserCustom")))Then
		
			On Error Resume Next
			COMObject.Instance.RemovePriceableItem(Clng(mdm_UIValue("mdmUserCustom")))
			If(Err.Number)Then
		    
		        EventArg.Error.Save Err
		        RemovePriceableItem_Click = FALSE
		        'Err.Clear  Do not clear the error so it can be returned to the MDM error manager
		    Else
          mcmTriggerUpdateOfPONavigationPane
		        RemovePriceableItem_Click = TRUE
		    End If
		End if
	End if						 
END FUNCTION
%>

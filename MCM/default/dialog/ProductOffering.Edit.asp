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

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE
Form.RouteTo        = FrameWork.GetDictionary("PRODUCT_OFFERING_LIST_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: Check if the time for the end date was set if not we set 23:59:59.
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
      Inherited("Form_Populate") ' First Let us call the inherited event
      
      mcm_CheckEndDate EventArg, "EffectiveDate__EndDate"
      mcm_CheckEndDate EventArg, "AvailabilityDate__EndDate"
      Form_Populate = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject    
  Dim objMTProductOffering
	
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

  ' Find the PriceableItem and store it into the MDM COM Object, this will take care of the sub object like EffectiveDate  
  Set objMTProductOffering  = objMTProductCatalog.GetProductOffering(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service
  Set COMObject.Instance    = objMTProductOffering 
  
  Form("GridId") = Request.QueryString("GridId")
  If Not IsValidObject(COMObject.Instance) Then
      Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("ID")
      Response.end
  End If

  ' Not used by MetraNet. Removing
  'COMObject.Properties("SelfUnSubscribable").Caption        = FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING_SelfUnSubscribable")
  'COMObject.Properties("SelfSubscribable").Caption          = FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING_SelfSubscribable")
  COMObject.Properties("EffectiveDate__StartDate").Caption   = FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING_EffectiveDate.StartDate")
  COMObject.Properties("EffectiveDate__EndDate").Caption     = FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING_EffectiveDate.EndDate")
  COMObject.Properties("AvailabilityDate__StartDate").Caption= FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING_AvailabilityDate.StartDate")
  COMObject.Properties("AvailabilityDate__EndDate").Caption  = FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING_AvailabilityDate.EndDate")

  ' If it is a Master PO, don't show effective and availability dates
  If objMTProductOffering.Properties.Item("POPartitionId") = 0 Then
    mdm_GetDictionary().Add "IS_MASTER_PO", "TRUE"
  Else
    mdm_GetDictionary().Add "IS_MASTER_PO", "FALSE"
  End If

  ' Create and define the Extended Properties Grid
  Form.Grids.Add "ExtendedProperties", "Extended Properties"
  Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties

  Form.Grids("ExtendedProperties").Properties.ClearSelection
  Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
  Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
  'Form.Grids("ExtendedProperties").Properties("Required").Selected   = 3
  
  Form.Grids("ExtendedProperties").ShowHeaders=False
  Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
  Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"

  COMObject.Properties("Name").Enabled = FALSE
  COMObject.Properties.Enabled         = TRUE ' Every control is enabled
  Form.Grids.Enabled                   = TRUE ' All Grid are enabled

  mcm_IncludeCalendar
  'SECENG: Fixing problems with output encoding  
  Service.Properties.Add "po_edit_name", "String",  1024, FALSE, TRUE
  Service.Properties("po_edit_name") = SafeForHtml(COMObject.Instance.Name)
  
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
    bAllowMoreThanOnePendingChange = objApprovals.ApprovalAllowsMoreThanOnePendingChange("ProductOfferingUpdate")
    if NOT bAllowMoreThanOnePendingChange then
      bProductOfferingHasPendingChange = objApprovals.HasPendingChange("ProductOfferingUpdate", COMObject.Instance.ID)
    end if
  end if

  if bProductOfferingHasPendingChange then
    dim strPendingChangeWarning
    strPendingChangeWarning =  FrameWork.GetDictionary("TEXT_APPROVALS_PRODUCTOFFERING_ALREADY_HAS_PENDING_CHANGE")
    strPendingChangeWarning = strPendingChangeWarning & "<br>Pending Change: ApprovalsEnabled [" & bApprovalsEnabled & "] Allow Multiple Pending Changes [" & bAllowMoreThanOnePendingChange & "]"
    mdm_GetDictionary().Add "HAS_BLOCKING_CHANGES", "TRUE"
    mdm_GetDictionary().Add "HAS_NO_BLOCKING_CHANGES", "FALSE"  
	COMObject.Properties.Enabled = FALSE
	Form.Grids.Enabled = FALSE
  Else
    mdm_GetDictionary().Add "HAS_BLOCKING_CHANGES", "FALSE"
    mdm_GetDictionary().Add "HAS_NO_BLOCKING_CHANGES", "TRUE"  
    'ESR-5994
    'Cannot edit extended property if Approvals applied  
    COMObject.Properties.Enabled = TRUE
	Form.Grids.Enabled = TRUE
  end if

  If Session("isPartitionUser") Then
    COMObject.Properties("POPartitionId").Enabled = FALSE
  End If

  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  On Error Resume Next

  mcmTriggerUpdateOfPONavigationPane   
  
  ' An empty start date means no date, not infinitely in the past (CR8205)
  If IsEmpty(COMObject.Properties("EffectiveDate__StartDate")) Then
    COMObject.Instance.EffectiveDate.StartDateType = PCDATE_TYPE_NO_DATE
  End If
  If IsEmpty(COMObject.Properties("AvailabilityDate__StartDate")) Then 
    COMObject.Instance.AvailabilityDate.StartDateType = PCDATE_TYPE_NO_DATE
  End If
  'If IsEmpty(COMObject.Properties("EffectiveDate__EndDate")) Then
  '  COMObject.Instance.EffectiveDate.EndDateType = PCDATE_TYPE_NO_DATE
  'End If
  'If IsEmpty(COMObject.Properties("AvailabilityDate__EndDate")) Then 
  '  COMObject.Instance.AvailabilityDate.EndDateType = PCDATE_TYPE_NO_DATE
  'End If

  If COMObject.Instance.DisplayName = "" then
   COMObject.Instance.DisplayName = "Dummy"
  end if
  
  '//Approvals
  dim objApprovals, bApprovalsEnabled, bAllowMoreThanOnePendingChange, bProductOfferingHasPendingChange, tmpSessionContext
  bApprovalsEnabled = false
  bAllowMoreThanOnePendingChange = true
  bProductOfferingHasPendingChange = false

  set objApprovals = CreateObject("MetraTech.Approvals.SimplifiedClient")
  set tmpSessionContext = Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)
  set objApprovals.SessionContext = tmpSessionContext
  bApprovalsEnabled = objApprovals.ApprovalsEnabled("ProductOfferingUpdate")

  If Session("isPartitionUser") Then
    COMObject.Instance.POPartitionId = COMObject.Properties("POPartitionId").DefaultValue
  End If
  
  Dim idChange, errorsSubmit
  If bApprovalsEnabled Then
    Dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject    
    Dim objChangeDetailsHelper
    Set objChangeDetailsHelper = CreateObject("MetraTech.Approvals.ChangeDetailsHelper")
    Dim objDetails
    Set objDetails = objApprovals.Convert(COMObject.Instance)
    objChangeDetailsHelper("productOffering") = objDetails
    objChangeDetailsHelper("productOffering.OLD") = objApprovals.Convert(objMTProductCatalog.GetProductOffering(COMObject.Instance.ID))
    idChange = objApprovals.SubmitChangeForApproval("ProductOfferingUpdate", COMObject.Instance.ID, COMObject.Instance.Name, "", objChangeDetailsHelper.ToBuffer, errorsSubmit)
  Else
    COMObject.Instance.Save
  End If

  IF (Err.Number) Then
    EventArg.Error.Save Err
    OK_Click = FALSE
    Err.Clear
  Else       
    If (Len(Form("GridId")) > 0) then
      Form.JavaScriptInitialize = "window.parent.close();"
    End If
    OK_Click = TRUE
  End If    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CANCEL_Click
PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean
  If (Len(Form("GridId")) > 0) Then
    Form.JavaScriptInitialize = "window.parent.close();"
  End If    
  CANCEL_Click = TRUE
END FUNCTION
%>

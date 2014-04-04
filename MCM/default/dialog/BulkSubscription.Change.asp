<% 
' ---------------------------------------------------------------------------------------------------------
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
' ---------------------------------------------------------------------------------------------------------
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres, K.Boucher
' VERSION	    : 2.0
'
' ---------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("ADVANCED_MENU_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    
    Service.Properties.Add "PONameSource",         MSIXDEF_TYPE_STRING,   256, TRUE,  Empty
    Service.Properties.Add "PONameDestination",    MSIXDEF_TYPE_STRING,   256, TRUE,  Empty
    Service.Properties.Add "POIDSource",           MSIXDEF_TYPE_INT32,      0, FALSE, Empty
    Service.Properties.Add "POIDDEstination",      MSIXDEF_TYPE_INT32,      0, FALSE, Empty
    Service.Properties.Add "EffectiveDate",        MSIXDEF_TYPE_TIMESTAMP,  0, TRUE,  Empty
    Service.Properties.Add "BillingCycleRelative", MSIXDEF_TYPE_BOOLEAN,    0, FALSE, Empty
    
    'Service.Properties("PONameSource").Enabled      = FALSE
    'Service.Properties("PONameDestination").Enabled = FALSE
    
    Service.Properties("PONameSource").Caption      = FrameWork.GetDictionary("TEXT_BULK_SUBSCRIPTION_PO_SOURCE")
    Service.Properties("PONameDestination").Caption = FrameWork.GetDictionary("TEXT_BULK_SUBSCRIPTION_PO_DESTINATION")
    Service.Properties("EffectiveDate").Caption     = FrameWork.GetDictionary("TEXT_BULK_SUBSCRIPTION_EFFECTIVE_DATE")
    Service.Properties("BillingCycleRelative").Caption     = FrameWork.GetDictionary("TEXT_BULK_SUBSCRIPTION_EFFECTIVE_DATE_BILLING_CYCLE_RELATIVE")
    
    mcm_IncludeCalendar
    Form_Initialize = TRUE
END FUNCTION


PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    If (UCase(Request.QueryString("POMode"))="SOURCE") Then        
        Service.Properties("PONameSource").Value = Request.QueryString("OptionalValues")
        Service.Properties("POIDSource").Value = Request.QueryString("IDs")            
    ElseIf (UCase(Request.QueryString("POMode"))="DESTINATION") Then    
        Service.Properties("PONameDestination").Value = Request.QueryString("OptionalValues")
        Service.Properties("POIDDEstination").Value = Request.QueryString("IDs")
    End if
        
    If(Service.Properties("POIDDEstination").Value = Service.Properties("POIDSource").Value)Then
'    
 '       Service.Properties("PONameDestination").Value = Empty
  '      Service.Properties("POIDDEstination").Value   = Empty
    End if
    
    Form_Refresh = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  
  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject

  Dim prodOff
  Set prodOff = objMTProductCatalog.GetProductOffering(Clng(Service.Properties("POIDSource").Value))

  Dim destPO
  Set destPO = objMTProductCatalog.GetProductOffering(CLng(Service.Properties("POIDDestination").Value))

  If prodOff.POPartitionId <> destPO.POPartitionId Then
    EventArg.Error.Description = FrameWork.Dictionary().Item("MCM_ERROR_PARTITION_NOT_EQUAL").Value
    EventArg.Error.Number = 1
    OK_Click = FALSE
    Exit Function
  End If

  'Determine if destination PO has any UDRCS... we won't allow the bulk update
  dim objPriceableItems
  set objPriceableItems = destPO.GetPriceableItems
  dim FoundUDRCs
  FoundUDRCs = FALSE
    
  dim objPI
  for each objPI in objPriceableItems
    If ProductCatalogHelper.IsTypeUDRC(objPI.PriceAbleItemType) then
      FoundUDRCs = TRUE
      Exit Function
    End If
  next
    
  If FoundUDRCs Then
    EventArg.Error.Description  = FrameWork.Dictionary().Item("MCM_ERROR_1009").Value
    EventArg.Error.Number       = 1009+USER_ERROR_MASK
    OK_Click = FALSE
    Exit Function
  End If

  On Error Resume Next
  objMTProductCatalog.BulkSubscriptionChange CLng(Service.Properties("POIDSource").Value), _
		CLng(Service.Properties("POIDDestination").Value), _
		Service.Properties("EffectiveDate").Value, _
		Service.Properties("BillingCycleRelative").Value
    
  If (Err.Number) Then 
    EventArg.Error.Save Err
    OK_Click = FALSE
    Err.Clear
  Else
    OK_Click = TRUE        
  End If
END FUNCTION
%>

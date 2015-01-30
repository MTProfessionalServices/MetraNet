<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2011 by MetraTech Corporation
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
' AUTHOR	    : Kevin A. Boucher  
' VERSION	    : 6.7
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
  
  Set objMTProductCatalog                         = GetProductCatalogObject
  Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
  
  ' Save the id so we can use it on links in the page	
  mdm_GetDictionary().Add "CURRENT_PRODUCTOFFERING_ITEM_ID",Request.QueryString("ID")

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

    ' Check to see if this PO can be modified, if not display a warning  
    If len(Request("UpdateNav"))>0 Then
      mcmTriggerUpdateOfPONavigationPane
    End If

    Form_Refresh = TRUE
    
END FUNCTION


%>

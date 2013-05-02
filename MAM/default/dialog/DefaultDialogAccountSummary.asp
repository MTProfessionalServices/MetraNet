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
' NAME        :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit 

%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
' Mandatory
Form.ServiceMsixdefFileName 	= mam_GetAccountCreationMsixdefFileName()
Form.RouteTo			            = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog  
  Dim MTAccountReference ' As MTAccountReference
  Dim acctID             ' As Long
  
  Set objMTProductCatalog = GetProductCatalogObject
  acctID =  mam_GetSubscriberAccountID()
 
  ' Get account reference
  Set MTAccountReference = objMTProductCatalog.GetAccount(CLng(acctID))

  ' Get Subscriber properties
  MAM().Subscriber.CopyTo Service.Properties

  ' Set Extra Account Details
  ProductView.Properties.Add "AccountName", "String", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  ProductView.Properties("AccountName").Value = mam_GetFieldIDFromAccountID(mam_GetSubscriberAccountID())
  ProductView.Properties("AccountName").Caption = mam_GetDictionary("TEXT_ACCOUNT")

  ProductView.Properties.Add "Payer", "String", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  ProductView.Properties("Payer").Value = mam_GetFieldIDFromAccountID(ProductView.Properties("PayerID").value)
  ProductView.Properties("Payer").Caption = mam_GetDictionary("TEXT_PAYER")
    
  ProductView.Properties.Add "Ancestor", "String", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  ProductView.Properties("Ancestor").Value = mam_GetFieldIDFromAccountID(ProductView.Properties("AncestorAccountID").value)
  ProductView.Properties("Ancestor").Caption = mam_GetDictionary("TEXT_ANCESTOR")
  
  mam_Account_SetDynamicEnumType
  
  ProductView.RenderLocalizationMode = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process
  
  mdm_GetDictionary.Add "INPUT_TAG",IIF(mdm_UIValueDefault("ShowBackSelectionButton","FALSE")="TRUE","INPUT","INPUT_INVISIBLE")
  
  ' Populate Default Account Pricelist
  PopulateDefaultAccountPricelist

  If UCase(session("SubscriberYAAC").AccountType) = "INDEPENDENTACCOUNT" Then
		mdm_GetDictionary.Add "bIndependentAccount", true 
	Else
		mdm_GetDictionary.Add "bIndependentAccount", false
	End If
      
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : BackToSelection_Click
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean

    Form.RouteTo			            = mam_GetDictionary("SUBSCRIBER_FIND_BROWSER")
    CANCEL_Click                  = TRUE
END FUNCTION

PRIVATE FUNCTION RefreshPage_Click(EventArg) ' As Boolean

    Call response.redirect( mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & mam_GetSubscriberAccountID() & "&ForceLoad=TRUE")

    RefreshPage_Click = TRUE
END FUNCTION
%>

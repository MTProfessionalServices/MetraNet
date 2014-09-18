<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998,2000,2001 by MetraTech Corporation
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
'  $Date$
'  $Author$
'  $Revision$
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
Form.Version        = MDM_VERSION     ' Set the dialog version
Form.RouteTo        = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim objYAAC
 ' Dim strPath
 ' Dim arrPath
 ' Dim p, i

  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  If Request.QueryString("MODE") = "SYSTEM_USER" Then
    FrameWork.Dictionary.Add "QUICK_INFO_MODE_SYSTEM_USER", TRUE  
  Else
    FrameWork.Dictionary.Add "QUICK_INFO_MODE_SYSTEM_USER", FALSE    
  END IF                  
                  
   ' Add dialog properties
  Service.Properties.Add "AccountName", "String", 255, TRUE, ""                   
  Service.Properties.Add "LoginName", "String", 255, TRUE, ""   
  Service.Properties.Add "Namespace", "String", 255, TRUE, ""   
  Service.Properties.Add "AccountID", "String", 255, TRUE, ""   
  Service.Properties.Add "AccountType", "String", 0, TRUE, Empty
  'Service.Properties.Add "HierarchyPath", "String", 255, TRUE, ""   
  Service.Properties.Add "CorporateAccountID", "String", 255, TRUE, ""   
  Service.Properties.Add "IsFolder", "String", 255, TRUE, ""   
  Service.Properties.Add "State", "String", 0, TRUE, Empty   
  Service.Properties.Add "Currency", "String", 0, TRUE, Empty   

  Service.Properties("State").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountStatus"	
'  Service.Properties("AccountType").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountType"	                  
                  
  ' Localize captions 
  Service.Properties("AccountName").Caption = mam_GetDictionary("TEXT_ACCOUNT_NAME")
  Service.Properties("LoginName").Caption = mam_GetDictionary("TEXT_LOGIN_NAME")
  Service.Properties("Namespace").Caption = mam_GetDictionary("TEXT_NAMESPACE")
  Service.Properties("AccountID").Caption = mam_GetDictionary("TEXT_ACCOUNT")
  Service.Properties("AccountType").Caption = mam_GetDictionary("TEXT_ACCOUNT_TYPE")
  'Service.Properties("HierarchyPath").Caption = "Hierarchy Path"
  Service.Properties("CorporateAccountID").Caption = mam_GetDictionary("TEXT_KEYTERM_CORPORATE_ACCOUNT")
  Service.Properties("IsFolder").Caption = mam_GetDictionary("TEXT_IS_FOLDER")
  Service.Properties("State").Caption = mam_GetDictionary("TEXT_ACCOUNT_STATE")
  Service.Properties("Currency").Caption = mam_GetDictionary("TEXT_CURRENCY")

  ' Get Values from YAAC
  If CLng(Request.QueryString("ID")) <> MAM_HIERARCHY_ROOT_ACCOUNT_ID Then
    Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Request.QueryString("ID")), mam_ConvertToSysDate(mam_GetHierarchyTime()))

    Service.Properties("AccountName").Value = objYAAC.AccountName
    Service.Properties("LoginName").Value = objYAAC.LoginName
    Service.Properties("Namespace").Value = objYAAC.Namespace
    Service.Properties("AccountID").Value = mam_GetFieldIDFromAccountID(objYAAC.AccountID)
    Service.Properties("AccountType").Value = objYAAC.AccountType
    Service.Properties("CorporateAccountID").Value = mam_GetFieldIDFromAccountID(objYAAC.CorporateAccountID)
    Service.Properties("IsFolder").Value = objYAAC.IsFolder
    Service.Properties("State").Value = objYAAC.GetAccountStateMgr().GetStateObject().Name
    
    ' Jump through some hoops to get currency for acocunt
    Service.Properties("Currency").Value = mam_GetCurrencyForAccountID(objYAAC.AccountID)
    
   ' arrPath = Split(objYAAC.HierarchyPath, "/")
   ' i = 0
   ' for each p in arrPath
   '   if i > 0 then
   '     strPath = strPath & "/" & mam_GetFieldIDFromAccountID(p)
   '   end if
   '   i = i + 1  
   ' next
    
   ' Service.Properties("HierarchyPath").Value = strPath
        
  End IF  	
  mdm_GetDictionary.Add "TEXT_ID", Request.QueryString("ID")
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
		      
	Form_Initialize                   = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Cancel_Click = TRUE
END FUNCTION

%>


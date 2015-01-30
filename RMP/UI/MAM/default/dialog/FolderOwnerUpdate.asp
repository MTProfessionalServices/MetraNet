<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
    Dim objYAAC
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  If Session("FOLDER_OWNER_MODE") = "SYSTEM_USER" Then
    Set Session("ActiveYAAC") = mam_GetSystemuser()
    FrameWork.Dictionary.Add "SYSTEM_USER_MODE", TRUE
  Else
    Set Session("ActiveYAAC") = SubscriberYAAC()
    FrameWork.Dictionary.Add "SYSTEM_USER_MODE", FALSE
  End IF
  
  
  ' Add dialog properties
  Service.Properties.Add "FolderOwner", "String", 256, TRUE,  ""
  Service.Properties("FolderOwner").Value = mam_GetFieldIDFromAccountID(Session("ActiveYAAC").CurrentFolderOwner)
  
  ' Set Captions 
  Service.Properties("FolderOwner").caption = mam_GetDictionary("TEXT_FOLDER_OWNER")
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    Dim objYAAC
    Dim AccountID
    On Error Resume Next
    If FrameWork.DecodeFieldID(Service.Properties("FolderOwner").value, AccountID) Then
    
    ' first, remove original folder owner if there is one
    If Not Session("ActiveYAAC").CurrentFolderOwner = -1 Then
        Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Session("ActiveYAAC").CurrentFolderOwner))
        ' make sure yaac didn't give us an error
        If(CBool(Err.Number <> 0)) then
            EventArg.Error.Save Err
            Form_DisplayErrorMessage EventArg
            Response.End
            exit function
        End If
        
        Call objYAAC.RemovedOwnedFolderById(CLng(Session("ActiveYAAC").AccountID))
    End If

    Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(AccountID))
    ' make sure yaac didn't give us an error
    If(CBool(Err.Number <> 0)) then
        EventArg.Error.Save Err
        Form_DisplayErrorMessage EventArg
        Response.End
        exit function
    End If
    
    Call objYAAC.AddOwnedFolderByID(CLng(Session("ActiveYAAC").AccountID))
    
    If Session("FOLDER_OWNER_MODE") = "SYSTEM_USER" Then
        Session("ActiveYAAC").Refresh(mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))
    Else
        Session("ActiveYAAC").Refresh(mam_ConvertToSysDate(mam_GetHierarchyTime()))
    End If
    Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_FOLDER_OWNER_UPDATE"), mam_GetDictionary("TEXT_FOLDER_OWNER_UPDATED_SUCCESS"), mam_GetDictionary("WELCOME_DIALOG"))
    Else
        EventArg.Error.number = 1037
        EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1037")
        Form_DisplayErrorMessage EventArg
        Response.End
    End If
    
    If (CBool(Err.Number = 0)) Then
        On Error Goto 0
        OK_Click = TRUE
    Else
        EventArg.Error.Save Err
        Form_DisplayErrorMessage EventArg
        Response.End
    End If

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Cancel_Click
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		    : Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
  Cancel_Click = TRUE
END FUNCTION

%>


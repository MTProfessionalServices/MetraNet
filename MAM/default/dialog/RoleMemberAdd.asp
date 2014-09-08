<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: RoleMemberAdd.asp$
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
'  $Date: 9/18/2002 5:02:18 PM$
'  $Author: Noah Cushing$
'  $Revision: 11$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/DropAccountsLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version       = MDM_VERSION     ' Set the dialog version - we are version 2.0.

If Session("Role") Is Nothing Then
  Form.RouteTo       = "RoleMemberSetup.asp?id=" & Session("Role").id
Else
 Form.RouteTo       = "RoleMemberSetup.asp?id=" & Session("Role").id & "&RoleName=" & server.URLEncode(Session("Role").name)
End If

Session("BATCH_ERROR_RETURN_PAGE") = Form.RouteTo

If Not IsEmpty(Session(mdm_EVENT_ARG_ERROR)) Then 
 If Not Session(mdm_EVENT_ARG_ERROR) Is Nothing Then
  If Session(mdm_EVENT_ARG_ERROR).Error.Number = -492896228 Then
    mdm_Main
  Else
	'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
	'Added HTML encoding
    Response.Write(SafeForHtml(Session(mdm_EVENT_ARG_ERROR).Error.Description))
    Response.End
  End If
 Else
   mdm_Main ' invoke the mdm framework
 End If
Else
  mdm_Main
End If


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  dim bAccount 
  bAccount = true 
  
 
    Form("RoleName") = request.QueryString("RoleName")  
    FrameWork.Dictionary().Add "RoleMemberAdd.Asp_ROLENAME", SafeForHtml(Form("RoleName"))

    ' Find out if role is only csr_assignable

    If(Form("RoleName") = "") Then
      Form("Role") =FrameWork.Policy.GetRoleByName(FrameWork.SessionContext, Session("Role").Name)   
    Else    
     Form("Role") = FrameWork.Policy.GetRoleByName(FrameWork.SessionContext, Form("RoleName"))    
   End If


     If (Form("Role").CSRAssignable and (not Form("Role").SubscriberAssignable)) Then
       bAccount = false
     End If
  
  dim jsString
  If bAccount Then
    jsString = "<script language=""Javascript"">parent.showHierarchy();</script>"
  Else
    jsString = "<script language=""Javascript"">parent.showUserHierarchy();</script>"
  End If
  FrameWork.Dictionary().Add "SHOW_HIERARCHY_JAVASCRIPT", jsString
   
  
  ' Initialize Drop Grid -  bFolderOptions, bFoldersOnly
  InitDropGrid TRUE, FALSE
 
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  ' Include Calendar javascript    
  mam_IncludeCalendar
  
	Form_Initialize                   = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

  On Error Resume Next

  Form.Grids("DropGrid").Rowset.MoveFirst

  ' Make sure we have at least one account to act on
  If Form.Grids("DropGrid").Rowset.recordCount = 0 Then
      EventArg.Error.number = 1033
      EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1033")
      OK_Click = FALSE       
      Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
      Response.Redirect mdm_GetCurrentFullURL()             
      Exit Function  
  End IF
      
  If Form.Grids("DropGrid").Rowset.recordCount = 1 Then

      Form("AuthAccount") = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext, CLng(Form.Grids("DropGrid").Properties("id").value), mam_ConvertToSysDate(mam_GetHierarchyTime()))
      If err.number <> 0 then
        Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
      End If
        
	    Form("AccountPolicy") = Form("AuthAccount").GetActivePolicy(FrameWork.SessionContext)
    	Form("AccountPolicy").AddRole(Session("Role"))
      If Err.Number <> 0 Then
        EventArg.Error.Save Err
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()            
        Exit Function
      End If    	

  		Form("AuthAccount").Save
      If Err.Number <> 0 Then
        EventArg.Error.Save Err
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()            
        Exit Function
      End If    
      
  Else
      ' Batch Update  
      Set Session("LAST_BATCH_ERRORS") = Session("Role").AddMemberBatch(FrameWork.SessionContext, GetAccountIDCollection(), nothing)

      If Err.Number <> 0 Then
        EventArg.Error.Save Err
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()            
        Exit Function
      End If
              
      ' Get Batch Errors  
      If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
        EventArg.Error.number = 2015
        EventArg.Error.description = mam_GetDictionary("MAM_ERROR_2015")
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg    
        dim redirectURL 
        redirectURL = mdm_GetCurrentFullURL() 
        redirectURL = redirectURL & "&RoleName=" & server.URLEncode(Form("RoleName")) 
        Response.Redirect redirectURL
        Exit Function
      End If

  End If

  'if there are no errors then return TRUE
  OK_Click = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Form.RouteTo = "RoleMemberSetup.asp?id=" & Session("Role").id & "&RoleName=" & server.URLEncode(Session("Role").name)

  Cancel_Click = TRUE
END FUNCTION

%>


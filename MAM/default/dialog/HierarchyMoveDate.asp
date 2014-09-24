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
<!-- METADATA type="TypeLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/DropAccountsLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.

Form.RouteTo        = mam_GetDictionary("WELCOME_DIALOG")

Session("BATCH_ERROR_RETURN_PAGE") = "HierarchyMoveDate.asp"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim arr
  Dim i
  Dim objYAAC
  Dim id
    
	Service.Clear 	' Set all the property of the service to empty. 
  ' The Product view if allocated is cleared too.
  Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

  ' Make sure to clear the service properties
	Do while Service.Properties.count
	  Service.Properties.Remove(1)
	Loop

  ' Initialize Drop Grid -  bFolderOptions, bFoldersOnly
  InitDropGrid TRUE, FALSE
  
  ' If we are doing an individual move from a menu option
  If(UCase(Request.QueryString("INDIVIDUAL")) = "TRUE") Then
    Session("DROP_ACTION") = "SINGLE"
    Session("CHILD") = CLng(mam_GetSubscriberAccountID())
    Service.Properties("Child").Value = Session("CHILD")
    Session("PARENT") = ""
    FrameWork.Dictionary.Add "EDIT_PARENT", TRUE
  Else
    Session("CHILD") = ""
    FrameWork.Dictionary.Add "EDIT_PARENT", TRUE  
  End If  
  
  mdm_GetDictionary.Add "ShowCorporateWarning", false
                
  Call DropGrid_Click(null)
                    
  ' Add dialog properties
  Service.Properties.Add "StartDate", "String", 0, FALSE, Empty    
  Service.Properties.Add "Parent", "string", 0, FALSE, Empty

  If(Session("PARENT") = "1") Then
    Form("CorporateAccountID") = "1"
    Service.Properties("Parent").value = mam_GetDictionary("TEXT_CORPORATE_ACCOUNT") & " (1)"
  ElseIf(Session("PARENT") = "") Then
    Service.Properties("Parent").value = "" 
  Else
    Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Session("PARENT")), mam_ConvertToSysDate(mam_GetHierarchyTime()))
    Form("CorporateAccountID") = objYAAC.CorporateAccountID          
    Service.Properties("Parent").value = objYAAC.AccountName & " (" & CLng(Session("PARENT")) & ")"
  End If

  Service.Properties("StartDate") = mdm_Format(mam_GetHierarchyDate(),mam_GetDictionary("DATE_FORMAT"))
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
    
  ' Localize captions  
  Service.Properties("StartDate").Caption = mam_GetDictionary("TEXT_MOVE_DATE")
  Service.Properties("Parent").Caption = mam_GetDictionary("TEXT_NEW_PARENT")
	      
  ' Include Calendar javascript    
  mam_IncludeCalendar
  
  ' Make sure we are in the same corporate if business rule is enabled
  Dim pc
  Set pc = GetProductCatalogObject()  
  If pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) and mam_GetDictionary("EDIT_PARENT") = FALSE Then
    For each id in GetAccountIDCollection()
      Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(id), mam_ConvertToSysDate(mam_GetHierarchyTime()))
      If objYAAC.CorporateAccountID <> Form("CorporateAccountID") Then
        mdm_GetDictionary.Add "ShowCorporateWarning", true
    	  Form_Initialize = TRUE      
        Exit Function
      End If
    Next
  End IF

	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    Dim strDropAction           'Drop action to take
    Dim arrChildren             '
    Dim strParent               'Where to move items
    Dim strEntity               'Used to iterate through entities
    Dim objHC
    Dim i
    Dim col
    Dim objYAAC
    Dim nameSpace
    Dim newCol
    Dim id
    Dim ENUM_SINGLE, DIRECT_DESCENDENTS, RECURISVE
    ENUM_SINGLE = 0
    DIRECT_DESCENDENTS = 1
    RECURISVE = 2

    On Error Resume Next
    Dim startDate
    startDate = CDate(mam_ConvertToSysDate(Service.Properties("StartDate")))
    If FrameWork.DecodeFieldID(Service.Properties("Parent").value, strParent) Then
        If strParent <> "1" then
          ' Make sure we have a valid Parent account
          Set objYAAC = FrameWork.AccountCatalog.GetAccount(strParent, startDate)           
          
          If Err.Number <> 0 Then
              EventArg.Error.number = 1049
              EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1049")
              OK_Click = FALSE       
              Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
              Response.Redirect mdm_GetCurrentFullURL()             
              Exit Function  
          End If   

          nameSpace = objYAAC.Namespace
        Else 
          nameSpace = "mt"
        End If

        ' Make sure we have at least one account to act on
        If Form.Grids("DropGrid").Rowset.recordCount = 0 Then
            EventArg.Error.number = 1033
            EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1033")
            OK_Click = FALSE       
            Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
            Response.Redirect mdm_GetCurrentFullURL()             
            Exit Function  
        End IF
        
        set col = GetAccountIDCollection()
      	Set newCol = Server.CreateObject(MT_COLLECTION_PROG_ID)

        for each id in col
           Set objYAAC = FrameWork.AccountCatalog.GetAccount(id, mam_ConvertToSysDate(mam_GetHierarchyTime()))
           If (objYAAC.Namespace <> nameSpace) Then 
             EventArg.Error.number = 1053
             EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1053")
             OK_Click = FALSE       
             Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
             Response.Redirect mdm_GetCurrentFullURL()             
             Exit Function
           End If
           Call objYAAC.GetDescendents(newCol, mam_GetHierarchyTime(), RECURISVE, CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS"))) 
        next
    
        If col.count = 1 Then
          Call objYAAC.GetAncestorMgr().MoveAccount(strParent, CLng(col.item(1)), startDate)
        Else
          Set Session("LAST_BATCH_ERRORS") = objYAAC.GetAncestorMgr().MoveAccountBatch(strParent, col, nothing, startDate)
          
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
            Dim errorMessage 
            errorMessage = Session("LAST_BATCH_ERRORS").PopulatedRecordSet.Fields("description").Value
            If ((errorMessage = Empty) Or (errorMessage = "")) Then
              EventArg.Error.description = mam_GetDictionary("MAM_ERROR_2015")
            Else
              EventArg.Error.description = errorMessage
            End If
            OK_Click = FALSE       
            Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
            Response.Redirect mdm_GetCurrentFullURL()             
            Exit Function
          End If
                
        End If
    
        ' Note that UserName and Name_Space are passed empty we need them only when we do an add account
    	  CONST ASP_CALL_TEMPLATE = "[ASP]?MDMReload=TRUE&Mode=Move&AccountID=[ACCOUNTID]&AncestorAccountID=[ANCESTORACCOUNTID]&MoveStartDate=[MOVESTARTDATE]"
        Set Session("BATCH_TEMPLATE_COLLECTION") = newCol
        
        'Route to the apply template prompt page
        Form.RouteTo = PreProcess(ASP_CALL_TEMPLATE, Array("ASP", mam_GetDictionary("ACCOUNT_TEMPLATE_APPLY_PROMPT"), "ACCOUNTID", CLng(col.item(1)), "ANCESTORACCOUNTID"	, strParent,"MOVESTARTDATE", startDate))
		Else
            EventArg.Error.number = 1049
            EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1049")
            OK_Click = FALSE       
            Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
            Response.Redirect mdm_GetCurrentFullURL()             
            Exit Function  
 		End If
    		
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        Form.Grids("DropGrid").Rowset.Clear
        OK_Click = TRUE		
        Response.Redirect Form.RouteTo 		
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()   
    End If
END FUNCTION

%>


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

Session("BATCH_ERROR_RETURN_PAGE") = mam_GetDictionary("SYSTEM_USER_HIERARCHY_MOVE_DATE_DIALOG")

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

  ' Make sure to clear the service properties
	Do while Service.Properties.count
	  Service.Properties.Remove(1)
	Loop
  
  ' If we are doing an individual move from a menu option
  If(UCase(Request.QueryString("INDIVIDUAL")) = "TRUE") Then
    Session("DROP_ACTION") = "SINGLE"
    Session("CHILD") = CLng(mam_GetSubscriberAccountID())
    Session("PARENT") = ""
    FrameWork.Dictionary.Add "EDIT_PARENT", TRUE
  Else
    FrameWork.Dictionary.Add "EDIT_PARENT", FALSE  
  End If  
  
  mdm_GetDictionary.Add "ShowCorporateWarning", false
        
  Call DropGrid()
                    
  ' Add dialog properties
  Service.Properties.Add "StartDate", "TIMESTAMP", 0, FALSE, Empty    
  Service.Properties.Add "Parent", "string", 0, FALSE, Empty

  If(Session("PARENT") = "1") Then
    Form("CorporateAccountID") = "1"
    Service.Properties("Parent").value = mam_GetDictionary("TEXT_CORPORATE_ACCOUNT") & " (1)"
  ElseIf(Session("PARENT") = "") Then
    Service.Properties("Parent").value = "" 
  Else
    Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Session("PARENT")), mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))
    Form("CorporateAccountID") = objYAAC.CorporateAccountID          
    Service.Properties("Parent").value = objYAAC.AccountName & " (" & CLng(Session("PARENT")) & ")"
  End If

  Service.Properties("StartDate") = CDate(mdm_Format(Session("SYSTEM_USER_HIERARCHY_HELPER").SnapShot,mam_GetDictionary("DATE_FORMAT")))
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
    
  ' Localize captions  
  Service.Properties("StartDate").Caption = mam_GetDictionary("TEXT_MOVE_DATE")
  Service.Properties("Parent").Caption = "New Parent"
	      
  ' Include Calendar javascript    
  mam_IncludeCalendar
  
  ' Make sure we are in the same corporate if business rule is enabled
  Dim pc
  Set pc = GetProductCatalogObject()  
  If pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) and mam_GetDictionary("EDIT_PARENT") = FALSE Then
    For each id in GetAccountIDCollection()
      Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(id), mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))
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
    Dim newCol
    Dim id
    Dim ENUM_SINGLE, DIRECT_DESCENDENTS, RECURISVE
    ENUM_SINGLE = 0
    DIRECT_DESCENDENTS = 1
    RECURISVE = 2
      
    On Error Resume Next

    Set objHC     = session("SYSTEM_USER_HIERARCHY_HELPER")

    If FrameWork.DecodeFieldID(Service.Properties("Parent").value, strParent) Then
        if strParent <> "1" then
          ' Make sure we have a valid Parent account
          Set objYAAC = FrameWork.AccountCatalog.GetAccount(strParent, mam_ConvertToSysDate(CDate(Service.Properties("StartDate"))))
          If Err.Number <> 0 Then
              EventArg.Error.number = 1049
              EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1049")
              OK_Click = FALSE       
              Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
              Response.Redirect mdm_GetCurrentFullURL()             
              Exit Function  
          End If   
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
           Set objYAAC = FrameWork.AccountCatalog.GetAccount(id, mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))
           Call objYAAC.GetDescendents(newCol, mam_GetSystemUserHierarchyTime(), RECURISVE, CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS"))) 
        next
    
        If col.count = 1 Then
             ' no need for a progress bar if we only have one account
    
          Call objHC.actorYaac.GetAncestorMgr().MoveAccount(strParent, CLng(col.item(1)), CDate(Service.Properties("StartDate")))
        Else
    
          Set Session("LAST_BATCH_ERRORS") = objHC.actorYaac.GetAncestorMgr().MoveAccountBatch(strParent,col,nothing, CDate(Service.Properties("StartDate")))
          
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
            Response.Redirect mdm_GetCurrentFullURL()             
            Exit Function
          End If
                
        End If
    
        ' Note that UserName and Name_Space are passed empty we need them only when we do an add account
    	  CONST ASP_CALL_TEMPLATE = "[ASP]?MDMReload=TRUE&Mode=Move&AccountID=[ACCOUNTID]&AncestorAccountID=[ANCESTORACCOUNTID]&MoveStartDate=[MOVESTARTDATE]"
        Set Session("BATCH_TEMPLATE_COLLECTION") = newCol
        
        'Route to the apply template prompt page
        Form.RouteTo = PreProcess(ASP_CALL_TEMPLATE, Array("ASP", mam_GetDictionary("ACCOUNT_TEMPLATE_APPLY_PROMPT"), "ACCOUNTID", CLng(col.item(1)), "ANCESTORACCOUNTID"	, strParent,"MOVESTARTDATE", Service.Properties("StartDate")))
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
        Response.Redirect Form.RouteTo 		
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()   
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    DropGrid
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION DropGrid()
  Dim arr
  Dim i
  Dim AccountID
  Dim UserName 
  Dim rs
  Dim objYAAC

  Set rs = server.CreateObject("MTMSIX.MTSQLRowsetSimulator")
         
  ' Add Drop Grid
  Form.Grids.Add "DropGrid", "DropGrid" 

 ' Populate Drop Grid
  If Len(Session("DROP_ACTION")) > 0 Then
    If UCase(Session("DROP_ACTION")) = "SINGLE" Then
      
      AccountID = Session("CHILD")
      If CStr(AccountID) = CStr(MAM_HIERARCHY_ROOT_ACCOUNT_ID) Then
        Exit Function
      End If
      on error resume next
      Set objYAAC =  FrameWork.AccountCatalog.GetAccount(CLng(AccountID), mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime())
      UserName = objYAAC.AccountName & " (" & AccountID & ")"      
      if err.number > 0 then
        exit function
      end if
      on error goto 0

      rs.Initialize 1, 4 
      rs.Name(0) = "icon"
      rs.Name(1) = "id"
      rs.Name(2) = "name"
      rs.Name(3) = "folderAction"          
      rs.MoveFirst
 	      
      rs.Value(0) = objYAAC.IsFolder
      rs.Value(1) = AccountID
      rs.Value(2) = userName
      rs.Value(3) = "folderAction"          
      rs.MoveFirst

    Else

      arr = Split(Session("CHILD"), ",")

      rs.Initialize Ubound(arr)+1, 4 
      rs.Name(0) = "icon"
      rs.Name(1) = "id"
      rs.Name(2) = "name"
      rs.Name(3) = "folderAction"          
      rs.MoveFirst
      
      For i = 0 to Ubound(arr) 
      
          AccountID = arr(i)
          If CStr(AccountID) = CStr(MAM_HIERARCHY_ROOT_ACCOUNT_ID) Then
            Exit Function
          End If
          If Not IsNumeric(AccountID) Then
            Exit Function
          End If
          Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(AccountID), mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))          
          UserName = objYAAC.AccountName & " (" & AccountID & ")"
        
          rs.Value(0) = objYAAC.IsFolder
          rs.Value(1) = AccountID
          rs.Value(2) = UserName
          rs.Value(3) = "folderAction"          
          rs.MoveNext

      Next
      rs.MoveFirst
    End If  
	 End If

  ' Populate DropGrid grid from rowset    
  Set Form.Grids("DropGrid").Rowset = rs
    
  Form.Grids("DropGrid").Width      = "80%"	
  Form.Grids("DropGrid").Properties.ClearSelection
    
  If Form.Grids("DropGrid").Properties.count Then
    Form.Grids("DropGrid").Properties("name").Selected         = 1	 
    Form.Grids("DropGrid").Properties("name").Caption          = "Moving Accounts"	 
  End If

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Remove_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Remove_Click(EventArg) ' As Boolean
	
	Form("RemoveID") = mdm_UIValue("mdmUserCustom")

  Form.Grids("DropGrid").Rowset.RemoveRow CLng(Form("RemoveID") -1)
  		
	Remove_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 	 : DropGrid_DisplayCell
' PARAMETERS :
' DESCRIPTION:
' RETURNS		 : Return TRUE if ok else FALSE
PRIVATE FUNCTION DropGrid_DisplayCell(EventArg) ' As Boolean

    Select Case lcase(EventArg.Grid.SelectedProperty.Name)

        Case "name"
            EventArg.HTMLRendered  = "<td align='left' class='" & EventArg.Grid.CellClass & "' style='cursor:default;'>"
             
            EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a style='cursor:hand;' onclick='mdm_RefreshDialogUserCustom(this,""" & EventArg.Grid.Row & """);' name='Remove'><img src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></a>&nbsp;&nbsp;&nbsp;"
               
            EventArg.HTMLRendered  = EventArg.HTMLRendered & EventArg.Grid.SelectedProperty.Value & "</td>"
            DropGrid_DisplayCell = TRUE

        Case "folderaction"
            EventArg.HTMLRendered  =  "<td width='150px' class='" & EventArg.Grid.CellClass & "'>"
            If CBool(EventArg.Grid.Properties("icon").Value) Then
              Service.Properties.Add "folderAction" & EventArg.Grid.Properties("id").Value, "String",  256, FALSE, mam_GetDictionary("TEXT_ALL_DESCENDANTS") 
               
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a href=""JavaScript:SetFolderAction(" & "document.all.folderActionText" & EventArg.Grid.Properties("id").Value & ");"">"  
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "<img align='absmiddle' border=0 src='/mam/default/localized/en-us/images/toggle.gif'></a>"
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "&nbsp;<input name='" & "folderActionText" & EventArg.Grid.Properties("id").Value & "' class='" &  EventArg.Grid.CellClass & "' style='border:0;' type='test' value='" &  Service.Properties("folderAction" & EventArg.Grid.Properties("id").Value )  & "'>"
              
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"
            End If
            DropGrid_DisplayCell = TRUE

        Case else
            DropGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select
END FUNCTION    
%>


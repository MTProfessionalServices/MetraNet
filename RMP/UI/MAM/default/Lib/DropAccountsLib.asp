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
' NAME        : DropAccountsLib.asp
' DESCRIPTION	: 
' AUTHOR	    : Kevin A. Boucher
' VERSION	    :
'
' NOTES:
'    <div class="clsDrop" dropEvent="HandleDrop" dragID="DropField" name="DropField" style="width:200px;padding:5px;background-color:white;border:solid 1px black;">
'      Drag and drop folders here...
'    </div>  
'    <br><br>
'    
'    <!-- Drop Accounts -->
'    <MDMGRID name="DropGrid"></MDMGRID>
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    InitDropGrid
' PARAMETERS:  bFolderOptions, bFoldersOnly
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE 
 FUNCTION InitDropGrid(bFolderOptions, bFoldersOnly)
  InitDropGrid = FALSE

  If Form.Grids.Exist("DropGrid") Then
    Call Form.Grids.Remove("DropGrid")
  End If
  
  ' Add Folder Options 
  Form("bFolderOptions") = CBool(bFolderOptions)
  Form("bFoldersOnly") = CBool(bFoldersOnly)
  
  ' Add Drop Properties
	Service.Properties.Add "DropAction",     "String", 256,   FALSE, Empty   
  Service.Properties.Add "Child",          "String", 4096,   FALSE, Empty      

  ' Add Drop Grid
  Form.Grids.Add "DropGrid", "DropGrid" 
  
  Service.Properties("DropAction") = "MULTI" 
    
  InitDropGrid = TRUE
 END FUNCTION
 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    DropGrid
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION DropGrid_Click(EventArg)
  Dim arr
  Dim i
  Dim AccountID
  Dim UserName 
  Dim rs
  Dim objYAAC
  Dim DropAction
  Dim Child
  
  Set rs = server.CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)

  If UCase(mam_GetDictionary("ENABLE_ADVANCED_MANUAL_ENTRY")) = "TRUE" Then
    Service.Properties("DropAction") = "MULTI"    ' if advanced mode allow multi entry
  End IF  
  
  DropAction = Service.Properties("DropAction").Value
  Child = Service.Properties("Child").Value
  Service.Properties("Child").Value = ""
  
  If CStr(Child) = CStr(MAM_HIERARCHY_ROOT_ACCOUNT_ID) Then
    Exit Function
  End If
  
 ' If folder only, and an account is droped return silently
  If Form("bFoldersOnly") Then
    If Len(DropAction) > 0 Then
      If UCase(DropAction) = "SINGLE" Then
        AccountID = Child
        Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(AccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))
        If Not CBool(objYAAC.IsFolder) Then 
          mam_ShowGuide(mam_GetDictionary("TEXT_DRAG_ONLY_FOLDERS_HERE"))
          Exit Function 
        End If
      Else
        arr = Split(Child, ",")
        For i = 0 to Ubound(arr) 
          AccountID = arr(i)
          Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(AccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))
          If Not CBool(objYAAC.IsFolder) Then 
            mam_ShowGuide(mam_GetDictionary("TEXT_DRAG_ONLY_FOLDERS_HERE"))
            Exit Function       
          End If
        Next  
      End If
    End If  
  End If  
  
 ' Populate Drop Grid
  If Len(DropAction) > 0 Then
    If UCase(DropAction) = "SINGLE" Then
      
      AccountID = Child
      Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(AccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))
      UserName = objYAAC.AccountName & " (" & AccountID & ")"

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

      arr = Split(Child, ",")
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
          
          If Not IsNumeric(AccountID) Then 'Make sure there is no funny business
            Exit Function       
          End If
          
          Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(AccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))          
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
  If Not IsEmpty(Form("SaveRS")) Then
    Call Form.Grids("DropGrid").AddToRowset(Form("SaveRS"), "id") 
  End If  
  Set Form("SaveRS") = Form.Grids("DropGrid").Rowset
 
  Form.Grids("DropGrid").Width      = "80%"	
  Form.Grids("DropGrid").Properties.ClearSelection
    
  If Form.Grids("DropGrid").Properties.count Then
    Form.Grids("DropGrid").Properties("name").Selected         = 1	 
  
    If CBool(Form("bFolderOptions")) Then
      Form.Grids("DropGrid").Properties("folderAction").Selected = 2	 
      'Form.Grids("DropGrid").Properties("folderAction").Caption  = mam_GetDictionry("TEXT_OPTIONS")
      If CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS")) Then
        Form.Grids("DropGrid").Properties("folderAction").Caption = mam_GetDictionary("TEXT_OPTIONS") & " &nbsp;" & mam_GetDictionary("TEXT_INCLUDING_FOLDERS") 
      Else   
       Form.Grids("DropGrid").Properties("folderAction").Caption = mam_GetDictionary("TEXT_OPTIONS") & " &nbsp;" & mam_GetDictionary("TEXT_EXCLUDING_FOLDERS")       
      End IF         
    End If
    
    Form.Grids("DropGrid").Properties("name").Caption          = mam_GetDictionary("TEXT_LOGIN_NAME")
    
  End If

    
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
            
           ' If UCase(mam_GetDictionary("ENABLE_ADVANCED_MANUAL_ENTRY")) <> "TRUE" Then
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a style='cursor:hand;' onclick='mdm_RefreshDialogUserCustom(this,""" & EventArg.Grid.Row & """);' name='Remove'><img src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></a>&nbsp;&nbsp;&nbsp;"
           ' End If

            EventArg.HTMLRendered  = EventArg.HTMLRendered & EventArg.Grid.SelectedProperty.Value & "</td>"
            DropGrid_DisplayCell = TRUE

        Case "folderaction"
            EventArg.HTMLRendered  =  "<td width='220px' class='" & EventArg.Grid.CellClass & "'>"
            If CBool(EventArg.Grid.Properties("icon").Value) Then
            
              If Not Service.Properties.Exist("folderAction" & EventArg.Grid.Properties("id").Value) Then
                Service.Properties.Add "folderAction" & EventArg.Grid.Properties("id").Value, "String",  256, FALSE, mam_GetDictionary("TEXT_ALL_DESCENDANTS") 
              End IF
               
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a href=""JavaScript:SetFolderAction(" & "document.all.folderAction" & EventArg.Grid.Properties("id").Value & ");"">"  
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "<img align='absmiddle' border=0 src='/mam/default/localized/en-us/images/toggle.gif'></a>"
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "&nbsp;<input name='" & "folderAction" & EventArg.Grid.Properties("id").Value & "' class='" &  EventArg.Grid.CellClass & "' style='border:0;' type='text' value='" &  Service.Properties("folderAction" & EventArg.Grid.Properties("id").Value )  & "'>"
             
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"
            End If
            DropGrid_DisplayCell = TRUE

        Case else
            DropGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select

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
' FUNCTION 	 : GetAccountIDCollection
' PARAMETERS :
' DESCRIPTION: Gets the current account ids in the drop grid and returns a collection
' RETURNS		 : Return collection 
PRIVATE FUNCTION GetAccountIDCollection()
	Dim col
  Dim objYAAC
  Dim ENUM_SINGLE, DIRECT_DESCENDENTS, RECURISVE
  ENUM_SINGLE = 0
  DIRECT_DESCENDENTS = 1
  RECURISVE = 2
  
  GetAccountIDCollection = Empty
	Set col = Server.CreateObject(MT_COLLECTIONEX_PROG_ID)

  If Not IsValidObject(Form.Grids("DropGrid").Rowset) Then
    Set GetAccountIDCollection = col
    Exit Function
  End If  
  
  Form.Grids("DropGrid").Rowset.MoveFirst

  Do While Not Form.Grids("DropGrid").Rowset.EOF 

     ' Check to see if we are a folder 
     If CBool(Form.Grids("DropGrid").Properties("icon").Value) AND CBool(Form("bFolderOptions")) Then

           If Service.Properties("folderAction" & Form.Grids("DropGrid").Properties("id").Value).Value =  mam_GetDictionary("TEXT_ALL_DESCENDANTS") Then
             ' Add all descendants
             Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Form.Grids("DropGrid").Properties("id").Value), mam_ConvertToSysDate(mam_GetHierarchyTime()))
             Call objYAAC.GetDescendents(col, mam_ConvertToSysDate(mam_GetHierarchyTime()), RECURISVE, CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS")))  '	STDMETHOD(GetDescendents)(/*[in]*/ IMTCollection* pCol,DATE RefDate,/*[in]*/ MTHierarchyPathWildCard treeHint,/*[in]*/ VARIANT_BOOL IncludeFolders);
  
           ELseIf Service.Properties("folderAction" & Form.Grids("DropGrid").Properties("id").Value).Value =  mam_GetDictionary("TEXT_DIRECT_DESCENDANTS") Then
             ' Add direct descendants
             Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Form.Grids("DropGrid").Properties("id").Value), mam_ConvertToSysDate(mam_GetHierarchyTime()))
             Call objYAAC.GetDescendents(col, mam_ConvertToSysDate(mam_GetHierarchyTime()), DIRECT_DESCENDENTS, CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS")))  '	STDMETHOD(GetDescendents)(/*[in]*/ IMTCollection* pCol,DATE RefDate,/*[in]*/ MTHierarchyPathWildCard treeHint,/*[in]*/ VARIANT_BOOL IncludeFolders);
  
           Else
             col.Add CLng(Form.Grids("DropGrid").Properties("id").Value)  
           End If
         
     Else
         col.Add CLng(Form.Grids("DropGrid").Properties("id").Value)  
     End If   
     
     Form.Grids("DropGrid").Rowset.MoveNext  
  Loop    
  
  ' Check for empty collection
  'If col.count = 0 Then
  '  EventArg.Error.number = 1034
  '  EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1034")
  '  Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
  '  Response.Redirect mdm_GetCurrentFullURL()             
  '  Exit Function
  'End If
      
  Set GetAccountIDCollection = col
END FUNCTION
 
 %>

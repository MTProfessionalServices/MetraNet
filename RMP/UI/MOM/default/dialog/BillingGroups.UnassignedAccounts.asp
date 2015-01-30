<% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultDialogPVBFailedTransaction.asp$
' 
'  Copyright 1998-20002 by MetraTech Corporation
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
'  Created by: Rudi
' 
'  $Date: 11/14/2002 11:53:10 AM$
'  $Author: Frederic Torres$
'  $Revision: 48$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : DefaultDialogAddNameSpace.asp
' DESCRIPTION : Note that this dialog hit the SQL Server directly through MTSQLRowset Object and some query file.
'               We do not use MT Service or MT Product View. The Rowset is viewed as a product view.
'
'
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/Common/Widgets/Progress/CProgress.asp" -->
<!-- #INCLUDE FILE="../../default/lib/FailedTransactionLibrary.asp"     -->
<%



Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mom_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	  on error resume next  
    Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
    Dim i      
    Form_Initialize = FALSE
    
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW    
    
    ProductView.Properties.Selector.ColumnID        = "AccountId" ' Specify the column id to use as the select key
    ProductView.Properties.Selector.Clear
    
    ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
    
    Form("Status") = Request.QueryString("Status")

    Dim title
    
    'Set the screen title
    If Form("Status")="HardClosed" Then
      title = mom_GetDictionary("TEXT_Unassigned_Accounts_That_Are_Hard_Closed")
    Else
      title = mom_GetDictionary("TEXT_Unassigned_Accounts_That_Are_Open")
    End If

    mdm_GetDictionary().Add "UNASSIGNED_ACCOUNTS_TITLE", title

    'ProductView.Properties.Interval.DisplayInvoiceNumber  = FALSE    
	Form_Initialize                                       = TRUE
    
    '//TODO: FIX THIS SO WE CAN HAVE MULTIPLE WINDOWS!
    
    'if len(request("Status"))>0 then
    
    '    Session("FailedTransactionBrowserFilter")=lcase(request("Status"))
    'end if
    
    'Form("Status")=Session("FailedTransactionBrowserFilter")
    'Form("BatchView_ID")=request("BatchView_ID")
    Form("IntervalID") = Request.QueryString("IntervalID")

    Form.ShowExportIcon           = TRUE ' Export
    
    ProductView.Properties.Selector.Clear

    Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

    ' Include Progress Bar
    mdm_IncludeProgress
    
    Form_Initialize = MyForm_LoadProductView(EventArg)
    on error goto 0
END FUNCTION

' Don't load/refresh data on select and unselect all
PRIVATE FUNCTION Form_LoadProductView(EventArg)
  If((mdm_UIValue("mdmProperty") = "butMDMSelectAll") or (mdm_UIValue("mdmProperty") = "butMDMUnSelectAll")) Then
    Form_LoadProductView = TRUE
  Else
    Form_LoadProductView = MyForm_LoadProductView(EventArg)
  End If  
END FUNCTION

PRIVATE FUNCTION MyForm_LoadProductView(EventArg) ' As Boolean

  Dim objUSM
  Set objUSM = mom_GetUsageServerClientObject()
  
  Dim objFilter
  set objFilter = Server.CreateObject("MetraTech.UsageServer.UnassignedAccountsFilter")
  objFilter.IntervalId = CLng(Form("IntervalID"))
  
  'if len(Form("Status"))>0 then
    if Form("Status")= "HardClosed" then
		objFilter.Status = UnassignedAccountStatus_HardClosed
    else
		objFilter.Status = UnassignedAccountStatus_Open
    end if
  'end if
  'CLng(Form("IntervalID"))
  
  Dim partitionId 
  partitionId = Session("MOM_SESSION_CSR_PARTITION_ID")
  if Not IsEmpty(Session("MOM_SESSION_CSR_PARTITION_ID")) then
    if Not (partitionId = 1) then
      objFilter.PartitionId = (partitionId)
    end if
  end if

  Set ProductView.Properties.RowSet = objUSM.GetUnassignedAccountsForIntervalAsRowset((objFilter))
  
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ' Check to see if items have been filtered and inform the user
  If ProductView.Properties.RowSet.RecordCount >= 1000 Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
  
  ProductView.Properties.ClearSelection                    
  


dim i
i=1
ProductView.Properties("DisplayName").Selected = i : i=i+1
ProductView.Properties("AccountID").Selected =   i : i=i+1  
ProductView.Properties("nm_login").Selected =    i : i=i+1
ProductView.Properties("nm_space").Selected =   i : i=i+1

ProductView.Properties("DisplayName").Caption = mom_GetDictionary("TEXT_Account")
ProductView.Properties("AccountID").Caption 	= mom_GetDictionary("TEXT_Account_ID")
ProductView.Properties("nm_login").Caption    = mom_GetDictionary("TEXT_User_Name")
ProductView.Properties("nm_space").Caption    = mom_GetDictionary("TEXT_Namespace")

  
  mdm_SetMultiColumnFilteringMode TRUE  
  'ProductView.LoadJavaScriptCode
  
  mdm_SetMultiColumnFilteringMode TRUE
        
  MyForm_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
                          
  ' Store the rowset so the sub dialog can use it, because there is no way to close a PVB dialog
  ' this object will remain in the session until mom_GarbageCollector will be called when 
  ' the user log out or the session time out.
  'Set Session("FAILED_TRANSACTIONS_ROWSET_SESSION_NAME")  = ProductView.Properties.RowSet
  
  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
  ProductView.LoadJavaScriptCode
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: inheritedForm_DisplayBeginOfPage
' PARAMETERS		:
' DESCRIPTION 	: I have to over write this because I need to set the caption of mdmIntervalID this property is create on the fly
'                 by the MDM after the Form_LoadProductView event and I have no way to set it rather that here...
' RETURNS			  :
PRIVATE FUNCTION Form_DisplayBeginOfPage(EventArg) ' As Boolean

    'ProductView.Properties("mdmIntervalID").Caption = mom_GetDictionary("TEXT_INTERVAL_ID")    
    'ProductView.Properties("ViewId").Caption        = mom_GetDictionary("TEXT_VIEW_ID")
    'ProductView.Properties("SessionID").Caption     = mom_GetDictionary("TEXT_SESSION_ID")
    'ProductView.Properties("SessionType").Caption   = mom_GetDictionary("TEXT_SESSION_TYPE")
    
    Form_DisplayBeginOfPage                         = Inherited("Form_DisplayBeginOfPage(EventArg)") ' Call the inherited event    
    Form_DisplayBeginOfPage                         = TRUE
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION Form_Terminate(EventArg) ' As Boolean
      Set Session("FAILED_TRANSACTIONS_ROWSET_SESSION_NAME") = Nothing ' Well anyway this event will not be called - just in case for the future
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayCell
' PARAMETERS    :  EventArg
' DESCRIPTION   :  
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode, objPreProcessor, strTemplateEdit, strTemplateCheckBox, strTemplateIDS, strID, strTemplateStatus
    
    Set objPreProcessor   = mdm_CreateObject(CPreProcessor)    
    strTemplateIDS        = "<INPUT Type='Hidden' Name='SessionIDS' Value='[ID_FAILURE]'>"
    'strTemplateStatus     = "<INPUT Type=Hidden Name='Status[ID_FAILURE]' Value='[TRANS_STATUS]'>"
    'strTemplateEdit       = "<A Name='Edit[ID_FAILURE]' HRef='[ASP_FILE_EDIT]?mdmReload=TRUE&IdFailure=[ID_FAILURE]'><img src='[LOCALIZED_PATH]/images/edit.gif' Border='0' Alt='[TEXT_EDIT]'></A>"
    strTemplateCheckBox   = "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[FAILURECOMPOUNDSESSIONID]'>"
    
    Select Case Form.Grid.Col
    
        Case 1
			  If Form("Status")<>"HardClosed" Then
              strID = ProductView.Properties("AccountId").Value
              
              'ProductView.Log "SELECTION=" & ProductView.Properties.Selector.ToString()
              'ProductView.Log "CHECK SELECTED ID=" & strID
              'ProductView.Log "CHECK SELECTED ISSelected:" & ProductView.Properties.Selector.IsItemSelected(strID)
              
              objPreProcessor.Add "CHECKBOX_SELECTED", IIF(ProductView.Properties.Selector.IsItemSelected(strID),"CHECKED","") ' Select All mode
                          
              'objPreProcessor.Add "TEXT_EDIT"        , mom_GetDictionary("TEXT_EDIT"  )
              objPreProcessor.Add "TEXT_DELETE"      , mom_GetDictionary("TEXT_DELETE")
              objPreProcessor.Add "TEXT_EXPORT"      , mom_GetDictionary("TEXT_EXPORT") 
  
              If true then
                  objPreProcessor.Add "ASP_FILE_EDIT"    , mom_GetDictionary("EDIT_FAILED_COMPOUND_TRANSACTION_DIALOG")                
              Else
                  objPreProcessor.Add "ASP_FILE_EDIT"    , mom_GetDictionary("EDIT_FAILED_ATOMIC_TRANSACTION_DIALOG")
              End if
                         
              objPreProcessor.Add "ASP_FILE_DELETE"  , mom_GetDictionary("DELETE_FAILED_TRANSACTION_DIALOG")
              objPreProcessor.Add "ASP_FILE_EXPORT"  , mom_GetDictionary("EXPORT_FAILED_TRANSACTION_DIALOG")           
              objPreProcessor.Add "LOCALIZED_PATH"   , mom_GetDictionary("DEFAULT_PATH_REPLACE")
              objPreProcessor.Add "ID_FAILURE"       , 999 'ProductView("CaseNumber")
              'objPreProcessor.Add "TRANS_STATUS"     , "Binky" 'ProductView("Status")
              objPreProcessor.Add "FAILURECOMPOUNDSESSIONID" , ProductView("AccountId")
              
              '//Disable edit link for resubmitted and deleted transactions because the MSIX is gone....
              'if ProductView("Status")="R" or ProductView("Status")="P" or ProductView("Status")="D" then
              
              '    strTemplateEdit = "&nbsp;&nbsp;&nbsp;&nbsp;"
              'end if
              
              'if Form("Status") <> "resubmitted" then
                strSelectorHTMLCode   = objPreProcessor.Process(strTemplateIDS+strTemplateCheckBox)
              'else
              '  strSelectorHTMLCode = "&nbsp;"
              'end if
              Else
                strSelectorHTMLCode = "&nbsp;"
              End If
              EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell      = TRUE
        
        Case 2
              'Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
			  EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & "&nbsp;" & "</td>"
              Form_DisplayCell      = TRUE
        Case Else

              Select Case LCase(Form.Grid.SelectedProperty.Name)
              
        
                  Case "errormessage"
                      'In the case of embedded symbols, escape out the HTML
                      EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & Server.HTMLEncode(Form.Grid.SelectedProperty.Value) & "</td>"
                      
                      EventArg.HTMLRendered = mdm_GetDictionary().PreProcess(EventArg.HTMLRendered)
                  
        	        Case else
                      Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
              End Select                  
    End Select    
END FUNCTION




' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp

  If Form("Status")<>"HardClosed" AND ProductView.Properties.RowSet.RecordCount>0 AND FrameWork.CheckCoarseCapability("Manage Intervals") AND (IsEmpty(Session("MOM_SESSION_CSR_PARTITION_ID")) OR Session("MOM_SESSION_CSR_PARTITION_ID")=1) Then
      Form_DisplayEndOfPageAddSelectButtons EventArg, "", FALSE ' No JavaScript, Do not close the form
       
      strTmp = "<div align='center'><BR><button  name='HARDCLOSE' Class='clsButtonXLarge' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>" & mom_GetDictionary("TEXT_Mark_As_Hard_Closed") & "</button>" & vbNewLine
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
	    
      'Only display 'Manually Assign Accounts' if interval has been materialized (otherwise we won't be successful on the next screen)
      Dim objUSM
      Set objUSM = mom_GetUsageServerClientObject()
	  Dim interval
	  Set interval = objUSM.GetUsageInterval(CLng(Form("IntervalID")))
	  If CBool(interval.HasBeenMaterialized) Then
        strTmp = "&nbsp;<button name='CREATEGROUP' Class='clsButtonXLarge' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>" & mom_GetDictionary("TEXT_Manually_Assign_Accounts") & "</button>" & vbNewLine
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    End If
  Else
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</TABLE><br><div align='center'>" & vbNewLine
	End If
	  
        strTmp = "&nbsp; <button onclick='window.close()' name='cancel' Class='clsButtonSmall' ID='Button2'>" & mom_GetDictionary("TEXT_CLOSE") & "</button></div>" & vbNewLine
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp  
     
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(strEndOfPageHTMLCode,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION SUBMIT_Click(EventArg)

      SUBMIT_Click  = PerformActionOnSelectedSession("SUBMIT",EventArg)
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION EXPORT_Click(EventArg)
  
    EXPORT_Click  = PerformActionOnSelectedSession("EXPORT",EventArg)
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION DELETE_Click(EventArg)

    DELETE_Click  = PerformActionOnSelectedSession("DELETE",EventArg)
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION HARDCLOSE_Click(EventArg)

    HARDCLOSE_Click  = PerformActionOnSelectedItems("HARDCLOSE",EventArg)

END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION CREATEGROUP_Click(EventArg)

    CREATEGROUP_Click  = PerformActionOnSelectedItems("CREATEGROUP",EventArg)

END FUNCTION
' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION PerformActionOnSelectedItems(strAction, EventArg)
  Dim itm
  Dim strItm
  Dim strIdList
  Dim objUIItems          ' AS CVariables
  Dim strFailureCompoundID 
  Dim strExportedSession
  Dim booNoActionTaken
  Dim FailureCompoundIDs 
  Dim lngExportError:lngExportError=0
  
    
  booNoActionTaken                = TRUE
  PerformActionOnSelectedItems  = FALSE

  Server.ScriptTimeout = 1800 'Increase script timeout for this page to 30 minutes while performing action  
  
  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
  
  Form_ChangePage EventArg,0,0 ' We need to call the event our self here so we update the ProductView.Properties.Selector

  Set FailureCompoundIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSet(ProductView.Properties.Rowset,"FailureCompoundSessionId")
  
  If FailureCompoundIDs.Count=0 Then
  
      EventArg.Error.Description  = mom_GetDictionary("MOM_ERROR_1008")
      EventArg.Error.Number       = 1008
      Exit Function
  End If
 
 
'response.Write "<textarea>" & sAccountIdBuffer & "</textarea>"
 'response.End
  
  Select Case UCase(strAction)
  
   Case "CREATEGROUP"
   
      Form.Modal = FALSE
      
      'Turn our collection into a string?
     dim sAccountIdBuffer
     For Each strFailureCompoundID In FailureCompoundIDs
       If Len(strFailureCompoundID) Then
         sAccountIdBuffer= sAccountIdBuffer & strFailureCompoundID & " "
       End If
     Next
    
      'Form.RouteTo = "BillingGroupManualCreate.asp?IntervalId=" & Form("IntervalID") & "&AccountsInSession=TRUE"
	  Session("BillingGroupAccountList") = sAccountIdBuffer
	  PerformActionOnSelectedItems = TRUE
	  
	  mdm_CloseDialogAndExecuteDialog "BillingGroupManualCreate.asp?IntervalId=" & Form("IntervalID") & "&AccountsInSession=TRUE"
      ProductView.Properties.Selector.Clear
      Exit Function    
         
   Case "HARDCLOSE"

     Dim objUSM,objErrors
     Set objUSM = mom_GetUsageServerClientObject()
     set objErrors = objUSM.SetAccountStatusToHardClosedForInterval((FailureCompoundIDs), Form("IntervalId"),true)
     
     if objErrors.RecordCount > 0 then
       EventArg.Error.Description  = "There were " & objErrors.RecordCount & " errors." 'mom_GetDictionary("MOM_ERROR_1008")
       EventArg.Error.Number       = 1008
       Exit Function

     else
       Form.Modal = TRUE
       PerformActionOnSelectedItems = TRUE
	 end if
  End Select
  
  ProductView.Properties.Selector.Clear
  
END FUNCTION

%>

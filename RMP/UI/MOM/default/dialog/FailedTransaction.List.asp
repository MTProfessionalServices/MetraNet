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

PRIVATE FUNCTION CheckReRunError()
    If(err.number)Then  
      EventArg.Error.Save Err

      Select Case Err.Number
       Case -2146233087
         EventArg.Error.Description = mom_GetDictionary("MOM_ERROR_1010")
         EventArg.Error.Number = 1010
       Case Else
         EventArg.Error.LocalizedDescription = EventArg.Error.Description
      End Select 
      
      response.write "<html><head><LINK rel='STYLESHEET' type='text/css' href='/mom/default/localized/en-us/styles/styles.css'></head><body>"  
      Form_DisplayErrorMessage EventArg
      response.write "</body></html>"
      Session("FAILEDTRANSACTION_CURRENT_RERUNID") = Empty
      Response.End
    End If
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	  on error resume next  
    Dim i      
    Form_Initialize = FALSE
    
    Framework.AssertCourseCapability "Update Failed Transactions", EventArg

    ' Check to see if a resubmit of failed transactions is in progress.
    ' If it is, then go to the progress screen.
    If Not IsEmpty(Session("FAILEDTRANSACTION_CURRENT_RERUNID")) Then
    	Dim objReRun
      Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)  
      objReRun.Login FrameWork.SessionContext
      objReRun.ID = Session("FAILEDTRANSACTION_CURRENT_RERUNID")
    	objReRun.Synchronous = FALSE
      CheckReRunError
       
      dim complete
      complete = objReRun.IsComplete
      CheckReRunError
  
      If not complete Then
        mdm_TerminateDialogAndExecuteDialog "FailedTransactionWait.asp?ReturnUrl=" & mom_GetDictionary("FAILED_TRANSACTION_BROWSER_DIALOG") & "&Title=" & Server.UrlEncode("Submitting Failed Transactions") & "&MessageTitle=" & Server.UrlEncode("Resubmit Status:")
      Else
				objReRun.Abandon "Completed resubmitting failed transactions" 'CR:12998
        Session("FAILEDTRANSACTION_CURRENT_RERUNID") = Empty
        Session("FAILEDTRANSACTION_CURRENT_STATUS_MESSAGE") = "Done."
        Session("FAILEDTRANSACTION_CURRENT_COMMENT") = "The process is done."
      End If

    End If  
    
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW    
    
    ProductView.Properties.Selector.ColumnID        = "FailureCompoundSessionId" ' Specify the column id to use as the select key
    ProductView.Properties.Selector.Clear
    
    ProductView.Properties.TimeZoneId               = mom_GetCSRTimeZoneID()
    ProductView.Properties.DayLightSaving           = mom_GetDictionary("DAY_LIGHT_SAVING")
    
    ProductView.Properties.Interval.DateFormat  = mom_GetDictionary("DATE_FORMAT") ' Set the date format into the Interval Id Combo Box
    
    '//If (Not ProductView.Properties.Interval.Load(GLOBAL_CSR_METERED_ACCOUNT_ID)) Then Exit Function ' Load the interval id rowset - The MDM PVBrowser

    ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
    

    ProductView.Properties.Interval.DisplayInvoiceNumber  = FALSE    
	  Form_Initialize                                       = TRUE
    
    '//TODO: FIX THIS SO WE CAN HAVE MULTIPLE WINDOWS!
    
    if len(request("Status"))>0 then
    
        Session("FailedTransactionBrowserFilter")=lcase(request("Status"))
    end if
    
    Form("Status")=Session("FailedTransactionBrowserFilter")
    Form("BatchView_ID")=request("BatchView_ID")
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

  dim sQuery, sQueryWhereClause, rowset

  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"

  select case Form("Status")
  
      case "open"
        rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_OPEN__")
        mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_OPEN")
      case "underinvestigation"
         rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_UNDER_INVESTIGATION__")
        mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_UNDER_INVESTIGATION")
      case "corrected"
        rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_CORRECTED__")
        mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_CORRECTED")
      case "resubmitted"
        rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_RESUBMITTED__")
        mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_RESUBMITTED")
      case "dismissed"
        rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_DISMISSED__")
        mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_DISMISSED")
      case else
        rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_ALL__")
        mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_ALL")    
  end select
  
  if Form("BatchView_ID")<>"" then
  
      rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_FOR_BATCH__")
      rowset.AddParam "%%ID_BATCH_ENCODED%%", Cstr(Form("BatchView_ID"))
      mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTIONS_FAILED_TRANSACTION_BROWSER", mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_FOR_BATCH") & " " & Form("BatchView_ID")   
  end if
  
  rowset.Execute

  '// Sort
  rowset.Sort "FailureTime", 2

  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  if false then
      ProductView.Properties.SelectAll
  else
      ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
      
      Dim i
      i = 1
      ProductView.Properties("CaseNumber").Selected         = i : i=i+1
      ProductView.Properties("Status").Selected             = i : i=i+1
      ProductView.Properties("FailureTime").Selected        = i : i=i+1
      
      ProductView.Properties("Code").Selected               = i : i=i+1
      ProductView.Properties("CodeMessage").Selected         = i : i=i+1  
      ProductView.Properties("ErrorMessage").Selected       = i : i=i+1  
      ProductView.Properties("FailureServiceName").Selected = i : i=i+1
      ProductView.Properties("StageName").Selected          = i : i=i+1
      ProductView.Properties("PlugIn").Selected             = i : i=i+1
      'ProductView.Properties("BatchId").Selected             = i : i=i+1
      ProductView.Properties("FailureCompoundSessionId").Selected         = i : i=i+1
      ProductView.Properties("FailureSessionId").Selected         = i : i=i+1  
      'ProductView.Properties("MeteredTime").Selected       = i : i=i+1
      'ProductView.Properties("Sender").Selected             = i : i=i+1
      'ProductView.Properties("PossibleAccountID").Selected = i : i=i+1      
      'ProductView.Properties.SelectAll
  end if
  
  ProductView.Properties.CancelLocalization

  mdm_SetMultiColumnFilteringMode TRUE
        
  MyForm_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
                          
  ' Store the rowset so the sub dialog can use it, because there is no way to close a PVB dialog
  ' this object will remain in the session until mom_GarbageCollector will be called when 
  ' the user log out or the session time out.
  Set Session("FAILED_TRANSACTIONS_ROWSET_SESSION_NAME")  = ProductView.Properties.RowSet
  
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
    strTemplateStatus     = "<INPUT Type=Hidden Name='Status[ID_FAILURE]' Value='[TRANS_STATUS]'>"
    strTemplateEdit       = "<A Name='Edit[ID_FAILURE]' HRef='[ASP_FILE_EDIT]?mdmReload=TRUE&IdFailure=[ID_FAILURE]'><img src='[LOCALIZED_PATH]/images/edit.gif' Border='0' Alt='[TEXT_EDIT]'></A>"
    strTemplateCheckBox   = "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[FAILURECOMPOUNDSESSIONID]'>"
    
    Select Case Form.Grid.Col
    
        Case 1

              strID = ProductView.Properties("FailureCompoundSessionId").Value
              
              'ProductView.Log "SELECTION=" & ProductView.Properties.Selector.ToString()
              'ProductView.Log "CHECK SELECTED ID=" & strID
              'ProductView.Log "CHECK SELECTED ISSelected:" & ProductView.Properties.Selector.IsItemSelected(strID)
              
              objPreProcessor.Add "CHECKBOX_SELECTED", IIF(ProductView.Properties.Selector.IsItemSelected(strID),"CHECKED","") ' Select All mode
                          
              objPreProcessor.Add "TEXT_EDIT"        , mom_GetDictionary("TEXT_EDIT"  )
              objPreProcessor.Add "TEXT_DELETE"      , mom_GetDictionary("TEXT_DELETE")
              objPreProcessor.Add "TEXT_EXPORT"      , mom_GetDictionary("TEXT_EXPORT") 
  
              If UCase(ProductView.Properties.RowSet.Value("Compound"))="Y" then
                  objPreProcessor.Add "ASP_FILE_EDIT"    , mom_GetDictionary("EDIT_FAILED_COMPOUND_TRANSACTION_DIALOG")                
              Else
                  objPreProcessor.Add "ASP_FILE_EDIT"    , mom_GetDictionary("EDIT_FAILED_ATOMIC_TRANSACTION_DIALOG")
              End if
                         
              objPreProcessor.Add "ASP_FILE_DELETE"  , mom_GetDictionary("DELETE_FAILED_TRANSACTION_DIALOG")
              objPreProcessor.Add "ASP_FILE_EXPORT"  , mom_GetDictionary("EXPORT_FAILED_TRANSACTION_DIALOG")           
              objPreProcessor.Add "LOCALIZED_PATH"   , mom_GetDictionary("DEFAULT_PATH_REPLACE")
              objPreProcessor.Add "ID_FAILURE"       , ProductView("CaseNumber")
              objPreProcessor.Add "TRANS_STATUS"     , ProductView("Status")
              objPreProcessor.Add "FAILURECOMPOUNDSESSIONID" , ProductView("FailureCompoundSessionId")
              
              '//Disable edit link for resubmitted and deleted transactions because the MSIX is gone....
              if ProductView("Status")="R" or ProductView("Status")="P" or ProductView("Status")="D" then
              
                  strTemplateEdit = "&nbsp;&nbsp;&nbsp;&nbsp;"
              end if
              
              if Form("Status") <> "resubmitted" then
                strSelectorHTMLCode   = objPreProcessor.Process(strTemplateStatus+strTemplateIDS+strTemplateEdit+strTemplateCheckBox)
              else
                strSelectorHTMLCode = "&nbsp;"
              end if
              EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell      = TRUE
        
        Case 2
              Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation

        Case Else

              Select Case LCase(Form.Grid.SelectedProperty.Name)
              
                  Case "status"
                      EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & GetFailedTransactionStatusString(Form.Grid.SelectedProperty.Value)
                      if Form.Grid.SelectedProperty.Value="P" or Form.Grid.SelectedProperty.Value="I" or Form.Grid.SelectedProperty.Value="D" then
                        EventArg.HTMLRendered = EventArg.HTMLRendered & " (" & ProductView("StateReasonCode") & ")"
                      end if
                      EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
                      Form_DisplayCell      = TRUE
                    
                  Case "code"
                      EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & Form.Grid.SelectedProperty.Value & "</td>"
                      Form_DisplayCell      = TRUE
                  
                  Case "errormessage"
                      'In the case of embedded symbols, escape out the HTML
                      EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & Server.HTMLEncode(Form.Grid.SelectedProperty.Value) & "</td>"
                      
                      EventArg.HTMLRendered = mdm_GetDictionary().PreProcess(EventArg.HTMLRendered)
                  
        	        Case else
                      Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
              End Select                  
    End Select    
END FUNCTION


PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName

    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & ">" & vbNewLine

    '// List various properties here
    dim strPropertyName
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader' style='background-color=#688ABA'><td align='center' colspan=2>Properties</td></tr>"    

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap align='right'><b>&nbsp;" & "Compound Session Id" & ":&nbsp;&nbsp;</td><td nowrap>" & ProductView.Properties.RowSet.Value("FailureCompoundSessionId") & "&nbsp;</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap align='right'><b>&nbsp;" & "Session Id" & ":&nbsp;&nbsp;</td><td nowrap>" & ProductView.Properties.RowSet.Value("FailureSessionId") & "&nbsp;</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td style='text-align:right' nowrap align='right'><b>&nbsp;" & "Batch Id" & ":&nbsp;&nbsp;</td><td nowrap>" & ProductView.Properties.RowSet.Value("BatchId") & "&nbsp;</td></tr>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE><BR>"
    
    '// List audit events for this case number
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine

    
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\audit"
  	rowset.SetQueryTag("__SELECT_AUDIT_LOG_FOR_SPECIFIC_ENTITY__")  
    rowset.AddParam "%%ENTITY_TYPE_ID%%", 5
    rowset.AddParam "%%ENTITY_ID%%", CLng(ProductView.Properties.RowSet.Value("CaseNumber"))
  	rowset.Execute
  

    rowset.Sort "Time", 1
        
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='5'>Failed Transaction History</td></tr>"    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left'>Time</td><td align='left'>EventName</td><td align='left'>Details</td><td align='left'>User</td></tr>"    

    if rowset.eof then
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableDetailCell'><td colspan='4'>No audit events have been recorded for this failure.</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip
          'sToolTip = rowset.value("Details")
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableDetailCell' title='" & sToolTip & "'><td style='vertical-align: top'>" & rowset.value("Time") & "</td>"
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td style='vertical-align: top'>" & rowset.value("EventName") & "</td>"  
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td width='350px' style='vertical-align: top'>" & rowset.value("Details") & "&nbsp;</td>"
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td style='vertical-align: top'>" & rowset.value("UserName") & "&nbsp;</td></tr>"    
          rowset.movenext
      loop 
    end if
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE><BR>" & vbNewLine
    
    'if ucase(mdm_GetDictionary().Item("INTERVAL_MANAGEMENT_ADVANCED_USER"))="TRUE" then
    '  EventArg.HTMLRendered = EventArg.HTMLRendered & "<br>&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='EditMapping' onclick=""window.open('DefaultDialogIntervalAdapterList.asp?IntervalId=" & idCurrentInterval & "&IntervalType=" & sIntervalType & "&IntervalState=" & iState & "','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes')"">" & "Run Adapter..." &  "</button>" & vbNewLine
    'end if
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    if Form("Status") <> "resubmitted" then
      Form_DisplayEndOfPageAddSelectButtons EventArg, "", FALSE ' No JavaScript, Do not close the form tag
      
      strTmp = "<BR><button  name='CHANGESTATUS' Class='clsOkButton' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>Change Status</button>" & vbNewLine
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
  
      strTmp = "<button name='EXPORT' GrayOnClick='False' Class='clsOkButton' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>Export</button>" & vbNewLine
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    end if
    
    if Form("Status") <> "resubmitted" then
			strTmp = "<button  name='SUBMIT' Class='clsOkButton' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>Submit</button>" & vbNewLine
    else
			'// Disabled button doesn't look good so just don't display it
      'strTmp = "<button  disabled name='SUBMIT' Class='clsOkButton' onclick=''>Submit</button>" & vbNewLine
      strTmp =""
    end if
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
PRIVATE FUNCTION CHANGESTATUS_Click(EventArg)

    CHANGESTATUS_Click  = PerformActionOnSelectedSession("CHANGESTATUS",EventArg)
'    If Not CHANGESTATUS_Click Then
 '       response.write "<script language='JavaScript1.2'>alert('" & mom_GetDictionary("TEXT_PLEASE_SELECT") & "');</script>"
  '  End IF
END FUNCTION


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION PerformActionOnSelectedSession(strAction, EventArg)
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
  PerformActionOnSelectedSession  = FALSE

  Server.ScriptTimeout = 1800 'Increase script timeout for this page to 30 minutes while performing action  
  
  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
  
  Form_ChangePage EventArg,0,0 ' We need to call the event our self here so we update the ProductView.Properties.Selector

  Set FailureCompoundIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSet(ProductView.Properties.Rowset,"FailureCompoundSessionId")
  
  If FailureCompoundIDs.Count=0 Then
  
      EventArg.Error.Description  = mom_GetDictionary("MOM_ERROR_1008")
      EventArg.Error.Number       = 1008
      Exit Function
  End If
 
  Select Case UCase(strAction)
  
   Case "SUBMIT"
     PerformActionOnSelectedSession = BulkResubmitFailedTransactions(FailureCompoundIDs)     
     Exit Function
         
   Case "EXPORT"
     For Each strFailureCompoundID In FailureCompoundIDs
       If Len(strFailureCompoundID) Then
         If Not ExportSession(EventArg,strFailureCompoundID, strExportedSession) Then lngExportError=lngExportError+1
         booNoActionTaken = FALSE
       End If
     Next
     If (lngExportError=0) Then  
       SendExportedSessionToClient strExportedSession
     Else
       Exit Function
     End If
    
   Case "CHANGESTATUS"
     set session("FailedTransactionChangeStatusCollection") = FailureCompoundIDs
     mdm_CloseDialogAndExecuteDialog(mom_GetDictionary("FAILED_TRANSACTION_STATUS_CHANGE_DIALOG"))
  
  End Select
  
  PerformActionOnSelectedSession = TRUE
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION DeleteSession(istrErrorID) ' As Boolean

	dim mobjFailures ' as object
	set mobjFailures = mdm_CreateObject("MetraPipeline.MTSessionFailures.1")

    ' Initialize Progress Bar
  Progress.Initialize(EventArg)
  Progress.SetCaption mam_GetDictionary("TEXT_SETTING_PAYER") & ": "    		

  On Error Resume Next
  
  'Set Session("LAST_BATCH_ERRORS") = PaymentMgr.PayForAccountBatch(GetAccountIDCollection(), Progress.GetProgressObject(), CDate(Service.Properties("StartDate")), CDate(Service.Properties("EndDate")))

  mobjFailures.AbandonSession CStr(istrErrorID)
  DeleteSession   = CBool(Err.Number)
  
  set mobjFailures = Nothing
	DeleteSession    = TRUE
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION DeleteSessions(FailureIdCollection) ' As Boolean

	dim objPipeline ' as object
	set objPipeline = mdm_CreateObject("MetraTech.Pipeline.ReRun.BulkFailedTransactions")

    ' Initialize Progress Bar
  Progress.Initialize(EventArg)
  Progress.SetCaption "Doing It To It" & ": "    		

  On Error Resume Next
  
  'Set Session("LAST_BATCH_ERRORS") = PaymentMgr.PayForAccountBatch(GetAccountIDCollection(), Progress.GetProgressObject(), CDate(Service.Properties("StartDate")), CDate(Service.Properties("EndDate")))
  dim objResultRowset
  set objResultRowset = objPipeline.DeleteCollection(FailureIdCollection, Progress.GetProgressObject())
  'mobjFailures.DeleteCollection CStr(istrErrorID)
  
  DeleteSessions   = CBool(Err.Number)

End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION SendExportedSessionToClient(strXML) ' As Boolean

        ' the XML is not correct therefore we export it in am txt file
        Response.ContentType = "application/txt"
  	    Response.AddHeader "Content-disposition", "filename=" & "ExportedSessions.AutoSdk.txt"
        Response.Write strXML
        Response.end				
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION ExportSession(EventArg,istrErrorID,strOutPut) ' As Boolean

  	Dim objSession  ' as object
    Dim strExport
    Dim strXML 'unused
    
    ExportSession = FALSE
    
	  Set objSession = GetFailedSession(EventArg,istrErrorID,strXML)
    If objSession Is Nothing Then Exit Function
    
    GetMTPipeLineObject().SessionContext = FrameWork.SessionContext
    strExport      = ExtractSessionFromXML(GetMTPipeLineObject().ExportSession(objSession))
    strExport      = Replace(strExport,Chr(10),"#CR#")
    strExport      = Replace(strExport,"#CR#",Chr(13) & Chr(10))
    strOutPut      = strOutPut & vbNewLine & vbNewLine & strExport  	
    set objSession = Nothing
    ExportSession  = TRUE
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION ExtractSessionFromXML(strXMLSession) ' As Boolean

    Dim lngStartPos
    Dim lngEndPos
    
    'lngStartPos             = InStr(UCase(strXMLSession),XML_TAG_START_SESSION)
    'lngEndPos               = InStr(UCase(strXMLSession),XML_TAG_END_SESSION)  
    'ExtractSessionFromXML   =  Mid(strXMLSession,lngStartPos,lngEndPos+Len(XML_TAG_END_SESSION)-lngStartPos)  
    ExtractSessionFromXML   =  strXMLSession
END FUNCTION
%>

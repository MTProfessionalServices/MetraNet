<% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: $
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
'  Created by: Kevin A. Boucher
' 
'  $Date: 11/14/2002 11:53:10 AM$
'  $Author: Frederic Torres$
'  $Revision: 48$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' Dialog: DefaultDialogPVBLostTransaction.asp
' Description: This dialog is modeled after the failed transactions dialog.  It supports paging and multi-page-select.
'              There are 2 different exports - xml from clicking the export button and a csv format for the list
'              by clicking the export icon in the toolbar.  You can also delete or re-submit 1 or more lost sessions.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="../../default/lib/FailedTransactionLibrary.asp"     -->
<%
Form.Version                    = MDM_VERSION
Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mom_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain 

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW    
    
    ProductView.Properties.Selector.Clear
    ProductView.Properties.Selector.ColumnID        = "Message ID" ' Specify the column id to use as the select key
    
    ProductView.Properties.TimeZoneId               = mom_GetCSRTimeZoneID()
    ProductView.Properties.DayLightSaving           = mom_GetDictionary("DAY_LIGHT_SAVING")
    
    ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order

    Form.ShowExportIcon = TRUE 
     
	  Form_Initialize                                       = TRUE
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  dim sQuery
  dim suspendedTxnManager
  dim rowset
  set suspendedTxnManager = server.CreateObject("MetraTech.Pipeline.SuspendedTxnManager")
  set rowset = suspendedTxnManager.GetSuspendedMessagesRowset()
  set ProductView.Properties.RowSet = rowset 
  
  
  ' set column captions
  ProductView.Properties("Message ID").Caption = mom_GetDictionary("TEXT_Message_ID") 
  ProductView.Properties("Metered On").Caption = mom_GetDictionary("TEXT_Metered_On") 
  ProductView.Properties("Assigned On").Caption = mom_GetDictionary("TEXT_Assigned_On") 
  ProductView.Properties("Assigned To").Caption = mom_GetDictionary("TEXT_Assigned_To") 
  ProductView.Properties("Session Count").Caption = mom_GetDictionary("TEXT_Session_Count") 
  
  ProductView.Properties.SelectAll

  mdm_SetMultiColumnFilteringMode TRUE

  ' Store the rowset so the sub dialog can use it, because there is no way to close a PVB dialog
  ' this object will remain in the session until mom_GarbageCollector will be called when 
  ' the user log out or the session time out.
  Set Session("LOST_TRANSACTIONS_ROWSET_SESSION_NAME")  = ProductView.Properties.RowSet
    
  ProductView.LoadJavaScriptCode

  Form_LoadProductView = TRUE 
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION Form_Terminate(EventArg) ' As Boolean
      Set Session("LOST_TRANSACTIONS_ROWSET_SESSION_NAME") = Nothing ' Well anyway this event will not be called - just in case for the future
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayCell
' PARAMETERS    :  EventArg
' DESCRIPTION   :  
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode, objPreProcessor, strTemplateCheckBox, strTemplateIDS, strID, strTemplateStatus, strTemplateEdit
    
    Set objPreProcessor   = mdm_CreateObject(CPreProcessor)    
    strTemplateIDS        = "<INPUT Type='Hidden' Name='SessionIDS' Value='[ID_FAILURE]'>"
    strTemplateCheckBox   = "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[FAILURECOMPOUNDID]'>"
    
    Select Case Form.Grid.Col
    
        Case 1
               strID = ProductView("Message ID")

              objPreProcessor.Add "CHECKBOX_SELECTED", IIF(ProductView.Properties.Selector.IsItemSelected(strID),"CHECKED","") ' Select All mode
                          
              objPreProcessor.Add "TEXT_DELETE"      , mom_GetDictionary("TEXT_DELETE")
              objPreProcessor.Add "TEXT_EXPORT"      , mom_GetDictionary("TEXT_EXPORT") 
                           
              objPreProcessor.Add "ASP_FILE_DELETE"  , mom_GetDictionary("DELETE_LOST_TRANSACTION_DIALOG")
              objPreProcessor.Add "ASP_FILE_EXPORT"  , mom_GetDictionary("EXPORT_LOST_TRANSACTION_DIALOG")           
              objPreProcessor.Add "LOCALIZED_PATH"   , mom_GetDictionary("DEFAULT_PATH_REPLACE")

              objPreProcessor.Add "FAILURECOMPOUNDID", ProductView("Message ID")
              
              strSelectorHTMLCode   = objPreProcessor.Process(strTemplateStatus+strTemplateIDS+strTemplateEdit+strTemplateCheckBox)
              EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell      = TRUE
                
        Case 2
              mdm_NoTurnDownHTML EventArg                 
     	  Case else
              Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
    End Select    
END FUNCTION




' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    Form_DisplayEndOfPageAddSelectButtons EventArg, "", FALSE ' No JavaScript, Do not close the form tag
    
    strTmp = "<BR><button  name='SUBMIT' Class='clsOkButton' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>"& mom_GetDictionary("TEXT_Resubmit") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp

    strTmp = "<button  name='Delete' Class='clsOkButton' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>"& mom_GetDictionary("TEXT_Delete") & "</button>" & vbNewLine
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

      SUBMIT_Click  = PerformActionOnSelectedSession("SUBMIT")
      If Not SUBMIT_Click Then
          response.write "<script language='JavaScript1.2'>alert('" & mom_GetDictionary("TEXT_PLEASE_SELECT") & "');</script>"
      End IF
END FUNCTION


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION DELETE_Click(EventArg)

    DELETE_Click  = PerformActionOnSelectedSession("DELETE")
    If Not DELETE_Click Then
        response.write "<script language='JavaScript1.2'>alert('" & mom_GetDictionary("TEXT_PLEASE_SELECT") & "');</script>"
    End IF
END FUNCTION


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION PerformActionOnSelectedSession(strAction)
  Dim objUIItems          ' AS CVariables
  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
  
  Form_ChangePage EventArg, 0, 0 ' We need to call the event our self here so we update the ProductView.Properties.Selector

  Dim messageIDs
  Set messageIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSet(ProductView.Properties.Rowset,"Message ID")

  If messageIDs.Count = 0 Then
      PerformActionOnSelectedSession = FALSE
      Exit Function
  End If
  
	dim bulkResubmit 
	set bulkResubmit = mdm_CreateObject("MetraTech.Pipeline.ReRun.BulkFailedTransactions")

  Select Case UCase(strAction)
    Case "SUBMIT" : bulkResubmit.ResubmitSuspendedMessageCollection (messageIDs)
    Case "DELETE" : bulkResubmit.DeleteSuspendedMessageCollection (messageIDs)
  End Select

  ProductView.Properties.Selector.Clear
  
  PerformActionOnSelectedSession = TRUE
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION DeleteSession(istrErrorID) ' As Boolean


  On Error Resume Next
  mobjFailures.AbandonLostSession CStr(istrErrorID)
  DeleteSession   = CBool(Err.Number)
  
  set mobjFailures = Nothing
	DeleteSession    = TRUE
End Function


%>

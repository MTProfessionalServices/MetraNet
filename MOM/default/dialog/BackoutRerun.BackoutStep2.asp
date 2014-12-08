 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BackoutRerun.BackoutStep2.asp$
'
'  Copyright 1998-2003 by MetraTech Corporation
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
'  $Date: 11/15/2002 12:35:31 PM$
'  $Author: Rudi Perkins$
'  $Revision: 2$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       :
' DESCRIPTION :
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%
PRIVATE m_strStep

Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = TRUE
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo        = "BackOutRerun.BackoutStep3.asp" 'mom_GetDictionary("WELCOME_DIALOG")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Framework.AssertCourseCapability "Manage Backouts and Reruns", EventArg

    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end

    if len(request.querystring("rerunid"))>0 then
      Session("BACKOUTRERUN_CURRENT_RERUNID")=clng(request.querystring("rerunid"))
      Session("BACKOUTRERUN_CURRENT_COMMENT")="[No comment because we resumed a previous backout]"
      Session("BACKOUTRERUN_CURRENT_RETURNURL")=request("ReturnUrl")
    end if

	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE


  '//Determine if Indentify/Analyze are complete yet
  Dim objReRun, bIsComplete
  m_strStep = "MTBillingReRun"
  Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)
  m_strStep = "MTBillingReRun.Login"
  objReRun.Login FrameWork.SessionContext
  If Not CheckError() Then Exit Function
  m_strStep = "MTBillingReRun.ID"
  objReRun.ID = Clng(Session("BACKOUTRERUN_CURRENT_RERUNID"))

  If Not CheckError() Then Exit Function

  objReRun.Synchronous = mom_GetBackoutRerunSynchronousOperationSetting
  bIsComplete = objReRun.IsComplete

  if not bIsComplete then
    Session("WaitRefreshCount") = Session("WaitRefreshCount")+1
    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.BackoutWait.asp?ReturnUrl=" & "BackoutRerun.BackoutStep2.asp" & "&Title=" & Server.UrlEncode("Backout Step 2: Results Of Identify & Analyze") & "&MessageTitle=" & Server.UrlEncode("Step 2 Status:")
  end if

  dim tableName
  tableName = objReRun.TableName
  'response.Write tableName

  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\mom"

  rowset.SetQueryTag("__GET_BACKOUT_ANALYZE_RESULT_INFORMATION__")
  rowset.AddParam "%%TABLE_NAME%%", tableName

  rowset.Execute


  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  'ProductView.Properties.AddPropertiesFromRowset rowset

  ProductView.Properties.SelectAll

  Service.Properties.Add "ReRunId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("ReRunId").Value=Session("BACKOUTRERUN_CURRENT_RERUNID")

  Service.Properties.Add "Comment", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("Comment").Value=Session("BACKOUTRERUN_CURRENT_COMMENT")

  Service.Properties.Add "SummaryNumberOfMessages", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "SummaryNumberOfDatabaseSessionsToBackout", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "SummaryNumberOfDatabaseSessionsInHardClosedIntervals", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "SummaryNumberOfFailedTransactionToBackout", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "SummaryNumberOfTransactionsVetoedByAdapters", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "SummaryNumberOfSynchronouslyMeteredTransactionsThatWontBeBackedOut", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET

  Service.Properties("View Name").Caption = mom_GetDictionary("TEXT_View_Name1")
  Service.Properties("Count").Caption = mom_GetDictionary("TEXT_Count1")
  Service.Properties("Amount").Caption = mom_GetDictionary("TEXT_Amount1")
  Service.Properties("Currency").Caption = mom_GetDictionary("TEXT_Currency1")

  dim rowset2
  set rowset2 = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset2.Init "queries\mom"

  rowset2.SetQueryTag("__GET_BACKOUT_ANALYZE_RESULT_SUMMARY_INFORMATION__")
  rowset2.AddParam "%%TABLE_NAME%%", tableName
	rowset2.Execute

  'Service.Properties("SummaryNumberOfMessages").Value=rowset2.value("NumberOfMessages")
  Service.Properties("SummaryNumberOfDatabaseSessionsToBackout").Value=rowset2.value("DatabaseSessionsToBackout")
  Service.Properties("SummaryNumberOfDatabaseSessionsInHardClosedIntervals").Value=rowset2.value("SessionsInHardClosedIntervals")
  Service.Properties("SummaryNumberOfFailedTransactionToBackout").Value=rowset2.value("FailedTransactionsToBackout")
  Service.Properties("SummaryNumberOfTransactionsVetoedByAdapters").Value=rowset2.value("TransactionsVetoedByAdapters")
  Service.Properties("SummaryNumberOfSynchronouslyMeteredTransactionsThatWontBeBackedOut").Value=rowset2.value("TransactionsMarkedSynchronous")

  'ProductView.Properties.CancelLocalization

  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog

END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col = 2 then
          EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>&nbsp;</td>"
          Form_DisplayCell = true
       else
          Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
       end if

END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean
  EventArg.HTMLRendered = EventArg.HTMLRendered & "</table><br><br><div align='center'>"
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<button Class='clsButtonXXXLarge' name='BackoutResubmit' onclick='mdm_RefreshDialog(this); return false;'>" & mom_GetDictionary("TEXT_Next_Step_Resubmit_These_Records") & "&nbsp;<IMG valign=middle border=0 src='/mcm/default/localized/en-us/images/icons/arrowSelect.gif'></button>&nbsp;&nbsp;"
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<button Class='clsButtonXXXLarge' name='BackoutDelete' onclick='if(confirm(""" & mom_GetDictionary("TEXT_Are_you_sure_you_wish") & """)){mdm_RefreshDialog(this); return false;}'>" & mom_GetDictionary("TEXT_Next_Step_Delete_These_Records") & "&nbsp;<IMG valign=middle border=0 src='/mcm/default/localized/en-us/images/icons/arrowSelect.gif'></button>&nbsp;&nbsp;"
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<button Class='clsButtonXXXLarge' name='Abandon' onclick='mdm_RefreshDialog(this); return false;'>" & mom_GetDictionary("TEXT_Abandon_This_Backout_And_Start_Over") & "</button>"
  EventArg.HTMLRendered = EventArg.HTMLRendered & "</div>"

  Form_DisplayEndOfPage = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    OK_Click = FALSE
    On Error Resume Next

    Dim objReRun, objFilter
    m_strStep = "MTBillingReRun.Setup"
    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)

    m_strStep = "MTBillingReRun.Login"
    objReRun.Login FrameWork.SessionContext

    If Not CheckError() Then Exit Function

    objReRun.ID = Clng(Service.Properties("ReRunId").Value)

    objReRun.Synchronous = false
    Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Backout_Prepare_Extract_In_Progress")
    m_strStep = "MTBillingReRun.BackoutPrepareExtract"
    objReRun.BackoutPrepareExtract Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function

    OK_Click = TRUE
END FUNCTION

PRIVATE FUNCTION BackoutResubmit_Click(EventArg) ' As Boolean

    BackoutResubmit_Click = FALSE
    On Error Resume Next

    Dim objReRun, objFilter
    m_strStep = "MTBillingReRun.Setup"
    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)

    m_strStep = "MTBillingReRun.Login"
    objReRun.Login FrameWork.SessionContext

    If Not CheckError() Then Exit Function

    objReRun.ID = Clng(Service.Properties("ReRunId").Value)

    objReRun.Synchronous = false
    Session("BACKOUTRERUN_CURRENT_TITLE_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Resubmit")
    Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Resubmit_In_Progress")
    Session("BACKOUTRERUN_COMPLETE_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Resubmit_Complete")
    Session("WaitRefreshCount")=Clng(0)
    
    m_strStep = "MTBillingReRun.BackoutResubmit"
    objReRun.BackoutResubmit Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function

    Dim objWinApi
    Set objWinApi = Server.CreateObject(CWindows)
    objWinApi.Sleep 500 'If we delay a half second, the operation will have a chance at being complete and we will not have to go to wait screen

    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.BackoutStep3.asp"

    BackoutResubmit_Click = TRUE
END FUNCTION

PRIVATE FUNCTION BackoutDelete_Click(EventArg) ' As Boolean

    BackoutDelete_Click = FALSE
    On Error Resume Next

    Dim objReRun, objFilter

    m_strStep = "MTBillingReRun.Setup"

    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)

    m_strStep = "MTBillingReRun.Login"
    objReRun.Login FrameWork.SessionContext

    If Not CheckError() Then Exit Function

    objReRun.ID = Clng(Service.Properties("ReRunId").Value)

    objReRun.Synchronous = false
    Session("BACKOUTRERUN_CURRENT_TITLE_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Delete")
    Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Delete_In_Progress")
    Session("BACKOUTRERUN_COMPLETE_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Delete_Complete")
    Session("WaitRefreshCount")=Clng(0)
    
    m_strStep = "MTBillingReRun.BackoutDelete"
    objReRun.BackoutDelete Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function
        ' Wait a second to be sure that all action hace a different dt_action
    Dim objWinApi
    Set objWinApi = Server.CreateObject(CWindows)
    objWinApi.Sleep 500 'If we delay a half second, the operation will have a chance at being complete and we will not have to go to wait screen
    
    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.BackoutStep3.asp"

    BackoutDelete_Click = TRUE
END FUNCTION



PRIVATE FUNCTION CheckError() ' As Boolean

    CheckError = FALSE
    If(Err.Number)Then
        EventArg.Error.Save Err
        EventArg.Error.Description = EventArg.Error.Description & "; Step=" & m_strStep
        Err.Clear
        Exit Function
    End If
    CheckError = TRUE

    ' Wait a second to be sure that all action hace a different dt_action
    Dim objWinApi
    Set objWinApi = Server.CreateObject(CWindows)
    objWinApi.Sleep 1
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Abandon_Click(EventArg) ' As Boolean

  on error resume next

  Abandon_Click = false

    Dim objReRun, objFilter

    m_strStep = "MTBillingReRun.Setup"

    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)

    m_strStep = "MTBillingReRun.Login"
    objReRun.Login FrameWork.SessionContext
    If Not CheckError() Then Exit Function

    objReRun.ID = Clng(Service.Properties("ReRunId").Value)

    m_strStep = "MTBillingReRun.Abandon"
    objReRun.Abandon Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function

    '//We successfully abandoned, return to whence we came
    if Session("BACKOUTRERUN_CURRENT_RETURNURL")<>"" then
      '// Return the batch screen from whence we came
      mdm_TerminateDialogAndExecuteDialog Session("BACKOUTRERUN_CURRENT_RETURNURL")
    else
      mdm_TerminateDialogAndExecuteDialog "BackoutRerun.BackoutStep1.asp"
    end if

  Abandon_Click = true

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Reanalyze_Click(EventArg) ' As Boolean

  Reanalyze_Click = false

    Dim objReRun, objFilter

    m_strStep = "MTBillingReRun.Setup"

    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)

    m_strStep = "MTBillingReRun.Login"
    objReRun.Login FrameWork.SessionContext
    If Not CheckError() Then Exit Function

    objReRun.ID = Clng(Service.Properties("ReRunId").Value)

    objReRun.Synchronous = mom_GetBackoutRerunSynchronousOperationSetting

    Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Backout_and_Delete")
    m_strStep = "MTBillingReRun.Analyze"
    objReRun.Analyze "Reanalyze"
    If Not CheckError() Then Exit Function

  Reanalyze_Click = true

END FUNCTION

%>

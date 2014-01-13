<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchManagement.UpdateStatus.asp$
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
'  $Date: 11/13/2002 5:45:45 PM$
'  $Author: Rudi Perkins$
'  $Revision: 7$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

PRIVATE CONST enum_FT_BULK_CHANGE_ALL                   = 1
PRIVATE CONST enum_FT_BULK_CHANGE_IF_PREVIOUS_VALUE_IS  = 2

Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Modal                      = FALSE

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean


	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Form("BatchId") = Request.QueryString("BatchId")                  
  Form("BatchTableId") = Request.QueryString("BatchTableId")
  Form("BatchAction") = Request.QueryString("BatchAction")
  Form("BatchStatus") = Request.QueryString("BatchStatus")
  Form("BatchDisplayName") = Request.QueryString("BatchDisplayName")

  Form.RouteTo			              = mom_GetDictionary("BATCH_MANAGEMENT_DIALOG") & "?ID=" & Form("BatchTableId")
  
  ' 1-Change all - 2-If Previous value is
  Service.Properties.Add "PageTitle"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchDisplayName"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchCurrentStatus"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Comment"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  
  
  'Set the title for the page
  select case Form("BatchAction")
    case "F"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_MARK_AS_FAILED_TITLE")
    case "C"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_MARK_AS_COMPLETED_TITLE")
    case "D"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_MARK_AS_DISMISSED_TITLE")
    case "B"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_BACKOUT_TITLE")
    case else
      Service.Properties("PageTitle").Value = "Doing some stuff"
   end select
   
   Service.Properties("BatchDisplayName").Value = Form("BatchDisplayName")
   Service.Properties("BatchCurrentStatus").Value = Form("BatchStatus")

  if Form("BatchAction")="B" and Form("BatchStatus")<>"F" then
    mdm_GetDictionary().Add "SHOW_BACKOUT_FAILED_STATE_WARNING", 1
  else
    mdm_GetDictionary().Add "SHOW_BACKOUT_FAILED_STATE_WARNING", 0
  end if
   
  'PopulateThePropertyComboBox
  
  Service.LoadJavaScriptCode  
  
	Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

  On Error Resume Next
  OK_Click = FALSE

  '//Update the status of the batch    
  dim mtbatch
  Set mtbatch = CreateObject(MT_BATCH_PROG_ID)
  
  mtbatch.SetSessionContext FrameWork.SessionContext
  
  select case Form("BatchAction")
  case "F"
    mtbatch.MarkAsFailed Form("BatchId"), Service.Properties("Comment").Value
    If Not CheckError("MarkAsFailed") Then Exit Function
  case "D"
    mtbatch.MarkAsDismissed Form("BatchId"), Service.Properties("Comment").Value
    If Not CheckError("MarkAsDismissed") Then Exit Function
  case "C"
    mtbatch.MarkAsCompleted Form("BatchId"), Service.Properties("Comment").Value
    If Not CheckError("MarkAsCompleted") Then Exit Function
  end select
  
  if Form("BatchAction")="B" then
    if ucase(Form("BatchStatus"))="ACTIVE" or ucase(Form("BatchStatus"))="COMPLETED" then
      mtbatch.MarkAsFailed Form("BatchId"), Service.Properties("Comment").Value
      If Not CheckError("MarkAsCompleted") Then Exit Function
    end if
    Form.RouteTo			              = "BackOutRerun.BackoutStep1.asp" & "?BatchTableId=" & Request.querystring("BatchTableId") & "&BatchId=" & server.urlencode(Form("BatchId")) & "&BatchComment=" & server.urlencode(Service.Properties("Comment").Value) & "&ReturnUrl=" & Server.UrlEncode(Form.RouteTo)
  end if  
    
  OK_Click = TRUE

END FUNCTION

PRIVATE FUNCTION CheckError(sStepNameForErrorMessage) ' As Boolean

    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = EventArg.Error.Description & "; Step=" & sStepNameForErrorMessage
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
    
END FUNCTION

%>




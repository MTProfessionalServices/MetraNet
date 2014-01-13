<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MOM Dialog
' DESCRIPTION	: 
' AUTHOR	    : Rudi
' VERSION	    : 1.0
'
'Check out and build UI\Server\MTAdminTools\MTConfigHelper from the 3.5 Branch.
'
'Dim objConfigHelper
'Set objConfigHelper= Server.CreateObject("MTConfigHelper.ConfigHelper")
'Call objConfigHelper.Initialize(false)
'
''Get the services
'Set collServices = objConfigHelper.GetServiceCollection
'
'for each objService in collServices
'  strPath = objService.Path
'next
'
'Set collPV = objConfigHelper.GetProductViewCollection
'
'for each objPV in collPV
'  strPath = objPV.Path
'next
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MoMLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%

PRIVATE m_strStep

Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = "BackOutRerun.List.asp?Filter=InProgress" 'mom_GetDictionary("WELCOME_DIALOG")
Form.ErrorHandler   = true

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Manage Backouts and Reruns", EventArg

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
    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.BackoutWait.asp?ReturnUrl=" & "BackoutRerun.BackoutStep3.asp" & "&Title=" & Server.UrlEncode("Backout Step 3: " & Session("BACKOUTRERUN_CURRENT_TITLE_MESSAGE")) & "&MessageTitle=" & Server.UrlEncode("Step 3 Status:")
  end if
    
  Service.Properties.Add "Title", "string", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("Title").Value=Session("BACKOUTRERUN_CURRENT_TITLE_MESSAGE")
  
  Service.Properties.Add "StatusMessage", "string", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("StatusMessage").Value=Session("BACKOUTRERUN_COMPLETE_STATUS_MESSAGE") 
 
  Service.Properties.Add "ReRunId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("ReRunId").Value=Session("BACKOUTRERUN_CURRENT_RERUNID")

  Service.Properties.Add "Comment", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("Comment").Value=Session("BACKOUTRERUN_CURRENT_COMMENT")

  call objRerun.Abandon("completed")
     
  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  if Session("BACKOUTRERUN_CURRENT_RETURNURL")<>"" then
    '// Return the batch screen from whence we came
    Form.RouteTo = Session("BACKOUTRERUN_CURRENT_RETURNURL")
  end if
    
  OK_Click = TRUE
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

%>


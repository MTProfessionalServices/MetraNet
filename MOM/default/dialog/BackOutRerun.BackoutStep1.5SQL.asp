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
Form.RouteTo        = "BackOutRerun.BackoutStep2.asp" 'mom_GetDictionary("WELCOME_DIALOG")
Form.ErrorHandler   = true

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Manage Backouts and Reruns", EventArg

  Service.Properties.Add "ReRunId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("ReRunId").Value=Session("BACKOUTRERUN_CURRENT_RERUNID")

  Service.Properties.Add "Comment", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("Comment").Value=Session("BACKOUTRERUN_CURRENT_COMMENT")
  
  'Determine which database help information/sample query to display
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\mom"
  
  if rowset.GetDBType = "{Oracle}" then
    Call mdm_GetDictionary.Add("DATABASE_IS_ORACLE", true)
  else
	Call mdm_GetDictionary.Add("DATABASE_IS_NOT_ORACLE", true)   
  end if
  
  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim objReRun, objFilter

    m_strStep = "MTBillingReRun.Setup"

    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)

    m_strStep = "MTBillingReRun.Login"
    objReRun.Login FrameWork.SessionContext
    If Not CheckError() Then Exit Function

    objReRun.ID = Clng(Service.Properties("ReRunId").Value)

    objReRun.Synchronous = mom_GetBackoutRerunSynchronousOperationSetting

    Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Identify_Complete_Analyze_In_Progress") 
    m_strStep = "MTBillingReRun.Analyze"
    objReRun.Analyze "Reanalyze"
    If Not CheckError() Then Exit Function

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


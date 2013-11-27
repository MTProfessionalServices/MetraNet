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
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MoMLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/LogInLib.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
'<!-- #INCLUDE FILE="../../auth.asp" -->

Form.RouteTo			              = mom_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form_Initialize = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: OK_Click
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION RefreshQueryFiles_Click(EventArg) ' As Boolean

    RefreshQueryFiles_Click = FALSE   
    on error resume next

    dim objQueryCache
    set objQueryCache=CreateObject("MTQueryCache.MTQueryCache.1")
    
    objQueryCache.RefreshConfiguration true
    RefreshQueryFiles_Click = CheckError("Refresh Query Cache")  
      

    
    'if (RefreshQueryFiles_Click) then
    '  dim sMessage
    '  sMessage = "<strong>Events Added: </strong>" & iAdded & "<BR><strong>Events Removed: </strong>" & iRemoved & "<BR>"
    '  Form.RouteTo = mdm_MsgBoxOk("Synchronize Adapter Configuration Complete", sMessage , "UsageServer.Synchronize.asp",empty) ' As String
    '  mdm_TerminateDialogAndExecuteDialog Form.RouteTo
    'end if
    
END FUNCTION

PRIVATE FUNCTION CheckError(sErrorMessage) ' As Boolean


    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = sErrorMessage & ":" & EventArg.Error.Description
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
    
END FUNCTION
    




%>

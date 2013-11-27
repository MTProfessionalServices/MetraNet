<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>

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
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
'There are two important cases where the SDK client should retry when sending sessions to the server.  
'The first case is when the routing queue is full on the server.  The server will return an error (MT_ERR_SERVER_BUSY) saying it is busy.  
'The second case is when the pipeline takes longer than the synchronous metering timeout to respond to a request.  
'This error is the infamous MT_ERR_SYN_TIMEOUT.
' 
'By retrying correctly, the client can wait any period of time for a request to go through.  
'This is especially important in applications like MAM, or any payment server client.
' 
'When a timeout or server busy error is returned, it's best to wait a little longer on each attempt to let the server do its work.  
'In my example below, I wait a second longer on each attempt.  You could also double the wait time on each attempt or multiply by some other factor.
' 
'TECH DOC: we need to document this somewhere so services knows how to correctly retry when metering.
' 
'DEVELOPMENT: if you're metering sessions somewhere I recommend you use a loop like this.  I can point you to examples in C++ or C#.
'
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

' Mandatory
Form.Version = MDM_VERSION     ' Set the dialog version

mdm_Main ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Service.Properties.Add "ActionMessage"  ,MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "OKMessage"      ,MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "CANCELMessage"  ,MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "ReTryCounter"   ,MSIXDEF_TYPE_INT32 ,0    ,FALSE,EMPTY
    
    Service("ReTryCounter").Caption = FrameWork.Dictionary().Item("TEXT_RETRY_COUNTER").Value    
    Service("ReTryCounter").Value   = 0
    
    Service("ActionMessage").Value  = mdm_UIValue("ActionMessage")
    Service("OKMessage").Value      = mdm_UIValue("OKMessage")
    Service("CANCELMessage").Value  = mdm_UIValue("CANCELMessage")
    Form.RouteTo                    = mdm_UIValue("RouteTo")
        
	  Form_Initialize                 = TRUE
END FUNCTION

PRIVATE FUNCTION cmdOK_Click(EventArg) ' As Boolean

  Dim booNeedToRetry
   Service("ReTryCounter").Value =  Service("ReTryCounter").Value + 1
  If mdm_MeteringTimeOutManagerReTry(EventArg, booNeedToRetry) Then
      cmdOK_Click = TRUE
      ConcludeDialog Service("OKMessage").Value,"OK"
  Else
      cmdOK_Click = FALSE
  End If
END FUNCTION

PRIVATE FUNCTION cmdCANCEL_Click(EventArg) ' As Boolean

    ConcludeDialog Service("CANCELMessage").Value,"CANCEL"
    cmdCANCEL_Click = TRUE
END FUNCTION

PRIVATE FUNCTION ConcludeDialog(strMessage, strStatusCode)
    mdm_MeteringTimeOutManagerClear
'    EventArg.Error.Description = strMessage
 '   EventArg.Error.Number      = 1
  '  Form_DisplayErrorMessage EventArg
   ' Response.Write "<INPUT Type='HIDDEN' Name='StatusCode' Value='" & strStatusCode & "'>"    
    'mdm_TerminateDialog
    'Response.End    
    Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_METERING_TIME_OUT_MANAGER_TITLE"), strMessage , Form.RouteTo)
    
    mdm_TerminateDialogAndExecuteDialog Form.RouteTo
END FUNCTION    

%>


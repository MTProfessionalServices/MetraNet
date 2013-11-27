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

mdm_Main ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    Service.Properties.Add "Message"  ,     MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "MessageTitle"  ,     MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "Title"          ,MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "RerunId"          ,MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "Comment"          ,MSIXDEF_TYPE_STRING,16000,FALSE,EMPTY
    Service.Properties.Add "RefreshCount"          ,"int32",0,FALSE,EMPTY

    Service("Message").Value        = Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE")
    Service("MessageTitle").Value   = mdm_UIValue("MessageTitle")
    Service("Title").Value          = mdm_UIValue("Title")
    Form.RouteTo                    = mdm_UIValue("ReturnUrl")

    Service("RefreshCount").Value          = Session("WaitRefreshCount")

    Service("ReRunId").Value=Session("BACKOUTRERUN_CURRENT_RERUNID")
    Service("Comment").Value=Session("BACKOUTRERUN_CURRENT_COMMENT")

	Form_Initialize = true
END FUNCTION






%>

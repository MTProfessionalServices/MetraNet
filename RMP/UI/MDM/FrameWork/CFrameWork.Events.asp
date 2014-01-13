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
' NAME		        : CFrameWork.Class.Asp - MetratTech Application FrameWork
' VERSION	        : 1.0
' CREATION_DATE   : 02/08/2001
' AUTHOR	        : UI Team
' DESCRIPTION	    : This file implement the Application/Framework event.
'                   This file is always included by CFrameWork.Class.asp, so the FrameWork object is available in the file.
' 
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST FRAMEWORK_APPLICATION_NAME = "MXX" ' We use this entry initialize the logger object

PUBLIC SUB Session_OnStart()
    FrameWork.Log "Session_OnStart()", LOGGER_DEBUG    
END SUB

PUBLIC SUB Session_OnEnd()
    FrameWork.Log "Session_OnEnd()", LOGGER_DEBUG    
END SUB

PUBLIC SUB Application_OnStart()
    FrameWork.Log "Application_OnStart()", LOGGER_DEBUG        
END SUB

PUBLIC SUB Application_OnEnd()
    FrameWork.Log "Application_OnEnd()", LOGGER_DEBUG    
END SUB

%>

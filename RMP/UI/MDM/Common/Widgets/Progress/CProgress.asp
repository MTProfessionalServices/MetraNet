<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2002 by MetraTech Corporation
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
' NAME          : CProgress.Asp - MetratTech DHTML Progress Bar
' VERSION       : 1.0
' CREATION_DATE : 02/10/2002
' AUTHOR        : Kevin A. Boucher
' DESCRIPTION   :
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Dim Progress
Set Progress = New CProgress   ' Allocate the progress bar instance

response.buffer = false

    
CLASS CProgress ' -- The Progress Bar Class --

      Public m_strWidgetName
      Private m_nDelay
      Private m_nServerTimeOut
      
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : GetProgressObject
	    ' PARAMETERS  : 
	    ' DESCRIPTION : Returns the COM+ ProgressReader to pass into batch operations
	    ' RETURNS     :      
      PUBLIC FUNCTION GetProgressObject()
        Set GetProgressObject = Server.CreateObject(MT_PROGRESS_READER_PROG_ID)        

        If Delay = 0 Then    
          GetProgressObject.ProgressString = "<script language='JavaScript'>setProgress(%d, %d);</script>" 
        Else
          GetProgressObject.ProgressString = "<script language='JavaScript'>setProgressSlow(%d, %d" & ", " & CLng(Delay) & ");</script>" 
        End If
        
      END FUNCTION
        
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : SetProgress
	    ' PARAMETERS  : lngPos, lngMax
	    ' DESCRIPTION : Moves the progress bar to the current position
	    ' RETURNS     :
	    PUBLIC FUNCTION SetProgress(lngPos,lngMax) ' As Boolean
        If Delay = 0 Then    
          response.write "<script language='JavaScript'>setProgress(" & CLng(lngPos) & "," & CLng(lngMax) & ");</script>" 
        Else
          response.write "<script language='JavaScript'>setProgressSlow(" & CLng(lngPos) & "," & CLng(lngMax) & "," & CLng(Delay) & ");</script>"         
        End If
        
        If Response.Buffer Then Response.Flush
        SetProgress = TRUE
	    END FUNCTION
		  
      ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : SetCaption
	    ' PARAMETERS  : strCaption
	    ' DESCRIPTION : Sets the caption that is displayed above the moving progress bar
	    ' RETURNS     :
	    PUBLIC FUNCTION SetCaption(strCaption) ' As Boolean
        response.write "<script language='JavaScript'>strCaption = '" & strCaption & "';</script>" 
        If Response.Buffer Then Response.Flush       
	      SetCaption = TRUE
	    END FUNCTION

      ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Surpress
	    ' PARAMETERS  :
	    ' DESCRIPTION : Forget about the progress bar - hides the progress bar and sets the operation to done
	    ' RETURNS     :
	    PUBLIC FUNCTION Suppress() ' As Boolean
        response.write "<script language='JavaScript'>setDone();</script>" 
        If Response.Buffer Then Response.Flush       
	      Suppress = TRUE
	    END FUNCTION
	    
      ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : RouteTo
	    ' PARAMETERS  : strRouteTo
	    ' DESCRIPTION : Because we cannot do a response.redirect or a server.transfer we have
      '               to write javascript to the client to navigate to the next page.
      '               We will not actually go to the next page until the progress bar has finished
      '               or we suppress it.  NOTE:  no server side script will execute after this call.
	    ' RETURNS     :
	    PUBLIC FUNCTION RouteTo(strRouteTo) ' As Boolean
	      mdm_Terminate
        response.write "<script language='JavaScript'>setRouteTo('" & strRouteTo & "');</script>" 
        If Response.Buffer Then Response.Flush
        Response.End  'End of the road for this dialog
	      RouteTo = TRUE
	    END FUNCTION    
	          
      ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Main Initialize
	    ' PARAMETERS  : EventArg
	    ' DESCRIPTION : 
	    ' RETURNS     :
	    PUBLIC FUNCTION Initialize(EventArg) ' As Boolean
        response.write Form("ProgressBackgroundHTML")  ' Here is the main trick, we need to write the original rendered HTML that we stored in the On_Paint Event
        response.write "<script language='JavaScript'>initialize();</script>" 
        If Response.Buffer Then Response.Flush
	      Initialize = TRUE
	    END FUNCTION    
      
      ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Reset
	    ' PARAMETERS  : EventArg
	    ' DESCRIPTION : 
	    ' RETURNS     :
	    PUBLIC FUNCTION Reset() ' As Boolean
        response.write "<script language='JavaScript'>initialize();</script>" 
        If Response.Buffer Then Response.Flush
	      Reset = TRUE
	    END FUNCTION    
            
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Default Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :
	    PRIVATE SUB Class_Initialize() ' As Boolean
        m_strWidgetName = "ProgressBar"
        Delay = 0
       
       ' Save timeout value and increase it for this page
       m_nServerTimeOut = Server.ScriptTimeout 
       Server.ScriptTimeout = 60 * 15    ' set to 15 minutes 
	    END SUB
      
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :
	    PRIVATE SUB Class_Terminate() ' As Boolean

      ' Set timeout back  
      Server.ScriptTimeout = m_nServerTimeOut   
	    END SUB		  
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET Delay() ' As String
	    
	       Delay = m_nDelay
	    END PROPERTY
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY LET Delay(nDelay) ' As String

	       m_nDelay = nDelay
	    END PROPERTY	    	    

END CLASS    	

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Paint
' PARAMETERS		  :
' DESCRIPTION 		: Important!  - If you implement your own Form_Paint you will have to set
'                   Form("ProgressBackgroundHTML") = EventArg.HTMLRendered on your own.
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Paint(EventArg) ' As Boolean
	  ' Use this next line if you want to keep the old dialog background
    'Form("ProgressBackgroundHTML") = EventArg.HTMLRendered
    
    Dim strHTML
    
    strHTML = strHTML & "<HTML>"
    strHTML = strHTML & "<HEAD>"
    strHTML = strHTML & "  <LINK Localized='TRUE' rel='STYLESHEET' type='text/css' href='/mdm/common/widgets/progress/ProgressStyles.css'>" 
    strHTML = strHTML & Form.Widgets("Progress").GetHeader()  
    strHTML = strHTML & "</HEAD>"
    strHTML = strHTML & "<body>"
    strHTML = strHTML & Form.Widgets("Progress").GetFooter()  
    strHTML = strHTML & "</body>"
    strHTML = strHTML & "</html>"
    
    Form("ProgressBackgroundHTML") = strHTML
    
    Form_Paint = TRUE
END FUNCTION
  
%>
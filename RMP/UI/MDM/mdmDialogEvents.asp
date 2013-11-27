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
' NAME		        :   MetraTech Dialog Manager - Default Dialog Events Implementation
' VERSION	        :   1.0
' CREATION_DATE   :   08/xx/2000
' AUTHOR	        :   F.Torres.
' DESCRIPTION	    :   This file contains the default implementation of the MDM ProductView Browser Events.
'                     For each event I define 2 functions, For instance :
'                     Form_DisplayBeginOfPage
'                     inheritedForm_DisplayBeginOfPage
'
'                     Form_DisplayBeginOfPage just calls inheritedForm_DisplayBeginOfPage, and nothing must be implemented
'                     in Form_DisplayBeginOfPage but every thing in inheritedForm_Initialize!
'                     WHY?
'                     This events are part of the MDM Product View Browser Form class. If you do not define
'                     an event the default one is executed. Now If you define your own event
'                     in the ASP Form file; your event is executed instead. A good Object Oriented question
'                     that comes then is How can I call the default implementation
'                     (the inherited event). 
'                     I want the programmer to be able to call the Default Super/Inherited Event from its own event
'                     this way inherited("Form_Initialize(EventArg)"). 
'                     In the case of Product View Browser Form; it is very use full to be able to call the inherited event.
'                     In the case of a Dialog Form only the event Form_Click contains code.
'                     Since it is use full in the PV and may become usefull in the next future for a dialog.
'                     F.TORRES 9/2/2000!
'
'                     The Form_Refresh event is not documented.
'
' ----------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: inheritedForm_Initialize
' PARAMETERS		:
' DESCRIPTION 	: Raise for the initialiation of the dialog
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Initialize(EventArg) ' As Boolean

  'mdm_LogWarning "Default Default Event Executed Form_Initialize()"    
	inheritedForm_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: inheritedForm_Paint
' PARAMETERS		:
' DESCRIPTION 	: Raise once the html template file has been rendered and yes sent to the client
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Paint(EventArg) ' As Boolean

  'mdm_LogWarning "Default Default Event Executed Form_Paint()"
	inheritedForm_Paint = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: inheritedForm_Paint
' PARAMETERS		:
' DESCRIPTION 	: Raise once the html template file has been rendered and yes sent to the client
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Open(EventArg) ' As Boolean

	inheritedForm_Open = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION inheritedOk_Click(EventArg) ' As Boolean

    'mdm_LogWarning "Default Default Event Executed OK_Click()"
    inheritedOK_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION inheritedCancel_Click(EventArg) ' As Boolean

    'mdm_LogWarning "Default Default Event Executed Cancel_Click()"
	  inheritedCancel_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Click(EventArg) ' As Boolean
    
    'mdm_LogWarning "Default Default Event Executed PRIVATE FUNCTION Form_Click(EventArg)"    
    inheritedForm_Click = Eval(EventArg.Name & "_Click(EventArg)")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Terminate(EventArg) ' As Boolean

  'mdm_LogWarning "Default Default Event Executed Form_Terminate()"
	inheritedForm_Terminate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Error(EventArg) ' As Boolean

    'mdm_LogWarning "Default Default Event Executed Form_Error()"
    inheritedForm_Error = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Refresh(EventArg) ' As Boolean

    'mdm_LogWarning "Default Default Event Executed Form_Refresh()"
    inheritedForm_Refresh = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_DisplayErrorMessage(EventArg) ' As Boolean
    
	Response.write "<TABLE Width='100%' CellPadding=0 CellSpacing=0 Border=0>"                                              & vbNewLine
	Response.write "<TR><TD Class='ErrorMessageCaption'>MDM Default Error Message</TD></TR>"                                & vbNewLine
	Response.write "<TR><TD Class='ErrorMessage'>&nbsp;" & EventArg.Error.ToString() & "</TD></TR>" & vbNewLine
	Response.write "</TABLE>" & vbNewLine

	inheritedForm_DisplayErrorMessage = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_Populate(EventArg) ' As Boolean

    'mdm_LogWarning "Default Default Event Executed inheritedForm_Populate()"
    inheritedForm_Populate = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	: This event is not used..
' RETURNS			  :
PRIVATE FUNCTION inheritedForm_TimeOut(EventArg) ' As Boolean

	inheritedForm_TimeOut = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' PUBLIC DEFINITION OF THE EVENTS
' ---------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean    

	Form_Initialize = inheritedForm_Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_Paint(EventArg) ' As Boolean

	Form_Paint = inheritedForm_Paint(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    OK_Click = inheritedOk_Click(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION Cancel_Click(EventArg) ' As Boolean

	Cancel_Click = inheritedCancel_Click(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_Click(EventArg) ' As Boolean   

    Form_Click = inheritedForm_Click(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_Terminate(EventArg) ' As Boolean

	Form_Terminate = inheritedForm_Terminate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_Error(EventArg) ' As Boolean

    Form_Error = inheritedForm_Error(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: Form_Refresh
' PARAMETERS		:
' DESCRIPTION 	: This is event is not documented
' RETURNS			  :
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    Form_Refresh = inheritedForm_Refresh(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: inheritedForm_Populate
' PARAMETERS		:
' DESCRIPTION 	: Not documented this event is raised before we populated the MSIXHandler instance.
'                 So if there is a bad value...coming from the UI, we can change it...
' RETURNS			  :
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
    Form_Populate = inheritedForm_Populate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_DisplayErrorMessage(EventArg) ' As Boolean

	Form_DisplayErrorMessage = inheritedForm_DisplayErrorMessage(EventArg)
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: Form_Open
' PARAMETERS		:
' DESCRIPTION 	: Raise once the html template file has been rendered and yes sent to the client
' RETURNS			  :
PRIVATE FUNCTION Form_Open(EventArg) ' As Boolean

	Form_Open = inheritedForm_Open(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_TimeOut(EventArg) ' As Boolean

	Form_TimeOut = inheritedForm_TimeOut(EventArg)
END FUNCTION

%>

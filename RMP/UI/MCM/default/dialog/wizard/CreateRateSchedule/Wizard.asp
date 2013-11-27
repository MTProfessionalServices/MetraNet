<%
' //==========================================================================
' // @doc $Workfile: D:\source\development\UI\MTAdmin\us\checkIn.asp$
' //
' // Copyright 1998 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' // Created by: Noah Cushing
' //
' // $Date: 5/11/00 11:51:14 AM$
' // $Author: Noah Cushing$
' // $Revision: 6$
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Wizard.asp                                                               '
'  Render pages of the wizard.                                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit
response.expires = 0

%>
  <!-- #INCLUDE FILE="WizardInclude.asp" -->
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->

<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'gobjMTWizard  is created by include file
Dim strHTML     'HTML for the page

strHTML = gobjMTWizard.GetPageHTML()


Call ProcessForm()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ProcessForm()                                               '
' Description : Handle the form submission, perform any custom data         '
'             : processing, then redirect to the appropriate page of the    '
'             : wizard.                                                     '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ProcessForm()
  Dim strName
  Dim strValue
  Dim i
  Dim bForward
  Dim bFinish
  
  'If updating then
  if UCase(request.QueryString("Update")) = "TRUE" then
    'Parse the form data and store it in the session

    'Get the form data
    for i = 1 to request.Form.Count
      strName = request.Form.key(i)

      'Note: This does not handle multi-selects, multi-checkboxes yet
      strValue = request.form(strName)

      if UCase(strName) = "DIRECTION" then
        if UCase(strValue) = "FORWARD" then
          bForward = true
        else
          bForward = false
        end if
        if UCase(strValue) = "FINISH" then
        	'response.write("Finish")
			'response.end
			bFinish=true
        end if
      end if
      
      if len(strName) >= len(gobjMTWizard.Name) then
        if left(strName, len(gobjMTWizard.Name)) = gobjMTWizard.Name then
          session(strName) = strValue
        end if
      end if
    next
    
    'Check inputs expected by the wizard
    Call gobjMTWizard.CheckInputs()
    
    'If a validation routine was specified for this update and we are moving forward, execute it
    if bForward and gobjMTWizard.UpdateVerificationRoutine <> "" then
      if not eval(gobjMTWizard.UpdateVerificationRoutine) then
        'We did not pass the validation routine, so return to the same page, prepared to display an error
        response.redirect("Wizard.asp?PageID=" & gobjMTWizard.CurrentPage & "&Error=Y&Path=" & gobjMTWizard.Path)
      end if
    end if
  
    'If we are finished, to WizardEnd.asp, otherwise go to the previous or next page
    if bFinish then
      Call response.redirect("WizardEnd.asp?PageID=" & gobjMTWizard.PreviousPage & "&Path=" & gobjMTWizard.Path)
    else
	    if bForward then
	      Call response.redirect("wizard.asp?PageID=" & gobjMTWizard.NextPage & "&Path=" & gobjMTWizard.Path)
	    else
	      Call response.redirect("wizard.asp?PageID=" & gobjMTWizard.PreviousPage & "&Path=" & gobjMTWizard.Path)    
	    end if
    end if
    
    
  end if
End Function


Response.write strHTML
%>


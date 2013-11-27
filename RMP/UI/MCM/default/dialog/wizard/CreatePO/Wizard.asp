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
Dim strHTML

strHTML = gobjMTWizard.GetPageHTML()


Call ProcessForm()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ProcessForm()                                               '
' Description : Handle the form submission, perform any custom data         '
'             : processing, Then redirect to the appropriate page of the    '
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
  
  'If updating Then
  
  If UCase(request.QueryString("Update")) = "TRUE" Then
  
    'Parse the form data and store it in the session
    
    For i = 1 to request.Form.Count 'Get the form data
    
      strName  = Request.Form.key(i)
      strValue = Request.form(strName) 'Note: This does not handle multi-selects, multi-checkboxes yet

      if UCase(strName) = "DIRECTION" Then
      
          bForward = CBool ( UCase(strValue) = "FORWARD" )        
          If UCase(strValue) = "FINISH" Then bFinish = true
      End If
      
      if len(strName) >= len(gobjMTWizard.Name) Then
      
        if left(strName, len(gobjMTWizard.Name)) = gobjMTWizard.Name Then
        
          session(strName) = strValue
        End If
      End If
    Next
    
    Call gobjMTWizard.CheckInputs() 'Check inputs expected by the wizard
    
    If bForward And gobjMTWizard.UpdateVerificationRoutine <> "" Then 'If a validation routine was specified for this update and we are moving forward, execute it
    
      If Not eval(gobjMTWizard.UpdateVerificationRoutine) Then
      
            response.redirect("Wizard.asp?PageID=" & gobjMTWizard.CurrentPage & "&Error=Y&Path=" & gobjMTWizard.Path) 'We did not pass the validation routine, so return to the same page, prepared to display an error
      End If
    End If
    
    If bFinish Then 'If we are finished, to WizardEnd.asp, otherwise go to the previous or next page
    
        Call response.redirect("WizardEnd.asp?PageID=" & gobjMTWizard.PreviousPage & "&Path=" & gobjMTWizard.Path)
    Else
    
  	    If bForward Then
        
  	      Call response.redirect("wizard.asp?PageID=" & gobjMTWizard.NextPage & "&Path=" & gobjMTWizard.Path)
  	    Else
  	      Call response.redirect("wizard.asp?PageID=" & gobjMTWizard.PreviousPage & "&Path=" & gobjMTWizard.Path)    
  	    End If
    End If
  End If
End Function

Response.write Replace(strHTML, "﻿", "")  ' We remove the BOM in case someone saved the wizard template as utf-8 with BOM
%>

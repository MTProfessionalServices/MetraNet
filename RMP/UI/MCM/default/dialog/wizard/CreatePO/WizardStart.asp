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

Option Explicit
response.expires = 0

%>
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->
<%


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  WizardStart.asp                                                          '
'  Contains initialization routines for the dynamic wizard.                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'gobjMTWizard  is created by include file
Dim mstrWizardPath        'Path to the wizard, passed in via the URL
Dim mobjServiceWizard     'Service Wizard Helper object

Call ClearWizardSession()

  Dim strWizard
  strWizard = gobjMTWizard.Name

if UCASE(request("CREATENEW"))= "TRUE" then
  session(strWizard & "_CreateNew") = "1"
  session(strWizard & "_SELECTTEMPLATE") = "-1"  ' This indicates the template doesn't exist
else
  session(strWizard & "_CreateNew") = "0"
end if
	
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ClearWizardSession()                                      '
' Description   : Clear all session variables associated with this wizard.  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ClearWizardSession()
  Dim strWizard
  Dim xSessionItem
  
  strWizard = gobjMTWizard.Name
  
  for each xSessionItem in Session.Contents
    if len(xSessionItem) >= len(strWizard) then
      if left(xSessionItem, len(strWizard)) = strWizard then
        
        if isobject(Session.Contents(xSessionItem)) then
          Set Session.Contents(xSessionItem) = nothing
        else
          Session.Contents(xSessionItem) = ""
        end if
      
      end if
    end if
  next
End Function

response.redirect("Wizard.asp?Path=" & gobjMTWizard.Path & "&PageiD=" & gobjMTWizard.CurrentPage)
response.end

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''               Page Processing                     '''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <script language="Javascript">
      window.open('Wizard.asp?Path=<%=gobjMTWizard.Path%>&PageiD=<%=gobjMTWizard.CurrentPage%>', '_blank', 'height=400,width=600,resizable=yes,scrollbars=yes');
    </script>
  </head>
  <body>
  </body>
</html>


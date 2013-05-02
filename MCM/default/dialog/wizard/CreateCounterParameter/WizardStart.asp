<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998 - 2002 by MetraTech Corporation
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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' DIALOG	    : WizardStart.asp
' DESCRIPTION	: 
' AUTHOR	    : K. Boucher
' VERSION	    : V3.5
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
response.expires = -1000
%>
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->
  <!-- #INCLUDE VIRTUAL="/MDM/FrameWork/CFrameWork.Class.asp"-->
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/MTProductCatalog.Library.asp"-->
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
      
session(strWizard & "_ReturnURL") = Request.QueryString("NextPage")

' Objects used to build Counter Parameter
Set session(strWizard & "_MTCounterParameter") = server.CreateObject("Metratech.MTCounterParameter")
Set session(strWizard & "_ProductViewCatalog") = server.CreateObject("Metratech.ProductViewCatalog")
Set session(strWizard & "_ProductViewCatalog").SessionContext = FrameWork.SessionContext
  
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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''               Page Processing                     '''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <script language="Javascript">
  	  window.location = 'Wizard.asp?Path=<%=gobjMTWizard.Path%>&PageiD=<%=gobjMTWizard.CurrentPage%>';
    </script>
  </head>
  <body>
  </body>
</html>


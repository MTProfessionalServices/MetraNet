<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2006 by MetraTech Corporation
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
' NAME        : CustomCode.asp
' DESCRIPTION : The goal of this file is to store all the MetraCare
'               functions that have been customized.
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: CustomCheckAccountTypeBusinessRules
' PARAMETERS	: objAccountType, objMenuTab
' DESCRIPTION : Adjusts the menu according to custom acount type business rules
' RETURNS			: True or False
PUBLIC FUNCTION CustomCheckAccountTypeBusinessRules(objAccountType, objMenuTab)

  CustomCheckAccountTypeBusinessRules = FALSE
  
  ' Make all links visible to start with...
  Dim link
  For Each link in objMenuTab.MenuLinks
    link.Visible = TRUE
  Next

	' Add your Account Type-specific business rules here

  CustomCheckAccountTypeBusinessRules = TRUE
END FUNCTION

%>

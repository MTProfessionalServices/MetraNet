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
' // Created by: Dave Wood
' //
' // $Date: 5/11/00 11:51:14 AM$
' // $Author: Noah Cushing$
' // $Revision: 6$
' //==========================================================================

'On Error Resume Next

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Styles.asp                                                                 '
'  Set the styles for the classes used by the wizard.                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim gobjTestObject

'Clear the error
err.clear



'Initialize the forms object
Set gobjTestObject = gobjMTForms

if err then
  err.clear
else
  gobjMTForms.LegendClass       = "clsWizardLegend"
  gobjMTForms.TableBodyClass    = "clsWizardBody"
  gobjMTForms.PromptClass       = "clsWizardPrompt"
  gobjMTForms.InputClass        = "clsWizardInputBox"
  gobjMTForms.SelectClass       = "clsWizardInputBox"
  gobjMTForms.MultiSelectClass  = "clsWizardInputBox"
  gobjMTForms.RadioClass        = "clsWizardInputBox"
  gobjMTForms.CheckboxClass     = "clsWizardInputBox"
end if

'Initialize the grid object
Set gobjTestObject = gobjMTGrid

if err then
  err.clear
else
  gobjMTGrid.HeaderStyle        = "clsWizardTableSubHeader"
  gobjMTGrid.SubHeaderSTyle     = "clsWizardTableSubHeader"
  gobjMTGrid.OddRowStyle        = "clsWizardPromptOdd"
  gobjMTGrid.EvenRowStyle       = "clsWizardPromptEven"
  gobjMTGrid.DivStyle           = "clsWizardScrollingDiv"
  gobjMTGrid.TableStyle         = "clsWizardBody"
  gobjMTGrid.AlternateStyles    = true
end if

%>


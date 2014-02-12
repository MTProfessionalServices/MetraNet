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
  <!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->
  <!-- #INCLUDE VIRTUAL="/MDM/FrameWork/CFrameWork.Class.asp"--> 
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/MTProductCatalog.Library.asp"-->  
<%



  Dim strWizardName
  strWizardName = gobjMTWizard.Name

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject
  
  Dim intTypeId
  Dim objChargeType

  Dim intTemplateId  'This is the id we pass pack to the calling page (PO uses it to know what to item to add)

  Dim poId
  poId = session("POID")
  
  ' Determine if we are adding an existing template or if we are creating a new one  
  if session(strWizardName & "_SELECTTEMPLATE") <>  "-1" then
    ' We are adding an existing template
    intTemplateId = CLng(session(strWizardName & "_SELECTTEMPLATE"))

  else
    ' We are creating a new template    
    intTypeId = Clng(session(strWizardName & "_NewType"))
    set objChargeType = objMTProductCatalog.GetPriceableItemType(intTypeId)
    
    Dim objChargeTemplate
    set objChargeTemplate = objChargeType.CreateTemplate
    
    objChargeTemplate.Name = session(strWizardName & "_Name")
    objChargeTemplate.DisplayName = session(strWizardName & "_DisplayName")
    objChargeTemplate.Description = session(strWizardName & "_Description")

    dim sUsersCurrentLanguageCode
    sUsersCurrentLanguageCode = Framework.GetLanguageCodeForCurrentUser()
    
    dim sDefaultDisplayNameSuffix
    sDefaultDisplayNameSuffix=FrameWork.GetDictionary("PRODUCT_CATALOG_DEFAULT_LOCALIZED_DISPLAY_NAME_SUFFIX")
  
    dim objLanguage
    for each objLanguage in objChargeTemplate.DisplayNames
      if objLanguage.LanguageCode=sUsersCurrentLanguageCode then
        'User specified this language
        objChargeTemplate.DisplayNames.SetMapping objLanguage.LanguageCode, session(strWizardName & "_DisplayName")
      else
        'Set the default for other language as what the user specified plus the language code  
        objChargeTemplate.DisplayNames.SetMapping objLanguage.LanguageCode, session(strWizardName & "_DisplayName") & Replace(sDefaultDisplayNameSuffix,"%%LANGCODE%%", objLanguage.LanguageCode)
      end if
    next
    
    for each objLanguage in objChargeTemplate.DisplayDescriptions
      if objLanguage.LanguageCode=sUsersCurrentLanguageCode then
        'User specified this language
        objChargeTemplate.DisplayDescriptions.SetMapping objLanguage.LanguageCode, session(strWizardName & "_Description")
      else
        'Set the default for other language as what the user specified plus the language code  
        objChargeTemplate.DisplayDescriptions.SetMapping objLanguage.LanguageCode, session(strWizardName & "_Description") & Replace(sDefaultDisplayNameSuffix,"%%LANGCODE%%", objLanguage.LanguageCode)
      end if
    next
    
    Dim intEventId
    'intEventId = Clng(session(strWizardName & "_NewEvent"))
    
    objChargeTemplate.NonRecurringChargeEvent = Clng(session(strWizardName & "_NewEvent"))

    On Error Resume Next  
	
    objChargeTemplate.Save
   	if (Err.Number) then
		    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
		    'Adding HTML Encoding
		    'session(strWizardName & "__ErrorMessage") = Err.Description
		    session(strWizardName & "__ErrorMessage") = SafeForHtmlAttr(Err.Description)
    	response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/AddNonRecurringCharge&PageID=summary&Error=Y")    
 	  End If
    intTemplateId = objChargeTemplate.ID
  end if
  
	
  ClearWizardSession
  
  
  
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
    <SCRIPT language="JavaScript" src="/mpte/shared/browsercheck.js"></SCRIPT>
   	<SCRIPT language="JavaScript" src="/mdm/internal/mdm.JavaScript.lib.js"></SCRIPT>	
  	<SCRIPT language="JavaScript">
		  //POMODE is 1 means,called from Product offering else called from Service  Charges
	    if(parseInt(<%=session("POMode")%>)==1)
      {	 		
       	document.location.href = "/MCM/default/dialog/Proxy.PriceableItem.asp?AddItem=<%=intTemplateId%>&ID=<%=poId%>";
      }
		  else
			{
		    window.opener.location = AddToQueryString(''+window.opener.location,'AddItem=<%=intTemplateId%>');	  
			  window.close();	 
			}		
    </script>
  </head>
  <body>
  </body>
</html>


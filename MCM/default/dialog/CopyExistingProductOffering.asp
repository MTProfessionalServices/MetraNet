<%
' //==========================================================================
' // @doc $Workfile$
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
' // $Date$
' // $Author$
' // $Revision$
' //==========================================================================

Option Explicit
response.expires = 0

%>
  <!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->
  <!-- #INCLUDE VIRTUAL="/MDM/FrameWork/CFrameWork.Class.asp"-->
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/MTProductCatalog.Library.asp"-->  
<%

  On Error Resume Next 

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject 
	
  Dim objNewProductOffering
  Dim poPartitionId
  Dim poName

    dim intSourceProductOfferingId, objSourceProductOffering

    intSourceProductOfferingId   = 510
	poName = "New PO"
	Set objSourceProductOffering = objMTProductCatalog.GetProductOffering(intSourceProductOfferingId)   
    Set objNewProductOffering    = objSourceProductOffering.CreateCopy(poName, session(strWizardName & "_CurrencyCode"))
    If Err.Number Then 
      SetErrorAndRedirect Err.Description
    End If
  End if 

  'Set objNewProductOffering = session(strWizardName & "ProductOffering")

  objNewProductOffering.Name = poName
  objNewProductOffering.DisplayName = session(strWizardName & "_DisplayName")
  objNewProductOffering.Description = session(strWizardName & "_Description")
  
  for each objLanguage in objNewProductOffering.DisplayDescriptions
    if objLanguage.LanguageCode=sUsersCurrentLanguageCode then
      'User specified this language
      objNewProductOffering.DisplayDescriptions.SetMapping objLanguage.LanguageCode, session(strWizardName & "_Description")
    else
      'Set the default for other language as what the user specified plus the language code  
      objNewProductOffering.DisplayDescriptions.SetMapping objLanguage.LanguageCode, session(strWizardName & "_Description") & Replace(sDefaultDisplayNameSuffix,"%%LANGCODE%%", objLanguage.LanguageCode)
    end if
  next
    
  objNewProductOffering.SetCurrencyCode("USD") ' session(strWizardName & "_CurrencyCode")) - Enabling Rating Currency 5/29/2013
  
  if session(strWizardName & "_effectivedatestart") <> "" then
	  objNewProductOffering.EffectiveDate.StartDate = CDate(session(strWizardName & "_effectivedatestart"))
  end if

  if session(strWizardName & "_availabilitydatestart") <> "" then
	  objNewProductOffering.AvailabilityDate.StartDate = CDate(session(strWizardName & "_availabilitydatestart"))
	end if

  If (Err.Number) then
    SetErrorAndRedirect Err.Description
  End If

  dim sUsersCurrentLanguageCode
  sUsersCurrentLanguageCode = Framework.GetLanguageCodeForCurrentUser()

  dim sDefaultDisplayNameSuffix
  sDefaultDisplayNameSuffix=FrameWork.GetDictionary("PRODUCT_CATALOG_DEFAULT_LOCALIZED_DISPLAY_NAME_SUFFIX")
  
  dim objLanguage
  for each objLanguage in objNewProductOffering.DisplayNames
    if objLanguage.LanguageCode=sUsersCurrentLanguageCode then
      'User specified this language
      objNewProductOffering.DisplayNames.SetMapping objLanguage.LanguageCode, Cstr(session(strWizardName & "_DisplayName"))
    else
      'Set the default for other language as what the user specified plus the language code  
      objNewProductOffering.DisplayNames.SetMapping objLanguage.LanguageCode, session(strWizardName & "_DisplayName") & Replace(sDefaultDisplayNameSuffix,"%%LANGCODE%%", objLanguage.LanguageCode)
    end if
  next

  objNewProductOffering.Properties.Item("POPartitionId") = poPartitionId

  objNewProductOffering.Save
 
%>
<html>
  <head>
    <script language="Javascript">
        // window.opener.top.MainContentIframe.ticketFrame.location.href = '/mcm/default/dialog/ProductOffering.ViewEdit.Frame.asp?ID=<%=objNewProductOffering.ID%>';
        // window.opener.top.MainContentIframe.location.reload(true); // This reloads the whole page. Next option is much better because it instructs the grid to reload just the data
        window.opener.top.MainContentIframe.LoadStoreWhenReady_ctl00_ContentPlaceHolder1_MTFilterGrid1();
        window.close();
    </script>
  </head>
  <body>
  </body>
</html>


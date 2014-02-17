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
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/CProductCatalogBillingCycle.class.asp"-->
 
<%

  Dim strWizardName
  strWizardName = gobjMTWizard.Name

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject
  
  Dim intTypeId
  Dim objChargeType 
  Dim  obj
  Dim intTemplateId  'This is the id we pass pack to the calling page (PO uses it to know what to item to add)
  
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
    
    'objChargeTemplate.Cycle.Relative  = UCase(session(strWizardName & "_Cycle__Relative")) = "TRUE"
		objChargeTemplate.Cycle.Relative = (Clng(session(strWizardName & "_CycleOption")) = 0)
			
		if Clng(session(strWizardName & "_CycleOption")) = 0 then
			'// Billing Cycle Relative
			if session(strWizardName & "_ConstrainSubscriberCycle") or session(strWizardName & "_Cycle__Relative") = "on" then
				objChargeTemplate.Cycle.CycleTypeID = Clng(session(strWizardName & "_Cycle__Relative_PeriodChoice"))
			else
				objChargeTemplate.Cycle.CycleTypeID = 0
			end if
		else
			objChargeTemplate.Cycle.CycleTypeID =  Clng(session(strWizardName & "_CycleTypeID")) '4	' weekly 
			'// Fixed Cycle
    	select case Clng(session(strWizardName & "_CycleTypeID"))
				case BILLING_CYCLE_MONTHLY: 
					objChargeTemplate.cycle.EndDayOfMonth = Clng(session(strWizardName & "_Cycle__Cycle@EndDayOfMonth_Monthly"))
				case BILLING_CYCLE_WEEKLY:
					objChargeTemplate.cycle.EndDayOfWeek = Clng(session(strWizardName & "_Cycle__EndDayOfWeek"))
				case BILLING_CYCLE_BI_WEEKLY:
					Set obj = Session("BI-WEEKLY.CycleType" & Clng(session(strWizardName & "_Cycle__BIWeekly")))  
					obj.CopyTo objChargeTemplate.Cycle
				case BILLING_CYCLE_SEMI_MONTHLY:
					objChargeTemplate.cycle.EndDayOfMonth = Clng(session(strWizardName & "_Cycle@EndDayOfMonth_SemiMonthly"))
					objChargeTemplate.cycle.EndDayOfMonth2 = Clng(session(strWizardName & "_Cycle__EndDayOfMonth2"))
				case BILLING_CYCLE_QUATERLY:
					objChargeTemplate.cycle.StartMonth = Clng(session(strWizardName & "_CycleStartMonthQuarterly"))
					objChargeTemplate.cycle.StartDay = Clng(session(strWizardName & "_CycleStartDayQuarterly"))
				case BILLING_CYCLE_ANNUALLY:
					objChargeTemplate.cycle.StartMonth = Clng(session(strWizardName & "_CycleStartMonthAnnual"))
					objChargeTemplate.cycle.StartDay = Clng(session(strWizardName & "_CycleStartDayAnnual"))
				case BILLING_CYCLE_SEMIANNUALLY:
					objChargeTemplate.cycle.StartMonth = Clng(session(strWizardName & "_CycleStartMonthSemiAnnual"))
					objChargeTemplate.cycle.StartDay = Clng(session(strWizardName & "_CycleStartDaySemiAnnual"))
  		end select
		end if
   
	 On Error Resume Next  

   objChargeTemplate.Save
   if (Err.Number) then
		 'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
		 'Adding HTML Encoding
		 'session(strWizardName & "__ErrorMessage") = Err.Description
		 session(strWizardName & "__ErrorMessage") = SafeForHtmlAttr(Err.Description)
     response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/AddDiscount&PageID=summary&Error=Y")    
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
	 		 var POID;
			 POID =<%=session("POID")%>;
			 	document.location.href = "/MCM/default/dialog/Proxy.PriceableItem.asp?AddItem=<%=intTemplateId%>"+"&ID="+POID;
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



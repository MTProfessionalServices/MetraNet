<%
' //==========================================================================
' // @doc $Workfile: WizardEnd.asp$
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
' // $Date: 11/18/2002 3:52:06 PM$
' // $Author: Frederic Torres$
' // $Revision: 29$
' //==========================================================================

Option Explicit
response.expires = 0

%>
  <!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->
  <!-- #INCLUDE VIRTUAL="/mpte/shared/Helpers.asp" -->
  <!-- #INCLUDE VIRTUAL="/MDM/FrameWork/CFrameWork.Class.asp"-->
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/MTProductCatalog.Library.asp"-->
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/CProductCatalogBillingCycle.class.asp"-->
 
<%

  Dim strWizardName, booIsUDRC
  strWizardName = gobjMTWizard.Name

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject
  
  Dim intTypeId
  Dim objChargeType
  Dim obj
  Dim intTemplateId  'This is the id we pass pack to the calling page (PO uses it to know what to item to add)
  
  ' Determine if we are adding an existing template or if we are creating a new one  
  if session(strWizardName & "_SELECTTEMPLATE") <>  "-1" then
    ' We are adding an existing template
    intTemplateId = CLng(session(strWizardName & "_SELECTTEMPLATE"))

  else
  

    ' We are creating a new template
    intTypeId = Clng(session(strWizardName & "_NewType"))
    
    set objChargeType = objMTProductCatalog.GetPriceableItemType(intTypeId)
    
    booIsUDRC = objChargeType
    
    Dim objChargeTemplate
    set objChargeTemplate = objChargeType.CreateTemplate
    
    objChargeTemplate.Name = session(strWizardName & "_Name")
    objChargeTemplate.DisplayName = session(strWizardName & "_DisplayName")

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
    
    objChargeTemplate.Description = session(strWizardName & "_Description")
    for each objLanguage in objChargeTemplate.DisplayDescriptions
      if objLanguage.LanguageCode=sUsersCurrentLanguageCode then
        'User specified this language
        objChargeTemplate.DisplayDescriptions.SetMapping objLanguage.LanguageCode, session(strWizardName & "_Description")
      else
        'Set the default for other language as what the user specified plus the language code  
        objChargeTemplate.DisplayDescriptions.SetMapping objLanguage.LanguageCode, session(strWizardName & "_Description") & Replace(sDefaultDisplayNameSuffix,"%%LANGCODE%%", objLanguage.LanguageCode)
      end if
    next
  
    dim bChargeInAdvance
    dim bProrateOnActivation
    dim bProrateOnDeactivation
    dim bProrateOnRateChange
    dim bChargePerParticipant

   if session(strWizardName & "_ChargeInAdvance") = "" then
    	objChargeTemplate.ChargeInAdvance = false
   else
     objChargeTemplate.ChargeInAdvance =  cbool(session(strWizardName & "_ChargeInAdvance"))
   end if

   if session(strWizardName & "_ProrateBasedOn") = "" then
   	objChargeTemplate.FixedProrationLength = false
   else
     objChargeTemplate.FixedProrationLength = cbool(session(strWizardName & "_ProrateBasedOn"))
   end if
    
   if session(strWizardName & "_ProrateOnActivation") = "" then
   	objChargeTemplate.ProrateOnActivation = false
   else
     objChargeTemplate.ProrateOnActivation = cbool(session(strWizardName & "_ProrateOnActivation"))
   end if
   
   if session(strWizardName & "_ProrateOnDeactivation") = "" then
   	 objChargeTemplate.ProrateOnDeactivation = false
   else
       objChargeTemplate.ProrateOnDeactivation = cbool(session(strWizardName & "_ProrateOnDeactivation"))
   end if

   if session(strWizardName & "_ChargePerParticipant") = "" then
   	 objChargeTemplate.ChargePerParticipant = false
   else
     objChargeTemplate.ChargePerParticipant = cbool(session(strWizardName & "_ChargePerParticipant"))
   end if

 
   if Clng(session(strWizardName & "_CycleOption")) = 0 then 'Relative
      if session(strWizardName & "_ConstrainSubscriberCycle") or session(strWizardName & "_Cycle__Relative") = "on" then 'Relative, constrained
        objChargeTemplate.Cycle.Mode = CYCLE_MODE_BCR_CONSTRAINED
				objChargeTemplate.Cycle.CycleTypeID = Clng(session(strWizardName & "_Cycle__Relative_PeriodChoice"))
			else
        objChargeTemplate.Cycle.Mode = CYCLE_MODE_BCR 'Relative, non-constrained
			end if
    elseif Clng(session(strWizardName & "_CycleOption")) = 1 Then '"Extended-Relative" or Aligned to subscriber's billing cycle
		  objChargeTemplate.Cycle.Mode = CYCLE_MODE_EBCR
		  objChargeTemplate.Cycle.CycleTypeID = Clng(session(strWizardName & "_Cycle__ExtendedRelative_PeriodChoice"))
		else
      '// Explicitly configured cycle
      objChargeTemplate.Cycle.Mode = CYCLE_MODE_FIXED ' New enum that describes the mode of the recurring charge - fixed, bcr 
      
      objChargeTemplate.Cycle.CycleTypeID =  Clng(session(strWizardName & "_CycleTypeID"))
	    select case objChargeTemplate.Cycle.CycleTypeID
	  	  case BILLING_CYCLE_MONTHLY
	      	objChargeTemplate.cycle.EndDayOfMonth = Clng(session(strWizardName & "_Cycle__Cycle@EndDayOfMonth_Monthly"))
	  	  case BILLING_CYCLE_WEEKLY
	      	objChargeTemplate.cycle.EndDayOfWeek = Clng(session(strWizardName & "_Cycle__EndDayOfWeek"))
		  	case BILLING_CYCLE_BI_WEEKLY
					Set obj = Session("BI-WEEKLY.CycleType" & Clng(session(strWizardName & "_Cycle__BIWeekly")))  
					obj.CopyTo objChargeTemplate.Cycle
		  	case BILLING_CYCLE_SEMI_MONTHLY
	       	objChargeTemplate.cycle.EndDayOfMonth = Clng(session(strWizardName & "_Cycle@EndDayOfMonth_SemiMonthly"))
	     		objChargeTemplate.cycle.EndDayOfMonth2 = Clng(session(strWizardName & "_Cycle__EndDayOfMonth2"))
	  	  case BILLING_CYCLE_QUATERLY
	       	objChargeTemplate.cycle.StartMonth = Clng(session(strWizardName & "_CycleStartMonthQuarterly"))
	    		objChargeTemplate.cycle.StartDay = Clng(session(strWizardName & "_CycleStartDayQuarterly"))
	      case BILLING_CYCLE_ANNUALLY
	      	objChargeTemplate.cycle.StartMonth = Clng(session(strWizardName & "_CycleStartMonthAnnual"))
	  	  	objChargeTemplate.cycle.StartDay = Clng(session(strWizardName & "_CycleStartDayAnnual"))
	      case BILLING_CYCLE_SEMIANNUALLY
	      	objChargeTemplate.cycle.StartMonth = Clng(session(strWizardName & "_CycleStartMonthSemiAnnual"))
	  	  	objChargeTemplate.cycle.StartDay = Clng(session(strWizardName & "_CycleStartDaySemiAnnual"))
	  	end select
		end if
    
    ' UDRC
    If Session("AddRecurring_IsUDRC")="TRUE" Then
    
        objChargeTemplate.UnitName        = Session(strWizardName & "_UnitName")
        
        ' Add Unit Display Name and create a default for each language with appropriate suffix
        objChargeTemplate.UnitDisplayName = Session(strWizardName & "_UnitDisplayName")
        
        dim sUsersCurrentLanguageCode1
        sUsersCurrentLanguageCode1 = Framework.GetLanguageCodeForCurrentUser()

        dim sDefaultDisplayNameSuffix1
        sDefaultDisplayNameSuffix1=FrameWork.GetDictionary("PRODUCT_CATALOG_DEFAULT_LOCALIZED_DISPLAY_NAME_SUFFIX")
      
        dim objLanguage1
        for each objLanguage1 in objChargeTemplate.UnitDisplayNames
          if objLanguage1.LanguageCode=sUsersCurrentLanguageCode then
            'User specified this language
            objChargeTemplate.UnitDisplayNames.SetMapping objLanguage1.LanguageCode, session(strWizardName & "_UnitDisplayName")
          else
            'Set the default for other language as what the user specified plus the language code  
            objChargeTemplate.UnitDisplayNames.SetMapping objLanguage1.LanguageCode, session(strWizardName & "_UnitDisplayName") & Replace(sDefaultDisplayNameSuffix1,"%%LANGCODE%%", objLanguage1.LanguageCode)
          end if
        next
            
        objChargeTemplate.RatingType      = CLng(Session(strWizardName & "_RatingType"))
        
        ' Must strip out the thousand separators to keep IsNumeric() happy.
        dim strMinValueNoThousandSeparators
        dim strMaxValueNoThousandSeparators
        strMinValueNoThousandSeparators = Replace(Session(strWizardName & "_MinUnitValue"), GetThousandSeparator(), "")
        strMaxValueNoThousandSeparators = Replace(Session(strWizardName & "_MaxUnitValue"), GetThousandSeparator(), "")

        If CBool(Len(Session(strWizardName & "_MinUnitValue"))) And IsNumeric(strMinValueNoThousandSeparators) Then
            objChargeTemplate.MinUnitValue  = CDec(Session(strWizardName & "_MinUnitValue"))
        End If
        If CBool(Len(Session(strWizardName & "_MaxUnitValue"))) And IsNumeric(strMaxValueNoThousandSeparators) Then
            objChargeTemplate.MaxUnitValue  = CDec(Session(strWizardName & "_MaxUnitValue"))
        End If
        
        objChargeTemplate.IntegerUnitValue = CBool(Session(strWizardName & "_IntegerUnitValue"))
    End If
		
    On Error Resume Next   

		' FEAT-4151 - ProrateInstantly is an obsolete property, that won't be used in future.
		objChargeTemplate.ProrateInstantly = false

		objChargeTemplate.Save
    
		if (Err.Number) then
        'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
        'Adding HTML Encoding
        'session(strWizardName & "__ErrorMessage") = Err.Description
    	session(strWizardName & "__ErrorMessage") = SafeForHtmlAttr(Err.Description)
    	response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/AddRecurringCharge&PageID=summary&Error=Y")    
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


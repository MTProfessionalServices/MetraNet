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
  
  <!-- #INCLUDE VIRTUAL="/MDM/mdmConst.asp"-->

  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/MultiTenancyLib.asp"-->
<%

  On Error Resume Next 
  
  Dim strWizardName
  strWizardName = gobjMTWizard.Name
  
  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject
  
  Dim objPriceList
  set objPriceList = objMTProductCatalog.CreatePriceList
  
  objPriceList.Name = session(strWizardName & "_Name")
  objPriceList.Description = session(strWizardName & "_description")
  'Disabling Currency dropdown as part of Enabling Rating Currency
  objPriceList.CurrencyCode = "USD" ' session(strWizardName & "_CurrencyCode")
  
  'Currently this indicates that the price list is a regular pricelist and not a ICB specific pricelist
  objPriceList.Shareable = true

  ' If this is a Partition admin, Prefix PL name with Partition name
  If Session("isPartitionUser") Then
    objPriceList.Name = Session("topLevelAccountUserName") + ":" + objPriceList.Name
  End If

  objPriceList.Save

  if (Err.Number) then
    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
    'Adding HTML Encoding
    'session(strWizardName & "__ErrorMessage") = Err.Description
    session(strWizardName & "__ErrorMessage") = SafeForHtmlAttr(Err.Description)
    response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreatePriceList&PageID=summary&Error=Y")    
  End If
 
  ' If this operation is being performed by a Partition user, save PartitionId in Extended properties
  'Dim PLPartitionId
  'If Session("isPartitionUser") Then
    ' objPriceList.Properties.Item("PLPartitionId") = Session("topLevelAccountId") ' Support for Extended properties for PLs was never finished
   ' PLPartitionId = Session("topLevelAccountId")
  'Else
  '  PLPartitionId = 1
  'End If
  'Dim success
  'success = SavePartitionIdForPriceList(objPriceList.ID, PartitionId)

  if (Not(success)) then
    session(strWizardName & "__ErrorMessage") = "Failed to add Partition Id to new Pricelist"
    response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreatePriceList&PageID=summary&Error=Y")    
  End If


  dim strRedirectUrl
  if session(strWizardName & "_ReturnURL")<>"" then
    strRedirectUrl = session(strWizardName & "_ReturnURL")
    strRedirectUrl = strRedirectUrl & "?PickerAddMapping=TRUE&mdmAction=Refresh"
		
    strRedirectUrl = strRedirectUrl & "&PickerIDs=" & objPriceList.ID
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
	  <SCRIPT language="JavaScript" src="/mdm/internal/mdm.JavaScript.lib.js"></SCRIPT>	
    <script language="Javascript">
    var strRedirectURL ="<% = strRedirectUrl %>";
    //window.alert("[" + strRedirectURL + "]");
   
	if (strRedirectURL.length == 0)
    {
		  window.opener.location = (window.opener.location); 
    }
    else
    {
      if (String(strRedirectURL).substring(0,16) == "DISPLAY_NEW_ITEM")
      {
          // window.opener.top.MainContentIframe.ticketFrame.location.href = '/mcm/default/dialog/Pricelist.ViewEdit.Frame.asp?ID=<%=objPriceList.ID%>';
          window.opener.top.MainContentIframe.LoadStoreWhenReady_ctl00_ContentPlaceHolder1_MTFilterGrid1();
      }
      else
      {
        window.opener.location = (strRedirectURL);
      }
    }
	  window.close();
    </script>
  </head>
    
  <body>
  </body>
</html>


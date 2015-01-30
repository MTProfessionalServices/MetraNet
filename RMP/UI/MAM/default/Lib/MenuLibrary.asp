<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2005 by MetraTech Corporation
'  All rights reserved
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
' ---------------------------------------------------------------------------------------------------------------------------------------
' NAME		    : MenuLibrary.asp
' AUTHOR	    : Kevin A. Boucher
' DESCRIPTION : MetraCare Menu rendering functions
' ---------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: MenuInitialize
' PARAMETERS	:
' DESCRIPTION : Sets up the initial menu state for MetraCare
' RETURNS			:
PUBLIC FUNCTION MenuInitialize() ' As Boolean

  If Not HideAccountMenus() Then Exit Function

  ' Reset the normal caption - subscriber not found
  MAM().Dictionary.ADD "TEXT_DYNAMIC_MAIN_MENU_TAB_SUBSCRIBER", mam_GetDictionary("TEXT_MAIN_MENU_TAB_SUBSCRIBER")
  MAM().Dictionary("SEND_EMAIL_DIALOG").value="mailto:"

  MenuInitialize = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: HideAccountMenus()
' PARAMETERS	: Hides all the menus
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION HideAccountMenus()
  
  ' Loop through the menu tabs and hide them all except the admin and action menus
  Dim menuTab 
  For Each menuTab in MAM().Menu.MenuTabs
    If UCase(menuTab.Id) = "ADMINISTRATION" or _
       UCase(menuTab.Id) = "ACTIONS" Then
      menuTab.Visible = TRUE
    Else
      menuTab.Visible = FALSE
    End If
  Next

  HideAccountMenus = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_AccountFound(booYes) ' As Boolean

    Dim strImage, strPriceListID, objPricelist, acctID, refDate, objMTProductCatalog, accountType, objAccountType, objMenuTab
		
    strImage = mam_GetDictionary("DEFAULT_PATH_REPLACE") &  "/images/CloseWindow.gif"
    
		Call HideAccountMenus()
 		
    If(booYes)Then
        
        Session("CURRENT_SYSTEM_USER") = Empty
          
			  ' Set SubscriberYAAC
        On error resume next
        Set Session("SubscriberYAAC") = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), mam_ConvertToSysDate(mam_GetHierarchyTime()))
        If err.number <> 0 then
          Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
        End If
        On error goto 0  
        
        accountType = Session("SubscriberYAAC").AccountType 
        Set objAccountType = mam_GetAccountType(accountType)
        If MAM().Menu.MenuTabs.Exist(accountType) and not LCase(accountType) = "coresubscriber" Then
          Set objMenuTab = MAM().Menu.MenuTabs(accountType)
          Call CustomCheckAccountTypeBusinessRules(objAccountType, objMenuTab)
        Else
          ' If no menu exists for the account type load the core subscriber menu
          ' and check account type business rules to hide menu options
          Set objMenuTab = MAM().Menu.MenuTabs("CoreSubscriber")
          Call CheckAccountTypeBusinessRules(objAccountType, objMenuTab)
        End If
        objMenuTab.Visible = TRUE      

        If MAM().Subscriber.Exist("EMail") Then
          MAM().Dictionary("SEND_EMAIL_DIALOG").value = "mailto:" & MAM().Subscriber("EMail")
        End If

        Dim strName, strTitle, strToolTip, strStatus, strHTML, strIcon

        strIcon = "<img src='/ImageHandler/images/Account/" & accountType & "/" & "account.gif" & _ 
                "?Payees=" & "0" & _
                "&State=" & Session("SubscriberYAAC").GetAccountStateMgr().GetStateObject().Name & _
                "&Folder=" & Session("SubscriberYAAC").IsFolder & "&R=33&G=48&B=107'>"
       
        strTitle = Server.HTMLEncode(mam_GetFieldIDFromAccountID(mam_GetSubscriberAccountID()))
 
        strStatus = mam_GetFieldIDFromAccountID(mam_GetSubscriberAccountID())

        strToolTip = strToolTip & "User Name:&nbsp;&nbsp;" & Session("SubscriberYAAC").LoginName & vbcrlf 
        strToolTip = strToolTip & "Namespace:&nbsp;&nbsp;" & Session("SubscriberYAAC").Namespace  & vbcrlf     
        strToolTip = strToolTip & "Account Type:&nbsp;&nbsp;" & accountType            

        strName = strName & "<table cellspacing='0' cellpadding='0' border='0'>"
        strName = strName & " <tr valign='middle'>"
        strName = strName & "  <td title='" & strToolTip & "' class='clsSelectedAccount' dropEvent='HandleDrop' onMouseOver=""window.status='" _
                                    & Replace(Replace(strStatus, "'", "\'"), """", "&quot;") & "';"" onMouseDown=""SelectMe('" & mam_GetSubscriberAccountID() & "');"""_
                                    & " id='text" & mam_GetSubscriberAccountID() & "' " _
                                    & " dragID='" & mam_GetSubscriberAccountID() & "' >" & strIcon & strStatus _
                          & "  </td>" _
                          & " </tr>" _
                          & "</table>"  
 
        strHTML = strHTML & "<script language='JavaScript1.2'>window.status='" & Replace(Replace(strStatus, "'", "\'"), """", "&quot;") & "';</script>"                                
        strHTML = strHTML & "<table align='right' width='235px' border='0' cellpadding='0' cellspacing='0'>"
        strHTML = strHTML & "  <tr>"
        strHTML = strHTML & "    <td valign='top' align='left' class='clsSubscriberHeading' width='100%'>"
        strHTML = strHTML & strName & "</td>"
        strHTML = strHTML & "    <td valign='top' align='right' class='clsCloseSubscriber' width='16px%'>"
        strHTML = strHTML & "      <a target='main' onclick='parent.hierarchy.ClearHighlight();' href='" &  mam_GetDictionary("SUBSCRIBER_FOUND") & "'><IMG Border=0 src='/mam/default/localized/en-us/images/CloseWindow.gif' alt='" & mam_GetDictionary("TEXT_CLOSEWINDOW") & "'></a>"
        strHTML = strHTML & "    </td>"
        strHTML = strHTML & "  </tr>"
        strHTML = strHTML & "</table>"
     
        MAM().Dictionary.ADD "TEXT_DYNAMIC_MAIN_MENU_TAB_SUBSCRIBER", strHTML
				 
        ' Massage Subscriber Rowset
        ' I have to go and get the pricelist name, because the finder only gives me the ID...
        ' but I need to meter the name... It is important that we do this every time we find a new subscriber
        Call mam_ConvertPriceListIDToString()
				
     Else
        ' Reset the normal caption - subscriber not found
        MAM().Dictionary.ADD "TEXT_DYNAMIC_MAIN_MENU_TAB_SUBSCRIBER", mam_GetDictionary("TEXT_MAIN_MENU_TAB_SUBSCRIBER")
        MAM().Dictionary("SEND_EMAIL_DIALOG").value="mailto:"
    
        Session("SubscriberYAAC") = Empty
        Session("CURRENT_SYSTEM_USER") = Empty  
    End If
    
    mam_AccountFound = TRUE
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_SystemUserFound(bFound) 
' DESCRIPTION	: Update the menu if the System User was found or not.  
' PARAMETERS	: bFound -- Indicates if the System User was found or not. 
' RETURNS		  :
Public Function mam_SystemUserFound(bFound)
  Dim strHTML
  Dim strTitle
  Dim strName
  Dim systemUser
  Dim objMapping
  
  Call HideAccountMenus()
  
  if bFound then

    Session("SubscriberYAAC") = Empty  
    Set systemUser = mam_GetSystemUser()
    
    strTitle = mam_GetDictionary("TEXT_SYSTEM_USER")
    strName = systemUser.AccountName & " (" & systemUser.AccountID & ")"
  
    strHTML = strHTML & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">"
    strHTML = strHTML & "  <tr>"
    strHTML = strHTML & "    <td class=""clsSubscriberHeading"">"
    strHTML = strHTML & "      " & Server.HTMLEncode(strTitle) & "</td>"
    strHTML = strHTML & "    <td valign=""top"" align=""right"" class=""clsCloseSubscriber"">"
    strHTML = strHTML & "      <a target=""main"" onclick=""parent.hierarchyUser.ClearHighlight();"" href=""" &  mam_GetDictionary("SUBSCRIBER_FOUND") & """><IMG Border=0 src=""/mam/default/localized/en-us/images/CloseWindow.gif"" alt=""" & mam_GetDictionary("TEXT_SYSTEM_USER") & """></a>"
    strHTML = strHTML & "    </td>"
    strHTML = strHTML & "  </tr>"
    strHTML = strHTML & "  <tr>"
    strHTML = strHTML & "    <td style=""font-size:11;font-weight:normal;"" colspan=""2"" class=""clsSubscriberHeading"">"
    strHTML = strHTML & "      " & strName & "</td>"
    strHTML = strHTML & "  </tr>"
    strHTML = strHTML & "</table>"
   
    MAM().Dictionary.ADD "TEXT_SYSTEM_USER_DYNAMIC_MAIN_MENU_TAB", strHTML
    MAM().Menu.MenuTabs("SystemUser").Visible = true
  Else
    Session("CURRENT_SYSTEM_USER") = Empty  
  End If
    
  mam_SystemUserFound = TRUE  

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: SetMenuLinkState
' PARAMETERS	: strLinkName, bEnabled
' DESCRIPTION : Takes in a menu link name as string and a condition 
' RETURNS			: True or False
PUBLIC FUNCTION SetMenuLinkState(strLinkName, bEnabled)
  SetMenuLinkState = FALSE

  Dim menuTab 
  For Each menuTab in MAM().Menu.MenuTabs
  	If menuTab.menulinks.Exist(strLinkName) Then	    
      If CBool(bEnabled) Then
        menuTab.menulinks(strLinkName).Enabled = TRUE  
      Else
        menuTab.menulinks(strLinkName).Enabled = FALSE
      End IF
    End If  
  Next
	
  SetMenuLinkState = TRUE
END FUNCTION
  
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: CheckAccountTypeBusinessRules
' PARAMETERS	: objAccountType, objMenuTab
' DESCRIPTION : Adjusts the menu according to acount type business rules
' RETURNS			: True or False
PUBLIC FUNCTION CheckAccountTypeBusinessRules(objAccountType, objMenuTab)
  CheckAccountTypeBusinessRules = FALSE
  
  ' Make all links visible to start with...
  Dim link
  For Each link in objMenuTab.MenuLinks
    link.Visible = TRUE
  Next
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Apply Account Type business rules to menu
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  ' Can be payer?
  If Not objAccountType.CanBePayer Then
    objMenuTab.MenuLinks("Payer").Visible = FALSE
    objMenuTab.MenuLinks("PaymentMethods").Visible = FALSE
  End If

 ' Can subscribe?
  If Not objAccountType.CanSubscribe AND Not objAccountType.CanParticipateInGSub Then
    objMenuTab.MenuLinks("SetupSubscriptions").Visible = FALSE
  End If
  
  ' Is Corporate?
  If Not objAccountType.IsCorporate Then
    objMenuTab.MenuLinks("GroupSubscriptions").Visible = FALSE  
    objMenuTab.MenuLinks("OwnerAccounts").Visible = FALSE  
  End If
    
  ' Visible in hierarchy? 
  If Not objAccountType.IsVisibleInHierarchy Then
    objMenuTab.MenuLinks("MoveAccount").Visible = FALSE
  End If

  ' Can exist in unconnected state? 
  If Not objAccountType.CanHaveSyntheticRoot Then
  
  End If

  ' Can have templates?
  If Not objAccountType.CanHaveTemplates Then
    objMenuTab.MenuLinks("EditAccountTemplate").Visible = FALSE
  End If  

  ' Can have children?
  Dim rs
  Set rs = objAccountType.GetDescendentAccountTypesAsRowset()
  If rs.RecordCount = 0 Then
    objMenuTab.MenuLinks("EditAccountTemplate").Visible = FALSE
	End If

  'In the case this is a new account type using the coresubscriber menu as a default, we need to turn off the contact info link (when this account type doesn't have its own custom menu of actions)
  select case UCase(objAccountType.Name)
    case "CORESUBSCRIBER", "CORPORATEACCOUNT", "DEPARTMENTACCOUNT", "INDEPENDENTACCOUNT":
      'Leave the menu option for updating contact information as it is
    case else
      'Turn off the contact option since we do not know if this account type supports contact information
      objMenuTab.MenuLinks("ContactInfo").Visible = FALSE
  end select
  'Call SetMenuLinkState("ContactInfo", false)    

  CheckAccountTypeBusinessRules = TRUE
END FUNCTION


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

  CustomCheckAccountTypeBusinessRules = TRUE
END FUNCTION
        

%>
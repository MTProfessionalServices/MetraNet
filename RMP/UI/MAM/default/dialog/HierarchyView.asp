<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit

Session.codepage = 65001 
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MAMLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<HTML>
<HEAD>
  <meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=UTF-8">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/styles.css">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/MAMMenu.css">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/ListTabs.css">  
  <META http-equiv="Page-Enter" content="blendTrans(Duration=.1)"> 
  <META http-equiv="Page-Exit" content="blendTrans(Duration=.1)">  

  <!-- Drag & Drop Functions --> 
  <script language="Javascript" src="/mam/default/dialog/js/dragdrop.js"></script> 
      
</HEAD>

<BODY onDrag="fOnDrag();" onDragEnd="fOnDragEnd();" onDragLeave="fOnDragLeave();" onDragEnter="fOnDragEnter();" onDragStart="fOnDragStart();" onDragOver="fOnDragOver();" onDrop="fOnDrop();"  style="background-color:#003B8E;margin:0px 14px 6px 5px;">

<!-- DIV for dragable shadow --> 
<div class="clsDragDiv" id="dragDiv"></div>

<span id="header">
  <ul>
      <%  
      If FrameWork.CheckCoarseCapability("Manage Account Hierarchies") or FrameWork.CheckCoarseCapability("Manage Sales Force Hierarchies") or FrameWork.CheckCoarseCapability("Manage Owned Accounts") Then 
      %>
       <li <%=GetCurrentTab("menu")%>><a OnClick="JavaScript:parent.showMenu();" href="<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=menu"><%=mam_GetDictionary("TEXT_MENU")%></a></li>
      <%
      End If
      If FrameWork.CheckCoarseCapability("Manage Account Hierarchies") or FrameWork.CheckCoarseCapability("Manage Owned Accounts") Then 
      %>
       <li <%=GetCurrentTab("account")%>><a OnClick="JavaScript:parent.showHierarchy();" href="<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=account"><%=mam_GetDictionary("TEXT_ACCOUNTS")%></a></li> 
      <%
      End If
      If FrameWork.CheckCoarseCapability("Manage Sales Force Hierarchies") Then
      %>
       <li <%=GetCurrentTab("sfh")%>><a OnClick="JavaScript:parent.showUserHierarchy();" href="<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=sfh"><%=mam_GetDictionary("TEXT_USERS")%></a></li>
      <%
      End If
      If FrameWork.CheckCoarseCapability("Manage Account Hierarchies") or FrameWork.CheckCoarseCapability("Manage Owned Accounts") Then 
      %>
      <li <%=GetCurrentTab("search")%>><a OnClick="JavaScript:parent.showSearch(false);" href="<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=search"><%=mam_GetDictionary("TEXT_FIND_ACCOUNT")%></a></li>
      <%
      End If
      %>      
  </ul>
</span>

<span id="blend">
  <div class='ActiveAccount'><%=ActiveAccount()%></div>
</span>
<%
Function ActiveAccount()
  On Error Resume Next

    If UCase(Session("SubscriberYAAC").AccountType) = UCase("INDEPENDENTACCOUNT") or _
       Session("SubscriberYAAC").CorporateAccountID = -1  then
    Else
       ActiveAccount = "<a style='dragable:true;' dragID='" & Session("SubscriberYAAC").AccountID & "' OnClick='showHierarchy(""" & Session("SubscriberYAAC").AccountID & """, ""FALSE"");' href='#'><img align='absmiddle' border='0' src='/mam/default/localized/en-us/images/sync.gif' alt='Find Account in Hierarchy'></a>&nbsp;"
    End IF
    ActiveAccount = ActiveAccount & "<a style='dragable:true;text-decoration:none;color:white' dragID='" & Session("SubscriberYAAC").AccountID & "' OnClick='showHierarchy(""" & Session("SubscriberYAAC").AccountID & """, ""FALSE"");' href='#'>" & Session("SubscriberYAAC").AccountName & " (" & Session("SubscriberYAAC").AccountID & ")</a>" 

    If err Then
      err.clear
      ActiveAccount = "<a OnClick='showHierarchy(""" & Session("CURRENT_SYSTEM_USER").AccountID & """, ""TRUE"");' href='#'><img align='absmiddle' border='0' src='/mam/default/localized/en-us/images/sync.gif' alt='Find Account in Hierarchy'></a>&nbsp;"
      ActiveAccount = ActiveAccount & Session("CURRENT_SYSTEM_USER").AccountName & " (" & Session("CURRENT_SYSTEM_USER").AccountID & ")" 
      If err Then
         err.clear
        ActiveAccount = ""
      End If  
    End If
  On Error Goto 0
End Function

Function GetCurrentTab(menu)
  GetCurrentTab = ""
  If LCase(mdm_UIValue("mdmCurrentTab")) = "" Then
    If LCase(menu) = "menu" Then
      GetCurrentTab = "id=""current"""
      Session("HelpContext") = "Welcome.asp.htm"           
    End If
  Else
    If LCase(mdm_UIValue("mdmCurrentTab")) = LCase(menu) Then
      GetCurrentTab = "id=""current"""

      ' Set help page based on tab
      Select Case LCase(mdm_UIValue("mdmCurrentTab"))
        Case "menu"
         Session("HelpContext") = "Menu_Tab_Introduction.htm"
        Case "account"
          Session("HelpContext") = "Accounts_Tab_Introduction.htm"
        Case "sfh"
          Session("HelpContext") = "Users_Tab_Introduction.htm"
        Case "search"
          Session("HelpContext") = "Search_Introduction.htm"
      End Select      
    End If
  End If  

End Function 

%>

      <script language="JavaScript1.2">

        function showHierarchy(id, systemUser)
        {
          parent.secret.document.location.href = "FindAccountInHierarchy.asp?ID=" + id + "&IsSystemUser=" + systemUser;    
        }
           
      </script>
</BODY>
</HTML>
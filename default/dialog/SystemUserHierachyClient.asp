<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 2003 by MetraTech Corporation
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
' 
' DIALOG	    :  SystemUserHierarchyclient.asp 
' DESCRIPTION	:  System Account Hierarchy Tree view - Managed Control
' AUTHOR	    :  Kevin A. Boucher 
' VERSION	    :  5.1 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- METADATA type="TypeLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/mamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
response.buffer = true

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Check Manage Account Hierarchies Capability and cache it in session
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
If IsEmpty(Session("CAP_MANAGE_SALES_FORCE")) Then
  Session("CAP_MANAGE_SALES_FORCE") = FrameWork.CheckCoarseCapability("Manage Sales Force Hierarchies")
End IF
If Not Session("CAP_MANAGE_SALES_FORCE") Then 
 response.end
End If
       
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim mobjHC              'Hierarchy class
Dim mstrID              'ID to get
Dim mstrAction          'Action to perform
Dim objDictionary       'Dictionary 

Set objDictionary = Session("objMAM").Dictionary     ' Dictionary object for the hierarchy page

mstrAction  = request.QueryString("Action")

If len(mstrAction) = 0 Then
  Set mobjHC = server.CreateObject(MT_HIERARCHY_HELPER_PROG_ID)
  Set mobjHC.actorYaac = Session("CSR_YAAC")
  Set session("SYSTEM_USER_HIERARCHY_HELPER") = mobjHC
  mobjHC.SnapShot = CDate(GetGMTDateFormatted() & " " & objDictionary("END_OF_DAY").Value)
else
  Set mobjHC = session("SYSTEM_USER_HIERARCHY_HELPER")  
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Run Action:  Drop, Load, Unload, Date or Find
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Select Case UCase(mstrAction)
  Case "DROP"
    Session("DROP_ACTION") = UCase(request.form("DropAction"))
    Session("CHILD")       = request.form("Child")
    Session("PARENT")      = request.form("Parent")

    response.write "<script>parent.main.location.href = '" & mam_GetDictionary("SYSTEM_USER_HIERARCHY_MOVE_DATE_DIALOG") & "'</script>"
     
  Case "DATE"
    Dim newDate
    newDate = DateSerial(request.Form("Year"),request.Form("Month"),request.Form("Day")) 
  	If IsDate(newDate) Then
      newDate = CDate(int(CDbl(CDate(newDate)))) ' Convert CDate to CLng to strip off time,then convert back to Cdate - this avoids localization issues
      mobjHC.SnapShot = CDate(newDate & " " & objDictionary("END_OF_DAY").Value)
	    'Call mobjHC.Show(mstrID)
      If mam_GetSubscriberAccountID() <> 0 Then
        ' We have an account loaded, see if he exists at this time in the hierarchy, if not show message
          If NOT CBool(mam_LoadSubscriberAccount(mam_GetSubscriberAccountID())) Then
            response.write "<script>parent.main.location.href = '" & mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & mam_GetSubscriberAccountID() & "&ForceLoad=TRUE';</script>"
          End If
      End If
  	End If    
End Select    

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION GetGMTDateFormatted()
  GetGMTDateFormatted = FrameWork.MSIXTools.Format(FrameWork.MetraTimeGMTNow(), objDictionary("DATE_FORMAT").Value)
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION DateFormat(varValue)
  DateFormat = FrameWork.MSIXTools.Format(varValue, objDictionary("DATE_FORMAT").Value)
END FUNCTION    
    
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/styles.css'>
    <LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/MAMMenu.css'>

    <meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=UTF-8">
    
    <SCRIPT language="JavaScript" src="js/hierarchyClient.js"></SCRIPT>
        
    <SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">
    var hWin = null; // handle stored for popup windows so we can set focus on drag event
    
    var LastID = null;
    
    function init() {

      try
      {
        // Initialize web service used by the client in javascript to get field id from acount id on drag-n-drop
        <%
        If UseHTTPSOnClientCalls() Then
        %>
          myWebService.useService("https://<%=request.ServerVariables("SERVER_NAME")%>/AccountHierarchy/Service.asmx?WSDL", "MAMHierarchyWebSvc");
        <%  
        Else
        %>
          myWebService.useService("http://<%=request.ServerVariables("SERVER_NAME")%>/AccountHierarchy/Service.asmx?WSDL", "MAMHierarchyWebSvc");
        <%  
        End If
        %>
        
        
      }
      catch(exp)
      {
         alert("<%=mam_GetDictionary("START_ACCOUNT_HIERARCHY_WEBSERVICE")%>  http://<%=request.ServerVariables("SERVER_NAME")%>/AccountHierarchy/Service.asmx");
      }

      try
      {
        // Initialize client side context menu according to capabilities
        loadContextMenu();  
      }
      catch(exp)
      {
         parent.main.location.href = "<%=mam_GetDictionary("CLIENT_HIERARCHY_SETUP_DIALOG")%>";
      }

      try
      {
        // XP display bug 
        refreshFolder(1);
      }
      catch(exp)
      {
      }        
    }
    
    function InitializeResult(result) {
      return;
    }
    
    function GetFieldIDFromAccountID(nID) {
      <%
        Dim objTools
        Set objTools = Server.CreateObject(MSIXTOOLS_PROG_ID)
      %>
      try
      {
        if(nID == 1)
        {
          LastID = "<%=mam_GetDictionary("TEXT_USERS")%>" + " (" + "<%=MAM_HIERARCHY_ROOT_ACCOUNT_ID%>" + ")";
        }
        else
        {
          myWebService.MAMHierarchyWebSvc.callService(GetFieldIDFromAccountIDResult, "GetFieldIDFromAccountID", nID, "<%=objTools.GetDateTimeInGMTFormat(mobjHC.SnapShot)%>", "<%=FrameWork.SessionContext.ToXML%>");
        }  
      }
      catch(exp)
      {
        alert(exp.message);
      }
    }

    function GetFieldIDFromAccountIDResult(result) {
      LastID = result.value;
    }
    </SCRIPT>

  </head>

  <body onload="init();window.status='<%=objDictionary("TEXT_LOADING_DONE")%>';" style="background-color:#003B8E; margin:3;">
    <script language="javascript">
      window.status='<%=objDictionary("TEXT_LOADING_HIERARCHY")%>';
    </script>

    <DIV ID="myWebService" STYLE="behavior:url(webservice.htc)"></DIV>

    <script language="javascript">
        window.status='<%=objDictionary("TEXT_LOADING_HIERARCHY")%>';
        
        // Hierarchy Parameters - JSON syntax
        var HierarchyParams = { "IsDebug": "Y",
          <%
          If UseHTTPSOnClientCalls() Then
          %>
            "Secure": "ON",
            "WebURL": "https:\/\/<%=request.ServerVariables("SERVER_NAME")%>\/AccountHierarchy\/Service.asmx",      
          <%  
          Else
          %>
            "Secure": "OFF",
            "WebURL": "http:\/\/<%=request.ServerVariables("SERVER_NAME")%>\/AccountHierarchy\/Service.asmx",       
          <%  
          End If
          %>        
          "Server": "<%=request.ServerVariables("SERVER_NAME")%>",
          "Day": "<%=Day(mobjHC.SnapShot)%>",
          "Month": "<%=Month(mobjHC.SnapShot)%>",
          "Year": "<%=Year(mobjHC.SnapShot)%>",
          "SerializedContext": "<%=FrameWork.SessionContext.ToXML%>",
          "TopNodeDisplayName": "<%=objDictionary("TEXT_USERS")%>",
          "HierarchyStartNodeAccountType": "<%=Session("HierarchyStartNodeAccountType")%>",
          "RefreshClickText": "<%=objDictionary("TEXT_REFRESH_CLICK")%>",
          "KeepAlive": "<%=objDictionary("KEEP_ALIVE")%>",
          "TypeSpace": "system_user",
          "HierarchyStartNode": "1",
          "Sorted": "<%=objDictionary("HIERARCHY_SORTED")%>",
          "ProxyRequiresLogin": "<%=objDictionary("PROXY_REQUIRES_LOGIN")%>",
          "ProxyUseDefaultCredentials": "<%=objDictionary("PROXY_USE_DEFAULT_CREDENTIALS")%>",
          "ProxyBypassLocal": "<%=objDictionary("PROXY_BYPASS_LOCAL")%>",
          "ProxyOverrideDefaultProxy": "<%=objDictionary("PROXY_OVERRIDE_DEFAULT_PROXY")%>",
          "ProxyName": "<%=objDictionary("PROXY_NAME")%>",
          "ProxyPort": "<%=objDictionary("PROXY_PORT")%>",
          "ProxyUserId": "",
          "ProxyPassword": "",
          "ProxyDomain": "" };

          // RUN HIERARCHY
          RunHierarchy(HierarchyParams);
      </script>
    
    <SCRIPT LANGUAGE="javascript" FOR="MyTree" EVENT="OnSelectAccount(sender, e)">
       if(e.ID != "1")
       {
         quickInfo(e.ID);
       }
    </SCRIPT>
    <SCRIPT LANGUAGE="javascript" FOR="MyTree" EVENT="OnMoveAccounts(sender, e)">
          //Set flag to indicate multi-drop
          document.DragForm.DropAction.value = "MULTI";       
        
          //Set the target of the drop
          document.DragForm.Parent.value = e.Destination;
        
          //Set the items to move
          document.DragForm.Child.value = e.Accounts;
          document.DragForm.ChildType.value = "ACCOUNT";      
      
          document.DragForm.submit();
    </SCRIPT>
    <SCRIPT LANGUAGE="javascript" FOR="MyTree" EVENT="OnHierarchyDrag(sender, e)">
        
        window.getFrameMetraNet().dragAccounts = e.Accounts;

        // if there is a popup set the focus
        try {
          if(hWin)
          {
            hWin.focus();
          }
        }
        catch(exp)
        {
          // nothing we can do here... so just forget about it
        }
           
    </SCRIPT>   
    <SCRIPT LANGUAGE="javascript" FOR="MyTree" EVENT="OnDateChange(sender, e)">
        document.DateForm.Month.value = e.Month;
        document.DateForm.Day.value   = e.Day;
        document.DateForm.Year.value  = e.Year;
        document.DateForm.submit();
    </SCRIPT>   
     <SCRIPT LANGUAGE="javascript" FOR="MyTree" EVENT="OnContextMenu(sender, e)">
        dragID = e.ID;

        switch(e.Event)
        {
          case "Manage":
            manageAccount();
            break;  
          case "Owned Accounts":
            loadAccount();
            ownedAccounts();
            break;  
          case "Search":
            searchSubHierarchy();
            break;          
          case "Add User":
            addAccount();
            break;  
          case "Security":
            loadAccount();
            updateSecurity();
            break;   
          case "Update Account":
            loadAccount();
            updateAccount();
            break;                          
          case "Refresh":
            refreshFolder(e.ID);
            break;    
          case "Show All":
            MyTree.ShowAllCorporations = true;
            MyTree.ClearVisibleAccounts();
            refreshFolder("1");
            MyTree.ExpandFolder("1");
            break;    
         case "Hide":
            MyTree.ShowAllCorporations = false;
            if(MyTree.VisibleAccounts.Count > 1)
            {
              MyTree.VisibleAccounts.Remove(e.ID);
              refreshFolder("1");
            }
            else
            {
              alert("The hide operation only works when accounts have been selectively loaded into the hierarchy.");
            }
            break;        
          case "Show Only":
            MyTree.ShowAllCorporations = false;
            MyTree.ClearVisibleAccounts();
            MyTree.AddVisibleAccount(e.ID);
            refreshFolder("1");
            break;                  
        }
    </SCRIPT>  
    <script language="JavaScript">
      function loadContextMenu()
      {
          // If you need to change the context menu this is the place...
          //        void AddContextMenu(string ItemName, string DisplayName, string MenuType);
          // ItemName: The event that is switched on in OnContextMenu
          // MenuType: 
      
          // ROOT
          <% If FrameWork.CheckCoarseCapability("Update CSR accounts") Then %>           
          MyTree.AddContextMenu("Add User", "<%=objDictionary("TEXT_CTX_MENU_ADD_USER")%>", "ROOT");          
          <% End If %>           
          MyTree.AddContextMenu("-", "-", "ROOT");
          MyTree.AddContextMenu("Search", "<%=objDictionary("TEXT_CTX_MENU_SEARCH")%>", "ROOT");
          MyTree.AddContextMenu("-", "-", "ROOT");
          MyTree.AddContextMenu("Show All", "<%=objDictionary("TEXT_CTX_MENU_SHOWALL")%>", "ROOT");            
          MyTree.AddContextMenu("Refresh", "<%=objDictionary("TEXT_CTX_MENU_REFRESH")%>", "ROOT");

          // SystemAccount
          MyTree.AddContextMenu("Manage", "<%=objDictionary("TEXT_CTX_MENU_MANAGE")%>", "SystemAccount");
          MyTree.AddContextMenu("-", "-", "SystemAccount");   
          MyTree.AddContextMenu("Search", "<%=objDictionary("TEXT_CTX_MENU_SEARCH")%>", "SystemAccount");
          MyTree.AddContextMenu("-", "-", "SystemAccount");    
          <% If FrameWork.CheckCoarseCapability("Update CSR accounts") Then %>                           
          MyTree.AddContextMenu("Update Account", "<%=objDictionary("TEXT_CTX_MENU_UPDATE_ACCOUNT")%>", "SystemAccount");
          <% End If %>             
          <% If FrameWork.CheckCoarseCapability("Update CSR accounts") Then %>           
          MyTree.AddContextMenu("Owned Accounts", "<%=objDictionary("TEXT_CTX_MENU_OWNED_ACCOUNTS")%>", "SystemAccount");          
          <% End If %>             
          <% If FrameWork.CheckCoarseCapability("Manage CSR Auth") Then %>            
          MyTree.AddContextMenu("Security", "<%=objDictionary("TEXT_CTX_MENU_SECURITY")%>", "SystemAccount");   
          <% End If %>                    
          MyTree.AddContextMenu("-", "-", "SystemAccount");
          <% If FrameWork.CheckCoarseCapability("Update CSR accounts") Then %>           
          MyTree.AddContextMenu("Add User", "<%=objDictionary("TEXT_CTX_MENU_ADD_USER")%>", "SystemAccount");          
          <% End If %>                     
          MyTree.AddContextMenu("-", "-", "SystemAccount");
          MyTree.AddContextMenu("Refresh", "<%=objDictionary("TEXT_CTX_MENU_REFRESH")%>", "SystemAccount");  
        
      }
    </script>           

	  <script language="javascript">
      var i; 
      var mLoadingLock = false;
      var dragID = 1;

      // On sync. to hierarchy do not show all corp. accounts, but only the ones
      // in the list of visible corporations (we build this list as we go).  Add
      // the syncing accounts corpID to the list, and make sure it is loaded at
      // the top level.  Then find the account in the hierarchy, and scroll it into view.
      function FindAccountInHierarchy(strIDs, myID, corpID){
        
        MyTree.ShowAllCorporations = false;
              
        var splitString = strIDs.split(",")
        var num = 0;
        
        while(num < splitString.length)
        {
       
          if(!MyTree.VisibleAccounts.Contains(splitString[num]))
          {
            MyTree.AddVisibleAccount(splitString[num]);
          }
          
          num += 1;
        }
        
        if(!MyTree.VisibleAccounts.Contains(myID))
        {
          MyTree.AddVisibleAccount(myID);
        }
        
        MyTree.RefreshFolder("1");
        MyTree.FindInHierarchy(strIDs, myID);
      }

      function refreshFolder(myID){
        MyTree.RefreshFolder(myID);  
      }
      
      function manageAccount(){
        // check lock
        if(mLoadingLock) {
          alert("Already loading account... [manageAccount] [" + dragID + "]  Please wait...");
          return;
        }
        mLoadingLock = true;
              
        if(dragID != 1) {
          parent.main.location.href = "<%=mam_GetDictionary("SYSTEM_USER_FOUND_DIALOG")%>?AccountId=" + dragID + "&ForceLoad=TRUE";
          i=0;
        }
        unlock();
        parent.hideHierarchy();
      }
  
      function quickInfo(id){
        parent.main.location.href = '<%=mam_GetDictionary("QUICK_INFO_DIALOG")%>?ID=' + id + '&MODE=SYSTEM_USER';
      }
  
      function loadAccount(){
        
        // check lock
        if(mLoadingLock) {
          alert("Already loading account... [loadAccount] [" + dragID + "] Please wait...");
          return;
        }
        mLoadingLock = true;
        
        if(dragID != 1) {            
           //Highlight(dragID);
           parent.secret.location.href = "<%=mam_GetDictionary("SYSTEM_USER_FOUND_DIALOG")%>?AccountId=" + dragID + "&ForceLoad=TRUE";
           i=0;
        }  
			}
      function issueCredit(){
         if(checkReadyState()) {
           parent.main.location.href = "<%=mam_GetDictionary("ISSUE_MISC_ADJUSTEMENT_DIALOG")%>";
           unlock();
           parent.hideHierarchy();
         }
         else {
           setTimeout("issueCredit()",100);   
         }  
      }
      function ownedAccounts(){
         if(checkReadyState()) {
           parent.main.location.href = "<%=mam_GetDictionary("SYSTEM_USER_OWNED_ACCOUNTS_DIALOG")%>";
           unlock();
           parent.hideHierarchy();
         }
         else {
           setTimeout("ownedAccounts()",100);   
         }  
      }      
      function addAccount(){
         if(checkReadyState()) {
          // if(dragID != 1) {      
			       parent.main.location.href = "<%=mam_GetDictionary("ADD_CSR_DIALOG")%>?FolderID=" + dragID;
          // }
           unlock();
         }
         else {
           setTimeout("addAccount()",100);   
         }  
      }
      function groupSub(){
          loadAccount();
          loadGroupSub();
      }			      
      function loadGroupSub() {
    	   if(checkReadyState()) {      
     	     parent.main.location.href = "<%=mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG")%>";
           unlock();
           parent.hideHierarchy();
         }
         else {
           setTimeout("loadGroupSub()",100);   
         }
      }           
			function additionalCharge(){
    	   if(checkReadyState()) {      
            parent.main.location.href = "<%=mam_GetDictionary("ADD_CHARGE_DIALOG")%>";
            unlock();
            parent.hideHierarchy();
         }
         else {
           setTimeout("additionalCharge()",100);   
         }      
      }
			function viewOnlineBill(){
    	   if(checkReadyState()) {      
            parent.main.location.href = "<%=mam_GetDictionary("INTERACTIVE_BILL_LOGON")%>";
            unlock();
            parent.hideHierarchy();
         }
         else {
           setTimeout("viewOnlineBill()",100);   
         }        
      }			
			function searchSubHierarchy(){
         parent.main.location.href = "<%=mam_GetDictionary("SYSTEM_USER_FIND_DIALOG")%>?subHierarcy=" + dragID;			
			}
			function updateAccount(){
    	   if(checkReadyState()) {      
            parent.main.location.href = "<%=mam_GetDictionary("SYSTEM_USER_UPDATE_DIALOG")%>?AccountId=" + dragID;
            unlock();
         }
         else {
           setTimeout("updateAccount()",100);   
         }        
      }			 
      
			function updateSecurity(){
    	   if(checkReadyState()) {      
            parent.main.location.href = "<%=mam_GetDictionary("MANAGE_SECURITY_RELOAD_DIALOG")%>&NextPage=<%=mam_GetDictionary("WELCOME_DIALOG")%>&Mode=CSR_ACTIVE_POLICY&AccountId=" + dragID;
            unlock();
         }
         else {
           setTimeout("updateSecurity()",100);   
         }        
      }			 
      

      function checkReadyState() {
         if((parent.main.document.readyState == "complete") && (parent.secret.document.readyState == "complete")){
            return true;
         }
         else {
           i = i  + 1;
           var mod = i % 4;
           switch (mod){
            case 0: 
              window.status = '<%=objDictionary("TEXT_HIERARCHY_LOADING")%> --';
              break;
            case 1:
              window.status = '<%=objDictionary("TEXT_HIERARCHY_LOADING")%> \\';
              break;
            case 2: 
              window.status = '<%=objDictionary("TEXT_HIERARCHY_LOADING")%> |';
              break;
            case 3: 
              window.status = '<%=objDictionary("TEXT_HIERARCHY_LOADING")%> /';
              break;
            }
            return false;
         }
      }     
      
      function unlock() {
         if(checkReadyState()) {
           mLoadingLock = false;
           window.status = "<%=objDictionary("TEXT_HIERARCHY_DONE")%>";
         }
         else {
           setTimeout("unlock()",100);   
         }  
      }
	  </script>

    <br>
   
    <form name="DateForm" id="DateForm" action="<%=objDictionary("SYSTEM_USER_HIERARCHY_CLIENT_DIALOG")%>?Action=date" method="post">
	    <input value="<%=Month(mobjHC.SnapShot)%>" type="hidden" name="Month" id="Month">
	    <input value="<%=Day(mobjHC.SnapShot)%>"   type="hidden" name="Day" id="Day">
	    <input value="<%=Year(mobjHC.SnapShot)%>"  type="hidden" name="Year" id="Year">
    </form>    
   
	  <!-- Drop Form -->
    <form target="secret" name="DragForm" action="<%=objDictionary("SYSTEM_USER_HIERARCHY_CLIENT_DIALOG")%>?Action=Drop" method="POST">
      <input name="Parent" type="hidden">
      <input name="Child" type="hidden">
      <input name="DropAction" type="hidden">
      <input name="ChildType" type="hidden">
    </form>   

  </body>
</html>
  
  
   

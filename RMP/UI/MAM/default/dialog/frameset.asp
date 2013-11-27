<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/mamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
  session("HelpContext") = ""
	
  If(mdm_UIValueDefault("HideSubscriber",TRUE))Then
      If IsEmpty(Session("HideOnceAtLogin")) Then
        Call MenuInitialize()
        Session("HideOnceAtLogin") = TRUE
      End If  
  End If
%>
<html>
<head>
	<title><%=mam_GetDictionary("TEXT_APPLICATION_TITLE")%></title>

<script language="JavaScript1.2">
var dragAccounts = null;

function resizeIt(){
  
  if(parent.document.all("TopFrame").all("BottomFrame").cols == "0,5,*"){
    if(parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols == "180,0,0"){
        parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
    }
    else{
        parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";    
    }
  }
  else{
    parent.document.all("TopFrame").all("BottomFrame").cols = "0,5,*";
  }
}

function resizeHierarchy(){
  
  if(parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols == "180,0"){
    parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
    parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,300";
  }
  else{
    parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
    parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "180,0";
  }
}

var bShownHierarchy = false;
function showHierarchy(){
  if(!bShownHierarchy)
  {
    getFrameMetraNet().hierarchy.location.href = "<%=mam_GetDictionary("HIERARCHY_VIEW_PAGE")%>";
    bShownHierarchy = true;
  }
  parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
  parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,0,300,0";
  getFrameMetraNet().HierarchySwitch.location.href = '<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=account';  
}

var bShownUserHierarchy = false;
function showUserHierarchy(){
  if(!bShownUserHierarchy)
  {
    getFrameMetraNet().hierarchyUser.location.href = "<%=mam_GetDictionary("SYSTEM_USER_HIERARCHY_CLIENT_DIALOG")%>";
    bShownUserHierarchy = true;
  }
  parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
  parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,0,0,300";
  getFrameMetraNet().HierarchySwitch.location.href = '<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=sfh';    
}


function showSearch(bForceLoad){
  
  if(bForceLoad)
    getFrameMetraNet().QuickFind.location.href = "<%=mam_GetDictionary("QUICK_FIND_DIALOG")%>";

  parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
  parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "300,0,0,0";
  getFrameMetraNet().HierarchySwitch.location.href = '<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=search';  
}


function showMenu(){
  getFrameMetraNet().menu.location.href = "<%=mam_GetDictionary("GLOBAL_MAIN_MENU")%>";

  parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
  parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,300,0,0";
  getFrameMetraNet().HierarchySwitch.location.href = '<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=menu';  
}

function hideHierarchy(){
  parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
  parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,300,0,0";
}

function hideUserHierarchy(){
  parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
  parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,300,0,0";
}

function hideGuide(){
    parent.document.all("TopFrame").all("BottomFrame").all("RightSide").rows = "11,*,0,0";
}

function showGuide(){
    getFrameMetraNet().guide.location = '<%=mam_GetDictionary("ERROR_RESOLUTION_ROADMAP")%>';
    parent.document.all("TopFrame").all("BottomFrame").all("RightSide").rows = "11,*,0,100";
}

function showLastAccounts(){
    parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").rows = "300,120,*,*";
}

</script>
 
</HEAD>

<!-- frames -->
<frameset rows="60,*" framespacing="0" frameborder="0" id="TopFrame" border="0">

	<frame SRC="<%=mam_GetDictionary("GLOBAL_HEADER_DIALOG")%>" NAME="Header" FRAMEBORDER="0" SCROLLING="NO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0" border="0">
  
	<frameset name="BottomFrame" cols="300,5,*" FRAMESPACING="0" FRAMEBORDER="0" border="0"> 
  
      <frameset name="LeftSide" rows="60,*" border="0" FRAMESPACING="0" FRAMEBORDER="0" border="0"> 
            <frame name="HierarchySwitch" src="<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>" border="0" FRAMEBORDER="0" SCROLLING="NO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">            
	          <frameset name="LeftSideBottom" cols="300,0,0,0" FRAMESPACING="0" FRAMEBORDER="0" border="1"> 
        	    <frame name="QuickFind" src="<%=mam_GetDictionary("QUICK_FIND_DIALOG")%>" border="0" FRAMEBORDER="0" SCROLLING="Auto" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
              <frame name="menu" src="<%=mam_GetDictionary("GLOBAL_MAIN_MENU")%>" border="0" FRAMEBORDER="0" SCROLLING="AUTO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
              <frame name="hierarchy" src="blank.htm" border="0" FRAMEBORDER="0" SCROLLING="NO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">            
              <frame name="hierarchyUser" src="blank.htm" border="0" FRAMEBORDER="0" SCROLLING="NO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">                          
            </frameset>
	    </frameset> 

	    <frame name="bevel" src="<%=mam_GetDictionary("BEVEL_DIALOG")%>" border="0" FRAMEBORDER="0" SCROLLING="no" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">

	    <frameset name="RightSide" rows="11,*,0,0" border="0" FRAMESPACING="0" FRAMEBORDER="0" border="0"> 
      	    <frame name="topcurve" src="<%=mam_GetDictionary("TOP_CURVE_DIALOG")%>" border="0" FRAMEBORDER="0" SCROLLING="no" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
<%
' If we have a routeto page load that in the main frame
If Len(request.QueryString("RouteTo")) Then 
%>
      	    <frame name="main" src="<%=request.QueryString("RouteTo")%>" border="0" FRAMEBORDER="0" SCROLLING="AUTO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
<%
Else
%>
      	    <frame name="main" src="<%=mam_GetDictionary(mdm_UIValueDefault("DicEntryMainPage","WELCOME_DIALOG"))%>" border="0" FRAMEBORDER="0" SCROLLING="AUTO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
<%
End IF
%>           
            <frame name="secret" src="preload.asp" border="0" FRAMEBORDER="0" SCROLLING="AUTO" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">						
            <frame name="guide" src="<%=mam_GetDictionary("ERROR_RESOLUTION_ROADMAP")%>" border="0" FRAMEBORDER="0" SCROLLING="AUTO" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">												
	    </frameset> 
      
  </frameset>      
</frameset>

<body>
</body>
</html>

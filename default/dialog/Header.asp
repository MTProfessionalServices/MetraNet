<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
dim imageURL
imageURL = FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/header/"
%>
<html>
  <head>
	  <title>MetraOffer</title>
    <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH")%>/styles/styles.css" />
    <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH")%>/styles/ListTabsMain.css" />
    <link rel="stylesheet" type="text/css" href="/Res/Ext/resources/css/ext-all.css?v=6.0.4" />

    <script type="text/javascript" src="/Res/Ext/adapter/ext/ext-base.js?v=6.0.4"></script>
    <script type="text/javascript" src="/Res/Ext/ext-all-debug.js?v=6.0.4"></script>
  
	  <script language="Javascript1.2">
		  var winHelp;
		  var winNew;
    
        function OpenHelp() {
            if (winHelp){
                if (!winHelp.closed)
                    winHelp.close();
            }
            // 'SECENG: Changed old help path to new help system CORE-4774 CLONE - MSOL BSS 27970 Unauthenticated Info Disclosure on /MOM/help.asp (post-pb)
            winHelp = window.open('<%=Session("mdm_LOCALIZATION_DICTIONARY").Item("APP_HTTP_PATH")%>/../MetraNetHelp/en-US/index.htm', 'HelpWindow', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
        }  
      
      function LogOut() {
        window.parent.location = "logout.asp?urlredirect=<%=Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)%>"
		  }    	
  	
  		function FullScreen() {
        parent.resizeIt();    
  	  }
      
    Ext.onReady(function(){
    var tabs = new Ext.TabPanel({
        renderTo: 'tabs1',
        activeTab: 0,
        resizeTabs:true, 
        tabWidth:135,
        width:550,
        plain:true,
        defaults: {autoScroll:true},
        items:[
            {contentEl:'none', title: '<%=FrameWork.GetDictionary("TEXT_KEYTERM_MENU_PRODUCT_OFFERINGS")%>', url:'<%=FrameWork.GetDictionary("PRODUCT_OFFERING_LIST_WITH_NAV_DIALOG")%>', listeners: {activate: handleActivate}},
            {contentEl:'none', title: '<%=FrameWork.GetDictionary("TEXT_SHARED_RATES")%>', url:'<%=FrameWork.GetDictionary("RATES_PRICE_LIST_LIST_DIALOG")%>', listeners: {activate: handleActivate}},
            {contentEl:'none', title: '<%=FrameWork.GetDictionary("TEXT_KEYTERM_MENU_PRICEABLE_ITEMS")%>', url:'<%=FrameWork.GetDictionary("SERVICE_CHARGES_USAGE_LIST")%>', listeners: {activate: handleActivate}},
            {contentEl:'none', title: '<%=FrameWork.GetDictionary("TEXT_KEYTERM_MENU_ADVANCED_OPTIONS")%>', url:'<%=FrameWork.GetDictionary("ADVANCED_MENU_DIALOG")%>', listeners: {activate: handleActivate}}
        ]
    });

    function handleActivate(tab){
        parent.frames[1].location = tab.url;
    }
});
  	</script>
  </head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

  <div id="north">
    
    <a style="float: right; margin-right: 10px;" target="_top" href="/MetraNet">
      <img border="0" alt="MetraNet" src="/Res/Images/Header/MetraNet1Small.png" />
    </a>
    <span style="float: right; margin-right: 10px;">
     <a href="JavaScript:FullScreen();"><img border="0" alt="<%=FrameWork.GetDictionary("TEXT_FULLSCREEN")%>" src="<%=imageURL%>left_nav_off.gif" width="25" height="25"></a>
     <img src="<%=imageURL%>spacer.gif" width="10" height="10">
     <a href="javascript:OpenHelp();"><img border="0" alt="<%=FrameWork.GetDictionary("TEXT_HELP")%>" src="<%=imageURL%>help.gif" width="25" height="25"></a>
     <img src="<%=imageURL%>spacer.gif" width="10" height="10">
     <a href="JavaScript:LogOut();"><img border="0" alt="<%=FrameWork.GetDictionary("TEXT_LOG_OUT")%>" src="<%=imageURL%>exit.gif" width="25" height="25"></a>
    </span>    
    
    <div class="title">MetraOffer
		  <span class="SmallText" style="padding-left:100px;">
		  <%
      ' Set server description
      Dim objVersionInfo, serverDescription
      Set objVersionInfo= CreateObject("MetraTech.Statistics.VersionInfo")
      serverDescription = objVersionInfo.GetServerDescription("")
      response.write serverDescription
      If instr(1,UCase(serverDescription),"PRODUCTION") Then
      %>
         <img src="<%=Session("LocalizedPath")%>images/Header/production.gif" width="10" height="10">
      <%
      End If
      %>
      </span>
    </div>
    <br />
    
    <div id="tabs1">
      <div id="none" class="x-hide-display"></div>
    </div>

  </div>

</body>

</html>

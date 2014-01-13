<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- METADATA type="TypeLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MAMLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<HTML>
<HEAD>
  <meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=UTF-8">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/styles.css">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/MAMMenu.css">
  <META http-equiv="Page-Enter" content="blendTrans(Duration=.1)"> 
  <META http-equiv="Page-Exit" content="blendTrans(Duration=.1)">
  
 	<!-- Drag & Drop Functions --> 
  <script language="Javascript" src="js/dragdrop.js"></script>  
  <script language="javascript">
    parent.document.all("TopFrame").all("BottomFrame").cols = "300,5,*";
    parent.document.all("TopFrame").all("BottomFrame").all("LeftSide").all("leftSideBottom").cols = "0,300,0,0";
    getFrameMetraNet().HierarchySwitch.location.href = '<%=mam_GetDictionary("RECENT_ACCOUNTS_DIALOG")%>?mdmCurrentTab=menu'; 
  </script>
  
</HEAD>
<body onDrag="fOnDrag();" onDragEnd="fOnDragEnd();" onDragLeave="fOnDragLeave();" onDragEnter="fOnDragEnter();" onDragStart="fOnDragStart();" onDragOver="fOnDragOver();" onDrop="fOnDrop();">
  
<!-- DIV for dragable shadow --> 
<div class="clsDragDiv" style="z-index:102;" id="dragDiv"></div>

<%
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Get recent account list
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Dim node
  Dim bExists
   
  bExists = false
  
  If mam_GetSubscriberAccountID() <> 0 Then
    If IsEmpty(Session("COL_RECENT_ACCOUNTS")) Then
      set Session("COL_RECENT_ACCOUNTS") = Server.CreateObject(MT_COLLECTION_PROG_ID)
    End If
    
    For Each node in Session("COL_RECENT_ACCOUNTS")
       If mam_GetSubscriberAccountID() = node Then
         bExists = true
         exit for
       End If
    Next 

    If not bExists Then
      Call Session("COL_RECENT_ACCOUNTS").add(mam_GetSubscriberAccountID())    
    End If
   
    If Session("COL_RECENT_ACCOUNTS").count > CLng(mam_GetDictionary("NUMBER_OF_RECENT_ACCOUNTS")) Then
      Session("COL_RECENT_ACCOUNTS").remove(1)
    End If
    %>
    <script>
      getFrameMetraNet().QuickFind.location.href = "<%=mam_GetDictionary("QUICK_FIND_DIALOG")%>";
    </script>
    <%
  End If

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' START MENU
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim varHTMLMenu
  Dim objTools
  set objTools = CreateObject(MSIXTOOLS_PROG_ID)
  
  'Check to see if the Payment Server is installed
  Call SetMenuLinkState("PaymentMethods", objTools.IsPayementServerInstalled(mam_GetDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")))
  
	'Check to see if the user is valid
  If IsValidObject(Session("objMAM").Subscriber) Then
  
			'If ON-DEMMAND then disable the Subscriptions option (for Jed) 
      ' Not that on-demand does not exist any more in 3.0 last days
      If Session("objMAM").Subscriber.Exist("usagecycletype") Then
			  Call SetMenuLinkState("usagecycletype", UCase(Session("objMAM").Subscriber("usagecycletype")) = "ON-DEMAND")
      End If 
       
	  	'Check to see if the account is billable - disable pay for accounts menu option if not
	  	If Session("objMAM").Subscriber.Exist("billable") Then
        Call SetMenuLinkState("payer", (UCase("" & Session("objMAM").Subscriber("billable").Value) = "1") or (UCase("" & Session("objMAM").Subscriber("billable").Value) = "TRUE") )
 			End If
  Else
    Session("CURRENT_SYSTEM_USER") = Empty
    Session("SubscriberYAAC") = Empty
  End If

  ' If hierarchy restricted operations are on then remove top level group subscriptions
  Dim pc, bHierarchyRestrictedOperations
  Set pc = GetProductCatalogObject()  
  bHierarchyRestrictedOperations = pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations)
  If bHierarchyRestrictedOperations Then
    MAM().Menu.MenuTabs("Actions").MenuLinks("GroupSubscriptions").Visible = FALSE
  else
    MAM().Menu.MenuTabs("CoreSubscriber").MenuLinks("GroupSubscriptions").Visible = FALSE
  End If
              
	' Render Menu
	If( Session("objMAM").Menu.RenderHTML(varHTMLMenu, False, FrameWork.SecurityContext, FrameWork.Policy, Session("CSR_YAAC")) ) Then
		Response.write CStr(varHTMLMenu)
	End If
%>

</BODY>
</HTML>
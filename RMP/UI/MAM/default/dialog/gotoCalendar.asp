<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE = "../../auth.asp" -->
<%
 
session("VIRTUAL_DIR") = "/mpte"
%>

<!-- #INCLUDE FILE = "../lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE VIRTUAL="/mpte/shared/Helpers.asp" -->
<!-- #INCLUDE VIRTUAL="/mpte/shared/MPTE_Common.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/Shared/CheckConnected.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/Shared/WriteError.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/Shared/CalendarInclude.asp" -->
<!-- #INCLUDE FILE 	 ="../lib/TabsClass.asp" -->

<% ' This is the include that actually draws the page we want %>
<!-- #INCLUDE VIRTUAL="/MPTE/us/Calendar/CalendarConfig.asp" -->


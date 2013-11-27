<!-- #INCLUDE FILE = "../../auth.asp" -->

<%
session("VIRTUAL_DIR") = "/mpte" ' TODO: Eventually get rid of this
%>

<!-- #INCLUDE VIRTUAL="/MDM/Framework/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE = "../lib/ProductCatalog/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE 	 ="../lib/TabsClass.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/shared/Helpers.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/Shared/CheckConnected.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/Shared/WriteError.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/Shared/CalendarInclude.asp" -->
<!-- #INCLUDE VIRTUAL="/MPTE/shared/MPTE_Common.asp" -->

<% ' This is the include that actually draws the page we want %>
<!-- #INCLUDE VIRTUAL="/MPTE/us/Calendar/CalendarConfig.asp" -->


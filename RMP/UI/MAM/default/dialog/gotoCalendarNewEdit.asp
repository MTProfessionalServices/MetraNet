<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE = "../../auth.asp" -->
<% 
   ' This is the file that will call the GenericEditRuleset popup window.
   ' It also includes the Framework, so we can eventually localize it.
%>

<!-- #INCLUDE FILE = "../lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/CheckConnected.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/WriteError.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/shared/Helpers.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/editbox.asp"-->
<!-- #INCLUDE VIRTUAL = "/mpte/Shared/CalendarInclude.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/shared/MPTE_Common.asp" -->
<!-- #include virtual = "/mpte/us/Calendar/CalendarNewEdit.asp" -->
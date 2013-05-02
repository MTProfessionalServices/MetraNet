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
<!-- #INCLUDE VIRTUAL = "/mpte/shared/MPTE_Common.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/editbox.asp"-->
<!-- #include virtual = "/mpte/us/Calendar/PeriodAddRemove.asp" -->
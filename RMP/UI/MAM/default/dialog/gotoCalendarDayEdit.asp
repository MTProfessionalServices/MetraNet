<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE = "../../auth.asp" -->
<% 
   ' This is the file that will call the GenericEditRuleset popup window.
   ' It also includes the Framework, so we can eventually localize it.
   
Dim objTextFile, strHTMLP
Set objTextFile = server.CreateObject("MTVBLib.CTextFile")

dim objDictionary
set objDictionary = Session("mdm_LOCALIZATION_DICTIONARY")

strHTMLP = objTextFile.LoadFile(server.mappath("/mdm/Common/Widgets/Calendar/Calendar.header.htm"))
strHTMLP = objDictionary.PreProcess(strHTMLP)
Response.write strHTMLP
   
%>

<!-- #//INCLUDE VIRTUAL="/mdm/Common/Widgets/Calendar/Calendar.header.htm" -->
<!-- #INCLUDE FILE = "../lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/CheckConnected.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/WriteError.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/shared/Helpers.asp" -->
<!-- #INCLUDE virtual = "/mpte/Shared/editbox.asp"-->
<!-- #include virtual = "/mpte/us/Calendar/CalendarDayEdit.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/Common/Widgets/Calendar/Calendar.footer.htm" -->
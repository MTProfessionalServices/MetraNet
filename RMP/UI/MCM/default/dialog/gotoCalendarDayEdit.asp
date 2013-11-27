<!-- #INCLUDE FILE = "../../auth.asp" -->

<% 
   ' This is the file that will call the GenericEditRuleset popup window.
   ' It also includes the Framework, so we can eventually localize it.

'// This code is to replace the include of Calendar.header.htm below
'// We need to process the file using the dictionary object before outputting it in the response.
Dim objTextFile, strHTMLP
Set objTextFile = server.CreateObject("MTVBLib.CTextFile")

dim objDictionary
set objDictionary = Session("FRAMEWORK_APP_DICTIONARY")

strHTMLP = objTextFile.LoadFile(server.mappath("/mdm/Common/Widgets/Calendar/Calendar.header.htm"))
strHTMLP = objDictionary.PreProcess(strHTMLP)
Response.write strHTMLP
   
%>

<!-- #////INCLUDE VIRTUAL="/mdm/Common/Widgets/Calendar/Calendar.header.htm" -->
<!-- #INCLUDE VIRTUAL = "/mdm/framework/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE = "../lib/ProductCatalog/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/Shared/CheckConnected.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/Shared/WriteError.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/Shared/Helpers.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/Shared/editbox.asp"-->
<!-- #include virtual = "/mpte/us/Calendar/CalendarDayEdit.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/Common/Widgets/Calendar/Calendar.footer.htm" -->
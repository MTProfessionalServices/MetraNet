<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../lib/MomLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->

<%
Logout

Sub Logout()

   Set Service = Server.CreateObject(MSIXHandler)
   
   Dim strM
   strM = mom_GetDictionary("TEXT_LOG_OUT_MESSAGE")
   strM = Replace(strM,"[START_PAGE]",Application("startPage"))
   
   mdm_GarbageCollector
   
   Set Service = Nothing
   
   response.write "<html>"
   response.write " <body>"
   response.write strM
   response.write " </body>"
   response.write "</html>"
   
   session.abandon
   response.end
End Sub
%>

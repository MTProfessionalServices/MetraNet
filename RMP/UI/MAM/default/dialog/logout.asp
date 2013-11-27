<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 

<%
Logout

Sub Logout()

   Set Service = Server.CreateObject(MSIXHandler)
   
   Dim strM
   strM = mam_GetDictionary("TEXT_LOG_OUT_MESSAGE")
   strM = Replace(strM,"[START_PAGE]",application("startPage") )
   
   Set Service = Nothing
   
   response.write "<html>"
   response.write " <body>"
   response.write strM

   If Not IsEmpty(Session("bTickectFromMetraView")) Then
     %>
      <script language="JavaScript1.2">
        window.close();
      </script>
     <%
   End If      
   response.write " </body>"
   response.write "</html>"
   
   mdm_GarbageCollector
   
   session.abandon
   response.end
End Sub
%>

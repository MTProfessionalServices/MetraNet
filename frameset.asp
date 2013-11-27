<!-- #INCLUDE FILE="MCMIncludes.asp" -->
<html>
<head><title><%=FrameWork.GetDictionary("TEXT_APPLICATION_TITLE")%></title>
    
<script language="JavaScript1.2">

    function resizeIt()
    {
      //Check to see if the document in our main frame has a resize function and then call the function if it does      
       if (frames[1].doFullSize)
         frames[1].doFullSize();
    }
</script>
</HEAD>
<frameset rows="70,*" framespacing="0" frameborder="0" id="TopFrame" border="0">
    <frame SRC="<%=FrameWork.GetDictionary("GLOBAL_HEADER_DIALOG")%>?Flip=true" NAME="Header" FRAMEBORDER="0" SCROLLING="NO" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0" BORDER="1" noresize>
    <frame name="main" 	src="<%=FrameWork.GetDictionary("WELCOME_DIALOG")%>" border="0" FRAMEBORDER="0" SCROLLING="YES" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0" noresize>
</frameset>
<body>
</body>
</html>
<%
    Session("HelpContext") = Empty
%>        

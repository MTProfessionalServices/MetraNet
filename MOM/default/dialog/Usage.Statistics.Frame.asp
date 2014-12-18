<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>View Batch Statistics: <%=SafeForHtml(request.QueryString("Title"))%></title>
</head>

    <frameset cols="284,*" framespacing="2" frameborder="no" name="fmeBottom">
        <frame src="Usage.Statistics.Select.asp?Title=<%=server.urlencode(request("Title"))%>&StartTime=<%=server.urlencode(request("StartTime"))%>&EndTime=<%=server.urlencode(request("EndTime"))%>" name="fmeStatSelect" frameborder="No" scrolling="Auto" marginwidth="0" marginheight="0" framespacing="0">
         <frame src="blank.htm" name="fmeStatView" frameborder="No" border="0" bordercolor="#D5D793" scrolling="Auto" marginwidth="10" marginheight="10" framespacing="0">
   </frameset>
     
</html>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>View Interval Statistics</title>
</head>
<%
dim IntervalId
IntervalId = request("IntervalId")
dim BillingGroupId
BillingGroupId = request("BillingGroupId")
%>

    <frameset cols="284,*" framespacing="2" frameborder="no" name="fmeBottom">

        <frame src="IntervalManagement.Statistics.Select.asp?IntervalId=<%=IntervalId%>&BillingGroupId=<%=BillingGroupId%>" name="fmeStatSelect" frameborder="No" scrolling="Auto" marginwidth="0" marginheight="0" framespacing="0">
        <frame src="blank.htm" name="fmeStatView" frameborder="No" border="0" bordercolor="#D5D793" scrolling="Auto" marginwidth="10" marginheight="10" framespacing="0">

   </frameset>

</html>

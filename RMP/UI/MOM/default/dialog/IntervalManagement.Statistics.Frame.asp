<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>View Interval Statistics</title>
</head>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

dim IntervalId
IntervalId = request("IntervalId")
dim BillingGroupId
BillingGroupId = request("BillingGroupId")
mdm_Main 
FUNCTION Form_Initialize(EventArg) 
  Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
      Dim html
    html = html & "<frameset cols='284,*' framespacing='2' frameborder='no' name='fmeBottom'>"
    html = html & "<frame src='IntervalManagement.Statistics.Select.asp?IntervalId="&IntervalId&"&BillingGroupId="&BillingGroupId&"' frameborder='No' scrolling='Auto' marginwidth='0' marginheight='0' framespacing='0'>"
    html = html & "<frame src='blank.htm' name='fmeStatView' frameborder='No' border='0' bordercolor='#D5D793' scrolling='Auto' marginwidth='10' marginheight='10' framespacing='0'>"
    html = html & "</frameset>"
    html = html & "</FORM></BODY></HTML>"
    Form.HTMLTemplateSource = html&Form.HTMLTemplateSource
    Form_Initialize = TRUE
END FUNCTION


%>

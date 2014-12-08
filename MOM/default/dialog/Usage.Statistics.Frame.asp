<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

mdm_Main 
FUNCTION Form_Initialize(EventArg) 
  Framework.AssertCourseCapability "Manage Usage Processing", EventArg
      Dim html
    html = html & "<html><head>"
    html = html & "<title>View Batch Statistics:" & SafeForHtml(request.QueryString("Title"))& "</title>"
    html = html & "</head>"
    html = html & "<body><form><frameset cols='284,*' framespacing='2' frameborder='no' name='fmeBottom'>"
    html = html & "<frame src='Usage.Statistics.Select.asp?Title="&server.urlencode(request("Title"))&"&StartTime="&server.urlencode(request("StartTime"))&"EndTime=" & server.urlencode(request("EndTime")) & "'>"
    html = html & "<frame src='blank.htm' name='fmeStatView' frameborder='No' border='0' bordercolor='#D5D793' scrolling='Auto' marginwidth='10' marginheight='10' framespacing='0'>"
    html = html & "</frameset>"
    html = html & "</FORM></BODY></HTML>"
    Form.HTMLTemplateSource = html&Form.HTMLTemplateSource
    Form_Initialize = TRUE
END FUNCTION


%>

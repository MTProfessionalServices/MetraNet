<%
option explicit
%>
<!-- #INCLUDE FILE="auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdmIncludes.asp"         -->
<!-- #INCLUDE FILE="default/lib/mamLibrary.asp"         -->
<%

  'Write script to refresh MAIN MENU frame
  response.Write "<script language=""JavaScript1.2"">" & vbNewline
  response.Write "  getFrameMetraNet().menu.location.reload();" & vbNewline 
  response.Write "</script>" & vbNewline

  'if URL was passed in... then load it
  if Len(Request.QueryString("URL")) then
  
    response.Write "<script language=""JavaScript1.2"">" & vbNewLine
    response.Write "if (document.images) {" & vbNewLine
    response.Write "  location.replace(""" & Request.QueryString("URL") & """); }" & vbNewLine
    response.Write "else {" & vbNewLine
    response.Write "  location.href = """ & Request.QueryString("URL") & """;" & vbNewLine
    response.Write "} </script>" & vbNewLine
  end if
%>
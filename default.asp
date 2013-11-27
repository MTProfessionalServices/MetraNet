<%
Option Explicit
%>
<!-- #INCLUDE FILE="default/lib/MOMLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
PUBLIC CONST GLOBAL_DEFAULT_LOGIN =  "/MetraNet/Login.aspx"

PUBLIC FRAMEWORK_APPLICATION_NAME : FRAMEWORK_APPLICATION_NAME = "MOM" ' -- Must be implemented because used by the FrameWork --

InitializeApplication
Response.Redirect GLOBAL_DEFAULT_LOGIN & "?Message=" & server.URLEncode(Request.QueryString("Message"))

' -- Must be implemented because used by the FrameWork --

PUBLIC FUNCTION Application_OnStart()
END FUNCTION

PUBLIC FUNCTION Session_OnStart() ' -- Call the Session_OnStart Event for the first time the user initialize the frame work
END FUNCTION
%>


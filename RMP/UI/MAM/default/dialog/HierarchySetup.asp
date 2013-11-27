<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%


FrameWork.Dictionary.Add "FRAMEWORK", FALSE

If Instr(Request.ServerVariables("HTTP_USER_AGENT"), ".NET CLR 1.1.4322") > 0 Then
  FrameWork.Dictionary.Add "FRAMEWORK_1_1", TRUE
  FrameWork.Dictionary.Add "FRAMEWORK", TRUE
ELSE
  FrameWork.Dictionary.Add "FRAMEWORK_1_1", FALSE
End If

If Instr(Request.ServerVariables("HTTP_USER_AGENT"), ".NET CLR 2.") > 0 Then
  FrameWork.Dictionary.Add "FRAMEWORK_2", TRUE
  FrameWork.Dictionary.Add "FRAMEWORK", TRUE
ELSE
  FrameWork.Dictionary.Add "FRAMEWORK_2", FALSE
End If

mdm_Main 
  
%>


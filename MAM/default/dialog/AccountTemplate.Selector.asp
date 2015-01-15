<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
Session.codepage = 65001 
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MAMLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<HTML>
<HEAD>
  <meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=UTF-8">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/styles.css">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/MAMMenu.css">
  <LINK rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>styles/ListTabs.css">  
  <META http-equiv="Page-Enter" content="blendTrans(Duration=.1)"> 
  <META http-equiv="Page-Exit" content="blendTrans(Duration=.1)">  
</HEAD>

<BODY style="margin:0px 14px 6px 5px;">

<span id="header">

  <ul>
  
  <%
    If Len(Request.QueryString("Types")) > 0 Then
      Response.Write "<div style='color:white;'>You moved the following types:  (" & Request.QueryString("Types") & ")</div><br>"
    End If
    
    Dim bFirst
    Dim mFirstType
    bFirst = TRUE

    Dim accType, rs, accountTypeName
    Set accType = mam_GetAccountType(SubscriberYAAC().AccountType)
    Set rs = accType.GetAllDescendentAccountTypesAsRowset()
    
    If rs.RecordCount = 0 Then
      response.Write "There are no account types that support templates under accounts of type " & SubscriberYAAC().AccountType & "."
    End If
    
    Do While not rs.EOF
      accountTypeName = rs.value("descendenttypename")
      
      %>
        <li <%=GetCurrentTab(accountTypeName)%>><a href="AccountTemplate.Selector.asp?mdmCurrentTab=<%=accountTypeName%>&mdmReload=true&Types=<%=Request.QueryString("Types")%>"><%=accountTypeName%></a></li>
      <%
      
      rs.MoveNext
    Loop
  %>

  </ul>

</span>

<%
If Len(mdm_UIValueDefault("mdmCurrentTab", accountTypeName)) Then
%>
  <span id="blend">
    <script language=javascript>
      parent.fmeTemplatePage.location.href = 'AccountTemplate.EditStart.asp?AccountType=<%=mdm_UIValueDefault("mdmCurrentTab", mFirstType)%>&mdmReload=true';
    </script>
  </span>
<%
End If
%>

<%

Function GetCurrentTab(menu)
  GetCurrentTab = ""
  If LCase(mdm_UIValue("mdmCurrentTab")) = "" Then
    If bFirst = TRUE Then
      GetCurrentTab = "id=""current"""
      mFirstType = menu
      Session("MAM_CURRENT_ACCOUNT_TYPE") = menu
      bFirst = FALSE
    End If
  Else
    If LCase(mdm_UIValue("mdmCurrentTab")) = LCase(menu) Then
      GetCurrentTab = "id=""current"""
      Session("MAM_CURRENT_ACCOUNT_TYPE") = menu
    End If
  End If  

End Function 
%>

</BODY>
</HTML>
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

  <script language=javascript>
    function selectAccountType(obj)
    {
      if(obj.value != "question")
        parent.fmeAddPage.location.href = obj.value;
    }
  </script>

</HEAD>

<BODY style="background-color:#003B8E;">

<span id="header" style="padding:4px;">
  <SELECT ID="accounttypeselect" onchange="selectAccountType(this);" NAME="accounttypeselect"> 
    <option id="defaultselect" value="question" style="color:navy;">.: Select an Account Type :.</option>
      <%
        Dim accountTypeName
        If IsEmpty(Session("AccountTypes")) Then
          Set Session("AccountTypes") = Server.CreateObject("MetraTech.Accounts.Type.AccountTypeCollection")
        End If
        
        For Each accountTypeName in Session("AccountTypes").Names
          If UCase(accountTypeName) = "ROOT" or UCase(accountTypeName) = "SYSTEMACCOUNT" Then
            'skip
          Else
          %>
            <option id="<%=accountTypeName%>" value="<%=GetDialogForAccountType(accountTypeName)%>?AccountType=<%=accountTypeName%>&mdmReload=true"><%=accountTypeName%></option>
          <%
          End If
        Next
      %>
  </select>
</span>
<%

Function GetDialogForAccountType(acc)
  GetDialogForAccountType = "GenericFind.asp"
End Function
%>

</BODY>
</HTML>
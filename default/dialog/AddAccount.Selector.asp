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
  <SELECT ID="accounttypeselect" onchange="selectAccountType(this);"> 
    <option id="defaultselect" value="question" style="color:navy;">.: Select an Account Type :.</option>
      <%
        Dim folderID
        Const ADD_OPERATION = "metratech.com/accountcreation/operation/Add"
                
        folderID = request.QueryString("AncestorID")
        
        If(Len(folderID) > 0) Then
          ' We know the ancestor so only get direct descendants that support the ADD operation
          Dim rs
          Dim objYAAC
          
          Set objYAAC = mdm_CreateObject(MT_YAAC_PROG_ID)
          Call objYAAC.InitAsSecuredResource(CLng(folderID), Framework.SessionContext, mam_GetHierarchyDate())
          Set rs = mam_GetAccountType(objYAAC.AccountType).GetDirectDescendentsWithOperationAsRowset(ADD_OPERATION)
          
          While Not CBool(rs.EOF)
            Call RenderDropDownRow(rs.Value("AccountTypeName"), folderID)
            rs.MoveNext
          Wend
          
        Else
          ' We don't know the ancestor so get all account types that support the ADD operation
          Dim col
          dim s
          Set col = FrameWork.AccountCatalog.FindAllAccountTypesWithOperation(ADD_OPERATION)
          
          For Each s in col
            Call RenderDropDownRow(s, folderID)
          Next
        End If
      %>
  </select>
</span>
<%

' RenderDropDownRow    
Public Function RenderDropDownRow(accountTypeName, folderID)
    If UCase(accountTypeName) = "ROOT" or UCase(accountTypeName) = "SYSTEMACCOUNT" Then
      ' Skip Root and SystemAccount
    Else
    %>
      <option id="<%=accountTypeName%>" value="<%=GetAddDialogForAccountType(accountTypeName)%>?AccountType=<%=accountTypeName%>&FolderID=<%=folderID%>&mdmReload=true"><%=accountTypeName%></option>
    <%
    End If
End Function

Function GetAddDialogForAccountType(acc)
  Dim dict
  dict = acc & "_ADD_DIALOG"
  GetAddDialogForAccountType = mam_GetDictionaryDefault(dict, mam_GetDictionary("GENERIC_ADD_DIALOG"))
End Function

%>

</BODY>
</HTML>
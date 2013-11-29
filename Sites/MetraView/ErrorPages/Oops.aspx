<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Oops.aspx.cs" Inherits="ErrorPages_Oops" Title="<%$Resources:Resource,TEXT_TITLE%>" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
     <img src="/Res/Images/oops.png" />
     <br />
     
     <asp:Localize meta:resourcekey="support" runat="server">MetraView is unable to show the requested information.  Please notify your customer support.</asp:Localize>
     
     <br />
     <a href="<%=Request.ApplicationPath%>/Default.aspx"><asp:Localize meta:resourcekey="moveAlong" runat="server">Move along...</asp:Localize></a>
    </div>
    </form>
</body>
</html>

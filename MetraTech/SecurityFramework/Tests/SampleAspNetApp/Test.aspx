<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="SampleAspNetApp.Test" %>

<%--<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">--%>
<%--<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">--%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <%--<script type="text/javascript">
        var text = "<%=GetText() %>";
        alert(text);
    </script>--%>
    <p>
        <asp:TextBox ID="txtTest" runat="server" Width="600px"></asp:TextBox>
    </p>
    <p>
        <asp:Label ID="lblTest" runat="server"></asp:Label>
    </p>
    <p>
        <asp:Label ID="lblTest2" runat="server"></asp:Label>
    </p>
    <p>
        <asp:CustomValidator ID="custEquals" runat="server" ErrorMessage="Not Equal" ValidateEmptyText="false"></asp:CustomValidator>
    </p>
    <p>
        Regex time (&#xb5;s): <asp:Label ID="lblRegexTime" runat="server"></asp:Label>
    </p>
    <p>
        Parse time (&#xb5;s): <asp:Label ID="lblParseTime" runat="server"></asp:Label>
    </p>
    <p>
        Ratio: <asp:Label ID="lblRatio" runat="server"></asp:Label>; Avg: <asp:Label ID="lblRatioAvg" runat="server"></asp:Label>
    </p>
    <p>
        <asp:Button ID="btnTest" runat="server" Text="Test" OnClick="btnTest_Click" />
    </p>
    <%--<div>"Text"</div>
    <div>&#x400;</div>--%>
    
    <script type="text/javascript">
        /*
        document.write('<div id="test"/>');
        window["elem"]  = document.getElementById("test");
        elem.innerHTML=atob("YWxlcnQoJnF1b3RUZXh0JiN4MjIp");
        eval(elem.innerHTML);
        elem.parentNode.removeChild(elem);
        */
        
        //alert("\u0133\U00000133\d33\xacb11881\x11%33\N");
        //alert(eval("++[++[[]][+[]]][+[]]"));
        //alert((x = /(<scr).*(ipt>)/).test(x)); (RegExp.$1 + RegExp.$2);
        //eval("new \nFunction(undefined === null ? 'alert(78);' : atob('amF2YXNjcmlwdDphbGVydCgxKQ'))();");
        //alert("\G");
    </script>
    <script type="text/vbscript">
        'eval("Document.Write(chrw(40)&chrw(34)&""Hi from VBScript""&chrw(34)&chrw(41))")
        'alert(chr(50))
    </script>
    </div>
    &rpar;&NBSP;&rarr;&ratio;&rceil;&rdquo;&ratail;&apos;&del;&amp;&lt;&GT&Copy;
    <div>
        &plus; (+)<br />
&sol; (/)<br />
&ast; (*)<br />
&hyphen; (-)<br />
&lcub; ({)<br />
&rcub; (})<br />
&equals; (=)<br />
&commat; (@)<br />
&semi; (;)<br />
&colon; (:)<br />
&num; (#)<br />
&quest; (?)<br />
&lpar; (()<br />
&rpar; ())<br />
&excl; (!)<br />
&period; (.)<br />
&percent; (%) <br />
    </div>
    </form>
</body>
</html>

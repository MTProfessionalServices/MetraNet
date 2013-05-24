<%@ Page Language="C#" AutoEventWireup="True" CodeBehind="Encoder.aspx.cs" MasterPageFile="~/Master.Master" Inherits="SampleAspNetApp.Encoder" Title="Encoders tests" ValidateRequest="False" EnableEventValidation="False" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h2>
        Tests for encoders</h2>
    <asp:UpdatePanel ID="pnlMain" runat="server">
        <ContentTemplate>
        <fieldset>
            <legend>URL</legend>
            <p>
                <asp:TextBox ID="txtUrl" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblUrlEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnUrlEncode" runat="server" Text="Encode" 
                onclick="btnUrlEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>HTML</legend>
            <p>
                <asp:TextBox ID="txtHtml" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblHtmlEmcoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnHtmlEncode" runat="server" Text="Encode" 
                onclick="btnHtmlEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>HTML attribute</legend>
            <p>
                <asp:TextBox ID="txtHtmlAttribute" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblHtmlAttributeEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnHtmlAttributeEncode" runat="server" Text="Encode"
                OnClick="btnHtmlAttributeEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>CSS</legend>
            <p>
                <asp:TextBox ID="txtCss" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblCssEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnCssEncode" runat="server" Text="Encode"
                OnClick="btnCssEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>JavaScript</legend>
            <p>
                <asp:TextBox ID="txtJavaScript" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblJavaScriptEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnJavaScriptEncode" runat="server" Text="Encode"
                OnClick="btnJavaScriptEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>VB Script</legend>
            <p>
                <asp:TextBox ID="txtVbScript" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblVbScriptEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnVbScriptEncode" runat="server" Text="Encode"
                OnClick="btnVbScriptEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>XML</legend>
            <p>
                <asp:TextBox ID="txtXml" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblXmlEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnXmlEncode" runat="server" Text="Encode"
                OnClick="btnXmlEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>XML attribute</legend>
            <p>
                <asp:TextBox ID="txtXmlAttribute" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblXmlAttributeEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnXmlAttributeEncode" runat="server" Text="Encode"
                OnClick="btnXmlAttributeEncode_Click" />
        </fieldset>
        <fieldset>
            <legend>LDAP</legend>
            <p>
                <asp:TextBox ID="txtLdap" runat="server"></asp:TextBox>
            </p>
            <p>
                Result:
            </p>
            <p>
                <asp:Label ID="lblLdapEncoded" runat="server"></asp:Label>
            </p>
            <asp:Button ID="btnLdapEncode" runat="server" Text="Encode"
                OnClick="btnLdapEncode_Click" />
        </fieldset>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Decoder.aspx.cs" Inherits="SampleAspNetApp.Decoder"  ValidateRequest="False" EnableEventValidation="False"%>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h2>
        Tests for decoders</h2>
    <asp:UpdatePanel runat="server" ID="pnlMain">
        <ContentTemplate>
   	     	<fieldset>
                <legend>Base64 group decoder</legend>
    	        <asp:HyperLink runat="server" ID="HyperLink4" NavigateUrl="~/DecoderBase64.aspx">go to Base64 group decoder page...</asp:HyperLink>
        	</fieldset>
            <fieldset>
                <legend>Html</legend>
                <asp:Panel runat="server" ID="pnlHtml" DefaultButton="btnHtmlDecode">
                    <p>
                        <asp:TextBox ID="txtHtml" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultHtmlDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnHtmlDecode" runat="server" Text="Decode" 
                        onclick="btnHtmlDecode_Click" />
                </asp:Panel>
            </fieldset>

             <fieldset>
                <legend>JavaScript</legend>
                <asp:Panel runat="server" ID="PanelJavaScript" DefaultButton="btnJavaScriptDecode">
                    <p>
                        <asp:TextBox ID="txtJavaScriptDecode" runat="server" Height="55px" 
                            TextMode="MultiLine" Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultJavaScriptDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnJavaScriptDecode" runat="server" Text="Decode" onclick="btnJavaScriptDecode_Click" />
                </asp:Panel>
            </fieldset>

             <fieldset>
                <legend>VBScript</legend>
                <asp:Panel runat="server" ID="PanelVbScriptDecode" DefaultButton="btnVbScriptDecode">
                    <p>
                        <asp:TextBox ID="txtVbScriptDecode" runat="server" Height="55px" 
                            TextMode="MultiLine" Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultVbScriptDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnVbScriptDecode" runat="server" Text="Decode" 
                        onclick="btnVbScriptDecode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Xml</legend>
                <asp:Panel runat="server" ID="pnlXml" DefaultButton="btnDecode">
                    <p>
                        <asp:TextBox ID="txtXml" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultXmlDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnDecode" runat="server" Text="Decode" OnClick="btnDecode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Url</legend>
                <asp:Panel ID="pnlUrl" runat="server" DefaultButton="btnUrlDecode">
                    <p>
                        <asp:TextBox ID="txtUrl" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultUrlDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnUrlDecode" runat="server" Text="Decode" 
                        onclick="btnUrlDecode_Click" />
                </asp:Panel>
            </fieldset>            

            <fieldset>
                <legend>Css</legend>
                <asp:Panel ID="pnlCss" runat="server" DefaultButton="btnCssDecode">
                    <p>
                        <asp:TextBox ID="txtCss" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultCssDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnCssDecode" runat="server" Text="Decode" OnClick="btnCssDecode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>GZip (compressed and BASE 64 encoded value)</legend>
                <asp:Panel ID="pnlGZip" runat="server">
                    <p>
                        <asp:TextBox ID="txtGZip" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultGZipDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnGZipDecode" runat="server" Text="Decode" OnClick="btnGZipDecode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Ldap</legend>
                <asp:Panel ID="pnlLdap" runat="server" DefaultButton="btnLdapDecode">
                    <p>
                        <asp:TextBox ID="txtLdap" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultLdapDecode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnLdapDecode" runat="server" Text="Decode" OnClick="btnLdapDecode_Click" />
                </asp:Panel>
            </fieldset>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

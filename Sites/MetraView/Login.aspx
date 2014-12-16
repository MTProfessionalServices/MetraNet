<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="login" CodeFile="Login.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <noscript>
    <meta http-equiv="Refresh" content="0; url=JavaScriptError.aspx" />
  </noscript>

<script type="text/javascript">
function onDetails()
{
  var details = Ext.get('<%=reasonText.ClientID %>').dom.innerHTML;
          Ext.MessageBox.show({
             title: TITLE_ERROR,
             msg: details,
             buttons: Ext.MessageBox.OK,
             fn: function(btn){
               if (btn == 'ok')
               {
               }
             },
            
             icon: Ext.MessageBox.ERROR
          });
}
</script>

<div id="loginwrapper">
<div class="logintop"></div>
<div class="login">
        <div class="logo"> <a href="#"><img src="<%= SiteConfig.GetApplicationLogo() %>" alt="Company logo" /></a></div>
          <div class="loginbox">
            <h2><asp:Localize meta:resourcekey="Login" runat="server">Login</asp:Localize></h2>
      <asp:Panel ID="pnlLogin" runat="server" Width="252px">
        <asp:Login ID="Login1" runat="server" OnAuthenticate="Login1_Authenticate" 
          DisplayRememberMe="False" TitleText="" meta:resourcekey="Login1Resource1">
          <LabelStyle Font-Bold="True" HorizontalAlign="Right" /> <LoginButtonStyle CssClass="button" /><FailureTextStyle ForeColor="#B22222"></FailureTextStyle>
        </asp:Login>
      </asp:Panel>
      
      <asp:Panel ID="pnlChangePassword" runat="server" Visible="False">
        <asp:Label ID="lblMessage" runat="server" Text="Your Password Expired" ForeColor="#B22222" meta:resourcekey="lblMessageResource1"></asp:Label>
        
        <MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name" TabIndex="100" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="150" Listeners="{}" ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbUserNameResource1" />
        <MT:MTTextBoxControl ID="tbOldPassword" runat="server" AllowBlank="False" Label="Old Password" OptionalExtConfig="inputType:'password'" TabIndex="110" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="150" Listeners="{}"  ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbOldPasswordResource1" />
        <MT:MTPasswordMeter ID="tbNewPassword" runat="server" AllowBlank="False" Label="New Password" TabIndex="120" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="150" Listeners="{}" ReadOnly="False" XType="PasswordMeter" XTypeNameSpace="ux" LabelSeparator=":" meta:resourcekey="tbNewPasswordResource1" />
        <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password" OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbNewPassword'" TabIndex="130" VType="password" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="150" Listeners="{}"  ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbConfirmPasswordResource1" />
    
        <div id="reasonText" class="inner" runat="server" style="color: #B22222" ></div>
        <div class="Buttons" style="text-align:left">
           <br />   
           <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" Width="70px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="150" meta:resourcekey="btnOKResource1" />&nbsp;&nbsp;&nbsp;
           <asp:Button CssClass="button" ID="btnCancel" Width="80px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
           <br />       
        </div>
      </asp:Panel>      

        </div>
        <div class="clearer"><!--important--></div>

    <a href="Login.aspx?l=en-US">English (US)</a> &middot; 
    <a href="Login.aspx?l=en-GB">English (GB)</a> &middot; 
    <a href="Login.aspx?l=fr-FR">Français</a> &middot; 
    <a href="Login.aspx?l=de-DE">Deutsch</a> &middot; 
    <a href="Login.aspx?l=es">Español</a> &middot; 
    <a href="Login.aspx?l=ja">日本語</a>&middot; 
    <a href="Login.aspx?l=pt-br">Português (Brazil)</a>&middot; 
    <a href="Login.aspx?l=it">Italiano</a>&middot; 
    <a href="Login.aspx?l=es-mx">Español (México)</a>
        
  </div>
      <!--/box500-->
  <p class="loginlegal">&copy;2014 MetraTech Corp. All rights reserved.</p>
</div><!--/loginwrapper-->




  <!--[if lt IE 7]>
  <div style='border: 1px solid #F7941D; background: #FEEFDA; text-align: center; clear: both; height: 75px; position: relative;'>
    <div style='position: absolute; right: 3px; top: 3px; font-family: courier new; font-weight: bold;'><a href='#' onclick='javascript:this.parentNode.parentNode.style.display="none"; return false;'><img src='http://www.ie6nomore.com/files/theme/ie6nomore-cornerx.jpg' style='border: none;' alt='Close this notice'/></a></div>
    <div style='width: 640px; margin: 0 auto; text-align: left; padding: 0; overflow: hidden; color: black;'>
      <div style='width: 75px; float: left;'><img src='http://www.ie6nomore.com/files/theme/ie6nomore-warning.jpg' alt='Warning!'/></div>
      <div style='width: 275px; float: left; font-family: Arial, sans-serif;'>
        <div style='font-size: 14px; font-weight: bold; margin-top: 12px;'>You are using an outdated browser</div>
        <div style='font-size: 12px; margin-top: 6px; line-height: 12px;'>For a better experience using this site, please upgrade to a modern web browser.</div>
    </div>
      <div style='width: 75px; float: left;'><a href='http://www.firefox.com' target='_blank'><img src='http://www.ie6nomore.com/files/theme/ie6nomore-firefox.jpg' style='border: none;' alt='Get Firefox 3.5'/></a></div>
      <div style='width: 75px; float: left;'><a href='http://www.browserforthebetter.com/download.html' target='_blank'><img src='http://www.ie6nomore.com/files/theme/ie6nomore-ie8.jpg' style='border: none;' alt='Get Internet Explorer 8'/></a></div>
      <div style='width: 73px; float: left;'><a href='http://www.apple.com/safari/download/' target='_blank'><img src='http://www.ie6nomore.com/files/theme/ie6nomore-safari.jpg' style='border: none;' alt='Get Safari 4'/></a></div>
      <div style='float: left;'><a href='http://www.google.com/chrome' target='_blank'><img src='http://www.ie6nomore.com/files/theme/ie6nomore-chrome.jpg' style='border: none;' alt='Get Google Chrome'/></a></div>
  </div>
  </div>
  <![endif]-->

</asp:Content>
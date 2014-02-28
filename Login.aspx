<%@ Page Language="C#" MasterPageFile="~/MasterPages/LoginPageExt.master" AutoEventWireup="true"
    Inherits="login" CodeFile="Login.aspx.cs" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Src="UserControls/ServerDescription.ascx" TagName="ServerDescription"
    TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <script type="text/javascript">

        Ext.onReady(function () {

            top.clearTimeout(this.timer);

            if (getFrameMetraNet().frames.length > 0) getFrameMetraNet().location.replace(document.location);

            if (Ext.get('ctl00_ContentPlaceHolder1_Login1_UserName')) {
                setTimeout("Ext.get('ctl00_ContentPlaceHolder1_Login1_UserName').dom.focus();", 500);
            }

            if (Ext.get('<%=ShowPopup.ClientID %>') != null) {
                if (Ext.get('<%=ShowPopup.ClientID %>').dom.value == "true") {
                    onDetails();
                }
            }
        });

        function onDetails() {
            var details = Ext.get('<%=reasonText.ClientID %>').dom.innerHTML;
            Ext.MessageBox.show({
                title: 'Error',
                msg: details,
                buttons: Ext.MessageBox.OK,
                fn: function (btn) {
                    if (btn == 'ok') {
                    }
                },

                icon: Ext.MessageBox.ERROR
            });
        }


        var flagDist = 34;
        var languageButtonPressed = false;
        var SelectedLanguageRightToLeft = false;



        function holdCurrentBackgroundImage() {
            Ext.util.Cookies.set('currentBackgroundImageNumber', currentBackgroundImageNumber);
        }

        function initializeLanguageButtons() {
            Ext.select('div#lang-picker img').on("click", function () {

                //holdCurrentBackgroundImage();

                if (languageButtonPressed) return;
                languageButtonPressed = true;

                var e1 = Ext.get('selected-lang');

                var currentLang = e1.getAttribute('data-langnum');
                var nextLang = this.getAttribute('data-langnum');

                e1.set({ 'data-langnum': nextLang });
                e1.alignTo(this, "c-c");
                document.location = this.getAttribute("link");

            });



        }
    </script>
    <div id="LoginDiv" class="transparent-container borders-on shadow-on rounded-lg">
        <!-- Logo -->
        <div>
            <img alt="MetraNet" height="45" width="300" src="/Res/Images/login/metranet_Logo_Wht.png"
                style="display: block; margin: 0 auto;">
        </div>
        <!-- Message -->
        <div class="banner" class="tspace">
        </div>
        <!-- Container -->
        <div id="loginContainer" class="tspace">
            <asp:Panel ID="pnlLogin" runat="server">
                <asp:Login ID="Login1" runat="server" OnAuthenticate="Login1_Authenticate" DisplayRememberMe="False"
                    TitleText="" meta:resourcekey="Login1Resource1">
                    <LabelStyle CssClass="hidden-label" />
                    <LoginButtonStyle CssClass="lg-button lg-button-submit rounded-lg" />
                    <FailureTextStyle Font-Size="13px" Font-Bold="true" />
                </asp:Login>
            </asp:Panel>
            <script>
                Ext.onReady(function () {
                    document.getElementById("<%= Login1.ClientID%>" + "_UserName").placeholder = "<%=userName%>";
                    document.getElementById("<%= Login1.ClientID%>" + "_Password").placeholder = "<%=password%>";

                });
       
            </script>
        </div>
        <div>
            <asp:Panel ID="pnlChangePassword" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server" Text="Your Password Expired" ForeColor="Red"
                    meta:resourcekey="lblMessageResource1"></asp:Label>
                &nbsp;&nbsp; <a href="javascript:onDetails();">
                    <asp:Label ID="lblDetails" runat="server" Text="details" meta:resourcekey="lblDetailsResource1"></asp:Label></a>
                <div id="reasonText" runat="server" style="display: none">
                    <asp:Label ID="lblPleaseChange" runat="server" Text="Please change your password"
                        meta:resourcekey="lblPleaseChangeResource1"></asp:Label>
                </div>
                <div id="boxes" style="position: relative; left: -70px; top: 20px;">
                    <MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name"
                        TabIndex="100" ControlWidth="180" OptionalExtConfig="cls:'aligned',labelWidth:200"
                        ControlHeight="40" HideLabel="False" Listeners="{}" ReadOnly="True" XType="TextField"
                        XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbUserNameResource1" />
                    
                    <MT:MTTextBoxControl ID="tbOldPassword" runat="server" AllowBlank="False" Label="Old Password"
                        OptionalExtConfig="inputType:'password',cls:'aligned',labelWidth:200" TabIndex="110"
                        ControlWidth="180" ControlHeight="40" HideLabel="False" Listeners="{}" ReadOnly="False"
                        XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbOldPasswordResource1" />
                    
                    <MT:MTPasswordMeter ID="tbNewPassword" runat="server" AllowBlank="False" Label="New Password"
                        OptionalExtConfig="inputType:'password',cls:'aligned',labelWidth:200" TabIndex="120"
                        ControlWidth="180" ControlHeight="40" HideLabel="False" Listeners="{}" ReadOnly="False"
                        XType="PasswordMeter" XTypeNameSpace="ux" LabelSeparator=":" meta:resourcekey="tbNewPasswordResource1" />
                    
                    <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password"
                        OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbNewPassword',cls:'aligned',labelWidth:200"
                        TabIndex="130" VType="password" ControlWidth="180" ControlHeight="40" HideLabel="False"
                        Listeners="{}" ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":"
                        meta:resourcekey="tbConfirmPasswordResource1" />
                </div>
                <center>
                    <div class="Buttons" style="text-align: left">
                        <asp:Button CssClass="lg-button lg-button-submit rounded-lg" ID="btnOK" OnClientClick="return ValidateForm();"
                            Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click"
                            TabIndex="150" Height="20px" />&nbsp;&nbsp;&nbsp;
                        <asp:Button CssClass="lg-button lg-button-submit rounded-lg" ID="btnCancel" runat="server"
                            Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False"
                            TabIndex="160" Height="20px" />
                    </div>
                </center>
                <script>
                    Ext.onReady(function () {
                        document.getElementById("<%= tbOldPassword.ClientID%>").placeholder = "Old Password";
                        document.getElementById("<%= tbNewPassword.ClientID%>").placeholder = "New Password";
                        document.getElementById("<%= tbConfirmPassword.ClientID%>").placeholder = "Confirm Password";
                    });

                </script>
                <input id="ShowPopup" runat="server" type="hidden" />
            
            </asp:Panel>
        </div>

      <div>
                  <div id="lang-picker" class="tspace bspace-half" style="text-align: center;">
                        <div id="selected-lang" data-langnum="<%=dataLangNum%>" style="visibility:hidden"></div>
                
                        <!-- Need to change this to be dynamic -->

                        <ul id="panelLanguageItems" class="alpha tspace" style="display: inline-block">
                            <%--<li id="lang-label">Select language:</li>--%>
                            <li><img link="Login.aspx?l=en-US&datalangnum=1" src="/Res/Images/flags/us.png" alt="English" title="English" data-langnum="1" lang-code="en-us"/></li>
                            <li><img link="Login.aspx?l=en-GB&datalangnum=2" src="/Res/Images/flags/gb.png" alt="English (GB)" title="English (GB)" data-langnum="2" lang-code="en-gb"/></li>
                            <li><img link="Login.aspx?l=fr-FR&datalangnum=3" src="/Res/Images/flags/fr.png" alt="Français" title="Français" data-langnum="3" lang-code="fr-fr" /></li>
                            <li><img link="Login.aspx?l=de-De&datalangnum=4" src="/Res/Images/flags/de.png" alt="Deutsch" title="Deutsch" data-langnum="4" lang-code="de-de" /></li>
                            <li><img link="Login.aspx?l=es&datalangnum=5" src="/Res/Images/flags/es.png" alt="Español" title="Español" data-langnum="5" lang-code="es-es" /></li>
                            <li><img link="Login.aspx?l=ja&datalangnum=6" src="/Res/Images/flags/jp.png" alt="日本語" title="日本語" data-langnum="6" lang-code="ja-jp" /></li>
                            <li><img link="Login.aspx?l=pt-br&datalangnum=7" src="/Res/Images/flags/br.png" alt="Português  (Brazil)" title="Português (Brazil)" data-langnum="7" lang-code="pt-br" /></li>
                            <li><img link="Login.aspx?l=it&datalangnum=8" src="/Res/Images/flags/it.png" alt="Italiano" title="Italiano" data-langnum="8" lang-code="it-it" /></li>
                            <li><img link="Login.aspx?l=es-mx&datalangnum=9" src="/Res/Images/flags/mx.png" alt="Español (Mexico)" title="Español (Mexico)" data-langnum="9" lang-code="es-mx" /></li>
                       
                       
                       
                        </ul>
           
                 
                     <script>
                         Ext.onReady(function () {
                             // select curren language
                             var dSelectedLang = Ext.get("selected-lang");
                             var imgToSelect = dSelectedLang.getAttribute('data-langnum');
                             var dImgToSelect = Ext.DomQuery.selectNode("div#lang-picker img[data-langnum=" + imgToSelect + "]");
                             dSelectedLang.alignTo(dImgToSelect, "c-c");
                             dSelectedLang.setVisible(true);
                             initializeLanguageButtons();

                         });


       
                     </script> 
        </div>  
  </div>

<footer id="footer" class="login transparent-container">
    <div class="inner container_12 small">
    <uc1:ServerDescription ID="ServerDescription1" runat="server" />
    <div class="align-alt float"> &copy;1998-2014 MetraTech Corp. All rights reserved.</div>
    </div>
</footer>



</asp:Content>
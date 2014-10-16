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

    });


    var flagDist = 34;
    var languageButtonPressed = false;
    var SelectedLanguageRightToLeft = false;
    var language = "<%=language%>";


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

    function validateEnteredPasswords() {
      var errorTextDiv = document.getElementById('<%= divChangePasswdFailureText.ClientID %>');
      var currentPwd = document.getElementById('<%= CurrentPassword.ClientID %>');
      var newPwd = document.getElementById('<%= NewPassword.ClientID %>');
      var confirmNewPwd = document.getElementById('<%= ConfirmNewPassword.ClientID %>');
      var validationFailed = false;


      if (currentPwd.value == '<%=passwordTxt%>' || currentPwd.value == '') {
        validationFailed = true;
        errorTextDiv.innerHTML = '<%=enterPasswordTxt%>';
      }
      else if (newPwd.value == '<%=newpasswordTxt%>' || newPwd.value == '') {
        validationFailed = true;
        errorTextDiv.innerHTML = '<%=enterNewPasswordTxt%>';
      }
      else if (confirmNewPwd.value == '<%=confirmnewpasswordTxt%>' || confirmNewPwd.value == '') {
        validationFailed = true;
        errorTextDiv.innerHTML = '<%=enterConfirmPasswordTxt%>';
      }
      else if (newPwd.value != confirmNewPwd.value) {
        validationFailed = true;
        errorTextDiv.innerHTML = '<%=passwordsDontMatchTxt%>';
      }
      if (validationFailed) {
        displayChangePasswdErrorBox();
        return false;
      }
      return true;
    }

  </script>
  <div id="LoginDiv" class="transparent-container borders-on shadow-on rounded-lg">
    <!-- Logo -->
    <div>
      <img alt="MetraNet" height="45" width="300" src="/Res/Images/login/metranet_Logo_Wht.png"
        style="display: block; margin: 0 auto;">
    </div>
    <!-- Container -->
    <div id="loginContainer" class="tspace">
      <asp:Panel ID="pnlLogin" runat="server">
        <asp:Login ID="Login1" runat="server" OnAuthenticate="Login1_Authenticate" DisplayRememberMe="False"
          TitleText="" meta:resourcekey="Login1Resource1">
          <LayoutTemplate>
            <u1>
              <li>
                <asp:TextBox ID="UserName" runat="server"  />
              </li>
              <li>
                <asp:TextBox ID="Password" runat="server" TextMode="Password" />
              </li>
              <li>
                <div id="divLoginFailure" class="alert error rounded-med">
                  <div class="inner">
                    <div class="loginerror">
                      <h5><asp:Literal ID="FailureText" runat="server" EnableViewState="false" /></h5> 
                    </div>
                    <a class="close-alert" href=""></a>
                  </div>
                </div>        
              </li>
              <li>
                <asp:Button ID="Login" CommandName="Login" runat="server" CssClass="lg-button lg-button-submit rounded-lg" />
              </li>
            </u1>
          </LayoutTemplate>
        </asp:Login>
      </asp:Panel>
      <script type="text/javascript">
        Ext.onReady(function () {
          if (document.getElementById("<%= Login1.ClientID%>" + "_UserName") != null) {
            document.getElementById("<%= Login1.ClientID%>" + "_UserName").placeholder = "<%=userNameTxt%>";
          }
          if (document.getElementById("<%= Login1.ClientID%>" + "_Password") != null) {
            document.getElementById("<%= Login1.ClientID%>" + "_Password").placeholder = "<%=passwordTxt%>";
          }

          // Fix for IE
          if (Object.hasOwnProperty.call(window, "ActiveXObject") && !window.ActiveXObject) {
            // is IE11

            var dataPlaceholders = document.querySelectorAll("input[placeholder]"),
                l = dataPlaceholders.length,
            // Set caret at the beginning of the input
                setCaret = function (evt) {
                  if (this.value === this.getAttribute("data-placeholder")) {
                    this.setSelectionRange(0, 0);
                    evt.preventDefault();
                    evt.stopPropagation();
                    return false;
                  }
                },
            // Clear placeholder value at user input
                clearPlaceholder = function (evt) {
                  if (!(evt.shiftKey && evt.keyCode === 16) && evt.keyCode !== 9) {
                    if (this.value === this.getAttribute("data-placeholder")) {
                      this.value = "";
                      this.className = "active";
                      if (this.id === "<%= Login1.ClientID%>" + "_Password") {
                        this.type = "password";
                      }
                    }
                  }
                },
                restorePlaceHolder = function () {
                  if (this.value.length === 0) {
                    this.value = this.getAttribute("data-placeholder");
                    setCaret.apply(this, arguments);
                    this.className = "";
                    if (this.type === "password") {
                      this.type = "text";
                    }
                  }
                },
                clearPlaceholderAtSubmit = function (evt) {
                  for (var i = 0, placeholder; i < l; i++) {
                    placeholder = dataPlaceholders[i];
                    if (placeholder.value === placeholder.getAttribute("data-placeholder")) {
                      placeholder.value = "";
                    }
                  }
                };

            for (var i = 0, placeholder, placeholderVal; i < l; i++) {
              placeholder = dataPlaceholders[i];
              placeholderVal = placeholder.getAttribute("placeholder");
              placeholder.setAttribute("data-placeholder", placeholderVal);
              placeholder.removeAttribute("placeholder");

              if (placeholder.value.length === 0) {
                placeholder.value = placeholderVal;
                if (placeholder.type === "password") {
                  placeholder.type = "text";
                }
              } else {
                placeholder.className = "active";
              }

              // Apply events for placeholder handling         
              placeholder.addEventListener("focus", setCaret, false);
              placeholder.addEventListener("drop", setCaret, false);
              placeholder.addEventListener("click", setCaret, false);
              placeholder.addEventListener("keydown", clearPlaceholder, false);
              placeholder.addEventListener("keyup", restorePlaceHolder, false);
              placeholder.addEventListener("blur", restorePlaceHolder, false);

              // Clear all default placeholder values from the form at submit
              placeholder.form.addEventListener("submit", clearPlaceholderAtSubmit, false);
            }
          }

          if ("true" == "<%=showFailureText%>") {
            displayErrorBox();
          }
        });
        
          function displayErrorBox() {
              $('#<%= Login1.ClientID%>').find('.alert').not('.ajax').slideDown("fast");
           	  $('#<%= Login1.ClientID%>').find('input[type=password]').val('');
              $('#<%= Login1.ClientID%>').focus();
              $("#<%= Login1.ClientID%>").attr("style", "");
          }
      </script>
    </div> 
    <!-- Change password on expiration -->
    <div id="changePasswordContainer">
      <asp:Panel ID="pnlChangePassword" DefaultButton="ChangePassword" runat="server" Visible="False">
       
          <u1>
                        <li>
                            <div id="divChangePasswdInfo" class="alert info rounded-med">
                              <div class="inner">
                                <div class="changepasswdinfo">
                                    <h2><asp:Label ID="lblMessage" runat="server" Text="Your Password has Expired. Please change your password" ForeColor="Red"
                                      meta:resourcekey="lblMessageResource1"></asp:Label></h2>
                            
                                </div>
                              </div>
                            </div>
                       </li>
                      
                        <li>
                             <asp:TextBox ID="CurrentPassword" runat="server" TextMode="Password" />
                               
                        </li>
                           <li>
                             <asp:TextBox ID="NewPassword" runat="server" TextMode="Password" />
                        </li>
                        <li>
                             <asp:TextBox ID="ConfirmNewPassword" runat="server" TextMode="Password" />
                         </li>
                        <li>
                          <div id="divFailureChangePasswd" class="alert error rounded-med">
                            <div class="inner">
                              <div ID="divChangePasswdFailureText" class="changepasswderror" runat="server">
                               </div>
                              
                            </div>
                          </div>
                        
                      </li>
                       <li>
                         <div style="width:100%;margin-top: 10px">
                          <div style="float:left;width:48%">
                             <asp:Button ID="ChangePassword" OnClick="btnChangePassword_Click" runat="server" OnClientClick="return validateEnteredPasswords();"
                             CssClass="left lg-button lg-button-submit rounded-lg" Text="<%$Resources:Resource,TEXT_OK%>"/>
                           </div>
                           <div style="float:right;width:48%">
                             <asp:Button ID ="Cancel" runat="server" 
                             CssClass="lg-button lg-button-submit rounded-lg" OnClick="btnCancel_Click" Text="<%$Resources:Resource,TEXT_CANCEL%>"/>
                            </div>
                          </div>
                        </li>
                    </u1>

        <script type="text/javascript">
          Ext.onReady(function () {
            document.getElementById("<%= CurrentPassword.ClientID%>").placeholder = "<%=passwordTxt%>";
            document.getElementById("<%= NewPassword.ClientID%>").placeholder = "<%=newpasswordTxt%>";
            document.getElementById("<%= ConfirmNewPassword.ClientID%>").placeholder = "<%=confirmnewpasswordTxt%>";

            // Fix for IE
            if (Object.hasOwnProperty.call(window, "ActiveXObject") && !window.ActiveXObject) {
              // is IE11

              var dataPlaceholders = document.querySelectorAll("input[placeholder]"),
                l = dataPlaceholders.length,
              // Set caret at the beginning of the input
                setCaret = function (evt) {
                  if (this.value === this.getAttribute("data-placeholder")) {
                    this.setSelectionRange(0, 0);
                    evt.preventDefault();
                    evt.stopPropagation();
                    return false;
                  }
                },
              // Clear placeholder value at user input
                clearPlaceholder = function (evt) {
                  if (!(evt.shiftKey && evt.keyCode === 16) && evt.keyCode !== 9) {
                    if (this.value === this.getAttribute("data-placeholder")) {
                      this.value = "";
                      this.className = "active";
                      if (this.id === "<%= CurrentPassword.ClientID%>" ||
                      this.id === "<%= NewPassword.ClientID%>" ||
                      this.id === "<%= ConfirmNewPassword.ClientID%>") {
                        this.type = "password";
                      }
                    }
                  }
                },
                restorePlaceHolder = function () {
                  if (this.value.length === 0) {
                    this.value = this.getAttribute("data-placeholder");
                    setCaret.apply(this, arguments);
                    this.className = "";
                    if (this.type === "password") {
                      this.type = "text";
                    }
                  }
                },
                clearPlaceholderAtSubmit = function (evt) {
                  for (var i = 0, placeholder; i < l; i++) {
                    placeholder = dataPlaceholders[i];
                    if (placeholder.value === placeholder.getAttribute("data-placeholder")) {
                      placeholder.value = "";
                    }
                  }
                };

              for (var i = 0, placeholder, placeholderVal; i < l; i++) {
                placeholder = dataPlaceholders[i];
                placeholderVal = placeholder.getAttribute("placeholder");
                placeholder.setAttribute("data-placeholder", placeholderVal);
                placeholder.removeAttribute("placeholder");

                if (placeholder.value.length === 0) {
                  placeholder.value = placeholderVal;
                  if (placeholder.type === "password") {
                    placeholder.type = "text";
                  }
                } else {
                  placeholder.className = "active";
                }

                // Apply events for placeholder handling         
                placeholder.addEventListener("focus", setCaret, false);
                placeholder.addEventListener("drop", setCaret, false);
                placeholder.addEventListener("click", setCaret, false);
                placeholder.addEventListener("keydown", clearPlaceholder, false);
                placeholder.addEventListener("keyup", restorePlaceHolder, false);
                placeholder.addEventListener("blur", restorePlaceHolder, false);

                // Clear all default placeholder values from the form at submit
                placeholder.form.addEventListener("submit", clearPlaceholderAtSubmit, false);
              }
            }

            if ("true" == "<%=showChangePasswdFailureText%>") {
              displayChangePasswdErrorBox();
            }
          });

          function displayChangePasswdErrorBox() {
            $('#<%= pnlChangePassword.ClientID%>').find('.alert').not('.ajax').slideDown("fast");
            <%-- $('#<%= pnlChangePassword.ClientID%>').find('input[type=password]').val(''); --%>
            $('#<%= pnlChangePassword.ClientID%>').focus();
            $("#<%= pnlChangePassword.ClientID%>").attr("style", "");
          }
       
       </script>
        <input id="ShowPopup" runat="server" type="hidden" />
      </asp:Panel>
    </div>
    <!-- Language Selection -->
    <div>
      <div id="lang-picker" class="tspace bspace-half" style="text-align: center;">
        <div id="selected-lang" data-langnum="<%=dataLangNum%>" style="visibility: hidden">
        </div>
        <!-- Need to change this to be dynamic -->
        <ul id="panelLanguageItems" class="alpha tspace" style="display: inline-block">
          <%--<li id="lang-label">Select language:</li>--%>
          <li>
            <img link="Login.aspx?l=en-us" src="/Res/Images/flags/us.png" alt="English"
              title="English" data-langnum="1" lang-code="en-us" /></li>
          <li>
            <img link="Login.aspx?l=en-gb" src="/Res/Images/flags/gb.png" alt="English (GB)"
              title="English (GB)" data-langnum="2" lang-code="en-gb" /></li>
          <li>
            <img link="Login.aspx?l=fr-fr" src="/Res/Images/flags/fr.png" alt="Français"
              title="Français" data-langnum="3" lang-code="fr-fr" /></li>
          <li>
            <img link="Login.aspx?l=de-de" src="/Res/Images/flags/de.png" alt="Deutsch"
              title="Deutsch" data-langnum="4" lang-code="de-de" /></li>
          <li>
            <img link="Login.aspx?l=es-es" src="/Res/Images/flags/es.png" alt="Español"
              title="Español" data-langnum="5" lang-code="es-es" /></li>
          <li>
            <img link="Login.aspx?l=ja-jp" src="/Res/Images/flags/jp.png" alt="日本語"
              title="日本語" data-langnum="6" lang-code="ja-jp" /></li>
          <li>
            <img link="Login.aspx?l=pt-br" src="/Res/Images/flags/br.png" alt="Português  (Brazil)"
              title="Português (Brazil)" data-langnum="7" lang-code="pt-br" /></li>
          <li>
            <img link="Login.aspx?l=it-it" src="/Res/Images/flags/it.png" alt="Italiano"
              title="Italiano" data-langnum="8" lang-code="it-it" /></li>
          <li>
            <img link="Login.aspx?l=es-mx" src="/Res/Images/flags/mx.png" alt="Español (Mexico)"
              title="Español (Mexico)" data-langnum="9" lang-code="es-mx" /></li>
        </ul>
        <script type="text/javascript">
          Ext.onReady(function () {
            // select curren language
            var dSelectedLang = Ext.get("selected-lang");
            var dImgToSelect = Ext.DomQuery.selectNode("div#lang-picker img[lang-code=\"<%=language.ToLower()%>\"]");
            var currentLang = dImgToSelect.getAttribute('data-langnum');
            dSelectedLang.set({ 'data-langnum': currentLang });

            dSelectedLang.alignTo(dImgToSelect, "c-c");
            dSelectedLang.setVisible(true);
            initializeLanguageButtons();

          });


        </script>
      </div>
    </div>


  </div>
  
  
 	<footer id="footer" class="login transparent-container">
      <div class="inner small">
       <uc1:ServerDescription ID="ServerDescription1" runat="server" />
        <div class="align-alt float"> &copy;1998-2014 MetraTech Corp. All rights reserved.</div>
      </div>
    </footer>
</asp:Content>

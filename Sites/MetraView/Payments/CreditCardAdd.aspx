<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_CreditCardAdd" Culture="auto"
  UICulture="auto" meta:resourcekey="PageResource1" CodeFile="CreditCardAdd.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<script type="text/javascript" src="<%=Request.ApplicationPath%>/JavaScript/Validators.js"></script>

  <h1>
    <asp:Localize ID="Localize1" meta:resourcekey="AddCC" runat="server">Add Credit Card</asp:Localize></h1>
  <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage"
    Width="100%" />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <!-- BILLING INFORMATION -->
  <div class="box500">
    <div class="box500top">
    </div>
    <div class="box">
      <div class="left">
        <div id="divPaymentData" runat="server">
          <MT:MTLiteralControl ID="lcAmount" runat="server" Label="Amount" meta:resourcekey="lcAmount" />
          <MT:MTLiteralControl ID="lcMethod" runat="server" Label="Method" meta:resourcekey="lcMethod" />
          <br />
          <hr />
          <br />
        </div>
        <MT:MTTextBoxControl ID="tbFirstName" runat="server" AllowBlank="False" Label="First Name"
          TabIndex="50" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbFirstNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbMiddleInitial" runat="server" AllowBlank="True" Label="Middle Initial"
          OptionalExtConfig="maxLength:1" TabIndex="60" ControlWidth="200" ControlHeight="18"
          HideLabel="False" LabelWidth="120" meta:resourcekey="tbMiddleInitialResource1"
          ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbLastName" runat="server" AllowBlank="False" Label="Last Name"
          TabIndex="70" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbLastNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbAddress" runat="server" AllowBlank="False" Label="Address Line 1"
          TabIndex="80" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbAddressResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbAddress2" runat="server" AllowBlank="True" ControlWidth="200"
          Label="Address Line 2" TabIndex="90" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbAddress2Resource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbCity" runat="server" AllowBlank="False" ControlWidth="200"
          Label="City" TabIndex="100" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbCityResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbState" runat="server" AllowBlank="True" ControlWidth="50"
          Label="State/Province" TabIndex="110" OptionalExtConfig="maxLength:2,regex:/\w{2}/" ControlHeight="18"
          HideLabel="False" LabelWidth="120" meta:resourcekey="tbStateResource1" ReadOnly="False"
          XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbZipCode" runat="server" AllowBlank="False" ControlWidth="100"
          Label="Zip/Postal Code" OptionalExtConfig="maxLength:10" TabIndex="120" ControlHeight="18"
          HideLabel="False" LabelWidth="120" meta:resourcekey="tbZipCodeResource1" ReadOnly="False"
          XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbEmail" runat="server" AllowBlank="True" ControlWidth="200" 
          Label="Email" OptionalExtConfig="maxLength:100" TabIndex="130" ControlHeight="18" 
          HideLabel="False" LabelWidth="120"  meta:resourcekey="tbEmail" ReadOnly="False" 
          XType="TextField" XTypeNameSpace="form" />
        <MT:MTDropDown ID="ddCountry" runat="server" AllowBlank="False" ControlWidth="200"
          Label="Country" TabIndex="140" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbCountryResource1" ReadOnly="False" />
        <br />
        <hr style="width: 480px;" />
        <br />
        <MT:MTDropDown ID="ddPriority" runat="server" AllowBlank="false" ControlWidth="70"
          ListWidth="70" meta:resourcekey="ddPriorityResource1" ReadOnly="false" TabIndex="150">
        </MT:MTDropDown>
        <MT:MTDropDown ID="ddCardType" runat="server" AllowBlank="False" Label="Credit Card Type"
          TabIndex="160" ControlWidth="200" HideLabel="False" meta:resourcekey="ddCardTypeResource1"
          ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTTextBoxControl ID="tbCCNumber" runat="server" AllowBlank="False" Label="Card Number"
          TabIndex="170" ControlWidth="200" OptionalExtConfig="maxLength:24" HideLabel="False"
          LabelWidth="120" VType="credit_card_number" meta:resourcekey="tbCCNumberResource1"
          ReadOnly="False" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbCCSafeNumber" runat="server" AllowBlank="True" ControlWidth="200"
           Label="CC safe #" TabIndex="180" ControlHeight="18" HideLabel="False" LabelWidth="120"  ReadOnly="true"
           XType="TextField" XTypeNameSpace="form" />
        <div id="Div3" style="float: left; width: 190px;">
          <MT:MTTextBoxControl ID="tbCVNNumber" runat="server" AllowBlank="False" Label="CVV Number"
            TabIndex="190" ControlWidth="50" OptionalExtConfig="maxLength:4" ControlHeight="18"
            HideLabel="False" LabelWidth="120" meta:resourcekey="tbCVNNumberResource1" ReadOnly="False"
            VType="cv_number" XTypeNameSpace="form" />
        </div>
        <div id="Div4" style="float: left; width: 100px;"> 
          <asp:LinkButton runat="server" ID="CCVNHelp" Text="Credit Card Verification Number" TabIndex="200"
            Width="700" meta:resourcekey="hrCCVNResource1" OnClientClick="loadHelp(); return false;"
            CausesValidation="false"></asp:LinkButton>
          <div>
            &nbsp;
          </div>
        </div>
        <div style="clear: both">
        </div>
        <div>
          <div id="Div1" style="float: left; width: 200px;">
            <MT:MTDropDown ID="ddExpMonth" runat="server" AllowBlank="False" TabIndex="210" ControlWidth="70"
              Width="70" Label="Expiration Date" HideLabel="False" meta:resourcekey="ddExpMonthResource1"
              ReadOnly="False">
            </MT:MTDropDown>
          </div>
          <div id="Div2" style="float:left;width:100px;padding-left:5px">
            <MT:MTDropDown ID="ddExpYear" runat="server" AllowBlank="False" ControlWidth="70"
              HideLabel="False" LabelWidth="10" LabelSeparator="" Label="/" meta:resourcekey="ddExpYearResource1"
              OptionalExtConfig="" ReadOnly="False" TabIndex="220" Width="70">
            </MT:MTDropDown>
          </div>
        </div>
        <div style="clear: both">
        </div>
        <!-- BUTTONS -->
        <div class="button">
        <%if (UsePaymentBroker == true)
          { %>
        <div id="divSafeCC" style="display:block">
            <MT:MTButton ID="MTButton1" runat="server" OnClick="btnOK_Click"
              OnClientClick="return sendCardToPaymentBroker();" TabIndex="390" Text="Generate safe CC #" Width="50px" /><!-- OnClientClick="sendCardToPaymentBroker()"/>-->
         </div>  
          <div class="centerbutton">
            <span class="buttonleft">
              <!--leftcorner-->
            </span>
             <div id="divBtnOk" style="display:none">
            <asp:Button OnClick="btnOK_Click" ID="btnOK1" TabIndex="300"
              runat="server" Text="<%$Resources:Resource,TEXT_OK%>" />
              </div>
            <span class="buttonright">
            
              <!--rightcorner-->
            </span>
          </div>
           <% }
          else
          { %>
           <div class="centerbutton">
            <span class="buttonleft">
              <!--leftcorner-->
            </span>
             <asp:Button OnClick="btnOK_Click" ID="btnOK" TabIndex="300"
              runat="server" Text="<%$Resources:Resource,TEXT_OK%>" />
            <span class="buttonright">
            
              <!--rightcorner-->
            </span>
          </div>
          <%} %>
          <span class="buttonleft">
            <!--leftcorner-->
          </span>
          <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false" TabIndex="400"
            Text="<%$Resources:Resource,TEXT_CANCEL%>" />
          <span class="buttonright">
            <!--rightcorner-->
          </span>
        </div>
      </div>
    </div>
    <div class="clearer">
    </div>
  </div>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingProperty="SelectedValue"
        BindingSource="CreditCard" BindingSourceMember="CreditCardType" ControlId="ddCardType"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem9" runat="server" BindingSource="CreditCard"
        BindingSourceMember="AccountNumber" ControlId="tbCCNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="CreditCard" BindingSourceMember="FirstName"
        ControlId="tbFirstName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem5" runat="server" BindingSource="CreditCard"
        BindingSourceMember="MiddleName" ControlId="tbMiddleInitial" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="CreditCard"
        BindingSourceMember="LastName" ControlId="tbLastName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="CreditCard" BindingSourceMember="Street"
        ControlId="tbAddress" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="CreditCard"
        BindingSourceMember="Street2" ControlId="tbAddress2" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="CreditCard" BindingSourceMember="City"
        ControlId="tbCity" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem6" runat="server" BindingSource="CreditCard"
        BindingSourceMember="State" ControlId="tbState" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem7" runat="server" BindingSource="CreditCard"
        BindingSourceMember="ZipCode" ControlId="tbZipCode" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingSource="CreditCard"
        BindingProperty="SelectedValue" BindingSourceMember="Country" ControlId="ddCountry"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingSource="CreditCard"
        BindingSourceMember="CVNumber" ControlId="tbCVNNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="ddExpYear" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script language="javascript" type="text/javascript">
    function sendCardToPaymentBroker() {
      if (Validate() == false) return false;
      if (Boolean("<%=UsePaymentBroker%>") != true) { return true; }

      // Collect information from user inputs.
      var serverAddress = "<%=PaymentBrokerAddress%>";
      var firstName = document.getElementById('<%=tbFirstName.ClientID%>').value;
      var middleInitial = document.getElementById('<%=tbMiddleInitial.ClientID%>').value;
      var lastName = document.getElementById('<%=tbLastName.ClientID%>').value;
      var address1 = document.getElementById('<%=tbAddress.ClientID%>').value;
      var address2 = document.getElementById('<%=tbAddress2.ClientID%>').value;
      var country = GetIsoCode(document.getElementById('<%=ddCountry.ClientID%>').value);
      var city = document.getElementById('<%=tbCity.ClientID%>').value;
      var state = document.getElementById('<%=tbState.ClientID%>').value;
      var zip = document.getElementById('<%=tbZipCode.ClientID%>').value;
      var email = document.getElementById('<%=tbEmail.ClientID%>').value;
      var type = document.getElementById('<%=ddCardType.ClientID%>').value;
      var cardNumber = document.getElementById('<%=tbCCNumber.ClientID%>').value;
      var verificationCode = document.getElementById('<%=tbCVNNumber.ClientID%>').value;
      var expirationMonth = document.getElementById('<%=ddExpMonth.ClientID%>').value;
      var expirationYear = document.getElementById('<%=ddExpYear.ClientID%>').value;

      // Form a request string based on collected information.
      // Add random value as the last parameter to avoid caching in IE.
      var request = 'https://' + serverAddress + '/paymentmethod/creditcard?' +
        'address1=' + escape(address1) +
        '&address2=' + escape(address2) +
        '&cardVerificationNumber=' + escape(verificationCode) +
        '&city=' + escape(city) +
        '&country=' + escape(country) +
        '&creditCardNumber=' + escape(cardNumber) +
        '&creditCardType=' + escape(type) +
        '&expirationDate=' + escape(expirationMonth + '/' + expirationYear) +
        '&email=' + escape(email) +
        '&firstName=' + escape(firstName) +
        '&lastName=' + escape(lastName) +
        '&middleName=' + escape(middleInitial) +
        '&postal=' + escape(zip) +
        '&state=' + escape(state) +
        '&random=' + Math.random();

      // Use JSONP pattern to communicate with payment broker.
      // See http://en.wikipedia.org/wiki/JSONP for more details.
      var head = document.getElementsByTagName('head')[0];
      removePreviousBrokerRequest(head);
      var script = document.createElement('script');
      script.setAttribute('src', request);
      script.addEventListener('error', completeErrorRequest);
      head.appendChild(script);
      return false;
    }

    // Removes from the document's header <script> element
    // created during previous request to the payment broker
    function removePreviousBrokerRequest(head) {
      var scripts = head.getElementsByTagName("script")
      for (var i = scripts.length; i >= 0; i--)
        if (scripts[i] && scripts[i].getAttribute("src") != null && scripts[i].getAttribute("src").indexOf('/paymentmethod/creditcard?address1=') != -1) {
          head.removeChild(scripts[i]);
          break;
        }
    }

    // Handle errors which occur while requesting the payment broker.
    function completeErrorRequest() {
      document.getElementById('<%=tbCCNumber.ClientID%>').value = 'PaymentBroker request error occurred';
    }

    // Process response from the payment broker.
    function callback(obj) {
      if (obj.ResponseType != 'Success') {
        document.getElementById('<%=tbCCNumber.ClientID%>').value = '';
        Ext.Msg.show({
          title: TEXT_ERROR,
          msg: obj.ResponseValue,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.ERROR
        });
      }
      else {
        document.getElementById('<%=tbCCSafeNumber.ClientID%>').value = "******" + document.getElementById('<%=tbCCNumber.ClientID%>').value.substr(12); //document.getElementById('<%=tbCCNumber.ClientID%>').length - 4);
        document.getElementById('<%=tbCCNumber.ClientID%>').value = obj.ResponseValue;
        document.getElementById('divSafeCC').style.display = 'none';
        document.getElementById('divBtnOk').style.display = 'block';
      }
    }

    function loadHelp() {
      var loadCCVNHelp = new Ext.Window({
        width: 600,
        height: 300,
        html: '<img src="<%=Request.ApplicationPath%>/Images/cvnn.jpg" />'
      });
      loadCCVNHelp.show();

      return false;
    }
   
    function Validate() {
      var fname = Ext.get("<%= tbFirstName.ClientID%>").dom.value;
      var lname = Ext.get("<%= tbLastName.ClientID%>").dom.value;
      var minitial = Ext.get("<%= tbMiddleInitial.ClientID%>").dom.value;
      var address = Ext.get("<%= tbAddress.ClientID%>").dom.value;
      var address2 = Ext.get("<%= tbAddress2.ClientID%>").dom.value;
      var city = Ext.get("<%= tbCity.ClientID%>").dom.value;
      var state = Ext.get("<%= tbState.ClientID%>").dom.value;
      var zipcode = Ext.get("<%= tbZipCode.ClientID%>").dom.value;

      if ((fname == ' ') ||
        (lname == ' ') ||
        (minitial == ' ') ||
        (address == ' ') ||
        (address2 == ' ') ||
        (city == ' ') ||
        (state == ' ') ||
        (zipcode == ' ')) {
        Ext.Msg.show({
          title: TEXT_ERROR,
          msg: TEXT_VALIDATION_ERROR,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.ERROR
        });
        return false;
      }
      else if ((fname.indexOf("\\") >= 0) ||
          (lname.indexOf("\\") >= 0) ||
          (minitial.indexOf("\\") >= 0) ||
          (address.indexOf("\\") >= 0) ||
          (address2.indexOf("\\") >= 0) ||
          (city.indexOf("\\") >= 0) ||
          (state.indexOf("\\") >= 0) ||
          (zipcode.indexOf("\\") >= 0)) {
        Ext.Msg.show({
          title: TEXT_ERROR,
          msg: TEXT_VALIDATION_ERROR,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.ERROR
        });
        return false;
      }
      else if (isNaN(Ext.get("<%= tbCVNNumber.ClientID%>").dom.value)) {
        Ext.Msg.show({
          title: TEXT_ERROR,
          msg: TEXT_INVALID_CVN_NUM,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.ERROR
        });
        Ext.get("<%= tbCVNNumber.ClientID%>").dom.focus();
        return false;
      }
      else {
        return ValidateForm();
      }
    }   
  </script>
</asp:Content>
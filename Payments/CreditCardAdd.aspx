<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_CreditCardAdd" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="CreditCardAdd.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <MT:MTTitle ID="MTTitle1" Text="Add Credit Card" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

  <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage" Width="100%" />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages" Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <script language="javascript" type="text/javascript" src="PaymentBroker.js?v=1.2"></script>
  <script language="javascript" type="text/javascript">
    function sendCardToPaymentBroker() {     
      if (window.ValidateForm() == false) return false;
      if (Boolean("<%=UsePaymentBroker%>") != true) {
        return true;
      }
      
      // Collect information from user inputs.
      var typeName = document.getElementById('<%=ddCardType.ClientID%>').value;
      var type = GetPaymentBrokerCreditCardType(typeName);
      if (type == 'Unknown') {
        window.Ext.Msg.alert(window.TEXT_INFO, typeName + ' ' + '<%=CreditCardTypeErrorMessage%>');
        return false;
      }
      
      var serverAddress = "<%=PaymentBrokerAddress%>";
      var firstName = document.getElementById('<%=tbFirstName.ClientID%>').value;
      var middleInitial = document.getElementById('<%=tbMiddleInitial.ClientID%>').value;
      var lastName = document.getElementById('<%=tbLastName.ClientID%>').value;
      var address1 = document.getElementById('<%=tbAddress.ClientID%>').value;
      var address2 = document.getElementById('<%=tbAddress2.ClientID%>').value;
      var country = window.GetIsoCode(document.getElementById('<%=ddCountry.ClientID%>').value);
      var city = document.getElementById('<%=tbCity.ClientID%>').value;
      var state = document.getElementById('<%=tbState.ClientID%>').value;
      var zip = document.getElementById('<%=tbZipCode.ClientID%>').value;
      var email = document.getElementById('<%=tbEmail.ClientID%>').value;
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
      if (script.addEventListener)
        script.addEventListener('error', completeErrorRequest);
      else if (script.attachEvent) {
        script.attachEvent('error', completeErrorRequest); // for support IE7
      }
      head.appendChild(script);
      return false;
    }

    function removePreviousBrokerRequest(head) {
      // Removes from the document's header <script> element
      // created during previous request to the payment broker
      var scripts = head.getElementsByTagName("script");
      for (var i = scripts.length; i >= 0; i--)
        if (scripts[i] && scripts[i].getAttribute("src") != null && scripts[i].getAttribute("src").indexOf('/paymentmethod/creditcard?address1=') != -1) {
          head.removeChild(scripts[i]);
          break;
        }
    }

    function completeErrorRequest() {
      // Handle errors which occur while requesting the payment broker.
      document.getElementById('<%=tbCCNumber.ClientID%>').value = 'PaymentBroker request error occurred';
    }

    function callback(obj) {
      // Process response from the payment broker.
      if (obj.ResponseType != 'Success') {
        document.getElementById('<%=tbCCNumber.ClientID%>').value = '';
        Ext.Msg.show({
          title: TEXT_ERROR,
          msg: obj.ResponseValue,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.ERROR
        });
      } else {
        document.getElementById('<%=paymentInstrumentId.ClientID%>').value = obj.ResponseValue;
        var number = document.getElementById('<%=tbCCNumber.ClientID%>').value;
        if (number != null) {
          var encryptedNumber = '';
          for (var i = 0; i < number.length - 4; i++)
            encryptedNumber += '*';
          document.getElementById('<%=tbCCNumber.ClientID%>').value = encryptedNumber + number.substr(number.length - 4, number.length - 4); // for support IE7
        }
        document.getElementById('<%=tbCCNumber.ClientID%>').setAttribute('readOnly', 'true'); // readOnly - for support IE7
        document.getElementById('divSafeCC').style.display = 'none';
        document.getElementById('divBtnOk').style.display = 'block';
      }
    }
  </script>

  <div style="width:810px">
    <!-- BILLING INFORMATION --> 
    <MT:MTPanel ID="pnlBillingInfo" runat="server"  meta:resourcekey="MTSection1Resource1" Collapsible="false">
    <div id="leftColumn" class="LeftColumn">
      <MT:MTDropDown ID="ddPriority" runat="server" AllowBlank="false" ControlWidth="70" ListWidth="70"
        TabIndex="5" meta:resourcekey="ddPriorityResource1" ReadOnly="false"></MT:MTDropDown>
      <MT:MTDropDown ID="ddCardType" runat="server" AllowBlank="False" Label="Credit Card Type" TabIndex="4" ControlWidth="200" HideLabel="False"  meta:resourcekey="ddCardTypeResource1" ReadOnly="False"></MT:MTDropDown>
      <MT:MTTextBoxControl ID="tbCCNumber" runat="server" AllowBlank="False" Label="Card Number"
        TabIndex="10" ControlWidth="200" OptionalExtConfig="maxLength:24"
         HideLabel="False" LabelWidth="120"   VType="credit_card_number"
       meta:resourcekey="tbCCNumberResource1" ReadOnly="False" XTypeNameSpace="form"  />
    
      <MT:MTTextBoxControl ID="tbCVNNumber" runat="server" AllowBlank="False" Label="CVN Number"
        TabIndex="20" ControlWidth="50" OptionalExtConfig="maxLength:4"  ControlHeight="18" HideLabel="False" LabelWidth="120"    
        meta:resourcekey="tbCVNNumberResource1" ReadOnly="False" VType="cv_number" XTypeNameSpace="form" />
      
      <div id="Div1" style="float:left; width:200px;">
        <MT:MTDropDown ID="ddExpMonth" runat="server" AllowBlank="False" TabIndex="30" ControlWidth="70" Width="70"
            Label="Expiration Date" HideLabel="False"  meta:resourcekey="ddExpMonthResource1" ReadOnly="False">               
            </MT:MTDropDown>
      </div>
      <div id="Div2" style="float:left; width:100px;">
        <MT:MTDropDown ID="ddExpYear" runat="server" AllowBlank="False" ControlWidth="70"
          HideLabel="False" LabelWidth="10" LabelSeparator="" Label="/" meta:resourcekey="ddExpYearResource1"
          OptionalExtConfig="" ReadOnly="False" TabIndex="40" Width="70">
        </MT:MTDropDown>  
      </div>
    </div>

  <div id="rightColumn" class="RightColumn">
    <MT:MTTextBoxControl ID="tbFirstName" runat="server" AllowBlank="False" Label="First Name" TabIndex="50" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbFirstNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbMiddleInitial" runat="server" AllowBlank="True" Label="Middle Initial" OptionalExtConfig="maxLength:1" TabIndex="60" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbMiddleInitialResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbLastName" runat="server" AllowBlank="False" Label="Last Name" TabIndex="70"  ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbLastNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
   
    <MT:MTTextBoxControl ID="tbAddress" runat="server" AllowBlank="False" Label="Address Line 1" TabIndex="80"
     ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbAddressResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbAddress2" runat="server" AllowBlank="True" ControlWidth="200"
      Label="Address Line 2" TabIndex="90" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbAddress2Resource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbCity" runat="server" AllowBlank="False" ControlWidth="200"
      Label="City" TabIndex="100" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbCityResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbState" runat="server" AllowBlank="True" ControlWidth="50"
      Label="State/Province" TabIndex="110" OptionalExtConfig="maxLength:2,regex:/\w{2}/" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbStateResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbZipCode" runat="server" AllowBlank="False" ControlWidth="100"
      Label="Zip/Postal Code" OptionalExtConfig="maxLength:10" TabIndex="120" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbZipCodeResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbEmail" runat="server" AllowBlank="True" Label="Email" TabIndex="130"
     ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbEmail" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddCountry" runat="server" AllowBlank="False" ControlWidth="200"
      Label="Country" TabIndex="140" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbCountryResource1" ReadOnly="False"/>       
  </div>
   
   <div style="clear:both"></div>
   </MT:MTPanel>

    <!-- BUTTONS -->
     <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center"> 
      <center>  
      <table cellspacing="0">
        <tr>
        <%if (UsePaymentBroker == true)
          { %>
          <td  class="x-panel-btn-td">
          <div id="divSafeCC" style="display:block">
            <MT:MTButton ID="MTButton1" runat="server" OnClick="btnOK_Click"
              OnClientClick="return sendCardToPaymentBroker();" TabIndex="390" Text="Generate safe CC #" Width="50px" />
           </div>
         </td>
        
          <td  class="x-panel-btn-td">
               <div id="divBtnOk" style="display:none">
            <MT:MTButton ID="btnOK" runat="server" OnClick="btnOK_Click"
               TabIndex="390" Text="<%$Resources:Resource,TEXT_OK%>" Width="50px" />
                </div>
          </td>
         
           <% }
          else
          { %>
           <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK1" runat="server" OnClick="btnOK_Click" OnClientClick="return ValidateForm();"
               TabIndex="390" Text="<%$Resources:Resource,TEXT_OK%>" Width="50px" />
          </td>
          <% } %>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" CausesValidation="False"
              OnClick="btnCancel_Click" TabIndex="400" Text="<%$Resources:Resource,TEXT_CANCEL%>" Width="50px"  />
          </td>
        </tr>
      </table>  
     </center>   
    </div>
  </div>
  </div>
  <asp:HiddenField ID="paymentInstrumentId" ClientIDMode="Static" runat="server" />

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingProperty="SelectedValue"
        BindingSource="CreditCard" BindingSourceMember="CreditCardType" ControlId="ddCardType"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem9" runat="server" BindingSource="CreditCard"
        BindingSourceMember="SafeAccountNumber" ControlId="tbCCNumber" ErrorMessageLocation="RedTextAndIconBelow">
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
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingSource="CreditCard" BindingProperty="SelectedValue"
        BindingSourceMember="Country" ControlId="ddCountry" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingSource="CreditCard"
        BindingSourceMember="CVNumber" ControlId="tbCVNNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
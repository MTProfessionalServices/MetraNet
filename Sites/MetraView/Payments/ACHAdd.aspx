<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_ACHAdd" Culture="auto" UICulture="auto"
  meta:resourcekey="PageResource1" CodeFile="ACHAdd.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <script type="text/javascript" src="<%=Request.ApplicationPath%>/JavaScript/Validators.js"></script>
  <h1>
    <asp:Localize ID="Localize1" meta:resourcekey="AddACH" runat="server" Text="Add ACH"></asp:Localize></h1>
  <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage" Width="100%" />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <!-- BILLING INFORMATION -->
  <div class="box500">
    <div class="box500top">
    </div>
    <div class="box">
      <div class="left">
        <div id="divPaymentData" runat="server">
          <MT:MTLiteralControl ID="lcAmount" runat="server" Label="Amount" meta:resourcekey="lcamount" />
          <MT:MTLiteralControl ID="lcMethod" runat="server" Label="Method" meta:resourcekey="lcmethod" />
          <br />
          <hr />
          <br />
        </div>
        <MT:MTTextBoxControl ID="tbFirstName" runat="server" AllowBlank="False" Label="First Name"
          TabIndex="50" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120" OptionalExtConfig="maxLength:40"            meta:resourcekey="tbFirstNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbMiddleInitial" runat="server" AllowBlank="True" Label="Middle Initial"
          OptionalExtConfig="maxLength:1" TabIndex="60" ControlWidth="200" ControlHeight="18"
          HideLabel="False" LabelWidth="120" meta:resourcekey="tbMiddleInitialResource1"
          ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbLastName" runat="server" AllowBlank="False" Label="Last Name"
          TabIndex="70" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="120"
          OptionalExtConfig="maxLength:40"
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
        <MT:MTDropDown ID="ddCountry" runat="server" AllowBlank="False" ControlWidth="200"
          Label="Country" TabIndex="130" ControlHeight="18" HideLabel="False" LabelWidth="120"
          meta:resourcekey="tbCountryResource1" ReadOnly="False" />
        <br />
        <hr style="width: 480px;" />
        <br />
        <MT:MTDropDown ID="ddPriority" runat="server" AllowBlank="false" ControlWidth="70"
          ListWidth="70" Label="Priority" TabIndex="140" meta:resourcekey="ddPriorityResource1"
          ReadOnly="false">
        </MT:MTDropDown>
        <div id="Div1" style="float: left; width: 340px;">
          <MT:MTTextBoxControl ID="tbAccountNumber" runat="server" AllowBlank="False" ControlWidth="200"
            Label="Account Number" TabIndex="150" ControlHeight="18" HideLabel="False" LabelWidth="120"
            meta:resourcekey="tbAccountNumberResource1" ReadOnly="False" XTypeNameSpace="form"
            OptionalExtConfig="minLength:11,&#13;&#10;maxLength:20" VType="digits" />
        </div>
        <div id="Div2" style="float: left; width: 140px;">
          <asp:LinkButton runat="server" ID="AcctNumLinkButton" Text="Account Number" Width="700"
            meta:resourcekey="tbAccountNumberLinkResource1" OnClientClick="loadHelp(); return false;"
            CausesValidation="false" TabIndex="160"></asp:LinkButton>
          <div>
            &nbsp;
          </div>
        </div>
        <div id="Div3" style="float: left; width: 340px;">
          <MT:MTTextBoxControl ID="tbRoutingNumber" runat="server" AllowBlank="False" ControlWidth="200"
            Label="Routing Number" TabIndex="170" ControlHeight="18" HideLabel="False" LabelWidth="120"
            meta:resourcekey="tbRoutingNumberResource1" OptionalExtConfig="minLength:9,&#13;&#10;maxLength:20"
            ReadOnly="False" XTypeNameSpace="form"/>
        </div>
        <div id="Div4" style="float: left; width: 140px;">
          <asp:LinkButton runat="server" ID="RoutNumLinkButton" Text="Routing Number" Width="700"
            meta:resourcekey="tbRoutingNumberLinkResource1" OnClientClick="loadHelp(); return false;"
            CausesValidation="false" TabIndex="180"></asp:LinkButton>
          <div>
            &nbsp;
          </div>
        </div>
        <div style="clear: both">
      </div>
      <table>
        <tr>
            <td>
                <MT:MTLiteralControl runat="server" ID="LitAccountType" Label="Account Type" meta:resourcekey="litAccountTypeResource1" ControlWidth="0"/>
            </td>
            <td>
                <div id="radiobtns">        
                    <div id="Div5" style="width: 100px">
                      <MT:MTRadioControl ID="radChecking" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
                        runat="server" BoxLabel="Checking" Name="r1" Text="1" Value="Checking" meta:resourcekey="radCheckingResource1"
                        TabIndex="190" />
                    </div>
                    <div id="Div6" style="float: left; width: 100px;">
                      <MT:MTRadioControl ID="radSavings" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
                        runat="server" BoxLabel="Savings" Name="r1" Text="2" Value="Savings" meta:resourcekey="radSavingsResource1"
                        TabIndex="200" Checked="true" />
                    </div>
                </div>
             </td>
        </tr>
        </table>
      </div>
      <div style="clear: both">
      </div>
    </div>
    <!-- BUTTONS -->
    <div class="button">
      <div class="centerbutton">
        <span class="buttonleft">
          <!--leftcorner-->
        </span>
        <asp:Button OnClick="btnOK_Click" OnClientClick="return Validate();" ID="btnOK" runat="server"
          Text="<%$Resources:Resource,TEXT_OK%>" />
        <span class="buttonright">
          <!--rightcorner-->
        </span>
      </div>
      <span class="buttonleft">
        <!--leftcorner-->
      </span>
      <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false"
        Text="<%$Resources:Resource,TEXT_CANCEL%>" />
      <span class="buttonright">
        <!--rightcorner-->
      </span>
    </div>
    <div class="clearer">
    </div>
    <br />
  </div>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingSource="ACHCard" BindingSourceMember="FirstName"
        ControlId="tbFirstName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem5" runat="server" BindingSource="ACHCard"
        BindingSourceMember="MiddleName" ControlId="tbMiddleInitial" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="ACHCard"
        BindingSourceMember="LastName" ControlId="tbLastName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="ACHCard" BindingSourceMember="Street"
        ControlId="tbAddress" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="ACHCard"
        BindingSourceMember="Street2" ControlId="tbAddress2" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="ACHCard" BindingSourceMember="City"
        ControlId="tbCity" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem6" runat="server" BindingSource="ACHCard"
        BindingSourceMember="State" ControlId="tbState" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem11" runat="server" BindingSource="ACHCard"
        BindingProperty="SelectedValue" BindingSourceMember="Country" ControlId="ddCountry"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem7" runat="server" BindingSource="ACHCard"
        BindingSourceMember="ZipCode" ControlId="tbZipCode" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingSource="ACHCard"
        BindingProperty="SelectedValue" BindingSourceMember="Country" ControlId="ddCountry"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem9" runat="server" BindingSource="ACHCard"
        BindingSourceMember="AccountNumber" ControlId="tbAccountNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingSource="ACHCard"
        BindingSourceMember="RoutingNumber" ControlId="tbRoutingNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="LitAccountType" 
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script type="text/javascript">
  function onCheck()
  {
    
  }
  
  
   function loadHelp()
  { 
     var loadCCVNHelp = new Ext.Window({
      width: 450,
      height: 300,
      html: '<img src="<%=Request.ApplicationPath%>/Images/check.gif" />'
    });
    loadCCVNHelp.show();
 
  return false;
   }
  
  function Validate()
  {
  
      var fname = Ext.get("<%= tbFirstName.ClientID%>").dom.value;
      var lname = Ext.get("<%= tbLastName.ClientID%>").dom.value;
      var minitial = Ext.get("<%= tbMiddleInitial.ClientID%>").dom.value;
      var address = Ext.get("<%= tbAddress.ClientID%>").dom.value;
      var address2 = Ext.get("<%= tbAddress2.ClientID%>").dom.value;
      var city = Ext.get("<%= tbCity.ClientID%>").dom.value;
      var state = Ext.get("<%= tbState.ClientID%>").dom.value;
      var zipcode = Ext.get("<%= tbZipCode.ClientID%>").dom.value;

      
        if((fname == ' ') ||
          (lname == ' ') || 
          (minitial == ' ') ||
          (address == ' ') || 
          (address2 == ' ') || 
          (city == ' ') || 
          (state == ' ') ||
          (zipcode == ' '))
        {
          Ext.Msg.show({
                             title: TEXT_ERROR,
                             msg: TEXT_VALIDATION_ERROR,
                             buttons: Ext.Msg.OK,               
                             icon: Ext.MessageBox.ERROR
                     });
          return false;
        }
        else  if((fname.indexOf("\\") >= 0) ||
             (lname.indexOf("\\") >= 0) ||
             (minitial.indexOf("\\") >= 0) ||
             (address.indexOf("\\") >= 0) ||
             (address2.indexOf("\\") >= 0) ||
             (city.indexOf("\\") >= 0) ||
             (state.indexOf("\\") >= 0) ||
             (zipcode.indexOf("\\") >= 0))
         {
          Ext.Msg.show({
                             title: TEXT_ERROR,
                             msg: TEXT_VALIDATION_ERROR,
                             buttons: Ext.Msg.OK,               
                             icon: Ext.MessageBox.ERROR
                     });
           return false;
         }
       else if(isNaN(Ext.get("<%= tbAccountNumber.ClientID%>").dom.value))
        {
           Ext.Msg.show({
                             title: TEXT_ERROR,
                             msg: TEXT_INVALID_ACCT_NUM,
                             buttons: Ext.Msg.OK,               
                             icon: Ext.MessageBox.ERROR
                     });
          Ext.get("<%= tbAccountNumber.ClientID%>").dom.focus();
          return false;
         }                 
         
         else if(isNaN(Ext.get("<%= tbRoutingNumber.ClientID%>").dom.value))
        {
           Ext.Msg.show({
                             title: TEXT_ERROR,
                             msg: TEXT_INVALID_ROUT_NUM,
                             buttons: Ext.Msg.OK,               
                             icon: Ext.MessageBox.ERROR
                     });
          Ext.get("<%= tbRoutingNumber.ClientID%>").dom.focus();
          return false;
         }
         else
         {
          return ValidateForm();
         }
         
         
         
  }
  
  
  </script>

</asp:Content>

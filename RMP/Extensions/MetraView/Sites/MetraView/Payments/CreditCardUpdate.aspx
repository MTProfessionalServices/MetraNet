<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_CreditCardUpdate" Culture="auto"
  meta:resourcekey="PageResource1" UICulture="auto" CodeFile="CreditCardUpdate.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <h1>
    <asp:Localize ID="Localize1" meta:resourcekey="UpdateCC" runat="server">Update Credit Card</asp:Localize></h1>
  <br />
  <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage"
    Width="100%" />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <div class="box500">
    <div class="box500top">
    </div>
    <div class="box">
      <div class="left">
        <MT:MTTextBoxControl ID="tbFirstName" runat="server" AllowBlank="False" ControlWidth="200"
          Label="First Name" TabIndex="50" ControlHeight="18" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbFirstNameResource1" ReadOnly="False" XType="TextField"
          XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbMiddleInitial" runat="server" AllowBlank="True" ControlWidth="200"
          Label="Middle Initial" OptionalExtConfig="maxLength:1" TabIndex="60" ControlHeight="18"
          HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbMiddleInitialResource1"
          ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbLastName" runat="server" AllowBlank="False" ControlWidth="200"
          Label="Last Name" TabIndex="70" ControlHeight="18" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbLastNameResource1" ReadOnly="False" XType="TextField"
          XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbAddress" runat="server" AllowBlank="False" ControlWidth="200"
          Label="Address Line 1" TabIndex="80" ControlHeight="18" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbAddressResource1" ReadOnly="False" XType="TextField"
          XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbAddress2" runat="server" AllowBlank="True" ControlWidth="200"
          Label="Address Line 2" TabIndex="90" ControlHeight="18" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbAddress2Resource1" ReadOnly="False" XType="TextField"
          XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbCity" runat="server" AllowBlank="False" ControlWidth="200"
          Label="City" TabIndex="100" ControlHeight="18" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbCityResource1" ReadOnly="False" XType="TextField"
          XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbState" runat="server" AllowBlank="True" ControlWidth="50"
          Label="State/Province" OptionalExtConfig="maxLength:2,regex:/\w{2}/" TabIndex="110" ControlHeight="18"
          HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbStateResource1"
          ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbZipCode" runat="server" AllowBlank="False" ControlWidth="100"
          Label="Zip/Postal Code" OptionalExtConfig="maxLength:10" TabIndex="120" ControlHeight="18"
          HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbZipCodeResource1"
          ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTDropDown ID="ddCountry" runat="server" AllowBlank="False" ControlWidth="200"
          Label="Country" TabIndex="130" ControlHeight="18" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbCountryResource1" ReadOnly="False" XType="TextField"
          XTypeNameSpace="form" />
        <MT:MTDropDown ID="ddPriority" runat="server" AllowBlank="false" ControlWidth="70"
          TabIndex="140" ListWidth="70" meta:resourcekey="ddPriorityResource1" ReadOnly="false">
        </MT:MTDropDown>
        <MT:MTLiteralControl ID="ddCardType" runat="server" Label="Credit Card Type" AllowBlank="False"
          ControlHeight="18" ControlWidth="200" HideLabel="False" LabelWidth="120" meta:resourcekey="ddCardTypeResource1"
          ReadOnly="False" TabIndex="150" XType="MiscField" XTypeNameSpace="form" Listeners="{}">
        </MT:MTLiteralControl>
        <MT:MTLiteralControl ID="tbCCNumber" runat="Server" ReadOnly="True" Label="Card Number"
          AllowBlank="False" ControlHeight="18" ControlWidth="200" HideLabel="False" LabelWidth="120"
          Listeners="{}" meta:resourcekey="tbCCNumberResource1" TabIndex="160" XType="MiscField"
          XTypeNameSpace="form" />
        <div id="Div1" style="float: left; width: 200px;">
          <MT:MTDropDown ID="ddExpMonth" runat="server" AllowBlank="False" TabIndex="170" ControlWidth="70"
            Width="70px" Label="Expiration Date" HideLabel="False" LabelSeparator=":" Listeners="{}"
            meta:resourcekey="ddExpMonthResource1" ReadOnly="False">
          </MT:MTDropDown>
        </div>
        <div id="Div2" style="float:left;width:100px;padding-left:5px">
          <MT:MTDropDown ID="ddExpYear" runat="server" AllowBlank="False" ControlWidth="70"
            HideLabel="False" LabelWidth="10" LabelSeparator="" Label="/" meta:resourcekey="ddExpYearResource1"
            TabIndex="180" Width="70px" Listeners="{}" ReadOnly="False">
          </MT:MTDropDown>
        </div>
      </div>
      <div style="clear: both">
      </div>
      <!-- BUTTONS -->
      <div class="button">
        <div class="centerbutton">
          <span class="buttonleft">
            <!--leftcorner-->
          </span>
          <asp:Button OnClick="btnOK_Click" OnClientClick="return Validate();" ID="btnOK"
            runat="server" Text="<%$Resources:Resource,TEXT_OK%>" />
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
    </div>
    <div class="clearer">
    </div>
  </div>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="CreditCard"
        BindingMode="OneWay" BindingSourceMember="CreditCardType" ControlId="ddCardType"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem9" runat="server" BindingSource="CreditCard"
        BindingSourceMember="AccountNumber" ControlId="tbCCNumber" ErrorMessageLocation="RedTextAndIconBelow"
        BindingMode="OneWay">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="CreditCard"
        BindingSourceMember="FirstName" ControlId="tbFirstName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem5" runat="server" BindingSource="CreditCard"
        BindingSourceMember="MiddleName" ControlId="tbMiddleInitial" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="CreditCard"
        BindingSourceMember="LastName" ControlId="tbLastName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem4" runat="server" BindingSource="CreditCard"
        BindingSourceMember="Street" ControlId="tbAddress" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem6" runat="server" BindingSource="CreditCard"
        BindingSourceMember="Street2" ControlId="tbAddress2" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem7" runat="server" BindingSource="CreditCard"
        BindingSourceMember="City" ControlId="tbCity" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingSource="CreditCard"
        BindingSourceMember="State" ControlId="tbState" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingSource="CreditCard"
        BindingSourceMember="ZipCode" ControlId="tbZipCode" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem11" runat="server" BindingSource="CreditCard"
        BindingProperty="SelectedValue" BindingSourceMember="Country" ControlId="ddCountry"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  
  
  <script language="javascript" type="text/javascript">
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
        else if((fname.indexOf("\\") >= 0) ||
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
         else
         {
          return ValidateForm();
         }
    }
  
  </script>
  
  
</asp:Content>

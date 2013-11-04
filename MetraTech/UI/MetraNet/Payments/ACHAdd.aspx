<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_ACHAdd" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ACHAdd.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="Add ACH" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

<asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage" Width="100%"/>
<asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages" Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
    
    <div style="width:810px">

      <!-- BILLING INFORMATION --> 
  
      <MT:MTPanel ID="pnlBillingInfo" runat="server" meta:resourcekey="MTSection1Resource1" Collapsible="false">
      <div id="leftColumn" class="LeftColumn">
        <MT:MTDropDown ID="ddPriority" runat="server" AllowBlank="false" ControlWidth="70" ListWidth="70"
          TabIndex="10" meta:resourcekey="ddPriorityResource1" ReadOnly="false"></MT:MTDropDown>  
        <div id="Div1" style="float: left; width: 330px;">
              <MT:MTTextBoxControl ID="tbAccountNumber" runat="server" AllowBlank="False" ControlWidth="200"
                Label="Account Number" TabIndex="20" ControlHeight="18" HideLabel="False" LabelWidth="120"
                meta:resourcekey="tbAccountNumberResource1" ReadOnly="False" XTypeNameSpace="form"
                OptionalExtConfig="minLength:11,&#13;&#10;maxLength:20" VType="digits" />
            </div>        
            <div id="Div3" style="float: left; width:330px; ">
              <MT:MTTextBoxControl ID="tbRoutingNumber" runat="server" AllowBlank="False" ControlWidth="200"
                Label="Routing Number" TabIndex="30" ControlHeight="18" HideLabel="False" LabelWidth="120"
                meta:resourcekey="tbRoutingNumberResource1" OptionalExtConfig="minLength:9,&#13;&#10;maxLength:20"
                ReadOnly="False" XTypeNameSpace="form"/>
            </div>                 
              <div id="Div2" style="float: left; width:330px; ">
            <MT:MTDropDown ID="ddAccountType" runat="server" AllowBlank="False" ControlWidth="80" ListWidth="80"
           HideLabel="False" Label="Account Type" ControlHeight="18" meta:resourcekey="ddAccountTypeResource1" ReadOnly="False" TabIndex="40" ></MT:MTDropDown>
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
        <MT:MTDropDown ID="ddCountry" runat="server" AllowBlank="False" ControlWidth="200"
          Label="Country" TabIndex="130" ControlHeight="18" HideLabel="False" LabelWidth="120"  meta:resourcekey="tbCountryResource1" ReadOnly="False"/>       

      </div>
  
   
       <div style="clear:both"></div>
       </MT:MTPanel>

       <!-- BUTTONS -->
   
        <div  class="x-panel-btns-ct">
            <div style="width:725px" class="x-panel-btns x-panel-btns-center"> 
                <center>  
                    <table cellspacing="0">
                    <tr>
                        <td  class="x-panel-btn-td">
                        <MT:MTButton ID="btnOK" runat="server" OnClick="btnOK_Click"
                            OnClientClick="return ValidateForm();" TabIndex="390" Text="<%$Resources:Resource,TEXT_OK%>" Width="50px" />
                        </td>
                        <td  class="x-panel-btn-td">
                        <MT:MTButton ID="btnCancel" runat="server" CausesValidation="False" 
                            OnClick="btnCancel_Click" TabIndex="400" Text="<%$Resources:Resource,TEXT_CANCEL%>" Width="50px" />
                        </td>
                    </tr>
                    </table>  
                </center>   
            </div>
        </div>
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
      <MT:MTDataBindingItem ID="MTDataBindingItem7" runat="server" BindingSource="ACHCard"
        BindingSourceMember="ZipCode" ControlId="tbZipCode" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingSource="ACHCard" BindingProperty="SelectedValue"
        BindingSourceMember="Country" ControlId="ddCountry" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem4" runat="server" BindingSource="ACHCard"
        BindingSourceMember="AccountNumber" ControlId="tbAccountNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingSource="ACHCard"
        BindingSourceMember="RoutingNumber" ControlId="tbRoutingNumber" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
       <MT:MTDataBindingItem runat="server" ControlId="pnlBillingInfo" 
         ErrorMessageLocation="RedTextAndIconBelow">
       </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script type="text/javascript">
  function onCheck()
  {

  }
  </script>
</asp:Content>


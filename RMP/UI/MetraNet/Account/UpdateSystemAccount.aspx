<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_UpdateSystemAccount" UICulture="auto" Culture="auto" 
Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="UpdateSystemAccount.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="Update System User" runat="server" 
    meta:resourcekey="MTTitle1Resource1" /><br />


   
<div style="width:810px">
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    </b>
  </div>

  <!-- BILLING INFORMATION -->
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" 
    DataBinderInstanceName="MTDataBinder1" TabIndex="10" ></MTCDT:MTGenericForm>

  <!-- LOGIN INFORMATION -->
  <MT:MTPanel ID="pnlLoginInfo" runat="server" Text="Login Information" 
    meta:resourcekey="pnlLoginInfo" Collapsed="False" Collapsible="True">
  <div id="leftColumn2" class="LeftColumn">
    <MT:MTTextBoxControl ID="tbAuthenticationType" runat="server" ReadOnly="True" AllowBlank="True" Label="Authentication Type" ControlWidth="150" meta:resourcekey="LblAuthenticationType" /> 
    <MT:MTTextBoxControl ID="tbUserName" runat="server" ReadOnly="True" AllowBlank="True" Label="User Name" ControlWidth="150" meta:resourcekey="LblUserName" /> 
    <MT:MTDropDown ID="ddBrandedSite" runat="server" AllowBlank="True" Label="Branded Site" TabIndex="180" ControlWidth="200" ListWidth="200" ReadOnly="true" meta:resourcekey="LblBrandedSite" >
      <asp:ListItem Value="MT" meta:resourcekey="ListItemResource1">MetraView</asp:ListItem>
    </MT:MTDropDown>
  </div>
  <div id="rightColumn2" class="RightColumn">
    <MT:MTInlineSearch ID="tbAncestorAccount" runat="server" TabIndex="210" AllowBlank="True" Label="Parent Account" meta:resourcekey="LblAncestorAccount"></MT:MTInlineSearch>
    <MT:MTTextBoxControl ID="tbStartDate" runat="server" AllowBlank="True" Label="Account Start Date" ControlWidth="200" ReadOnly="True" meta:resourcekey="LblAccountStartDate" />
  </div>
  <div style="clear:both"></div>
   </MT:MTPanel>
  <!-- ACCOUNT INFORMATION --> 
  <MT:MTPanel ID="pnlAccountInfo" runat="server" Text="Account Information" 
    Collapsed="False" Collapsible="True" meta:resourcekey="pnlAccountInfoResource1">
  <div id="leftColumn3" class="LeftColumn">
    <MT:MTDropDown ID="ddLanguage" runat="server" AllowBlank="True" HideLabel="False" Label="Language" TabIndex="320" ControlWidth="200" ListWidth="200" meta:resourcekey="LblLanguage" >
      <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">US English</asp:ListItem>
    </MT:MTDropDown>
  </div>
  <div id="rightColumn3" class="RightColumn">
    <MT:MTDropDown ID="ddTimeZone" runat="server" AllowBlank="True" Label="Time Zone" TabIndex="330" ListWidth="270" ControlWidth="200" meta:resourcekey="LblTimezone"></MT:MTDropDown>
    <br />
    <MT:MTDropDown ID="ddSecurityQuestion" runat="server" AllowBlank="True" Label="Security Question" TabIndex="370" ControlWidth="200" ListWidth="200" meta:resourcekey="LblSecurityQuestion"></MT:MTDropDown>
    <MT:MTTextBoxControl ID="tbSecurityQuestionText" runat="server" AllowBlank="true" Label="Custom Security Question" TabIndex="375" ControlHeight="18" ControlWidth="200" HideLabel="false" LabelSeparator=":" Listeners="{}" meta:resourcekey="tbSecurityQuestionTextResource1" ReadOnly="false" />
    <MT:MTTextBoxControl ID="tbSecurityAnswer" runat="server" AllowBlank="True" Label="Security Answer" TabIndex="380" ControlWidth="200" meta:resourcekey="LblSecurityAnswer"/>    
  </div>
  <div style="clear:both"></div>
  </MT:MTPanel>
  <!-- BUTTONS -->


    <div class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">
      <center>   
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="500" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" TabIndex="501" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>    
        </center> 
    </div>
  </div>

  
  

</div>
  
  <br />

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingSource="Account" BindingSourceMember="AncestorAccountID"
        ControlId="tbAncestorAccount" BindingProperty="AccountID" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
   
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="Name_Space" ControlId="ddBrandedSite" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
     
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="Language" ControlId="ddLanguage" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="TimeZoneID" ControlId="ddTimeZone" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
     
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AccountStartDate" ControlId="tbStartDate" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="UserName" ControlId="tbUserName" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="tbConfirmPassword" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="SecurityQuestion" ControlId="ddSecurityQuestion"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingMetaDataAlias="Internal" BindingProperty="Text"
        BindingSource="Internal" BindingSourceMember="SecurityQuestionText" ControlId="tbSecurityQuestionText"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="SecurityAnswer" ControlId="tbSecurityAnswer" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
    </DataBindingItems>
    <MetaDataMappings>
      <MT:MetaDataItem Alias="Account" AliasBaseType="CoreSubscriber" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="Internal" AliasBaseType="CoreSubscriber.Internal" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="BillTo" AliasBaseType="CoreSubscriber.LDAP.Item" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
    </MetaDataMappings>
   </MT:MTDataBinder>
</asp:Content>





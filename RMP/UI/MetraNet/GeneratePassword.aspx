<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GeneratePassword" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="GeneratePassword.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Generate Password" meta:resourcekey="MTTitle1Resource1" />
    
  <!-- Main Form -->
  <div style="width:810px">

    <br />
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <MT:MTLabel ID="lblMessage" runat="server" Text="info" meta:resourcekey="lblMessageResource1" />
    </div>
    <br />
      
    <MT:MTLiteralControl ID="lblSecurityQuestion" Label="Security Question" runat="server" AllowBlank="false" ControlHeight="18" ControlWidth="200" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="lblSecurityQuestionResource1" ReadOnly="False" TabIndex="0" XType="MiscField" XTypeNameSpace="form" />
    <MT:MTLiteralControl ID="lblSecurityQuestionText" Label="Security Question" runat="server" AllowBlank="false" ControlHeight="18" ControlWidth="200" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="lblSecurityQuestionResource1" ReadOnly="False" TabIndex="0" XType="MiscField" XTypeNameSpace="form" />
    <MT:MTLiteralControl ID="lblSecurityAnswer" Label="Security Answer" runat="server" AllowBlank="False" ControlHeight="18" ControlWidth="200" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="lblSecurityAnswerResource1" ReadOnly="False" TabIndex="0" XType="MiscField" XTypeNameSpace="form" />
  </div>
  <br />
      
  <!-- Buttons -->
  <center>
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" runat="server" Text="Generate New Password" OnClick="btnOK_Click" TabIndex="17" meta:resourcekey="btnOKResource1" />&nbsp;&nbsp;&nbsp;
     <asp:Button CssClass="button" ID="btnCancel"  runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="18"/>
     <br />       
  </div>
  </center>
  <br />
  
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
      <MetaDataMappings>
      <MT:MetaDataItem Alias="Account" AliasBaseType="CoreSubscriber" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="Internal" AliasBaseType="CoreSubscriber.Internal" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="BillTo" AliasBaseType="CoreSubscriber.LDAP.Item" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
    </MetaDataMappings>
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="SecurityQuestion" ControlId="lblSecurityQuestion"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="SecurityQuestionText" ControlId="lblSecurityQuestionText"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="SecurityAnswer" ControlId="lblSecurityAnswer" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="btnOK" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
        
</asp:Content>


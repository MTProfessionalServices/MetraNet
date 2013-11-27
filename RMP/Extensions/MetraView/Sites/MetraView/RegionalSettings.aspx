<%@ Page Language="C#" MasterPageFile="~/MasterPages/AccountPageExt.master" AutoEventWireup="true" Inherits="RegionalSettings" CodeFile="RegionalSettings.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

 
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

 <script type="text/javascript" src="/Res/JavaScript/Validators.js"></script>
  <h1><asp:Localize meta:resourcekey="RegionalSettings" runat="server">Regional Settings</asp:Localize></h1>

  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
    
      <MT:MTDropDown ID="ddTimeZone" runat="server" AllowBlank="True" Label="Time Zone"
        TabIndex="330" ListWidth="350" ControlWidth="250" HideLabel="False" LabelSeparator=":"
        Listeners="{}" meta:resourcekey="ddTimeZoneResource1" ReadOnly="False">
      </MT:MTDropDown>
      <br />
      <br />
        
      <!-- BUTTONS -->
      <div class="clearer"></div>
      <div class="button">
        <div class="centerbutton">
          <span class="buttonleft"><!--leftcorner--></span>
          <asp:Button OnClick="btnOK_Click" OnClientClick="return ValidateForm();" ID="btnOK"
            runat="server" Text="<%$Resources:Resource,TEXT_OK%>" meta:resourcekey="btnOKResource1" />
          <span class="buttonright"><!--rightcorner--></span>
        </div>
        <span class="buttonleft"><!--leftcorner--></span>
        <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false"
          meta:resourcekey="btnCancelResource1" Text="<%$Resources:Resource,TEXT_CANCEL%>" />
        <span class="buttonright"><!--rightcorner--></span>
      </div>

  </div>
  </div>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
   <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" ControlId="ddTimeZone" ErrorMessageLocation="None" BindingSourceMember="TimezoneID">
      </MT:MTDataBindingItem>
  </MT:MTDataBinder>

</asp:Content>


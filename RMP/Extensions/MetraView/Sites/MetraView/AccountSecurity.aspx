<%@ Page Language="C#" MasterPageFile="~/MasterPages/AccountPageExt.master" AutoEventWireup="true" CodeFile="AccountSecurity.aspx.cs" Inherits="AccountSecurity" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <script type="text/javascript" src="/Res/JavaScript/Validators.js"></script>
  <h1><asp:Localize ID="Localize1" meta:resourcekey="MTTitle1Resource1" runat="server">Account Information</asp:Localize></h1>

  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
    
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" EnableChrome="false"></MTCDT:MTGenericForm>

      <!-- BUTTONS -->
      <div class="clearer"></div>
      <div class="button">
        <div class="centerbutton">
          <span class="buttonleft"><!--leftcorner--></span>
     <asp:Button ID="btnOK" OnClientClick="return ValidateForm();" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="100" />
          <span class="buttonright"><!--rightcorner--></span>
        </div>
        <span class="buttonleft"><!--leftcorner--></span>
     <asp:Button ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" meta:resourcekey="btnCancelResource1" OnClick="btnCancel_Click" TabIndex="110" />
        <span class="buttonright"><!--rightcorner--></span>
      </div>

  </div>
  </div>

<MT:MTDataBinder ID="MTDataBinder1" runat="server"></MT:MTDataBinder>

</asp:Content>

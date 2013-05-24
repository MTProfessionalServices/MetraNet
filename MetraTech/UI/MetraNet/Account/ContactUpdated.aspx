<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="ContactUpdated" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ContactUpdated.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="lblTitle" Text="Confirmation" runat="server" meta:resourcekey="lblTitleResource1" /><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    <br />

    <!-- BUTTONS -->
    <div class="Buttons">
       <br />       
       <asp:Button CssClass="button" ID="btnOK" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="150" meta:resourcekey="btnOKResource1"/>&nbsp;&nbsp;&nbsp;
       <br />       
    </div>
   
  </div>
  
  <script type="text/javascript">
    Account.Refresh();
  </script>
</asp:Content>


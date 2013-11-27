<%@ Page Language="C#" MasterPageFile="~/MasterPages/AccountPageExt.master" AutoEventWireup="true" Inherits="GoPaperless" CodeFile="GoPaperless.aspx.cs" Title="<%$Resources:Resource,TEXT_TITLE%>"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script type="text/javascript" src="/Res/JavaScript/Validators.js"></script>
  <h1>
    <asp:Localize meta:resourcekey="GoPaperless" runat="server">Paperless Billing</asp:Localize></h1>
  <div class="box500">
    <div class="box500top">
    </div>
    <div class="box">
      <asp:Literal runat="server" Text="Are you sure you want to switch to paperless billing?"
        ID="LitGoGreen" meta:resourcekey="LitGoGreen"></asp:Literal>
      <br />
      <br />
      <!-- BUTTONS -->
      <div class="clearer">
      </div>
      <div class="button">
        <div class="centerbutton">
          <span class="buttonleft">
            <!--leftcorner-->
          </span>
          <asp:Button OnClick="btnOK_Click" OnClientClick="return ValidateForm();" ID="btnOK"
            runat="server" Text="<%$Resources:Resource,TEXT_YES%>" meta:resourcekey="btnOKResource1" />
          <span class="buttonright">
            <!--rightcorner-->
          </span>
        </div>
        <span class="buttonleft">
          <!--leftcorner-->
        </span>
        <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false"
          meta:resourcekey="btnCancelResource1" Text="<%$Resources:Resource,TEXT_NO%>" />
        <span class="buttonright">
          <!--rightcorner-->
        </span>
      </div>
    </div>
  </div>
  
</asp:Content>

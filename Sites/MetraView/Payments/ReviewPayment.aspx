<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_ReviewPayment" CodeFile="ReviewPayment.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Src="../UserControls/BillAndPayments.ascx" TagName="BillAndPayments" TagPrefix="uc4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <h1><asp:Localize ID="Localize1" meta:resourcekey="ReviewPayment" runat="server" Text="Make a Payment"></asp:Localize></h1>
  <div class="box500">
    <div class="box500top"></div>
    <div class="box">
      <table cellspacing="10" cellpadding="0">
        <tr>
          <td width="50%" style="vertical-align:top">
            <asp:Localize ID="Localize5" meta:resourcekey="Instructions" runat="server"></asp:Localize>
          </td>
          <td width="50%" style="vertical-align:top">
            <uc4:BillAndPayments ID="BillAndPayments2" runat="server" HidePaymentButton="true" />
          </td>
        </tr>
      </table>
      <div class="clearer"></div>
    </div>
  </div>
  


  <div class="box500">
    <div class="box500top"></div>
    <div class="box">
  <MT:MTLiteralControl ID="lcAmount" runat="server" Label="Amount"
      Text="" meta:resourcekey="lcAmount"/>
  <MT:MTLiteralControl ID="lcDate" runat="server" Label="Date"
      Text="" meta:resourcekey="lcDate" />
  <MT:MTLiteralControl ID="lcMethod" runat="server" Label="Method"
      Text="" meta:resourcekey="lcMethod"  />
  <MT:MTLiteralControl ID="lcType" runat="server" Label="Card Type"
      Text="" meta:resourcekey="lcType"/>
  <MT:MTLiteralControl ID="lcNumber" runat="server" Label="Card Number"
      Text="" meta:resourcekey="lcNumber"/>
      <div class="clearer"></div>
    </div>
  </div>

  <div>
    <div class="left">
    <div id="divCancel" runat="server" class="button">
      <span class="buttonleft"><!--leftcorner--></span>
      <asp:LinkButton ID="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Cancel" meta:resourcekey="Cancel"></asp:LinkButton>
      <span class="buttonright"><!--rightcorner--></span>
    </div>
    </div>

    <div class = "right">
      <div id="div1" runat="server" class="button">
        <span class="buttonleft"><!--leftcorner--></span>
        <asp:LinkButton ID="btnNext" runat="server" OnClick="btnNext_Click" Text="Make a Payment" meta:resourcekey="Next"></asp:LinkButton>
        <span class="buttonright"><!--rightcorner--></span>
    </div>
    </div>
  </div>
  

</asp:Content>


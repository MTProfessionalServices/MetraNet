<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" Inherits="ApprovalFrameworkManagement_ViewSubscriptionChangeDetails" CodeFile="ViewSubscriptionChangeDetails.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="ContentIndSub" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   
  <div class="CaptionBar">
    <asp:Label ID="lblChangesSummaryTitle" runat="server" />
  </div>

  <div>
    <img src='/ImageHandler/images/Account/<%# AccountTypeName %>/account.gif' alt="No image"/>
    <MT:MTLabel ID="LblAccountName" runat="server" />
  </div>
  <div>
    <MT:MTLabel ID="LblPoName" runat="server" />
  </div>
  
  <MT:MTViewChangeControl ID="SubChangeBasicStartDate" runat="server" Label="Start Date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
  <MT:MTViewChangeControl ID="SubChangeBasicNextStart" runat="server" Label="Next start of payer's billing period after this date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
  <MT:MTViewChangeControl ID="SubChangeBasicEndDate" runat="server" Label="End Date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
  <MT:MTViewChangeControl ID="SubChangeBasicNextEnd" runat="server" Label="Next end of payer's billing period after this date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
   
</asp:Content>
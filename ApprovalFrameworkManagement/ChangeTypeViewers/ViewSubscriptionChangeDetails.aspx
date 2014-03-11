<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" Inherits="ApprovalFrameworkManagement_ViewSubscriptionChangeDetails" CodeFile="ViewSubscriptionChangeDetails.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="ContentIndSub" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   
  <div class="CaptionBar">
    <asp:Label ID="lblChangesSummaryTitle" runat="server" />
  </div>
  
  <br />

  <MT:MTLiteralControl ID="LblAccountName" ControlWidth="500" meta:resourcekey="LblAccountNameResource" runat="server" />
  <MT:MTLiteralControl ID="LblPoName" ControlWidth="500" meta:resourcekey="LblPoNameResource" runat="server" />
  
  <MT:MTViewChangeControl ID="SubChangeBasicStartDate" runat="server" AllowBlank="False" meta:resourcekey="SubChangeBasicStartDateResource" />
  <MT:MTViewChangeControl ID="SubChangeBasicNextStart" runat="server" AllowBlank="False" meta:resourcekey="SubChangeBasicNextStartResource" />
  <MT:MTViewChangeControl ID="SubChangeBasicEndDate" runat="server" AllowBlank="False" meta:resourcekey="SubChangeBasicEndDateResource" />
  <MT:MTViewChangeControl ID="SubChangeBasicNextEnd" runat="server" AllowBlank="False" meta:resourcekey="SubChangeBasicNextEndResource" />
   
</asp:Content>
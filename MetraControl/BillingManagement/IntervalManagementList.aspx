<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="IntervalManagementList.aspx.cs" Inherits="MetraControl_BillingManagement_IntervalManagementList" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 
 <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Billable Intervals" ></asp:Label>   
 </div>


 <div style="padding-left:5px;">
   <MT:MTFilterGrid ID="IntervalListGrid" runat="server" TemplateFileName="IntervalManagementList" ExtensionName="Core">
   </MT:MTFilterGrid>
</div>

</asp:Content>
<%@ Page Language="C#" MasterPageFile="~/MasterPages/MetraViewExt.master" AutoEventWireup="true" Inherits="SelectBill" CodeFile="SelectBill.aspx.cs" Culture="auto" UICulture="auto"  meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Src="UserControls/ServerDescription.ascx" TagName="ServerDescription" TagPrefix="uc1" %>
<%@ Register src="UserControls/UsageGraph.ascx" tagname="UsageGraph" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script type="text/javascript">
  function onChange() {
    document.location.href = Ext.get("ctl00_ContentPlaceHolder1_ddAccountLinks").dom.value;
  }
</script>

<MT:MTLabel ID="lblAccountLinks" runat="server" 
    meta:resourcekey="lblAccountLinksResource1" />
<MT:MTDropDown ID="ddAccountLinks" runat="server"
    AllowBlank="False" 
    Listeners="{ 'select' : { fn: this.onChange, scope: this } }" Name="URL" 
    HideLabel="False" LabelSeparator=":" meta:resourcekey="ddAccountLinksResource1" 
    ReadOnly="False" />
    <MT:MTLabel ID="lblMsg" runat="server" />
</asp:Content>
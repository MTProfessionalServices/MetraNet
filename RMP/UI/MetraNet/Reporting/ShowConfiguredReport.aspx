<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="ShowConfiguredReport.aspx.cs" Inherits="ShowConfiguredReport" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="MTTitle1" Text="Report" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

  <MT:MTFilterGrid ID="MTFilterGridReport" runat="server" ExtensionName="Reporting" 
    TemplateFileName="" ButtonAlignment="Center" 
    Buttons="Back" DefaultSortDirection="Ascending" DisplayCount="True" 
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" 
    EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" 
    Exportable="False" FilterColumnWidth="350" FilterInputWidth="220" 
    FilterLabelWidth="75" FilterPanelCollapsed="False" 
    FilterPanelLayout="MultiColumn" meta:resourcekey="MTFilterGridBasicReportResource1" 
    MultiSelect="False" PageSize="10" 
    Resizable="True" RootElement="Items" SearchOnLoad="True" 
    SelectionModel="Standard" ShowBottomBar="True" ShowColumnHeaders="True" 
    ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" 
    ShowTopBar="True" TotalProperty="TotalRows" NoRecordsText="No records found" />

   <script type="text/javascript">
  	function onBack_<%= MTFilterGridReport.ClientID%>()
    {
      document.location.href = '<%=ReturnUrl %>';         
    }
  	</script>
</asp:Content>

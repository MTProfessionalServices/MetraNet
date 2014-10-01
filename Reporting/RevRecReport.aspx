<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="RevRecReport.aspx.cs" Inherits="RevRecReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Revenue Recognition Report" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <div style="position: relative; margin-top: 50px;">
    <MT:MTFilterGrid ID="grdRevRecReport" runat="server" ExtensionName="SystemConfig" TemplateFileName="RevRecReportGrid"
      ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True"
      EnableColumnConfig="True" EnableFilterConfig="false" EnableLoadSearch="False" EnableSaveSearch="False"
      Expandable="False" ExpansionCssClass="" Exportable="False" FilterColumnWidth="350"
      FilterInputWidth="0" FilterLabelWidth="0" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
      meta:resourcekey="MTFilterGrid1Resource1" MultiSelect="False" PageSize="100" Resizable="True"
      RootElement="Items" SearchOnLoad="True" SelectionModel="Standard" ShowBottomBar="True"
      ShowColumnHeaders="True" ShowFilterPanel="false" ShowGridFrame="True" ShowGridHeader="True"
      ShowTopBar="True" TotalProperty="TotalRows" ClientIDMode="Static">
    </MT:MTFilterGrid>
  </div>

  <script type="text/javascript">
    Ext.onReady(function () {
      if (grid_grdRevRecReport) {
        var columns = grid_grdRevRecReport.getColumnModel().getColumnsBy(function (c) {
          return c.id.indexOf("Amount") != -1;
        });
        var columnModel = grid_grdRevRecReport.getColumnModel();
        var i = 1;
        columns.forEach(function (e) {
          columnModel.setColumnHeader(e.position, "Month " + i.toString());
          i++;
        });
      }
    });

  </script>
</asp:Content>

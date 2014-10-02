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
      meta:resourcekey="MTFilterGrid1Resource1" MultiSelect="False" PageSize="10" Resizable="True"
      RootElement="Items" SearchOnLoad="True" SelectionModel="Standard" ShowBottomBar="True"
      ShowColumnHeaders="True" ShowFilterPanel="false" ShowGridFrame="True" ShowGridHeader="True"
      ShowTopBar="True" TotalProperty="TotalRows">
    </MT:MTFilterGrid>
  </div>

  <script type="text/javascript">
    $('#MainContentIframe').ready(
      $.ajax({
        url: "../Report/GetProductsFilter",
        success: function (res) {
          var s = $('<select />');
          s.appendTo('#ext-gen116');
        }
      })
    );

      Ext.onReady(function () {
        var s = $('<select />');

        //$('#ext-gen118 > tbody:last').append('<tr><td class="ux-datetime-time" width="110" id="ext-gen123"><select /></td>');
        //s.appendTo('#x-form-el-combo_filter_ProductId_ctl00_ContentPlaceHolder1_grdRevRecReport');
      });
  </script>
</asp:Content>

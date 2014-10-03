<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="RevRecReport.aspx.cs" Inherits="RevRecReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>"
  <MT:MTTitle ID="MTTitle1" Text="Revenue Recognition Report" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <div style="position: relative; margin-top: 50px;">
    <select id="accCycle" clientidmode="Static" runat="server">
    </select>
    <MT:MTFilterGrid ID="grdRevRecReport" runat="server" ExtensionName="SystemConfig"
      TemplateFileName="RevRecReportGrid" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
      DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="false" EnableLoadSearch="False"
      EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" Exportable="False"
      FilterColumnWidth="350" FilterInputWidth="0" FilterLabelWidth="0" FilterPanelCollapsed="False"
      FilterPanelLayout="MultiColumn" meta:resourcekey="MTFilterGrid1Resource1" MultiSelect="False"
      PageSize="100" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
      ShowBottomBar="True" ShowColumnHeaders="True" ShowFilterPanel="false" ShowGridFrame="True"
      ShowGridHeader="True" ShowTopBar="True" TotalProperty="TotalRows" ClientIDMode="Static">
    </MT:MTFilterGrid>
  </div>
  <script type="text/javascript">
    var headers = "<%=TableHeaders %>".split(',');
    var accCycleId;
    
    Ext.onReady(function () {
      accCycleId = $('#accCycle').val();
      var s = $('<select />');
      //$('#ext-gen118 > tbody:last').append('<tr><td class="ux-datetime-time" width="110" id="ext-gen123"><select /></td>');
      //s.appendTo('#x-form-el-combo_filter_ProductId_ctl00_ContentPlaceHolder1_grdRevRecReport');

      DrawHeaders();
      $(".x-panel-fbar button").on( "click", function() {
                                    RefreshHeaders();
                                  });
    });

    function DrawHeaders() {
      if (grid_grdRevRecReport) {
        var columns = grid_grdRevRecReport.getColumnModel().getColumnsBy(function (c) {
          return c.id.indexOf("Amount") != -1;
        });
        var columnModel = grid_grdRevRecReport.getColumnModel();
        var i = 0;
        columns.forEach(function (e) {
          columnModel.setColumnHeader(e.position, headers[i]);
          i++;
        });
      }
    }

    function RefreshHeaders() {
      var cycle = $('#accCycle').val();
      if (accCycleId !== cycle) {
        // let's get new headers
        $.ajax({
          url: '../Report/RevRecReportHeaders',
          type: 'GET',
          cache: false,
          data: { accountCycleId: cycle },
          success: function (data) {
            accCycleId = cycle;
            headers = data.headers.split(',');
            DrawHeaders();
          },
          error: function (data) {
            alert("Data retrival error!");
          }
        });

      }
    }  



    Ext.onReady(function () {
      $('#ext-gen120').hide();
      $('#ext-gen123').hide();
      var inpVal = $('#filter_ProductId_grdRevRecReport');
      var select = $("<select/>").width('218px').on('change', function () {
        inpVal.attr('value', this.value);
      });
      select.append($("<option/>"));
      $.ajax({
        url: "../Report/GetProductsFilter",
        success: function (res) {
          res.forEach(function (e) {
            select.append($("<option/>").attr("value", e.Key).text(e.Value));
          });
          var td = $('<td class="ux-datetime-time" width="110" id="customFilter"/>').append(select);
          $('#ext-gen123').parent().append(td);
        }
      });
    });
  </script>
</asp:Content>

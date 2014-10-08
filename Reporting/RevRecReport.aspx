<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" meta:resourcekey="PageResource1" 
  CodeFile="RevRecReport.aspx.cs" Inherits="RevRecReport" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <MT:MTTitle ID="MTTitle1" runat="server" ClientIDMode="Static" meta:resourcekey="MTTitle1Resource1"/>
  <div style="position: relative; margin-top: 50px;">
    <MT:MTFilterGrid ID="grdRevRecReport" runat="server" ExtensionName="SystemConfig"
      TemplateFileName="RevRecReportGrid" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
      DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="false" EnableLoadSearch="False"
      EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" Exportable="False"
      FilterColumnWidth="350" FilterInputWidth="0" FilterLabelWidth="0" FilterPanelCollapsed="False"
      FilterPanelLayout="MultiColumn" MultiSelect="False"
      PageSize="100" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
      ShowBottomBar="True" ShowColumnHeaders="True" ShowFilterPanel="false" ShowGridFrame="True"
      ShowGridHeader="True" ShowTopBar="True" TotalProperty="TotalRows" ClientIDMode="Static">
    </MT:MTFilterGrid>
  </div>
  <script type="text/javascript">
    var headers = "<%=TableHeaders %>".split(',');
    var accCycleId;

      function SetTitle() {
        var title = "<%=GetLocalResourceObject("MTTitle1Resource1.Text").ToString() %> - " + $('#selAccCycle :selected').text();
        $('#MTTitle1 div').text(title);
        top.document.title = "MetraNet - " + title;
      }
      
    Ext.onReady(function () {
      accCycleId = $('#combo_filter_AccountingCycleId_grdRevRecReport').val();
      DrawHeaders();
      $(".x-panel-fbar button").on( "click", function() {
                                    RefreshHeaders();
                                    SetTitle();
                                  });
    });

    function DrawHeaders() {
      if (!grid_grdRevRecReport) {
        return;
      }
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

    function RefreshHeaders() {
      var cycle = $('#combo_filter_AccountingCycleId_grdRevRecReport').val();
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
      $('#ext-gen121 td').hide();
      var inpVal = $('#filter_ProductId_grdRevRecReport');
      var select = $("<select/>").width('218px').on('change', function () {
        inpVal.val(this.value);
      });
      select.append($("<option/>"));
      $.ajax({
        url: "../Report/GetProductsFilter",
        success: function (res) {
          res.forEach(function (e) {
            select.append($("<option/>").val(e.Key).text(e.Value));
          });
          var td = $('<td class="ux-datetime-time" width="110" id="customFilter"/>').append(select);
          $('#ext-gen121 tr:first').append(td);
        }
      });

      $('#ext-gen129 td').hide();
      var inpValCycle = $('#combo_filter_AccountingCycleId_grdRevRecReport');
      var selectCycle = $("<select id='selAccCycle'/>").width('218px').on('change', function () {
        inpValCycle.val(this.value);
      });
      $.ajax({
        url: "../Report/GetAccountingCyclesFilter",
        success: function (res) {
          res.forEach(function (e) {
            selectCycle.append($("<option/>").val(e.Id).text(e.Name));
          });
          var td = $('<td class="ux-datetime-time" width="110" id="customFilter"/>').append(selectCycle);
          $('#ext-gen129 tr:first').append(td);
          RefreshHeaders();
          SetTitle();
        }
      });

    });
  </script>
</asp:Content>

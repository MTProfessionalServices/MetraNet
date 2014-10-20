<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ExpectedRevRecReport.aspx.cs" Inherits="ExpectedRevRecReport" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <MT:MTTitle ID="MTTitle1" runat="server" ClientIDMode="Static" meta:resourcekey="MTTitle1Resource1"/>
  <div style="position: relative; margin-top: 50px;">
    <MT:MTFilterGrid ID="grdExpectedRevRecReport" runat="server" ExtensionName="SystemConfig"
      TemplateFileName="ExpectedRevRecReportGrid" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
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
    var accCycleId;

      function SetTitle() {
        var title = "<%=GetLocalResourceObject("MTTitle1Resource1.Text").ToString() %> - " + $('#selAccCycle :selected').text();
        $('#MTTitle1 div').text(title);
        top.document.title = "MetraNet - " + title;
      }
      
    Ext.onReady(function () {
      $(".x-panel-fbar button").on( "click", function() {
                                    RefreshHeaders();
                                    SetTitle();
                                  });
    });

    function SetHeaders(cycle) {
      $.ajax({
        url: '../Report/RevRecReportHeaders',
        type: 'GET',
        cache: false,
        data: { accountCycleId: cycle },
        success: function(data) {
          accCycleId = cycle;
          var headers = data.headers.split(',');
          DrawHeaders(headers);
        },
        error: function(data) {
          alert("Data retrival error!");
        }
      });
    }

    function DrawHeaders(headers) {
      if (!grid_grdExpectedRevRecReport) {
        return;
      }
      var columns = grid_grdExpectedRevRecReport.getColumnModel().getColumnsBy(function (c) {
          return c.id.indexOf("Amount") != -1;
        });
        var columnModel = grid_grdExpectedRevRecReport.getColumnModel();
        var i = 0;
        columns.forEach(function (e) {
          columnModel.setColumnHeader(e.position, headers[i]);
          i++;
        });
    }

    function RefreshHeaders() {
      var cycle = $('#filter_AccountingCycleId_grdExpectedRevRecReport').val();;
      if (accCycleId !== cycle) {
        SetHeaders(cycle);
      }
    }

    Ext.onReady(function () {
      $('#ext-gen121 td').hide();
      var inpVal = $('#filter_ProductId_grdExpectedRevRecReport-value');
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

      var inpValCycle = $('#filter_AccountingCycleId_grdExpectedRevRecReport');
      inpValCycle.hide();
      var selectCycle = $("<select id='selAccCycle'/>").width('218px').on('change', function () {
        inpValCycle.val(this.value);
      });
      $.ajax({
        url: "../Report/GetAccountingCyclesFilter",
        success: function (res) {
          res.forEach(function (e) {
            selectCycle.append($("<option/>").val(e.Id).text(e.Name));
          });
          inpValCycle.parent().append(selectCycle);
          inpValCycle.val(selectCycle.val());
          accCycleId = selectCycle.val();
          SetHeaders(accCycleId);
          SetTitle();
        }
      });

    });
  </script>
</asp:Content>

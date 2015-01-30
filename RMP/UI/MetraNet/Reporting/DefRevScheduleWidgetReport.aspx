<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="DefRevScheduleWidgetReport.aspx.cs" Inherits="DefRevScheduleWidgetReport"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" EnableViewState="false"%>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css" />
  <style type="text/css">
	  #revrec-chart svg { width: 1140px; }
  </style>
  <MT:MTTitle ID="MTTitle1" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <div id="container">
    <div class="row">
      <MT:MTPanel runat="server" ID="filterPanel" ClientIDMode="Static">
        <MT:MTDropDown runat="server" ClientIDMode="Static" ID="accntCycleDd" TabIndex="1" />
        <MT:MTDropDown runat="server" ClientIDMode="Static" ID="currencyDd" TabIndex="2" />
        <MT:MTTextBoxControl  runat="server" ClientIDMode="Static" ID="revCodeInp" AllowBlank="True" TabIndex="3" />
        <MT:MTTextBoxControl  runat="server" ClientIDMode="Static" ID="defRevCodeInp" AllowBlank="True" TabIndex="4" />
        <MT:MTDropDown runat="server" ClientIDMode="Static" ID="productDd" TabIndex="5" />
        <MT:MTButton runat="server" ID="applyBtn" ClientIDMode="Static" EnableViewState="False" TabIndex="6" OnClientClick="ApplyFilter(); return false;" />
      </MT:MTPanel>
    </div>
    <div class="row">
      <div id="revrec-chart" class="dc-chart">
      </div>
    </div>
  </div>
  <script type="text/javascript" src="/Res/JavaScript/d3.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.js"></script>
  <script language="javascript" type="text/javascript">
    var revRecChart = dc.barChart("#revrec-chart");
    var stackDomain = ["<%=GetLocalResourceObject("Earned_Caption").ToString() %>", "<%=GetLocalResourceObject("Deferred_Caption").ToString() %>"];

    function ApplyFilter() {
      var accCycleId = $("#accntCycleDd").val();
      var currency = $("#currencyDd").val();
      var productId = $("#productDd").val();
      var revCode = $("#revCodeInp").val();
      var defRevCode = $("#defRevCodeInp").val();

      // let's get some data and draw the bar chart
      $.ajax({
        url: '../Report/DefRevScheduleWidgetReport',
        type: 'GET',
        cache: false,
        data: { accountingCycleId: accCycleId, currency: currency, revenueCode: revCode, deferredRevenueCode: defRevCode, productId: productId },
        success: function(data) {
          DisplayChart(data);
        },
        error: function () {
          alert("Data retrival error!");
        }
      });      
    }

    function DisplayChart(dataSet) {
      var data = crossfilter(dataSet.rows);
      var headers = dataSet.headers;
      var dateDim = data.dimension(function (d) {
        return d.month;
      });
      var revRecByMonth = dateDim.group().reduce(
                function (p, v) {
                  p.totalDeferred += v.deferred;
                  p.totalEarned += v.earned;
                  return p;
                },
                function (p, v) {
                  p.totalDeferred -= v.deferred;
                  p.totalEarned -= v.earned;
                  return p;
                },
                function () {
                  return {
                    totalDeferred: 0,
                    totalEarned: 0
                  };
                }
        );

      // colors
      var colorRange = ["#b2df8a", "#1f78b4"];

      revRecChart
                .width(900)
                .height(400)
                .margins({ top: 40, right: 50, bottom: 30, left: 60 })
                .dimension(dateDim)
                .group(revRecByMonth, stackDomain[1])
                .valueAccessor(function (d) { return d.value.totalDeferred; })
                .stack(revRecByMonth, stackDomain[0], function (d) { return d.value.totalEarned; })
                .colors(d3.scale.ordinal().domain(stackDomain).range(colorRange))
                .x(d3.scale.linear().domain([0, dataSet.rows.length+1]))
				        .renderHorizontalGridLines(true)
                .centerBar(true)
                .elasticY(true)
                .brushOn(false)
                .legend(dc.legend().x(890).y(50))
                .title(function (d) {
                  return headers[d.key-1]
                            + "\n" + stackDomain[0] + " " + Math.round(d.value.totalEarned)
                            + "\n" + stackDomain[1] + " " + Math.round(d.value.totalDeferred);
                });

      // formatting
      revRecChart.yAxis().ticks(10);
      revRecChart.xAxis().tickFormat(function (d) { return headers[d-1]; });

      dc.renderAll();
    }
  </script>
</asp:Content>

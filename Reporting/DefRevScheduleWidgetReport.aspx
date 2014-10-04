<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="DefRevScheduleWidgetReport.aspx.cs" Inherits="DefRevScheduleWidgetReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" EnableViewState="false"%>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css" />
  <style type="text/css">
	  #revrec-chart svg { width: 1040px; }
  </style>
  <MT:MTTitle ID="MTTitle1" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <div id="container">
    <div class="row">
      <MT:MTPanel runat="server" ID="filterPanel" ClientIDMode="Static">
      <MT:MTDropDown runat="server" ClientIDMode="Static" ID="accntCycleDd" />
      <MT:MTDropDown runat="server" ClientIDMode="Static" ID="currencyDd" />
      <MT:MTDropDown runat="server" ClientIDMode="Static" ID="productDd" />
      <MT:MTButton runat="server" ID="applyBtn" ClientIDMode="Static" EnableViewState="False" OnClientClick="ApplyFilter(); return false;"/>
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

    function ApplyFilter() {
      var accCycleId = $("#accntCycleDd").val();
      var currency = $("#currencyDd").val();
      var productId = $("#productDd").val();

      // let's get some data and draw the bar chart
      $.ajax({
        url: '../Report/DefRevScheduleWidgetReport',
        type: 'GET',
        cache: false,
        data: { accountingCycleId: accCycleId, currency: currency, revenueCode: "", deferredRevenueCode: "", productId: productId },
        success: function(data) {
          DisplayChart(data);
        },
        error: function (data) {
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
      var colorDomain = ["<%=GetLocalResourceObject("Earned_Caption").ToString() %>", "<%=GetLocalResourceObject("Deferred_Caption").ToString() %>"];
      var colorRange = ["#b2df8a", "#1f78b4"];

      revRecChart
                .width(900)
                .height(400)
                .margins({ top: 40, right: 50, bottom: 30, left: 60 })
                .dimension(dateDim)
                .group(revRecByMonth, "<%=GetLocalResourceObject("Deferred_Caption").ToString() %>")
                .valueAccessor(function (d) { return d.value.totalDeferred; })
                .stack(revRecByMonth, "<%=GetLocalResourceObject("Earned_Caption").ToString() %>", function (d) { return d.value.totalEarned; })
                .colors(d3.scale.ordinal().domain(colorDomain).range(colorRange))
                .x(d3.scale.linear().domain([1, headers.length]))
				        .renderHorizontalGridLines(true)
                .centerBar(true)
                .elasticY(true)
                .brushOn(false)
                .legend(dc.legend().x(890).y(50))
                .title(function (d) {
                  return headers[d.key-1]
                            + "\n<%=GetLocalResourceObject("Earned_Caption").ToString() %>: " + Math.round(d.value.totalEarned)
                            + "\n<%=GetLocalResourceObject("Deferred_Caption").ToString() %>: " + Math.round(d.value.totalDeferred);
                });

      // formatting
      revRecChart.yAxis().ticks(10);
      revRecChart.xAxis().tickFormat(function (d) { return headers[d-1]; });

      dc.renderAll();
    }
  </script>
</asp:Content>

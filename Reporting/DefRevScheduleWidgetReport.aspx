<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="DefRevScheduleWidgetReport.aspx.cs" Inherits="DefRevScheduleWidgetReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css" />
  <style type="text/css">
	  #revrec-chart svg { width: 1040px; }
  </style>
  <h1>Deferred Revenue Schedule Widget</h1>
  <div id="container">
    <div class="row">
      <div id="revrec-chart" class="dc-chart">
      </div>
    </div>
  </div>
  <script type="text/javascript" src="/Res/JavaScript/d3.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.js"></script>
  <script language="javascript" type="text/javascript">
    var mnthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    //var dtFormat = d3.time.format("%Y-%m-%d");
    var revRecChart = dc.barChart("#revrec-chart");

    // let's get some data
    d3.json("../Report/DefRevScheduleWidgetReport", function (csv) {
    csv.forEach(function (e) {
      e.jsDate = new Date(parseInt(e.date.substr(6)));
    });

    //var timeExtent = d3.extent(dataSet, function (d) { return d.date; });

    var data = crossfilter(csv);

    var dateDim = data.dimension(function (d) {
      return d.jsDate;
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
      
    // date ranges
    var minDate = dateDim.bottom(1)[0].jsDate;
    var maxDate = dateDim.top(1)[0].jsDate;

    // colors
    var colorDomain = ["Earned", "Deferred"]
    var colorRange = ["#b2df8a", "#1f78b4"];

    revRecChart
                .width(900)
                .height(400)
                .margins({ top: 40, right: 50, bottom: 30, left: 60 })
                .dimension(dateDim)
                .group(revRecByMonth, "Deferred")
                .valueAccessor(function (d) { return d.value.totalDeferred; })
                .stack(revRecByMonth, "Earned", function (d) { return d.value.totalEarned; })
                .colors(d3.scale.ordinal().domain(colorDomain).range(colorRange))
                .x(d3.time.scale().domain([minDate, maxDate]))
                .xUnits(d3.time.months)
				.renderHorizontalGridLines(true)
                .centerBar(true)
                .elasticY(true)
                .brushOn(false)
                .legend(dc.legend().x(890).y(50))
                .title(function (d) {
                  return d.key.getDate() + " " + mnthNames[d.key.getMonth()] + " " + d.key.getFullYear()
                            + "\nEarned: " + Math.round(d.value.totalEarned)
                            + "\nDeferred: " + Math.round(d.value.totalDeferred);
                });

    // formatting
    revRecChart.yAxis().ticks(10);
    revRecChart.xAxis().tickFormat(function (d) { return d.getDate() + " " + mnthNames[d.getMonth()] + " " + d.getFullYear(); });

    dc.renderAll();
  });
  </script>
</asp:Content>

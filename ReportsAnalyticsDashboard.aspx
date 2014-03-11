<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  Inherits="ReportsAnalyticsDashboard" Title="MetraNet" CodeFile="ReportsAnalyticsDashboard.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="ReportsAnalyticsDashboardPage" ContentPlaceHolderID="ContentPlaceHolder1"
  runat="Server">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
  <script type="text/javascript" src="MetraControl/ControlCenter/js/D3Visualize.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <MT:MTTitle ID="MTTitle1" Text="Finance Dashboard" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <%--<div style="margin: 40px; border: 1px solid; padding: 15px 10px 15px 35px; background-repeat: no-repeat;
    background-position: 10px center; color: #9F6000; background-color: #FEEFB3; background-image: url('/Res/Images/icons/error.png');">
    Under development
  </div>--%>
  <br />
  <div class="remaining-graphs span8">
    <h1>New Customers</h1>
    <div class="row-fluid">
      <div id='NewCustomersChart' class="pie-graph span4 dc-chart" style="float: none !important;">
      </div>
    </div>
  </div>
  <div class="remaining-graphs span8">
    <h1>Revenue</h1>
    <div class="row-fluid">
      <div id='RevenueChart' class="pie-graph span4 dc-chart" style="float: none !important;">
      </div>
    </div>
  </div>
  <div class="remaining-graphs span8">
    <h1>MRR</h1>
    <div class="row-fluid">
      <div id='MRRChart' class="pie-graph span4 dc-chart" style="float: none !important;">
      </div>
    </div>
  </div>
  <br />
  <script type="text/javascript">
    $(function () {
      getNewCustomers();
      getRevenue();
      getMRR();
    });
    
    function getNewCustomers() {
      $.ajax({
        type: 'GET',
        async: true,
        url: 'Report/NewCustomers',
        success: function (data) {
          RenderNewCustomersChart(data);
        },
        error: function () {
          alert("Error getting Data");
        }
      });
    };

    function RenderNewCustomersChart(JSONData) {

      var volumeChart = dc.barChart("#NewCustomersChart");

      var ndx = crossfilter(JSONData);

      var startValue = ndx.dimension(function (d) {
        return new Date(parseInt(d.Date.substr(6)));
      });
      var startValueGroup = startValue.group();

      var previousMonth = getUTCDate(new Date(<%= previousMonth %>));
      var firstMonth = getUTCDate(new Date(<%= firstMonth %>));

      console.log(previousMonth);
      console.log(firstMonth);
      
      volumeChart.width(800)
        .height(300)
        .dimension(startValue)
        .group(startValueGroup, "New Customers")
        .transitionDuration(1000)
        .margins({
                top: 10, 
                right: 50, 
                bottom: 30, 
                left: 70})
        .centerBar(true)
        .gap(15)
        .round(d3.time.month.round)
        .x(d3.time.scale().domain([firstMonth, previousMonth]))
        .xUnits(d3.time.months)
        .legend(dc.legend().x(680).y(0))
        .elasticY(true)  
        .on("postRender", function(chart) {
          AddXAxis(chart, "Months");
          AddYAxis(chart, "Customers");
        })
        .xAxis().tickFormat(d3.time.format("%b-%Y"));        

      dc.renderAll();
      dc.redrawAll();
    }
    
    function getUTCDate(dateForConvert) {
      return new Date(dateForConvert.getUTCFullYear(), dateForConvert.getUTCMonth(), dateForConvert.getUTCDate(),dateForConvert.getUTCHours(), dateForConvert.getUTCMinutes(), dateForConvert.getUTCSeconds());
    }

    function AddXAxis(chartToUpdate, displayText) {
      chartToUpdate.svg()
        .append("text")
        .attr("class", "x-axis-label")
        .attr("text-anchor", "middle")
        .attr("x", chartToUpdate.width() / 2)
        .attr("y", chartToUpdate.height() + 10)
        .text(displayText);
    }

    function AddYAxis(chartToUpdate, displayText) {
      chartToUpdate.svg().append("text")
        .attr("class", "y label")
        .attr("text-anchor", "middle")
        .attr("transform", "translate(20,"+ chartToUpdate.yAxisHeight()/2 + "),rotate(-90)")
        .text(displayText);
    }

    function getRevenue() {
      $.ajax({
        type: 'GET',
        async: true,
        url: 'Report/Revenue',
        success: function (data) {
          RenderRevenueChart(data);
        },
        error: function () {
          alert("Error getting Data");
        }
      });
    };

    function RenderRevenueChart(JSONData) {

      var volumeChart = dc.barChart("#RevenueChart");

      var ndx = crossfilter(JSONData);

      var startValue = ndx.dimension(function (d) {
        return new Date(parseInt(d.Date.substr(6)));
      });
      var startValueGroup = startValue.group();

      volumeChart.width(800)
        .height(300)
        .dimension(startValue)
        .group(startValueGroup, "Revenue")
        .transitionDuration(1500)
        .centerBar(true)
        .gap(15)
        .round(d3.time.month.round)
        .x(d3.time.scale().domain([new Date(2012, 11, 1), new Date(2013, 12, 31)]))
        .xUnits(d3.time.months)
        .legend(dc.legend().x(680).y(0))
        .elasticY(true)
        .xAxis().tickFormat(d3.time.format("%b-%Y"));

      dc.renderAll();
      dc.redrawAll();
    }
    
    function getMRR() {
      $.ajax({
        type: 'GET',
        async: true,
        url: 'Report/MRRByProduct',
        success: function (data) {
          RenderMRRChart(data);
        },
        error: function () {
          alert("Error getting Data");
        }
      });
    };
    
    function RenderMRRChart(JSONData) {

      var volumeChart = dc.barChart("#MRRChart");

      var ndx = crossfilter(JSONData);
      
      var startMonthMRR = getUTCDate(new Date(<%= startMonthMRR %>));
      var endMonthMRR = getUTCDate(new Date(<%= endMonthMRR %>));

      var startValue = ndx.dimension(function (d) {
        return new Date(parseInt(d.Date.substr(6)));
      });
      var startValueGroup = startValue.group().reduceSum(function(d) {
        return d.Amount;
      });

      volumeChart.width(800)
        .height(300)
        .dimension(startValue)
        .group(startValueGroup, "MRR")
        .transitionDuration(150)
        .centerBar(true)
        .gap(15)
        .round(d3.time.month.round)
        .x(d3.time.scale().domain([startMonthMRR, endMonthMRR]))
        .xUnits(d3.time.months)
        //.legend(dc.legend().x(680).y(0))
        .elasticY(true)
        .xAxis().tickFormat(d3.time.format("%b-%Y"));

      dc.renderAll();
      dc.redrawAll();
    }
  </script>
</asp:Content>

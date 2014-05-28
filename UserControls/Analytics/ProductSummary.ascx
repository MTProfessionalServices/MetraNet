<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Analytics_ProductSummary" CodeFile="ProductSummary.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<!--<asp:Label id="lblServerDescription" runat="server">Label</asp:Label>-->
<MT:MTPanel ID="MTPanel4" runat="server" Text="Analytics">
<div id="test">Rudi was here</div>
</MT:MTPanel> 
<button onclick="fillIt(); return false;">Test</button>


  <script type="text/javascript" src="/Res/JavaScript/d3.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.js"></script>

<script type="text/javascript">

    Ext.onReady(function () {
    fillIt();
    });

    function fillIt() {
        var chart = dc.barChart("#test");
        
        //d3.csv("morley.csv", function (error, experiments) {
        d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsSingleProductOverTime&_=" + new Date().getTime(), function (error, json) {
            if (error) alert(error);
            else {
                json.Items.forEach(function (x) {
                    x.mrr = +x.mrr;
                });

                var ndx = crossfilter(json.Items),
                    runDimension = ndx.dimension(function (d) { return +d.mrr; }); //,
                    //speedSumGroup = runDimension.group().reduceSum(function (d) { return d.Speed * d.Run / 1000; });

                chart
                //.width(768)
                .height(200)
                .x(d3.scale.linear().domain([6, 20]))
                .brushOn(false)
                            //.yAxisLabel("This is the Y Axis!")
                .dimension(runDimension)
                //.group(speedSumGroup);

                chart.render();
            }

        });
    };

//         d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopOfferingsByNewCustomers&_=" + new Date().getTime(), function (error, json) {
//         if (error) alert(error);
//         else {
//             //alert(json);
//             var objChartConfig = {
//               elementId: "#chartTopOfferingsSelectedByNewSubscribers",
//               datafield: "newcustomers",
//               tooltipFormatter: completeProductTooltipFormatter,
//               valueFormatter: defaultValueAsNumberSubscriptionsFormatter,
//               width: 600,
//               barHeight: 20,
//             };

//             objChartConfig.data = json.Items;
//             objChartConfig.data.forEach(function (d) {
//                    d[objChartConfig.datafield] = +d[objChartConfig.datafield];
//                });
//             fnVisualizeBarChartRudi(objChartConfig);
//         }
//     });  

 // });

</script>
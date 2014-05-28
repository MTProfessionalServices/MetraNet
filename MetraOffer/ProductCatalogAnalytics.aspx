<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ProductCatalogAnalytics.aspx.cs" Inherits="MetraOfferDashboard" Title="MetraOffer Dashboard" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 
   <script type="text/javascript" src="/MetraNet/MetraControl/ControlCenter/js/SampleData.js"></script>
   <script type="text/javascript" src="/MetraNet/MetraControl/ControlCenter/js/D3Visualize.js"></script>
   <script src="http://d3js.org/d3.v3.min.js"></script>
   <script src="http://labratrevenge.com/d3-tip/javascripts/d3.tip.v0.6.3.js"></script>

 <style>

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.line {
  fill: none;
  stroke: red;
  stroke-width: 1.5px;
}

.arc path {
  stroke: #fff;
}

.chart rect {
    fill: #a2c0d9;
}
.chart text {
    fill: white;
    font: 10px sans-serif;
    text-anchor: end;
}

.chart 
{
    margin: 10px;
    /*font-family: "Helvetica Neue","Arial Black", Arial, sans-serif;*/
}

.axis path, .axis line {
    fill: none;
    stroke: #000;
    shape-rendering: crispEdges;
}
.bar {
    fill: orange;
}
.bar:hover {
    fill: orangered;
}
.x.axis path {
    display: none;
}

.d3-tip {
    line-height: 1;
    font-weight: normal;
    padding: 12px;
    background: steelblue;
    color: #fff;
    border-radius: 2px;
    /*font-family: "Helvetica Neue","Arial Black", Arial, sans-serif;*/
    
}
.d3-tip .ProductCode {
    font-weight: bold;
}

/* Creates a small triangle extender for the tooltip */
 .d3-tip:after {
    box-sizing: border-box;
    display: inline;
    font-size: 10px;
    width: 100%;
    line-height: 1;
    color: steelblue;
    content:"\25BC";
    position: absolute;
    text-align: center;
}
/* Style northward tooltips differently */
 .d3-tip.n:after {
    margin: -2px 0 0 0;
    top: 100%;
    left: 0;
}

 .graphTitle {
    font-size: 16px;
    font-weight: bold;
    font-family: "Helvetica Neue","Arial Black", Arial, sans-serif;
    padding-bottom: 4px;
    color: #a2c0d9;
    margin: 10px 10px 0px 10px;
 }
 
.CaptionBar
{
 font-size: 16px ;
 font-weight:lighter;
 color: #4682b4;
 font-family: "Helvetica Neue","Arial Black", Arial, sans-serif;
}

.x-panel-header-text
{
 
font-size: 14px ;
color: #4682b4;
font-weight: lighter ;
font-family: "Helvetica Neue","Arial Black",Arial,sans-serif ;
}

/*.mtpanel-inner
{
 
width: 1000px
}*/
.mtpanel-formicon
{
    
background-image : none !important;
}
.x-panel-tl
.x-panel-icon , .x-window-tl .x-panel-icon {
   
padding-left: 0px !important ;
}
</style>
               
<MT:MTTitle ID="MTTitle1" Text="MetraOffer Dashboard" runat="server" meta:resourcekey="MTTitle1Resource1" />
<br />



             <MT:MTPanel ID="MTPanel4" runat="server" Text="Top MRR">
                   <table>
                        <tr >
                            <td><div class=graphTitle>Total</div><svg id="chartMRRTotal" class="chart"></svg></td>
                       </tr>
                        <tr >
                            <td><div class=graphTitle>Gain</div><svg id="chartMRRTotalGain" class="chart"></svg></td>
                       </tr>
                        <tr >
                            <td><div class=graphTitle>Loss</div><svg id="chartMRRTotalLoss" class="chart"></svg></td>
                       </tr>
                   </table>
             </MT:MTPanel>

               <MT:MTPanel ID="MTPanel1" runat="server" Text="Top Subscriptions">
                   <table>
                        <tr >
                            <td><div class=graphTitle>Total</div><svg id="chartSubscriptionsTotal" class="chart"></svg></td>
                       </tr>
                        <tr >
                            <td><div class=graphTitle>Gain</div><svg id="chartSubscriptionsGain" class="chart"></svg></td>
                       </tr>
                        <tr >
                            <td><div class=graphTitle>Loss</div><svg id="chartSubscriptionsLoss" class="chart"></svg></td>
                       </tr>
                   </table>
             </MT:MTPanel>
                   <MT:MTPanel ID="MTPanel2" runat="server" Text="Top Offerings Selected By New Subscribers">
                   <table>
                        <tr >
                            <td><svg id="chartTopOfferingsSelectedByNewSubscribers" class="chart"></svg></td>
                       </tr>
                   </table>
             </MT:MTPanel>


<script type="text/javascript">

     //Hack: Could't find our formatters so googled quick hack for now
     //Drop the decimals since decimals aren't cool
     function fnFormatCurrency(value, currencySymbol)
     {
         return currencySymbol + value.toFixed(0).replace(/./g, function (c, i, a) {
             return i > 0 && c !== "." && (a.length - i) % 3 === 0 ? "," + c : c;
         });
     }

// First, checks if it isn't implemented yet.
if (!String.prototype.format) {
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) { 
      return typeof args[number] != 'undefined'
        ? args[number]
        : match
      ;
    });
  };
}

    var defaultProductTooltipFormatter = (function (d) {
        return "<span class=ProductCode>" + d["productcode"] + "</span><br/><span class=Information>MRR: " + fnFormatCurrency(d["mrr"], "$") + "</span>";
    });

    var subscriptionProductTooltipFormatter = (function (d) {
        var perSubscriptionChange = ((d["subscriptionschange"]/d["subscriptionsprevious"])*100).toFixed(1);
        var html = "<div class=ProductCode>{0}</div><div class=Information>MRR: {1}</div>".format(d["productcode"], fnFormatCurrency(d["mrr"], "$"));
        html += "<div class=Information>Subscriptions: {0} <img src='/Res/Images/icons/arrow-{2}.png' style='vertical-align:sub;'/> {1}%</div>".format(d["subscriptions"], perSubscriptionChange, perSubscriptionChange<0 ? "down":"up");
        return html;
    });

    var completeProductTooltipFormatter = (function (d) {
        var perMRRChange = ((d["mrrchange"]/d["mrrprevious"])*100).toFixed(1);
        var perSubscriptionChange = ((d["subscriptionschange"]/d["subscriptionsprevious"])*100).toFixed(1);
        var msgNewCustomerChange = formatPercentageChangeMessage(d["newcustomersprevious"],d["newcustomerschange"], "{0} new customer");
        var html = "<div class=ProductCode>{0}</div>".format(d["productcode"]);
        html += "<div class=Information>MRR: {0} <img src='/Res/Images/icons/arrow-{2}.png' style='vertical-align:sub;'/> {1}%</div>".format(fnFormatCurrency(d["mrr"], "$"), perMRRChange, perMRRChange<0 ? "down":"up");
        html += "<div class=Information>Subscriptions: {0} <img src='/Res/Images/icons/arrow-{2}.png' style='vertical-align:sub;'/> {1}%</div>".format(d["subscriptions"], perSubscriptionChange, perSubscriptionChange<0 ? "down":"up");
        html += "<div class=Information>New customers: {0} {1}</div>".format(d["newcustomers"], msgNewCustomerChange);
        return html;
    });

    function formatPercentageChangeMessage(previous, change, changeText)
    {
      
      if (change==0)
      {
        return "<span class=NoChange></span>";
      }
      if (previous!=0)
      {
        var percentChange = ((change/previous)*100).toFixed(1);
        return "<img src='/Res/Images/icons/arrow-{1}.png' style='vertical-align:sub;'/> {0}%".format(percentChange, percentChange<0 ? "down":"up");
      }
      else
      {
        //We have no previous value so can't calculate the percentage
        //Just list the numerical increase
        return "<img src='/Res/Images/icons/arrow-{0}.png' style='vertical-align:sub;'/> {1}{2}".format(change<0 ? "down":"up", changeText, (change==1) ? "":"s");
      }
    }

    var defaultValueAsCurrencyFormatter = function (d,valuefield) { return fnFormatCurrency(d[valuefield],"$"); };
    var defaultValueFormatter = function (d,valuefield) { return d[valuefield]; };
    var defaultValueAsNumberSubscriptionsFormatter = function (d,valuefield) {
                                                                var subs = +d[valuefield];
                                                                return subs + " Subscription" + ((subs!=1)? "s" : ""); 
                                                                };

     function fnVisualizeBarChartRudi(objBarChartConfig)
     {
       //Bar Chart
       var width = objBarChartConfig.width;
       var barHeight = objBarChartConfig.barHeight;

       var data = objBarChartConfig.data;
       var DATA = objBarChartConfig.datafield;

       //Make sure to convert values to appropriate types
       data.forEach(function (d) {
         d[DATA] = +d[DATA];
       });

       var x = d3.scale.linear()
                 .range([0, width]);

                x.domain([0, d3.max(data, function (d) {
                                           return Math.abs(d[DATA]); 
                                         })])
                //.domain([0, d3.max(data)])


         var chart = d3.select(objBarChartConfig.elementId) //".chart")
            .attr("width", width)
            .attr("height", barHeight * data.length);

         //Add error checking/default handling if formatters aren't set in config

         var tip = d3.tip()
            .attr('class', 'd3-tip')
            .direction('n')
            .offset([0, 0])
//            .html(function (d) {
//                return "<span class=ProductCode>" + d["productcode"] + "</span><br/><span class=Information>MRR: " + fnFormatCurrency(d[DATA], "$") + "</span>";
//            });
            .html(function (d) {
                return objBarChartConfig.tooltipFormatter(d);
            });

         chart.call(tip);

         var onClick = function (d) {
             alert("You clicked " + d["productcode"]);
         }

         var bar = chart.selectAll("g")
            .data(data)
            .enter().append("g")
            .attr("transform", function (d, i) {
                return "translate(0," + i * barHeight + ")";
            })
            .on('mouseover', tip.show)
            .on('mouseout', tip.hide)
            .on("click", onClick);


         bar.append("rect")
            .attr("width", function (d) {return x(Math.abs(d[DATA]));})
            .attr("height", barHeight - 1);

         var valueText = bar.append("text")
            .attr("x", function (d) {return x(Math.abs(d[DATA])) - 3;})
            .attr("y", barHeight / 2)
            .attr("dy", ".35em")
//            .text(function (d) {
//                   return fnFormatCurrency(d[DATA],"$");
//                  })
            .text(function (d) {
                   return objBarChartConfig.valueFormatter(d,DATA);
                  })
            .attr("visibility", function (d) {
                           return this.getComputedTextLength()>(x(Math.abs(d[DATA])) - 3) ? "hidden" : "visible"
                           });

     }



     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopMRR&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfigMRRTotal = {
               elementId: "#chartMRRTotal",
               datafield: "mrr",
               tooltipFormatter: completeProductTooltipFormatter,
               valueFormatter: defaultValueAsCurrencyFormatter,
               width: 600,
               barHeight: 20,
             };

             objChartConfigMRRTotal.data = json.Items;
             objChartConfigMRRTotal.data.forEach(function (d) {
                    d[objChartConfigMRRTotal.datafield] = +d[objChartConfigMRRTotal.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfigMRRTotal);
         }
     });

     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopMRRGain&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfigMRRTotalGain = {
               elementId: "#chartMRRTotalGain",
               datafield: "change",
               tooltipFormatter: completeProductTooltipFormatter,
               valueFormatter: defaultValueAsCurrencyFormatter,
               width: 600,
               barHeight: 20,
             };

             objChartConfigMRRTotalGain.data = json.Items;
             objChartConfigMRRTotalGain.data.forEach(function (d) {
                    d[objChartConfigMRRTotalGain.datafield] = +d[objChartConfigMRRTotalGain.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfigMRRTotalGain);
         }
     });

     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopMRRLoss&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfigMRRTotalGain = {
               elementId: "#chartMRRTotalLoss",
               tooltipFormatter: completeProductTooltipFormatter,
               valueFormatter: defaultValueAsCurrencyFormatter,
               datafield: "change",
               width: 600,
               barHeight: 20,
             };

             objChartConfigMRRTotalGain.data = json.Items;
             objChartConfigMRRTotalGain.data.forEach(function (d) {
                    d[objChartConfigMRRTotalGain.datafield] = +d[objChartConfigMRRTotalGain.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfigMRRTotalGain);
         }
     });

     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopSubscriptions&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfigSubscriptionsTotal = {
               elementId: "#chartSubscriptionsTotal",
               datafield: "subscriptions",
               tooltipFormatter: subscriptionProductTooltipFormatter,
               valueFormatter: defaultValueAsNumberSubscriptionsFormatter,
               width: 600,
               barHeight: 20,
             };

             objChartConfigSubscriptionsTotal.data = json.Items;
             objChartConfigSubscriptionsTotal.data.forEach(function (d) {
                    d[objChartConfigSubscriptionsTotal.datafield] = +d[objChartConfigSubscriptionsTotal.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfigSubscriptionsTotal);
         }
     });

     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopSubscriptionGain&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfigSubscriptionsTotal = {
               elementId: "#chartSubscriptionsGain",
               datafield: "subscriptionschange",
               tooltipFormatter: subscriptionProductTooltipFormatter,
               valueFormatter: defaultValueAsNumberSubscriptionsFormatter,
               width: 600,
               barHeight: 20,
             };

             objChartConfigSubscriptionsTotal.data = json.Items;
             objChartConfigSubscriptionsTotal.data.forEach(function (d) {
                    d[objChartConfigSubscriptionsTotal.datafield] = +d[objChartConfigSubscriptionsTotal.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfigSubscriptionsTotal);
         }
     });

     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopSubscriptionLoss&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfigSubscriptionsTotal = {
               elementId: "#chartSubscriptionsLoss",
               datafield: "subscriptionschange",
               tooltipFormatter: subscriptionProductTooltipFormatter,
               valueFormatter: defaultValueAsNumberSubscriptionsFormatter,
               width: 600,
               barHeight: 20,
             };

             objChartConfigSubscriptionsTotal.data = json.Items;
             objChartConfigSubscriptionsTotal.data.forEach(function (d) {
                    d[objChartConfigSubscriptionsTotal.datafield] = +d[objChartConfigSubscriptionsTotal.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfigSubscriptionsTotal);
         }
     });

     d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=AnalyticsTopOfferingsByNewCustomers&_=" + new Date().getTime(), function (error, json) {
         if (error) alert(error);
         else {
             //alert(json);
             var objChartConfig = {
               elementId: "#chartTopOfferingsSelectedByNewSubscribers",
               datafield: "newcustomers",
               tooltipFormatter: completeProductTooltipFormatter,
               valueFormatter: defaultValueAsNumberSubscriptionsFormatter,
               width: 600,
               barHeight: 20,
             };

             objChartConfig.data = json.Items;
             objChartConfig.data.forEach(function (d) {
                    d[objChartConfig.datafield] = +d[objChartConfig.datafield];
                });
             fnVisualizeBarChartRudi(objChartConfig);
         }
     });     
     
//    Ext.onReady(function () {

//    });



 
  
  

</script>


</asp:Content>





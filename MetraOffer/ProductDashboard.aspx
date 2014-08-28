<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ProductDashboard.aspx.cs" Inherits="ProductDashboard" Title="Product Dashboard"
  Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <script src="http://labratrevenge.com/d3-tip/javascripts/d3.tip.v0.6.3.js"></script>

  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dashboard.css">

  <style>
 
 .dc-chart g.row text {
    fill: black;
    cursor: pointer;
    font: bold 11px tahoma,arial,verdana,sans-serif;
  }
    
    
    
   .x-panel-bwrap,.x-panel-body, 
   #formPanel_<%=pnlTop10MMR.ClientID%>,
   #formPanel_<%=pnlTop10Subs.ClientID%>,
   #formPanel_<%=pnlTop10Revenue.ClientID%>,
   #formPanel_<%=pnlTop10UniqueCustomers.ClientID%>,
   #formPanel_<%=pnlTop10NewCustomers.ClientID%>
     {
      width: 100% !important;
      height: 100% !important;
    }
    
    
   #formPanel_<%=pnlRecentOfferingChanges.ClientID%>, 
   #formPanel_<%=pnlRecentRateChanges.ClientID%>,
   #formPanel_<%=pnlMyRecentChanges.ClientID%>,
   #grid-container_ctl00_ContentPlaceHolder1_grdRecentOfferingChanges,
   #grid-container_ctl00_ContentPlaceHolder1_grdRecentRateChanges,
   #grid-container_ctl00_ContentPlaceHolder1_grdMyRecentChanges
   {
      width: 100% !important;
      height: 100% !important;
      
    }
    
    
    .x-panel-body
    {
      padding: 0px !important;
    }
    
    #gridsterul
    {
      position: static !important;
    }
    
    
    .mtpanel-inner {
     width: auto;
      height: 100%;
    }
    
    

  </style>
  <script type="text/javascript" >
    var demomode = false;
    var currencyFormat = d3.format("$,.0f");

    function visualizeRowChart(op, divid, fnData, fnDim, fnGroup, fnTitle, colors, demodata, headingid, headingtext) {
	  var data = [];
	  d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=" + op + "&_=" + new Date().getTime(), function (error, json) {
	    if (error) alert(error);
	    else {
	      d3.select(headingid).text(headingtext);

	      if (demomode)
	        data = demodata;
	      else
	        data = json.Items;


	      var rowChart = dc.rowChart(divid, op);

	      data.forEach(fnData);

	      var ndx = crossfilter(data),
                dimension = ndx.dimension(fnDim),
                group = dimension.group().reduceSum(fnGroup);

	      rowChart.width(310)
              .height(225)
              .margins({
                top: 5,
                left: 10,
                right: 50,
                bottom: 20
              })
              .dimension(dimension)
              .renderLabel(false)


	      //.title(fnTitle)
              .group(group)
              .colors(colors)
	      //.elasticX(true)
              .xAxis().ticks(5);


	      if (fnTitle == null) {
	        rowChart.title(function (d) { return CreateTitle(data[d.key - 1]); });
	      } else {
	        rowChart.title(fnTitle);
	      }

	      dc.renderAll(op);
	      var defs = rowChart.svg().append("defs");
	      var filter = defs.append("filter")
              .attr("id", "drop-shadow")
              .attr("height", "150%")
              .attr("width", "200%");

	      filter.append("feGaussianBlur")
              .attr("in", "SourceAlpha")
              .attr("stdDeviation", 5)
              .attr("result", "blur");

	      filter.append("feOffset")
              .attr("in", "blur")
              .attr("dx", 5)
              .attr("dy", 5)
              .attr("result", "offsetBlur");

	      var feMerge = filter.append("feMerge");

	      feMerge.append("feMergeNode")
              .attr("in", "offsetBlur");
	      feMerge.append("feMergeNode")
              .attr("in", "SourceGraphic");

	      if (data.length == 0) {
	        d3.select(divid + " svg .axis").attr("visibility", "hidden");
	        d3.select(divid + " svg").append("text")
	          .attr("x", 100)
	          .attr("y", 100)
	          .text("<%=NoDataText%>"); //.append("div").text("<%=NoDataText%>");
	      }
	      /*rowChart.selectAll("rect")
	      .style("filter", "url(#drop-shadow)")
	      .attr("rx", "4px")
	      .attr("ry", "4px");*/
	    }
	  });
    }

  </script>
  <MT:MTTitle ID="MTTitle1" Text="Product
   Dashboard" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <br />
  <div class="gridster" width="100%" height="100%">
    <ul width="100%" height="100%" id="gridsterul" style="width: 100%; align: left;">
      <li data-row="1" data-col="1" data-sizex="3" data-sizey="8" height="100%">
        <MT:MTPanel ID="pnlRecentOfferingChanges" runat="server" 
          Text="Recent Offering Changes" Collapsed="False" Collapsible="True" 
          EnableChrome="True" meta:resourcekey="pnlRecentOfferingChangesResource1">
            <div style="height:228px">
                <MT:MTFilterGrid ID="grdRecentOfferingChanges" runat="Server" ExtensionName="SystemConfig"
                    TemplateFileName="Dashboard.RecentOfferingChanges.xml" Width="100%" >
                </MT:MTFilterGrid>
            </div>
        </MT:MTPanel>
      </li>

      <li data-row="1" data-col="4" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlRecentRateChanges" runat="server" Text="Recent Rate Changes" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlRecentRateChangesResource1" >
         <div style="height:228px">
                <MT:MTFilterGrid ID="grdRecentRateChanges" runat="Server" ExtensionName="SystemConfig"
                    TemplateFileName="Dashboard.RecentRateChanges.xml">
                </MT:MTFilterGrid>
            </div>
        </MT:MTPanel>
      </li>
      
      <li data-row="1" data-col="7" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlMyRecentChanges" runat="server" Text="My Recent Changes" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlMyRecentChangesResource1"  >
            <div style="height:228px">
                <MT:MTFilterGrid ID="grdMyRecentChanges" runat="Server" ExtensionName="SystemConfig"
                    TemplateFileName="Dashboard.RecentRateChanges.xml">
                </MT:MTFilterGrid>
            </div>

        </MT:MTPanel>
      </li>
     

      <li data-row="8" data-col="1" data-sizex="9" data-sizey="8">
        <MT:MTPanel ID="pnlTop10MMR" runat="server" Text="Top 10 MRR" Collapsed="False" 
          Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10MMRResource1"  >
          <div id="divTop10MRRTotal" style="float:left; padding-left:10px">
                <h4 align="center" id="MRRTotalGraphTitle"> MRR Total </h4>
            </div>
            <div id="divTop10MRRGain"  style="float:left; padding-left:5px">
                <h4 align="center" id="MRRGainGraphTitle">MRR Gain</h4>
            </div>
            <div id="divTop10MRRLoss" style="float:left; padding-left:10px">
                  <h4 align="center" id="MRRLossGraphTitle">MRR Loss</h4>
            </div>
        </MT:MTPanel>
      </li>
     
      <li data-row="17" data-col="1" data-sizex="9" data-sizey="8">
        <MT:MTPanel ID="pnlTop10Subs" runat="server" Text="Top 10 Subscriptions" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10SubsResource1" >
           <div id="divTop10SubsTotal" style="float:left">
                <h4 align="center" id="TopSubsGraphTitle">Subscriptions Total</h4>
            </div>
            <div id="divTop10SubsGain"  style="float:left">
                <h4 align="center" id="TopSubsGainGraphTitle">Subscriptions Gain</h4>
            </div>
            <div id="divTop10SubsLoss" style="float:left">
               <h4 align="center" id="TopSubsLossGraphTitle">Subscriptions Loss</h4>
            </div>

        </MT:MTPanel>
      </li>
      
      <li data-row="25" data-col="1" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlTop10Revenue" runat="server" Text="Top 10 Revenue" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10RevenueResource1" >
           <div id="divTop10Revenue" style="float:left">
           </div>
        </MT:MTPanel>
      </li>
      <li data-row="25" data-col="4" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlTop10UniqueCustomers" runat="server" Text="Top 10 Customers" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10UniqueCustomersResource1" >
            <div id="divTop10UniqueCustomers" style="float:left;">
            </div>
        </MT:MTPanel>
      </li>
      <li data-row="25" data-col="7" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlTop10NewCustomers" runat="server" 
          Text="Top 10 New Customers (Last 30 days)" Collapsed="False" Collapsible="True" 
          EnableChrome="True" meta:resourcekey="pnlTop10NewCustomersResource1" >
          <div id="divTop10NewCustomers" style="float:left;">
          </div>
        </MT:MTPanel>
      </li>
    </ul>
  </div>
  <script type="text/javascript">
    Ext.onReady(function () {
      Ext.getCmp('formPanel_<%=pnlRecentOfferingChanges.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(0), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlRecentOfferingChanges.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(0), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlRecentRateChanges.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(1), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlRecentRateChanges.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(1), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlMyRecentChanges.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(2), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlMyRecentChanges.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(2), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlTop10MMR.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(3), 9, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10MMR.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(3), 9, 8); });
      Ext.getCmp('formPanel_<%=pnlTop10Subs.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(4), 9, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10Subs.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(4), 9,8); });
      Ext.getCmp('formPanel_<%=pnlTop10Revenue.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(5), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10Revenue.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(5), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlTop10UniqueCustomers.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(6), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10UniqueCustomers.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(6), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlTop10NewCustomers.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10NewCustomers.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3,8); });
    
      //Failed transaction area
      makeTop10MRRPart();
      makeTop10SubsPart();
      //makeTop10RevenuePart();
      //makeTop10UniqueCustomersPart();
      makeTop10NewCustomersPart();


    });
    

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


    var fnMRRTitle = (function (d) {
      var dataItem = data[d.key - 1];
      var perMRRChange = (dataItem.mrrprevious != 0) ? ((dataItem.mrrchange/dataItem.mrrprevious)*100) : 0;
        /*var perMRRChange = ((d["mrrchange"]/d["mrrprevious"])*100);
        //var perSubscriptionChange = ((d["subscriptionschange"]/d["subscriptionsprevious"])*100).;
        //var msgNewCustomerChange = formatPercentageChangeMessage(d["newcustomersprevious"],d["newcustomerschange"], "{0} new customer");
        var html = "<div class=ProductCode>{0}</div>".format(d["productcode"]);
        html += "<div class=Information>MRR: {0} <img src='/Res/Images/icons/arrow-{2}.png' style='vertical-align:sub;'/> {1}%</div>".format(d["mrr"], perMRRChange, perMRRChange<0 ? "down":"up");
        //html += "<div class=Information>Subscriptions: {0} <img src='/Res/Images/icons/arrow-{2}.png' style='vertical-align:sub;'/> {1}%</div>".format(d["subscriptions"], perSubscriptionChange, perSubscriptionChange<0 ? "down":"up");
        //html += "<div class=Information>New customers: {0} {1}</div>".format(d["newcustomers"], msgNewCustomerChange);
        return html;*/
      var titleText = String.format("{0}: {1} {2}: {3}", "Product Code", dataItem.productcode, "Product Name", dataItem.productname ) + ((dataItem.mrrprevious == 0) ? String.format(" {0}: {1}", "MRR", dataItem.mrr) : String.format(" {0}: {1}%", "MRR", perMRRChange));
      return titleText;    
    });

    function CreateTitle(dataItem) {
      var perMRRChange = (dataItem.mrrprevious != 0) ? ((dataItem.mrrchange/dataItem.mrrprevious)*100) : 0;
      var titleText = String.format("{0}: {1} {2}: {3}", "Product Code", dataItem.productcode, "Product Name", dataItem.productname ) + ((dataItem.mrrprevious == 0) ? String.format(" {0}: {1}", "MRR", dataItem.mrr) : String.format(" {0}: {1}%", "MRR", perMRRChange));
      return titleText;
    }    
    
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

    function makeTop10MRRPart() {
      
      //START MRR TOTAL
      var data = [];
/*
      data.push({ productcode: 1, mrr: 700, productname: "500 Free Minutes" });
      data.push({ productcode: 2, mrr: 900, productname: "Simple Web" });
      data.push({ productcode: 3, mrr: 100, productname: "On-Demand Cloud" });
      data.push({ productcode: 4, mrr: 400, productname: "Pre-paid Cloud" });
      data.push({ productcode: 5, mrr: 1100, productname: "Campaign Manager" });
      data.push({ productcode: 6, mrr: 600, productname: "Wholesale offer for Cloud10" });
      data.push({ productcode: 7, mrr: 700, productname: "Cloud10 WebSite Offer" });
      data.push({ productcode: 8, mrr: 700, productname: "Content Squared Revenue Share contract" });
*/

      var fnData = function(x) 
      {
        x.mrr = +x.mrr;
        x.productcode = +x.productcode;
        x.ordernum = +x.ordernum;
        x.mrrchange = +x.mrrchange;
        x.mrrprevious = +x.mrrprevious;      
      };
      
      var fnDim = function(d) {
        return d.ordernum; // d.productname;
      };

      var fnGroup = function(d) {
        return d.mrr;
      };

      var fnTitle = fnMRRTitle;//function (d) { return d.key + " - " + currencyFormat(d.value); };
      visualizeRowChart("AnalyticsTopMRR", "#divTop10MRRTotal", fnData, fnDim, fnGroup, null, "#0070c0", data, "#MRRTotalGraphTitle", "<%=MrrTotalGraphTitle%>");
      
      //DONE MRR TOTAL

      //START MRR GAIN
/*      data = [];

      data.push({ productcode: 1, mrr: 700, productname: "500 Free Minutes",change:"300" });
      data.push({ productcode: 3, mrr: 100, productname: "On-Demand Cloud" ,change:"50"});
      data.push({ productcode: 8, mrr: 700, productname: "Content Squared Revenue Share contract",change:"100" });

      fnData = function (x) {
        x.change = +x.change;
      };
*/
      
      fnGroup = function (d) {
        return d.mrrchange;
      };

      visualizeRowChart("AnalyticsTopMRRGain", "#divTop10MRRGain", fnData, fnDim, fnGroup, null, "#148622", data, "#MRRGainGraphTitle", "<%=MrrGainGraphTitle%>");


      //END MRR GAIN
      
      //START MRR LOSS
/*
      data = [];
      data.push({ productcode: 2, mrr: 900, productname: "Simple Web",change:"-100" });
      data.push({ productcode: 4, mrr: 400, productname: "Pre-paid Cloud", change: "-25" });
      data.push({ productcode: 5, mrr: 1100, productname: "Campaign Manager", change: "-40" });
      data.push({ productcode: 6, mrr: 600, productname: "Wholesale offer for Cloud10", change: "-65" });
      data.push({ productcode: 7, mrr: 700, productname: "Cloud10 WebSite Offer", change: "-210" });
*/
      fnGroup = function (d) {
        return -(d.mrrchange);
      };


      //fnTitle = function(d) { return d.key + " - -" + currencyFormat(d.value); };
      visualizeRowChart("AnalyticsTopMRRLoss", "#divTop10MRRLoss", fnData, fnDim, fnGroup, null, "#C00", data,  "#MRRLossGraphTitle", "<%=MrrLossGraphTitle%>");
      //END MRR LOSS
    }

    

    function makeTop10SubsPart() {
      
      //START Subs TOTAL
      var data = [];
/*      data.push({ productcode: 1, subscriptions: 7000, productname: "500 Free Minutes" });
      data.push({ productcode: 2, subscriptions: 9200, productname: "Simple Web" });
      data.push({ productcode: 3, subscriptions: 1040, productname: "On-Demand Cloud" });
      data.push({ productcode: 4, subscriptions: 500, productname: "Pre-paid Cloud" });
      data.push({ productcode: 5, subscriptions: 600, productname: "Campaign Manager" });
      data.push({ productcode: 6, subscriptions: 250, productname: "Wholesale offer for Cloud10" });
      data.push({ productcode: 7, subscriptions: 10000, productname: "Cloud10 WebSite Offer" });
      data.push({ productcode: 8, subscriptions: 300, productname: "Content Squared Revenue Share contract" });
*/

      var fnData = function(x) {
        x.subscriptions = +x.subscriptions;
      };
      
      var fnDim = function(d) {
        return d.productname;
      };

      var fnGroup = function(d) {
        return d.subscriptions;
      };

      var fnTitle = function(d) {
        return d.key + " - " + d.value;
      };

      visualizeRowChart("AnalyticsTopSubscriptions", "#divTop10SubsTotal", fnData, fnDim, fnGroup, fnTitle, "#0070c0", data,  "#TopSubsGraphTitle", "<%=TopSubsGraphTitle%>");
      
      
      //DONE Subs TOTAL

      //START Subs GAIN

/*      data = [];
      data.push({ productcode: 2, subscriptions: 9200, productname: "Simple Web",subscriptionschange:"200" });
      data.push({ productcode: 3, subscriptions: 1040, productname: "On-Demand Cloud" ,subscriptionschange:"40"});
      data.push({ productcode: 4, subscriptions: 500, productname: "Pre-paid Cloud" ,subscriptionschange:"100"});
      data.push({ productcode: 5, subscriptions: 600, productname: "Campaign Manager",subscriptionschange:"75" });
      data.push({ productcode: 6, subscriptions: 250, productname: "Wholesale offer for Cloud10" ,subscriptionschange:"50"});
      data.push({ productcode: 7, subscriptions: 10000, productname: "Cloud10 WebSite Offer",subscriptionschange:"3000" });
      data.push({ productcode: 8, subscriptions: 300, productname: "Content Squared Revenue Share contract",subscriptionschange:"10" });
*/
      fnData = function (x) {
        x.subscriptionschange = +x.subscriptionschange;
      };
      
      fnGroup = function (d) {
        return d.subscriptionschange;
      };

      visualizeRowChart("AnalyticsTopSubscriptionGain", "#divTop10SubsGain", fnData, fnDim, fnGroup, fnTitle, "#148622", data, "#TopSubsGainGraphTitle", "<%=TopSubsGainGraphTitle%>");


      //END Subs GAIN
      
      //START Subs LOSS

/*      data = [];
      data.push({ productcode: 1, subscriptions: 7000, productname: "500 Free Minutes",subscriptionschange:"-1000" });
*/      
      fnGroup = function (d) {
        return d.subscriptionschange;
      };

      fnTitle = function(d) {
        return d.key + " -  -" + d.value;
      };
      
      visualizeRowChart("AnalyticsTopSubscriptionLoss", "#divTop10SubsLoss", fnData, fnDim, fnGroup, fnTitle, "#C00", data, "#TopSubsLossGraphTitle", "<%=TopSubsLossGraphTitle%>");
      //END Subs LOSS

    }

    function makeTop10UniqueCustomersPart() {
      
      var data = [];
      data.push({ productcode: 1, subscriptions: 7000, productname: "500 Free Minutes",newcustomers:"125" });
      data.push({ productcode: 2, subscriptions: 9200, productname: "Simple Web" ,newcustomers:"30"});


      var fnData = function(x) {
        x.newcustomers = +x.newcustomers;
      };
      
      var fnDim = function(d) {
        return d.productname;
      };

      var fnGroup = function(d) {
        return d.newcustomers;
      };


      var fnTitle = function (d) { return d.key + " - " + d.value; };
      visualizeRowChart("AnalyticsTopOfferingsByUniqueCustomers", "#divTop10UniqueCustomers", fnData, fnDim, fnGroup, fnTitle, "#0070c0", data);

    }



    function makeTop10NewCustomersPart() {
      
      var data = [];
      data.push({ productcode: 1, subscriptions: 7000, productname: "500 Free Minutes",newcustomers:"125" });
      data.push({ productcode: 2, subscriptions: 9200, productname: "Simple Web" ,newcustomers:"30"});
      data.push({ productcode: 3, subscriptions: 1040, productname: "On-Demand Cloud" ,newcustomers:"10"});
      data.push({ productcode: 4, subscriptions: 500, productname: "Pre-paid Cloud" ,newcustomers:"11"});
      data.push({ productcode: 5, subscriptions: 600, productname: "Campaign Manager" ,newcustomers:"25"});
      data.push({ productcode: 6, subscriptions: 250, productname: "Wholesale offer for Cloud10",newcustomers:"60" });
      data.push({ productcode: 7, subscriptions: 10000, productname: "Cloud10 WebSite Offer",newcustomers:"200" });
      data.push({ productcode: 8, subscriptions: 300, productname: "Content Squared Revenue Share contract",newcustomers:"59" });


      var fnData = function(x) {
        x.newcustomers = +x.newcustomers;
      };
      
      var fnDim = function(d) {
        return d.productname;
      };

      var fnGroup = function(d) {
        return d.newcustomers;
      };


      var fnTitle = function (d) { return d.key + " - " + d.value; };

      visualizeRowChart("AnalyticsTopOfferingsByNewCustomers", "#divTop10NewCustomers", fnData, fnDim, fnGroup, fnTitle, "#0070c0", data);

    }
    

    function makeTop10RevenuePart() {
      
      var data = [];
      data.push({ productcode: 1, productname: "500 Free Minutes", revenue:"1250" });
      

      var fnData = function(x) {
        x.revenue = +x.revenue;
      };
      
      var fnDim = function(d) {
        return d.productname;
      };

      var fnGroup = function(d) {
        return d.revenue;
      };


      var fnTitle = function (d) { return d.key + " - " + d.value; };

      visualizeRowChart("AnalyticsTopOfferingsByRevenue", "#divTop10Revenue", fnData, fnDim, fnGroup, fnTitle, "#0070c0", data);

    }


    var gridster;

    $(function () {

      gridster = $(".gridster ul").gridster({
        widget_base_dimensions: [100, 25],
        widget_margins: [5, 5],
        helper: 'clone',
        resize: { enabled: false },
        autogrow_cols: true,
        min_rows: 30,
      }).data('gridster').disable();
    });
  </script>
</asp:Content>

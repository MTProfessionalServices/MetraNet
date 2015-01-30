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
  <script type="text/javascript" src="/Res/JavaScript/d3.v3.min.js"></script>
  <script  type="text/javascript" src="/Res/JavaScript/d3.tip.js"></script>

  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dashboard.css">

  <style>
 
 .dc-chart g.row text {
    fill: black;
    /*cursor: pointer;*/
    font: bold 11px tahoma,arial,verdana,sans-serif;
  }
  .dc-chart g.row rect {
  /*  fill-opacity: 0.8;*/
    cursor: default !important;
  }
     
   .x-panel-bwrap,.x-panel-body, 
   #formPanel_<%=pnlTop10MMR.ClientID%>,
   #formPanel_<%=pnlTop10Subs.ClientID%>,
   
   <%--#formPanel_<%=pnlTop10Revenue.ClientID%>, --%>
   <%--#formPanel_<%=pnlTop10UniqueCustomers.ClientID%>,--%>
   <%--#formPanel_<%=pnlTop10NewCustomers.ClientID%>--%>
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
    
    .d3-tip {
        line-height: 1;
        font-weight: normal;
        padding: 12px;
        background: rgba(211, 211, 211, 0.96);
        /*color: black;*/
        border-radius: 2px;
        z-index: 1000;
        /*font-family: "Helvetica Neue","Arial Black", Arial, sans-serif;*/
    
    }
     /* Creates a small triangle extender for the tooltip */
    .d3-tip:after {
      box-sizing: border-box;
      display: inline;
      font-size: 18px;
      width: 100%;
      line-height: 1;
      color: rgba(211, 211, 211, 0.96);
      position: absolute;
    }
    /* Eastward tooltips */
    .d3-tip.e:after {
      content: "\25C0";
      margin: -4px 0 0 0;
      top: 50%;
      left: -8px;
    }
    .d3-tip .ProductCode {
        font-weight: bold;
    }
  </style>
  <script type="text/javascript" >
    var demomode = false;
    var currencyFormat = d3.format("$,.0f");

    function visualizeRowChart(chartConfig) {
      var data = [];
      var chartWidth = 310;
      var chartHeight = 225;

      d3.json("/MetraNet/MetraOffer/AjaxServices/VisualizeService.aspx?operation=" + chartConfig.operation + "&_=" + new Date().getTime(), function (error, json) {
        if (error) alert(error);
        else {
          if (chartConfig.graphTitleId != null) {
            d3.select(chartConfig.graphTitleId).text(chartConfig.graphTitleText);
          }

          data = demomode ? chartConfig.demoData : json.Items;
          if (data.length == 0) {
            appendNoDataText(chartConfig.divId, chartWidth, chartHeight, "<%=NoDataText%>");
            return;
          }

          var rowChart = dc.rowChart(chartConfig.divId, chartConfig.operation);
          data.forEach(chartConfig.dataConversionFn);
          
          var ndx = crossfilter(data),
                dimension = ndx.dimension(chartConfig.dimensionFn),
                group = dimension.group().reduceSum(chartConfig.groupFn);

          rowChart.width(chartWidth)
            .height(chartHeight)
            .margins({ top: 5, left: 10, right: 50, bottom: 20 })
            .dimension(dimension)
            .renderLabel(false)
            .group(ordinal_groups([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], group))
            .ordering(function(d) {return -d.key;})
            .colors(chartConfig.color)
            .title(null)
            .xAxis().ticks(5);
            
          rowChart.onClick = function () { return false; };
          dc.renderAll(chartConfig.operation);

          //remove all but the first x grid line
          d3.select(chartConfig.divId + " svg").selectAll(".grid-line").filter(function(d){ return (d !=0 );}).remove();

          if (chartConfig.hideFractionTicks) {
            d3.select(chartConfig.divId + " svg").selectAll(".tick")
              .filter(function (d) { return (Math.floor(d) != d); })
              .remove();
          }

          d3.select(chartConfig.divId + " svg").selectAll(" .axis text").text(function (d) {
            return parseFloat(d).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 });
          });

          // tooltips
          var toolTip = d3.tip()
                .attr('class', 'd3-tip')
                .offset([0, 10])
                .direction('e')
                .html(function (d) {
                  return chartConfig.toolTipFormatterFn(data[d.key - 1]);
                });
          var toolTipSelector = 'div' + chartConfig.divId + '.dc-chart rect';
          d3.selectAll(toolTipSelector).call(toolTip);
          d3.selectAll(toolTipSelector).on('mouseover', toolTip.show)
                                       .on('mouseout', toolTip.hide);

          appendDefs(rowChart);
        }
      });
    }

    function ordinal_groups(keys, group) {
      return {
        all: function () {
          var values = {};
          group.all().forEach(function(d, i) {
            values[d.key] = d.value;
          });
          var g = [];
          keys.forEach(function(key) {
            g.push({key: key,
              value: values[key] || 0});
          });
          return g;
        }
      };
    }

  </script>
    <div class="CaptionBar" style="color: #ddd;font-size: 150%;">
    <asp:Label ID="MTTitle1" runat="server" meta:resourcekey="MTTitle1Resource1"></asp:Label>
  </div>
  <br />
  <div class="gridster" width="100%" height="100%">
    <ul width="100%" height="100%" id="gridsterul" style="width: 100%; align: left;">
      <li data-row="1" data-col="1" data-sizex="3" data-sizey="8" height="100%">
        <MT:MTPanel ID="pnlRecentOfferingChanges" runat="server" 
          Text="Recent Offering Changes" Collapsed="False" Collapsible="True" 
          EnableChrome="True" meta:resourcekey="pnlRecentOfferingChangesResource1">
            <div style="height:228px;margin-left:-10px;margin-right:10px;margin-top:-10px;">
                <MT:MTFilterGrid ID="grdRecentOfferingChanges" runat="Server" ExtensionName="SystemConfig"
                    TemplateFileName="Dashboard.RecentOfferingChanges.xml">
                </MT:MTFilterGrid>
            </div>
        </MT:MTPanel>
      </li>

      <li data-row="1" data-col="4" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlRecentRateChanges" runat="server" Text="Recent Rate Changes" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlRecentRateChangesResource1" >
         <div style="height:228px;margin-left:-10px;margin-right:10px;margin-top:-10px;">
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
            <div style="height:228px;margin-left:-10px;margin-right:10px;margin-top:-10px;">
                <MT:MTFilterGrid ID="grdMyRecentChanges" runat="Server" ExtensionName="SystemConfig"
                    TemplateFileName="Dashboard.RecentRateChanges.xml">
                </MT:MTFilterGrid>
            </div>

        </MT:MTPanel>
      </li>
     

      <li data-row="8" data-col="1" data-sizex="9" data-sizey="8" id="MRRGraphs" style="visibility: hidden">
        <MT:MTPanel ID="pnlTop10MMR" runat="server" Text="Top 10 MRR" Collapsed="False" 
          Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10MMRResource1" >
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
     
      <li data-row="17" data-col="1" data-sizex="9" data-sizey="8" id="SubscriptionGraphs" style="visibility: hidden">
        <MT:MTPanel ID="pnlTop10Subs" runat="server" Text="Top 10 Subscriptions" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10SubsResource1" >
           <div id="divTop10SubsTotal" style="float:left; padding-left:10px">
                <h4 align="center" id="TopSubsGraphTitle">Subscriptions Total</h4>
            </div>
            <div id="divTop10SubsGain"  style="float:left; padding-left:5px">
                <h4 align="center" id="TopSubsGainGraphTitle">Subscriptions Gain</h4>
            </div>
            <div id="divTop10SubsLoss" style="float:left; padding-left:10px">
               <h4 align="center" id="TopSubsLossGraphTitle">Subscriptions Loss</h4>
            </div>

        </MT:MTPanel>
      </li>
      <%--
      <li data-row="25" data-col="1" data-sizex="3" data-sizey="8">
        <MT:MTPanel ID="pnlTop10Revenue" runat="server" Text="Top 10 Revenue" 
          Collapsed="False" Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlTop10RevenueResource1" >
           <div id="divTop10Revenue" style="float:left; padding-left:10px">
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
       --%>
    </ul>
  </div>
  <script type="text/javascript">
    function ViewProductOffering(poId) {
      var targetURL="/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/ProductOffering.ViewEdit.Frame.asp|ID=" + poId;
      location.href = targetURL;
    }  
    
    function tx_detailsColRenderer(value, meta, record, rowIndex, colIndex, store) {
      var styles = String.format("style='white-space:normal; {0}'", ((rowIndex % 2) != 0) ? "background: rgb(245, 245, 245);" : "");
      meta.attr = styles;
      var str = "";
      // nm_po
      // tx_details
      // tx_desc
      // dt_crt
      // nm_login
      if (record.json.id_po != null) {
        str += String.format("<span title='Name_{0}'><img style='PADDING-RIGHT:5px; vertical-align:middle' src='/Res/Images/icons/package.png'><a style='cursor:auto;font-weight:bold;' id='viewName_{0}' title='{1}' href='JavaScript:ViewProductOffering({2});'>{3}</a></span><br/>", 
          record.json.unique_id,
          "<%=GetLocalResourceObject("VIEW_PO_TEXT")%>",
          record.json.id_po,
          record.json.nm_po);
      }
      str += String.format("{0}<br/><br/>",record.json.tx_desc); 
      if (record.json.tx_details != null) {
        str += String.format("{0}<br/><br/>", record.json.tx_details);
      }
      str += String.format("<b>{0}</b>",record.json.dt_crt); 
      if (record.json.nm_login != null) {
        str += String.format("<b> {0} {1}</b><br/>",
          "<%=GetLocalResourceObject("UPDATED_BY_TEXT")%>",
          record.json.nm_login);
      }
      return str;
    }

    function tx_detailsRecentChangesColRenderer(value, meta, record, rowIndex, colIndex, store) {
      var styles = String.format("style='white-space:normal; {0}'", ((rowIndex % 2) != 0) ? "background: rgb(245, 245, 245);" : "");
      meta.attr = styles;
      var str = "";
      // tx_details
      // tx_desc
      // dt_crt
      // nm_login
      str += String.format("{0}<br/><br/>",record.json.tx_desc);
      if (record.json.tx_details != null) {
        str += String.format("{0}<br/><br/>", record.json.tx_details);
      }
      str += String.format("<b>{0}</b>",record.json.dt_crt);
      if (record.json.nm_login != null) {
        str += String.format("<b> {0} {1}</b><br/>",
          "<%=GetLocalResourceObject("UPDATED_BY_TEXT")%>",
          record.json.nm_login);
      }
      return str;
    }    
    
    // Custom Renderers
    OverrideRenderer_<%= grdRecentOfferingChanges.ClientID %> = function(cm)
    {  
      cm.setRenderer(cm.getIndexById('tx_details'), tx_detailsColRenderer);
    };

    // Custom Renderers
    OverrideRenderer_<%= grdRecentRateChanges.ClientID %> = function(cm)
    {  
      cm.setRenderer(cm.getIndexById('tx_details'), tx_detailsRecentChangesColRenderer);
    };
    
    // Custom Renderers
    OverrideRenderer_<%= grdMyRecentChanges.ClientID %> = function(cm)
    {  
      cm.setRenderer(cm.getIndexById('tx_details'), tx_detailsRecentChangesColRenderer);
    };
        
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
      <%--
      Ext.getCmp('formPanel_<%=pnlTop10Revenue.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(5), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10Revenue.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(5), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlTop10UniqueCustomers.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(6), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10UniqueCustomers.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(6), 3, 8); });
      Ext.getCmp('formPanel_<%=pnlTop10NewCustomers.ClientID%>').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3, 1); });
      Ext.getCmp('formPanel_<%=pnlTop10NewCustomers.ClientID%>').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3,8); });
      --%>
      addPeriodsToWidgetTitles();
      if (<%=ShowFinancialData.ToString().ToLower()%>) {
        makeTop10MRRPart();
        makeTop10SubsPart();
      } 
      <%--makeTop10RevenuePart();
      makeTop10UniqueCustomersPart();
      makeTop10NewCustomersPart();
      --%>
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

    function addPeriodsToWidgetTitles() {
      var last30daysSpan = "<span style='font-weight: normal'>&nbsp;<%=Last30DaysText%></span>";
      var monthNameSpan =  "<span style='font-weight: normal'>&nbsp;<%=DateStampForGraph%></span>";
      var recentOfferingHeader = $('#formPanel_<%=pnlRecentOfferingChanges.ClientID%> .x-panel-header-text');
      var recentRateChangeHeader = $('#formPanel_<%=pnlRecentRateChanges.ClientID%> .x-panel-header-text');
      var myRecentRateChangeHeader = $('#formPanel_<%=pnlMyRecentChanges.ClientID%> .x-panel-header-text');
      var mrrGraphsPanelHeader = $('#formPanel_<%=pnlTop10MMR.ClientID%> .x-panel-header-text');
      var subscriptionsGraphsPanelHeader = $('#formPanel_<%=pnlTop10Subs.ClientID%> .x-panel-header-text');

      recentOfferingHeader.css('font-size', '12px');
      recentRateChangeHeader.css('font-size', '12px');
      myRecentRateChangeHeader.css('font-size', '12px');
      mrrGraphsPanelHeader.css('font-size', '12px');
      subscriptionsGraphsPanelHeader.css('font-size', '12px');
      
      $(last30daysSpan).insertAfter(recentOfferingHeader);
      $(last30daysSpan).insertAfter(recentRateChangeHeader);
      $(last30daysSpan).insertAfter(myRecentRateChangeHeader);
      
      $(monthNameSpan).insertAfter(mrrGraphsPanelHeader);
      $(monthNameSpan).insertAfter(subscriptionsGraphsPanelHeader);
    }
    
    function appendNoDataText(divId, chartWidth, chartHeight, txt) {
      var svg = d3.select(divId).append('svg').attr('width', chartWidth).attr('height', chartHeight);
      svg.append("text")
        .attr("x", chartWidth / 2)
        .attr("y", chartHeight / 2)
        .style("text-anchor", "middle")
        .style("fill", "gray")
        .text(txt);
    }
    
    function appendDefs(rowChart) {
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
    }
    function makeTop10MRRPart() {
      document.getElementById('MRRGraphs').style.visibility = "visible";
      
	  var tooltipDivWidth = 200;
      var data = [];
      var fnData = function(x) 
      {
        x.ordernum = +x.ordernum;
        x.mrr = +x.mrr;
        x.productcode = +x.productcode;
        x.mrrchange = +x.mrrchange;
        x.mrrprevious = +x.mrrprevious;      
      };      
      
      //MRR TOTAL
      var fnDim = function(d) {
        return d.ordernum; // d.productname;
      };
      var fnGroup = function(d) {
        return d.mrr;
      };
      var fnMRRToolTipFormatter = function(d) {
        var html = String.format("<div style='width:{3}px;'><div class=ProductCode style='width:{3}px; word-wrap:break-word'>{1}</div><div class=Information style='padding-top:2px; width:{3}px; word-wrap:break-word'>{0}: {2}</div></div>", "<%=MrrTooltipText%>", d.productname, d.mrrAsString.replace("&pound", "£"), tooltipDivWidth);
        return html;
      };
      
      var top10MRRChartConfig = {
        operation: "AnalyticsTopMRR",
        divId: "#divTop10MRRTotal",
        dataConversionFn: fnData,
        dimensionFn: fnDim,
        groupFn: fnGroup,
        color: "#0070c0",
        demoData: data,
        graphTitleId: "#MRRTotalGraphTitle",
        graphTitleText: "<%=MrrTotalGraphTitle%>",
        toolTipFormatterFn: fnMRRToolTipFormatter
      };
      visualizeRowChart(top10MRRChartConfig);

      //MRR GAIN
      fnGroup = function (d) {
        return d.mrrchange;
      };
      var fnMRRGainLossToolTipFormatter = function(d) {
        var perMRRChange = (d.mrrprevious != 0) ? ((d.mrrabschange/d.mrrprevious)*100) : 0;
        var localizedperMRRChange = parseFloat(perMRRChange).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 });
        var html = String.format("<div class=ProductCode style='width:{1}px; word-wrap:break-word'>{0}</div>", d.productname, tooltipDivWidth);
        html += (d.mrrprevious == 0) ? String.format("<div class=Information style='padding-top:2px; width:{2}px; word-wrap:break-word'>{0}: {1} </div>", "<%=MrrTooltipText%>", d.mrrAsString.replace("&pound", "£"), tooltipDivWidth)
                                     : String.format("<div class=Information style='padding-top:2px; width:{5}px; word-wrap:break-word'>{0}: {1} <img src='/Res/Images/icons/arrow-{3}.png' style='vertical-align:{4};'/> {2}%</div>", "<%=MrrTooltipText%>", d.mrrAsString.replace("&pound", "£"), localizedperMRRChange, d.mrrchange > 0 ? "up":"down", d.mrrchange > 0 ? "text-bottom":"middle", tooltipDivWidth);
        html += String.format("<div class=Information style='width:{2}px; word-wrap:break-word'>{0}: {1} </div>", d.mrrchange > 0 ?  "<%=GainTooltipText%>" : "<%=LossTooltipText%>", d.mrrabschangeAsString, tooltipDivWidth);
        return String.format("<div style='width:{1}px;'>{0}</div>", html, tooltipDivWidth);
      };
      var top10MRRGainChartConfig = {
        operation: "AnalyticsTopMRRGain",
        divId: "#divTop10MRRGain",
        dataConversionFn: fnData,
        dimensionFn: fnDim,
        groupFn: fnGroup,
        color: "#148622",
        demoData: data,
        graphTitleId: "#MRRGainGraphTitle",
        graphTitleText: "<%=MrrGainGraphTitle%>",
        toolTipFormatterFn: fnMRRGainLossToolTipFormatter
      };
      visualizeRowChart(top10MRRGainChartConfig);
      
      //MRR LOSS
      fnGroup = function (d) {
        return -(d.mrrchange);
      };
      var top10MRRLossChartConfig = {
        operation: "AnalyticsTopMRRLoss",
        divId: "#divTop10MRRLoss",
        dataConversionFn: fnData,
        dimensionFn: fnDim,
        groupFn: fnGroup,
        color: "#C00",
        demoData: data,
        graphTitleId: "#MRRLossGraphTitle",
        graphTitleText: "<%=MrrLossGraphTitle%>",
        toolTipFormatterFn: fnMRRGainLossToolTipFormatter
      };
      visualizeRowChart(top10MRRLossChartConfig);
      
    }

    

    function makeTop10SubsPart() {
      document.getElementById('SubscriptionGraphs').style.visibility = "visible";

	  var tooltipDivWidth = 200;
      var data = [];
      var fnData = function(x) {
        x.ordernum = +x.ordernum;
        x.productcode = +x.productcode;
        x.subscriptions = +x.subscriptions;
        x.subscriptionsprevious = +x.subscriptionsprevious;
        x.subscriptionschange = +x.subscriptionschange;
      };
      
      //SUBS TOTAL
      var fnDim = function(d) {
        return d.ordernum; 
      };
      var fnGroup = function(d) {
        return d.subscriptions;
      };
      var fnSubscriptionsToolTipFormatter = function(d) {
        var localizedSubscriptions = parseFloat(d.subscriptions).toLocaleString(CURRENT_LOCALE);
        var html = String.format("<div style='width:{3}px;'><div class=ProductCode style='width:{3}px; word-wrap:break-word'>{1}</div><div class=Information style='padding-top:2px; width:{3}px; word-wrap:break-word'>{0}: {2}</div></div>", "<%=SubscriptionsTooltipText%>", d.productname, localizedSubscriptions, tooltipDivWidth);
        return html;
      };      
      var top10SubscriptionsChartConfig = {
        operation: "AnalyticsTopSubscriptions",
        divId: "#divTop10SubsTotal",
        dataConversionFn: fnData,
        dimensionFn: fnDim,
        groupFn: fnGroup,
        color: "#0070c0",
        demoData: data,
        graphTitleId: "#TopSubsGraphTitle",
        graphTitleText: "<%=TopSubsGraphTitle%>",
        hideFractionTicks: true,        
		    toolTipFormatterFn: fnSubscriptionsToolTipFormatter
      };
      visualizeRowChart(top10SubscriptionsChartConfig);
      
      //SUBS GAIN
      fnGroup = function (d) {
        return d.subscriptionschange;
      };
      var fnSubscriptionsGainLossToolTipFormatter = function(d) {
        var localizedSubscriptions = parseFloat(d.subscriptions).toLocaleString(CURRENT_LOCALE);
        var localizedSubscriptionChangeValue = parseFloat(d.subscriptionsabschange).toLocaleString(CURRENT_LOCALE);
        var perSubscriptionsChange = (d.subscriptionsprevious != 0) ? ((d.subscriptionsabschange/d.subscriptionsprevious)*100) : 0;
        var localizedperSubscriptionsChange = parseFloat(perSubscriptionsChange).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 });
        var html = String.format("<div class=ProductCode style='width:{1}px; word-wrap:break-word'>{0}</div>", d.productname, tooltipDivWidth);
        html += (d.subscriptionsprevious == 0) ? String.format("<div class=Information style='padding-top:2px; width:{2}px; word-wrap:break-word'>{0}: {1} </div>", "<%=SubscriptionsTooltipText%>", localizedSubscriptions, tooltipDivWidth)
                                               : String.format("<div class=Information style='padding-top:2px; width:{5}px; word-wrap:break-word'>{0}: {1} <img src='/Res/Images/icons/arrow-{3}.png' style='vertical-align:{4};'/> {2}%</div>", "<%=SubscriptionsTooltipText%>", localizedSubscriptions, localizedperSubscriptionsChange, d.subscriptionschange > 0 ? "up":"down", d.subscriptionschange > 0 ? "text-bottom":"middle", tooltipDivWidth);
        html += String.format("<div class=Information style='width:{2}px; word-wrap:break-word'>{0}: {1} </div>", d.subscriptionschange > 0 ? "<%=GainTooltipText%>" : "<%=LossTooltipText%>", localizedSubscriptionChangeValue, tooltipDivWidth);
        return String.format("<div style='width:{1}px;'>{0}</div>", html, tooltipDivWidth);
      };
      var top10SubscriptionsGainChartConfig = {
        operation: "AnalyticsTopSubscriptionGain",
        divId: "#divTop10SubsGain",
        dataConversionFn: fnData,
        dimensionFn: fnDim,
        groupFn: fnGroup,
        color: "#148622",
        demoData: data,
        graphTitleId: "#TopSubsGainGraphTitle",
        graphTitleText: "<%=TopSubsGainGraphTitle%>",
        hideFractionTicks: true,
		    toolTipFormatterFn: fnSubscriptionsGainLossToolTipFormatter
      };      
      visualizeRowChart(top10SubscriptionsGainChartConfig);
      
      //SUBS LOSS
      fnGroup = function (d) {
        return -(d.subscriptionschange);
      };
      var top10SubscriptionsLossChartConfig = {
        operation: "AnalyticsTopSubscriptionLoss",
        divId: "#divTop10SubsLoss",
        dataConversionFn: fnData,
        dimensionFn: fnDim,
        groupFn: fnGroup,
        color: "#C00",
        demoData: data,
        graphTitleId: "#TopSubsLossGraphTitle",
        graphTitleText: "<%=TopSubsLossGraphTitle%>",
        hideFractionTicks: true,
		    toolTipFormatterFn: fnSubscriptionsGainLossToolTipFormatter
      };      
      visualizeRowChart(top10SubscriptionsLossChartConfig);

    }

    <%--
    function makeTop10UniqueCustomersPart() {
      
      var data = [];
/*      data.push({ productcode: 1, subscriptions: 7000, productname: "500 Free Minutes",newcustomers:"125" });
      data.push({ productcode: 2, subscriptions: 9200, productname: "Simple Web" ,newcustomers:"30"});
*/

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
/*      data.push({ productcode: 1, subscriptions: 7000, productname: "500 Free Minutes",newcustomers:"125" });
      data.push({ productcode: 2, subscriptions: 9200, productname: "Simple Web" ,newcustomers:"30"});
      data.push({ productcode: 3, subscriptions: 1040, productname: "On-Demand Cloud" ,newcustomers:"10"});
      data.push({ productcode: 4, subscriptions: 500, productname: "Pre-paid Cloud" ,newcustomers:"11"});
      data.push({ productcode: 5, subscriptions: 600, productname: "Campaign Manager" ,newcustomers:"25"});
      data.push({ productcode: 6, subscriptions: 250, productname: "Wholesale offer for Cloud10",newcustomers:"60" });
      data.push({ productcode: 7, subscriptions: 10000, productname: "Cloud10 WebSite Offer",newcustomers:"200" });
      data.push({ productcode: 8, subscriptions: 300, productname: "Content Squared Revenue Share contract",newcustomers:"59" });
*/

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

      var fnData = function(x) {
        x.revenue = +x.revenue;
      };
      
      var fnDim = function(d) {
        return d.ordernum; //d.productname;
      };

      var fnGroup = function(d) {
        return d.revenue;
      };

      visualizeRowChart("AnalyticsSingleProductOverTime", "#divTop10Revenue", fnData, fnDim, fnGroup, createTop10RevenueTitle, "#0070c0", data, null, null);
    }

     --%>
    var gridster;

    $(function () {

      gridster = $(".gridster ul").gridster({
        widget_base_dimensions: [100, 25],
        widget_margins: [5, 5],
        helper: 'clone',
        resize: { enabled: false },
        autogrow_cols: true,
        min_rows: 30,
        min_cols: 9,
      }).data('gridster').disable();
    });
  </script>
</asp:Content>

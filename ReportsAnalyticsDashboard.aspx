<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  Inherits="ReportsAnalyticsDashboard" Title="MetraNet" CodeFile="ReportsAnalyticsDashboard.aspx.cs" %>

<%@ Import Namespace="System.Globalization" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="ReportsAnalyticsDashboardPage" ContentPlaceHolderID="ContentPlaceHolder1"
  runat="Server">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dashboard.css">

  <script type="text/javascript" src="MetraControl/ControlCenter/js/D3Visualize.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <script  type="text/javascript" src="/Res/JavaScript/d3.tip.js"></script>
  <style>
   
    .dc-chart g.row text {
    fill: black;
    cursor: pointer;
    font: bold 11px tahoma,arial,verdana,sans-serif;
  }
   .x-panel-bwrap,.x-panel-body, 
   #formPanel_<%=pnlBilling.ClientID%>
   #formPanel_<%=pnlMRR.ClientID%>
   #formPanel_<%=pnlNewCustomers.ClientID%>
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
    
    .d3-tip .Period {
        font-weight: bold;
    }
  </style>
  <div class="CaptionBar" style="color: #ddd;font-size: 150%;">
    <asp:Label ID="Label1" runat="server" meta:resourcekey="MTTitle1Resource1">Finance Dashboard</asp:Label>
  </div>
  <br />
  <div class="gridster" width="100%" height="100%">
    <ul width="100%" height="100%" id="gridsterul" style="width: 100%; align: left;">
    <li data-row="1" data-col="1" data-sizex="3" data-sizey="8" height="100%" >
      <MT:MTPanel ID="pnlBilling" runat="server" Text="Billing" Collapsed="False" 
          Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlBillingResource1" >
        <div class="remaining-graphs span8">
          <div>
            <div id="divRevenueChartDd" style="visibility: hidden">
              <span id="spnSelectCurrency" runat="server"></span>
              <select id="selRevenueCurrency" style="width: 100px;"></select>
            </div>
          </div>
          <br/>
          <div class="row-fluid">
            <div id="RevenueChart" class="pie-graph span4 dc-chart" style="float: none !important;">
            </div>
          </div>
        </div>  
      </MT:MTPanel>
  </li>
  <li data-row="12" data-col="1" data-sizex="3" data-sizey="8" height="100%" >
      <MT:MTPanel ID="pnlMRR" runat="server" Text="MRR" Collapsed="False" 
          Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlMRRResource1" >
         <div class="remaining-graphs span8">
          <br/>
          <div class="row-fluid">
          <div id="MRRChart" class="pie-graph span4 dc-chart" style="float: none !important;">
          </div>
        </div>
        </div>
      </MT:MTPanel>
  </li>
  <li data-row="22" data-col="1" data-sizex="3" data-sizey="8" height="100%" style="padding-top: 14px">
      <MT:MTPanel ID="pnlNewCustomers" runat="server" Text="New Customers" Collapsed="False" 
          Collapsible="True" EnableChrome="True" 
          meta:resourcekey="pnlNewCustomersResource1" >
        <div class="remaining-graphs span8">
          <br/>
          <div class="row-fluid">
            <div id='NewCustomersChart' class="pie-graph span4 dc-chart" style="float: none !important;">
            </div>
          </div>
        </div>        
      </MT:MTPanel>
  </li>
  </ul>
  </div>

  <br />
  <script type="text/javascript">
      
    var ToolTipDivWidth = 150;
    var RevenueChartId = "#RevenueChart";
    var RevenueChartDdDivId = "#divRevenueChartDd";
    var RevenueChartDdId = "#selRevenueCurrency";
    var MRRChartId = "#MRRChart";
    var NewCustomersChartId = "#NewCustomersChart";
    var RevenueJSONData;      

    var Margin = {top: 10,right: 50,bottom: 30,left: 55},
        Width = 920 - Margin.left - Margin.right,
        Height = 340 - Margin.top - Margin.bottom,
        PreviousMonth = getUTCDate(new Date(<%= previousMonth %>)),
        FirstMonth = getUTCDate(new Date(<%= firstMonth %>));
          

    function populateCurrencyDd(JSONData, selectId, currencyFieldName, localizedCurrencyFieldName) {
      
      var currencies = [];
      var localizedCurrencies = [];
      $.each(JSONData, function(){
    	  if ($.inArray(this[currencyFieldName],currencies) === -1) {
    		  currencies.push(this[currencyFieldName]);
    	    localizedCurrencies.push([this[currencyFieldName], this[localizedCurrencyFieldName]]);
    	  }
      });

      for (var i=0; i<localizedCurrencies.length; i++)
      {
        $(selectId).append($('<option>', {
                                              value: localizedCurrencies[i][0],
                                              text:localizedCurrencies[i][1]
                                              }));
      }
      d3.select(RevenueChartDdDivId).style("visibility", "visible");
    }

   Ext.onReady(function () {

      $(RevenueChartDdId).change(function() {
        $(RevenueChartDdId +  " option:selected" ).val();
        renderRevenueChart(RevenueChartId, RevenueChartDdId, RevenueJSONData);
      });

      getRevenue();
      getMRR();
      getNewCustomers();
      setWidgetTitles();
    });
    
    function setWidgetTitles() {
      var billingPanelHeader = $('#formPanel_<%=pnlBilling.ClientID%> .x-panel-header-text');
      var mrrPanelHeader = $('#formPanel_<%=pnlMRR.ClientID%> .x-panel-header-text');
      var newCustomersPanelHeader = $('#formPanel_<%=pnlNewCustomers.ClientID%> .x-panel-header-text');
      
      billingPanelHeader.css('font-size', '12px');
      mrrPanelHeader.css('font-size', '12px');
      newCustomersPanelHeader.css('font-size', '12px');
    }

    function getUTCDate(dateForConvert) {
      return new Date(dateForConvert.getUTCFullYear(), dateForConvert.getUTCMonth(), dateForConvert.getUTCDate(),dateForConvert.getUTCHours(), dateForConvert.getUTCMinutes(), dateForConvert.getUTCSeconds());
    }

    function getRevenue() {
      $.ajax({
        type: 'GET',
        async: true,
        timeout: 10000,
        dataType: 'json',
        url: 'AjaxServices/VisualizeService.aspx?operation=RevenueReport&_=' + new Date().getTime(),
        success: function(data) {
          RevenueJSONData = data.Items;
          if (RevenueJSONData.length == 0) {
            appendNoDataText(RevenueChartId, RevenueChartDdDivId);
            return;
          }
          populateCurrencyDd(RevenueJSONData, RevenueChartDdId, "currency", "localizedCurrency");
          renderRevenueChart(RevenueChartId, RevenueChartDdId, RevenueJSONData);
        },
        error: function () {
          console.log("RevenueReport - Error getting Data");
        }
      });
    };

    function appendNoDataText(divId, ddDivId) {
      var svg = d3.select(divId).append('svg').attr('width', Width).attr('height', Height);
      svg.append("text")
        .attr("x", Width / 2)
        .attr("y", Height / 2)
        .style("text-anchor", "middle")
        .style("fill", "gray")
        .text("<%=Convert.ToString(GetLocalResourceObject("TEXT_NO_DATA_AVAILABLE"))%>");
      if (ddDivId != null) {
        d3.select(ddDivId).style("visibility", "hidden");
      }
    }

    function renderRevenueChart(divId, ddId, JSONData) {
      var revenueChart = dc.barChart(divId);
      var currentCurrency = $( ddId + " option:selected" ).val();
      var currentCurrencyLocalized = $( ddId + " option:selected" ).text();
      
      var ndx = crossfilter(JSONData),
          runDimension = ndx.dimension(function(d) {return new Date(Date.parse(d.date)); }),
          currencyGroup = runDimension.group().reduceSum(function(d) {if (d.currency == currentCurrency) return d.amount;return 0;});
      
      revenueChart.width(Width)
        .height(Height)
        .margins(Margin)
        .x(d3.time.scale().domain([FirstMonth, PreviousMonth]))
        .round(d3.time.month.round)
        .xUnits(d3.time.months)
        .brushOn(false)
        .elasticY(true)
        .dimension(runDimension)
        .group(currencyGroup, currentCurrency)
        .barPadding(0.1)
        .outerPadding(0.05)
        .transitionDuration(1500)
        .centerBar(true)
        .gap(15)
        .legend(dc.legend().x(800).y(0))
        .xAxis().tickFormat(d3.time.format("%b-%Y"));
      revenueChart.render();
      
      d3.select(divId + " svg").selectAll(" .axis text").text(function (d) {
        return localizeRevenueChartAxes(d);
      });
      d3.select(divId + " svg").selectAll(" .dc-legend text").text(function(d) {
        return currentCurrencyLocalized;
      });
      
      // tooltips
      var toolTip = d3.tip()
            .attr('class', 'd3-tip')
            .offset([0, 10])
            .direction('e')
            .html(function (d) {
              return getRevenueChartTooltipHtml(JSONData, d, currentCurrency);
            });
      var toolTipSelector = 'div' + divId + '.dc-chart rect';
      d3.selectAll(toolTipSelector).call(toolTip);
      d3.selectAll(toolTipSelector).on('mouseover', toolTip.show)
                                    .on('mouseout', toolTip.hide);
      
    }

    function getRevenueChartTooltipHtml(JSONData, d, currentCurrency) {
      if (d.data == null) return null;
      var currentItem = getDataItem(JSONData, d.data.key, currentCurrency);
      var html = (currentItem != null) ? String.format("<div style='width:{0}px;'><div class=Period>{1}</div><div>{2}</div></div>", ToolTipDivWidth, currentItem.period, currentItem.amountAsString) : null;
      return html;
    }
    
    function localizeRevenueChartAxes(d) {
       var tickDate = new Date(Date.parse(d));
        var month = tickDate.getMonth();
        var year = tickDate.getFullYear();
        
        if (Object.prototype.toString.call(d) === "[object Date]") {
          return getLocalizedTickText(month, year);  
        } else {
          return parseFloat(d).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 });;
        }
    }

    function getDataItem(JSONData, key, currentCurrency) {
      for (var i = 0; i < JSONData.length; i++) {
        if ((((new Date(Date.parse(JSONData[i].date))) - key) == 0) && JSONData[i].currency == currentCurrency)  {
          return JSONData[i];
        }
      }
      return null;
    }
    
    function getLocalizedTickText(month, year) {
      var tickTextFormat = "{0}-{1}";
      var tickText = "";
      switch(month+1) {
        case 1:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(1)%>", year);
          break;
        case 2:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(2)%>", year);
          break;
        case 3:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(3)%>", year);
          break;
        case 4:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(4)%>", year);
          break;
        case 5:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(5)%>", year);
          break;
        case 6:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(6)%>", year);
          break;
        case 7:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(7)%>", year);
          break;
        case 8:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(8)%>", year);
          break;
        case 9:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(9)%>", year);
          break;
        case 10:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(10)%>", year);
          break;
        case 11:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(11)%>", year);
          break;
        case 12:
          tickText = String.format(tickTextFormat, "<%=DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(12)%>", year);
          break;          
      }
      return tickText;
    }
    
    function getMRR() {
      $.ajax({
        type: 'GET',
        async: true,
        dataType: 'json',
        timeout: 10000,
        url: 'AjaxServices/VisualizeService.aspx?operation=MRRReport&_=' + new Date().getTime(),
        success: function(data) {
          var mrrJSONData = data.Items;
          if (mrrJSONData.length == 0) {
            appendNoDataText(MRRChartId, null);
            return;
          }          
          renderMRRChart(MRRChartId , mrrJSONData);
        },
        error: function() {
          console.log("MRRReport - Error getting Data");
        }
      });
    };

    function renderMRRChart(divId, data) {

      var currentCurrency = data[0].currency;
      
      var mrrChart = dc.barChart(divId);
      var ndx = crossfilter(data);

      var mrrValue = ndx.dimension(function(d) {
        return new Date(Date.parse(d.date));
      });
      
      var currencyGroup = mrrValue.group().reduceSum(function(d) {
        if (d.currency == currentCurrency) return d.amount;
        return 0;
      });

      mrrChart.width(Width)
        .height(Height)
        .dimension(mrrValue)
        .group(currencyGroup, currentCurrency)
        .transitionDuration(350)
        .margins(Margin)
        .centerBar(true)
        .gap(10)
        .round(d3.time.month.round)
        .x(d3.time.scale().domain([FirstMonth, PreviousMonth]))
        .brushOn(false)
        .title(function(d){return d.value;})
        .elasticY(true)
        .xUnits(d3.time.months)
        .legend(dc.legend().x(800).y(0))
        .xAxis().tickFormat(d3.time.format("%b-%Y"));
          
      mrrChart.render();
    }

    function getNewCustomers() {
      $.ajax({
        type: 'GET',
        async: true,
        dataType: 'json',
        timeout: 10000,
        url: 'AjaxServices/VisualizeService.aspx?operation=NewCustomersReport&_=' + new Date().getTime(),
        success: function (data) {
          var newCustomersJSONData = data.Items;
          if (newCustomersJSONData.length == 0) {
            appendNoDataText(NewCustomersChartId, null);
            return;
          }  
          renderNewCustomersChart(NewCustomersChartId, newCustomersJSONData);
        },
        error: function () {
          console.log("NewCustomersReport - Error getting Data");
        }
      });
    };

    function renderNewCustomersChart(divId, JSONData) {

      var newCustomersChart = dc.barChart(divId);
      var ndx = crossfilter(JSONData);

      var startValue = ndx.dimension(function(d) {
        return new Date(Date.parse(d.date));
      });
      var startValueGroup = startValue.group();

      newCustomersChart.width(Width)
        .height(Height)
        .dimension(startValue)
        .group(startValueGroup, "New Customers")
        .transitionDuration(1000)
        .margins(Margin)
        .centerBar(true)
        .gap(15)
        .round(d3.time.month.round)
        .x(d3.time.scale().domain([FirstMonth, PreviousMonth]))
        .brushOn(false)
        .title(function(d){return d.value;})
        .xUnits(d3.time.months)
        .legend(dc.legend().x(680).y(0))
        .elasticY(true)
        .xAxis().tickFormat(d3.time.format("%b-%Y"));
          
      newCustomersChart.render();
    }
    var gridster;

    $(function () {

      gridster = $(".gridster ul").gridster({
        widget_base_dimensions: [300, 25],
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

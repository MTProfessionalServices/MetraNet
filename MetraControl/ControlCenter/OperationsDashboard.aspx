<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
    CodeFile="OperationsDashboard.aspx.cs" Inherits="OperationsDashboard" Title="Operations Dashboard"
    Culture="auto" UICulture="auto" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
    TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <!--script type="text/javascript" src="js/d3.legend.js"></script-->
    <script type="text/javascript" src="js/D3Visualize.js"></script>
    <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
    <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
    <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
    <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
    <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
    <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
    <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
    <style>
        .legend rect
        {
            fill: white;
            stroke: black;
            opacity: 0.8;
        }
        
        .axis path, .axis line
        {
            fill: none;
            stroke: #7F7F7F;
            shape-rendering: crispEdges;
        }
		
        .arc path
        {
            stroke: #7F7F7F;
        }
        
        .line
        {
            fill: none;
        }
        
        .label
        {
            text-align: right;
        }
        
        .clszerovalue
        {
            border-style: solid;
            border-width: medium;
            border-color: #7F7F7F;
            font-size: 15px;
            color: #7F7F7F;
            background: white;
        }
        
        .clshasvalue
        {
            border-style: solid;
            border-width: medium;
            border-color: #7F7F7F;
            font-size: 15px;
            font-weight: bold;
            color: #FF0000;
            background: white;
        }
        
        .divleftfloat
        {
            float: left;
            width: 399px;
        }
        
        .divrightfloat
        {
            float: right;
            width: 399px;
        }
        
        
        
        .barchart text
        {
            fill: black;
            font: 4px sans-serif;
            text-anchor: end;
        }

#formPanel_ctl00_ContentPlaceHolder1_pnlPendingBillClose {
  width: 100% !important;
  height: 100% !important;
}

#formPanel_ctl00_ContentPlaceHolder1_pnlFailedAdapters {
  width: 100% !important;
  height: 100% !important;
}

#formPanel_ctl00_ContentPlaceHolder1_pnlRunningAdapters {
  width: 100% !important;
  height: 100% !important;
}

#grid-container_ctl00_ContentPlaceHolder1_grdPendingBillClose {
  width: 100% !important;
  height: 100% !important;
}

#grid-container_ctl00_ContentPlaceHolder1_grdFailedAdapters {
  width: 100% !important;
  height: 100% !important;
}

#grid-container_ctl00_ContentPlaceHolder1_grdRunningAdapters {
  width: 100% !important;
  height: 100% !important;
}

.x-panel-bwrap {
  width: 100%;
  height: 100%;
}

.x-panel-body {
  width: 100% !important;
  height: 100% !important;
  padding: 0px !important;
}

#gridsterul {
  position: static !important;
}
    </style>
    <MT:MTTitle ID="MTTitle1" Text="Operations Dashboard" runat="server" meta:resourcekey="MTTitle1Resource1" />
    <br />
    <div class="gridster" width="100%" height="100%">
	<ul width="100%" height="100%" id="gridsterul" style="width:100%; align:left;">
            <li data-row="1" data-col="1" data-sizex="4" data-sizey="9" width="100%">
                <MT:MTPanel ID="pnlFailedTransactionsQueue" runat="server" Text="Failed Transactions Queue"
                    Width="430" Height="305">
                    <table>
                        <tr width="100%">
                            <td rowspan="2">
                                <div id="div30DayAging" width="100%" height="100%">
                                </div>
                            </td>
                            <td>
                                <div id="divTotalTransactions" width="100%" height="50%">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td align="center">
                                <div id="divOverXDays" width="100%" height="75%">
                                    <table>
                                        <tr>
                                            <td align="center">
                                                <MT:MTLabel ID="lblOverXDays" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td id="tdOverXDays" class="clshasvalue" width="100%" height="40px" valign="middle"
                                                align="center">
                                                <MT:MTLabel ID="txtOverXDays" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </td>
                    </table>
                </MT:MTPanel>
            </li>
            <li data-row="1" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlBatchUsage" runat="server" Text="Usage Data Records" Width="430"
                    Height="305">
                    <table>
                        <tr width="100%">
                            <td width="70%" height="100%">
                                <div id="divBatchUsage" width="100%" height="100%">
                                </div>
                            </td>
                            <td width="40%" height="100%">
                                <div id="divLastBatch" width="100%" height="75%">
                                    <table>
                                        <tr>
                                            <td align="center">
                                                <MT:MTLabel ID="lblLastBatch" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td id="tdLastBatch" class="clshasvalue" width="100%" height="40px" valign="middle"
                                                align="center">
                                                <MT:MTLabel ID="txtLastBatchDate" runat="server" />
                                                <br />
                                                <MT:MTLabel ID="txtLastBatchTime" runat="server" />
                                                <br />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </td>
                    </table>
                </MT:MTPanel>
            </li>
            <li data-row="10" data-col="1" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlPricingQueue" runat="server" Text="Pricing Queue"
                    Width="430" Height="305">
					<div id="divPricingQueues">
					</div>
                </MT:MTPanel>
            </li>
            <li data-row="10" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlPricingBacklog" runat="server" Text="Pricing Engine (Real-Time and Batch)"
                    Width="430" Height="305">
                    <div id="divPricingBacklog">
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="19" data-col="1" data-sizex="8" data-sizey="9">
                <MT:MTPanel ID="pnlActiveBillRun" runat="server" Text="Active Bill Run" Width="870"
                    Height="315">
                     <div>
                        <MT:MTDropDown ID="ddActiveBillRun" runat="server" AllowBlank="False" HideLabel="True"
                            Listeners="{}" ReadOnly="False">
                        </MT:MTDropDown>
                    </div>
                    <div id="divActiveBillRun">
                        <table>
                            <tr>
                                <td width="30%">
                                    <table>
                                        <tr>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td align="center">
                                                            <MT:MTLabel ID="lblFailedAdapters" runat="server" Text="Failed Adapters" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td id="tdFailedAdapters" class="clshasvalue" width="75px" height="50px" valign="middle"
                                                            align="center">
                                                            <MT:MTLabel ID="txtFailedAdapters" runat="server" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td class="label">
                                                            <MT:MTLabel ID="lblSuccessful" runat="server" Text="Successful:" />
                                                        </td>
                                                        <td>
                                                            <MT:MTLabel ID="txtSuccessful" runat="server" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            <MT:MTLabel ID="lblReady" runat="server" Text="Ready:" />
                                                        </td>
                                                        <td>
                                                            <MT:MTLabel ID="txtReady" runat="server" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            <MT:MTLabel ID="lblWaiting" runat="server" Text="Waiting:" />
                                                        </td>
                                                        <td>
                                                            <MT:MTLabel ID="txtWaiting" runat="server" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td rowspan="2">
                                    <svg id="svgActiveBillRun"></svg>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <table>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblVariance" runat="server" Text="Variance:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtVariance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblEarliestETA" runat="server" Text="Earliest ETA:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtEarliestETA" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                </td>
                                <td>
                                    <svg id="svgActiveBillRunLegend" height="30">      
                                    </svg>
                                </td>
                            </tr>
                        </table>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="28" data-col="1" data-sizex="4" data-sizey="9" height="100%">
                <MT:MTPanel ID="pnlPendingBillClose" runat="server" Text="Pending Bill Close" Width="430"
                    Height="305">
                    <div height="100%" style="height: 248px">
                        <MT:MTFilterGrid ID="grdPendingBillClose" runat="Server" ExtensionName="SystemConfig"
                            TemplateFileName="Dashboard.PendingBillCloses.xml" Width="100%" Height="100%">
                        </MT:MTFilterGrid>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="28" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlBillCloseSynopsis" runat="server" Text="Bill Close Synopsis" Width="430"
                    Height="305">
                    <div style="width: 399px;">
                        <MT:MTDropDown ID="ddBillCloses" runat="server" AllowBlank="False" HideLabel="True"
                            Listeners="{}" ReadOnly="False">
                        </MT:MTDropDown>
                    </div>
                    <div style="width: 399px" height="100%">
                        <table>
                            <tr>
                                <td width="50%">
                                    <table>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisType" runat="server" Text="Type:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtBillCloseSynopisType" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisBillGroups" runat="server" Text="Bill Groups:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtBillCloseSynopisBillGroups" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisStart" runat="server" Text="Start:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtBillCloseSynopisStart" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisEnd" runat="server" Text="End:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtBillCloseSynopisEnd" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" valign="middle" align="center">
                                                <MT:MTLabel ID="lblBillCloseSynopisDaysUntilRun" runat="server" Text="Days Until Run" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="50px" valign="middle" align="center" colspan="2" class="clshasvalue">
                                                <MT:MTLabel ID="txtBillCloseSynopisDaysUntilRun" runat="server" Text="1" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    <div id="divBillCloseSynopsis">
                                    </svg>
                                </td>
                            </tr>
                        </table>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="37" data-col="1" data-sizex="3" data-sizey="7">
                <MT:MTPanel ID="pnlFailedAdapters" runat="server" Text="Failed Adapters" Width="320"
                    Height="235">
                    <div height="100%" style="height: 128px">
                        <MT:MTFilterGrid ID="grdFailedAdapters" runat="Server" ExtensionName="SystemConfig"
                            TemplateFileName="Dashboard.FailedAdapters.xml">
                        </MT:MTFilterGrid>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="37" data-col="4" data-sizex="3" data-sizey="7">
                <MT:MTPanel ID="pnlRunningAdapters" runat="server" Text="Running Adapters" Width="320"
                    Height="235">
                    <div height="100%" style="height: 128px">
                        <MT:MTFilterGrid ID="grdRunningAdapters" runat="Server" ExtensionName="SystemConfig"
                            TemplateFileName="Dashboard.RunningAdapters.xml">
                        </MT:MTFilterGrid>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="37" data-col="7" data-sizex="2" data-sizey="7">
                <MT:MTPanel ID="pnlPuppetNodes" runat="server" Text="Puppet Nodes" Width="210" Height="235">
                      <a href="https://puppet-corp1" target="_blank">Puppet Master</a>
                      
                      <div id="divPuppetNodes">
                        <svg class="barchart" id="svgPuppetNodes"> </svg>
                    </div>
                  
                </MT:MTPanel>
            </li>
        </ul>
    </div>
    <script type="text/javascript">
// Custom Renderers
OverrideRenderer_<%= grdPendingBillClose.ClientID %> = function(cm)
{   
  cm.setRenderer(cm.getIndexById('id_interval'), IntervalStatusLinkRenderer);
};
OverrideRenderer_<%= grdFailedAdapters.ClientID %> = function(cm)
{   
  cm.setRenderer(cm.getIndexById('name'), AdapterStatusLinkRenderer);
};
OverrideRenderer_<%= grdRunningAdapters.ClientID %> = function(cm)
{   
  cm.setRenderer(cm.getIndexById('name'), AdapterStatusLinkRenderer);
};

AdapterStatusLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
{
  var str = "";
  str += String.format("<a style='cursor:hand;' href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/AdapterManagement.Instance.ViewEdit.asp|ID={0}", record.data.id_instance);
  if (record.data.id_billgroup)
  {
	str += String.format("**BillingGroupId={0}", record.data.id_billgroup);
  }
  if (record.data.id_interval)
  {
	str += String.format("**IntervalId={0}", record.data.id_interval);
  }
  str += String.format("**ReturnUrl=%2FMetraNet%2FMetraControl%2FControlCenter%2FOperationsDashboard%2Easpx'>{0}</a>", value);
  
  return str;
};      

IntervalStatusLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
{
  var str = "";
  str += String.format("<a style='cursor:hand;' href='/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/IntervalManagement.asp|ID={0}", record.data.id_interval);
  str += String.format("**ReturnUrl=%2FMetraNet%2FMetraControl%2FControlCenter%2FOperationsDashboard%2Easpx'>{0}</a>", value);
  
  return str;
};      
    </script>
    <script type="text/javascript">
        Ext.onReady(function () {
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlFailedTransactionsQueue').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(0), 4, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlFailedTransactionsQueue').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(0), 4, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlBatchUsage').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(1), 4, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlBatchUsage').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(1), 4, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPricingQueue').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(2), 4, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPricingQueue').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(2), 4, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPricingBacklog').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(3), 4, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPricingBacklog').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(3), 4, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlActiveBillRun').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(4), 8, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlActiveBillRun').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(4), 8, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPendingBillClose').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(5), 4, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPendingBillClose').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(5), 4, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlBillCloseSynopsis').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(6), 4, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlBillCloseSynopsis').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(6), 4, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlFailedAdapters').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlFailedAdapters').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3, 7); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlRunningAdapters').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(8), 3, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlRunningAdapters').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(8), 3, 7); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPuppetNodes').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(9), 2, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlPuppetNodes').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(9), 2, 7); });
        });
    </script>
    <script type="text/javascript">

        var dayFormat = d3.time.format("%A, %B %e");
        var dateFormat = d3.time.format("%m/%d/%Y %I:%M:%S %p");
        var numberFormat = d3.format(",");
        var currencyFormat = d3.format("$,.0f");
        var percentageFormat = d3.format(".1%");

	Ext.onReady(function () {

        d3.select("#<%=ddBillCloses.ClientID %>").on("change", makeBillCloseSynopsisPart);
       
        //Failed transaction area
        makeFailedTransactionsQueuePart();
        //Usage Data Area
        makeBatchUsagePart();
        makeActiveBillRunsPart();
        makePendingBillClosePart();
        makeBillCloseSynopsisPart();
        makePuppetNodePart();
		makePricingEnginePart();

    });

    function makePendingBillClosePart() {
    }
    
    function makeFailedTransactionsQueuePart() {
        
        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() +"&operation=ft30dayaging", function (error, data) {
            if (error) console.log("Error:" + error.valueOf());
            else {
            data.Items.forEach(function (d) {
                d.fixed_count = +d.fixed_count;
                d.open_count = +d.open_count;
                d.under_investigation_count = +d.under_investigation_count;
                d.days_old = -d.days_old;
            });
            var ndx = crossfilter(data.Items);
            var all = ndx.groupAll();
            var dateDimension = ndx.dimension(function(d){return d.days_old;});
            var fixGroup = dateDimension.group().reduceSum(function(d){return d.fixed_count;});
            var openGroup = dateDimension.group().reduceSum(function(d){return d.open_count;});
            var uiGroup = dateDimension.group().reduceSum(function(d){return d.under_investigation_count;});
			/*
            var composite = dc.compositeChart("#div30DayAging");
            composite
                    .margins({top: 5, right: 5, bottom: 40, left: 5})
					.height(255)
					.width(400)
                    .x(d3.scale.linear().domain([-30,0]))
                    .elasticY(true)
                    .transitionDuration(0)
                    .legend(dc.legend().x(15).y(225).itemHeight(13).gap(5))
                    .brushOn(false)
					.renderHorizontalGridLines(true)
                    .title("Open", function(d){ return -d.key + " days back: " + numberFormat(d.value) + " Open";});
                    .title("Under Investigation", function(d){ return -d.key + " days back: " + numberFormat(d.value) + " Under Investigation";});
                    .compose([
                        dc.lineChart(composite)
                                .dimension(dateDimension)
                                .group(openGroup, "Open")
                                .colors('#0070C0')
                        ,
                        dc.lineChart(composite)
                                .dimension(dateDimension)
                                .group(uiGroup, "Under Investigation")
                                .colors('#148622')
                    ])
					;
			composite.xAxis().tickSize(0,0).tickFormat("");
            composite.xAxis().tickSize(0,0).tickFormat("");

            composite.render();
			*/
            var chart = dc.barChart("#div30DayAging");
            chart
                    .margins({top: 5, right: 5, bottom: 40, left: 5})
					.height(255)
					.width(410)
                    .x(d3.scale.linear().domain([-30,0]))
                    .elasticY(true)
                    .transitionDuration(0)
                    .legend(dc.legend().x(15).y(225).itemHeight(13).gap(5))
					.renderHorizontalGridLines(true)
                    .brushOn(false)
                    .dimension(dateDimension)
					.group(openGroup, "Open")
                    .colors('#0070C0')
                    .stack(uiGroup, "Under Investigation")
//                                .colors('#148622')
                    .title("Open", function(d){ return -d.key + " days back: " + numberFormat(d.value) + " Open";})
                    .title("Under Investigation", function(d){ return -d.key + " days back: " + numberFormat(d.value) + " Under Investigation";})
					.renderlet(function (_chart) {
						function setStyle(selection, keyName) {
							selection.style("fill", function (d) {
								if (d[keyName] == "Open")
									return "#0070C0";
								else if (d[keyName] == "Under Investigation")
									return "#148622";
							});
						}
						// set the fill attribute for the bars
						setStyle(_chart
								.selectAll("g.stack")
								.selectAll("rect.bar")
							, "layer"
						);
						// set the fill attribute for the legend
						setStyle(_chart
								.selectAll("g.dc-legend-item")
								.selectAll("rect")
							, "name"
						);
					})
					.renderHorizontalGridLines(true)
			;
            chart.xAxis().tickSize(0,0).tickFormat("");
            chart.yAxis().tickSize(0,0).tickFormat("");

            chart.render();
						
			dc.renderAll();
			}
			});

/*
        //Pie Chart
        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() + "&operation=ftgettotal", function (error, json) {
            if (error) console.log(error.valueOf());
            else {
			var data = [];
			json.Items.forEach(function (d) {
                d.numcount = +d.numcount;
            });
            var ndx = crossfilter(json.Items);
            var all = ndx.groupAll();
            var typeDimension = ndx.dimension(function(d){return d.name;});
            var countGroup = typeDimension.group().reduceSum(function(d){return d.numcount;});

			var chart = dc.pieChart("#divTotalTransactions")
					.height(150)
					.width(150)
					.ordinalColors(["#148622","#0070C0"])
                    .dimension(typeDimension)
                    .group(countGroup)
                    .transitionDuration(0)
					.render()
					;
            }
        });

*/
        //Overage Days

        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() + "&operation=ftoverxdays&threshold=<%=failedUdrCleanupThreshold%>", function (error, json) {
            if (error) console.log("Error:" + error.valueOf());
            else {
                var overXDaysData = json["Items"];
                if (overXDaysData[0]["count_over_set_days"] != null) {
                    var value = overXDaysData[0]["count_over_set_days"];

                    if(value == 0){
                        d3.select("#tdOverXDays").attr("class","clszerovalue");
                     }
                    else{
                         d3.select("#tdOverXDays").attr("class","clshasvalue");
                    }


                   d3.select("#<%=txtOverXDays.ClientID%>").text(value);

                   d3.select("#<%=txtOverXDays.ClientID%>").style("cursor","pointer");
                  d3.select("#<%=txtOverXDays.ClientID%>").on("click",function(){window.location="/MetraNet/MetraControl/FailedTransactions/FailedTransactionsView.aspx?Filter_FailedTransactionList=N";});
                 

                }
            }
        });
    }

    function makeBatchUsagePart() {
        var maxDate = new Date();
        var minDate = new Date();
        minDate.setDate(maxDate.getDate() - 30);
        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() +"&operation=batchusage30day", function (error, data) {
            if (error) console.log("Error:" + error.valueOf());
            else {
            data.Items.forEach(function (d) {
                d.udr_count = +d.udr_count;
                d.batch_count = +d.batch_count;
                d.day_no = +d.day_no;
                d.dd = dateFormat.parse(d.calendardate);
            });
            var ndx = crossfilter(data.Items);
            var all = ndx.groupAll();
            var dateDimension = ndx.dimension(dc.pluck('dd'));
            var batchGroup = dateDimension.group().reduceSum(dc.pluck('batch_count'));
            var udrGroup = dateDimension.group().reduceSum(dc.pluck('udr_count'));

            var composite = dc.compositeChart("#divBatchUsage");
            composite
                    .margins({top: 5, right: 5, bottom: 40, left: 5})
					.height(255)
					.width(410)
                    .x(d3.time.scale().domain([minDate, maxDate]))
                    .elasticY(true)
                    .transitionDuration(0)
                    .legend(dc.legend().x(15).y(225).itemHeight(13).gap(5))
					.renderHorizontalGridLines(true)
                    .brushOn(false)
					.title("UDRs", function(d){return dayFormat(d.key) + ": " + numberFormat(d.value) + " UDRs";})
					.title("Batches", function(d){return dayFormat(d.key) + ": " + numberFormat(d.value) + " Batches";})
                    .compose([
                        dc.lineChart(composite)
                                .dimension(dateDimension)
                                .group(udrGroup, "UDRs")
                                .colors('#0070C0')
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){return dayFormat(d.key) + ": " + numberFormat(d.value) + " UDRs";})
                        ,
                        dc.lineChart(composite)
                                .dimension(dateDimension)
                                .group(batchGroup, "Batches")
                                .colors('#148622')
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.useRightYAxis(true)
								.title(function(d){return dayFormat(d.key) + ": " + numberFormat(d.value) + " Batches";})
                    ])
					;
			composite.xAxis().tickSize(0,0).tickFormat("");
			composite.yAxis().tickSize(0,0).tickFormat("");
			composite.rightYAxis().tickSize(0,0).tickFormat("");

            composite.render();
			composite.redraw();
			dc.renderAll();
			}
        });

        //Recent Batch

        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() + "&operation=getlastbatch", function (error, json) {
            if (error) console.log("Error:" + error.valueOf());
            else {
                var lastBatchInfo = json["Items"];
                if (lastBatchInfo[0] != null) {
                    var timediff = lastBatchInfo[0]["time diff"];
                      var lastbatchdate = lastBatchInfo[0]["date"];
                     var lastbatchtime = lastBatchInfo[0]["time"];
                     var lastbatchid = lastBatchInfo[0]["batchid"];
                  
                   
                    if(timediff <= <%=udrBatchFrequencyThreshold%>){
 
                        d3.select("#tdLastBatch").attr("class","clszerovalue");
                     }
                    else{
                         d3.select("#tdLastBatch").attr("class","clshasvalue");
                    }
                   
                   
                   d3.select("#<%=txtLastBatchDate.ClientID%>").text(lastbatchdate);
                      
                   d3.select("#<%=txtLastBatchTime.ClientID%>").text(lastbatchtime);
                  
                  
                  d3.select("#<%=txtLastBatchDate.ClientID%>").style("cursor","pointer");
                  d3.select("#<%=txtLastBatchDate.ClientID%>").on("click",function(){window.location="/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/BatchManagement.ViewEdit.asp?ID=" + lastbatchid;});
                  
                   d3.select("#<%=txtLastBatchTime.ClientID%>").style("cursor","pointer");
                  d3.select("#<%=txtLastBatchTime.ClientID%>").on("click",function(){window.location="/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/BatchManagement.ViewEdit.asp?ID=" + lastbatchid;});
               
                         

                }
            }
        });

    }


    function makeActiveBillRunsPart() {
        var objActiveBillRunLineChartConfig = {
            width: 400,
            height: 207,
            margin: { left: 40, top: 20, right: 20, bottom: 20 },
            yAxis: {"Label":"Duration","IgnoreColumns": ["adapter"]},
            xAxis: {"Label":"Adapter","Column":"rownumber"},
            parentElementId: "#divActiveBillRun",
            elementId: "#svgActiveBillRun",
            chartTitle: "Current vs 3 Month Average",
            colordata:{
                "duration":"#148622",
                "average":"#FFC000"
        
            }

            
        };

        var activeBillRunInterval = d3.select("#<%=ddActiveBillRun.ClientID %>").node().value;


         d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() +"&operation=activebillrun&intervalid=" + activeBillRunInterval, function (error, json) {
            if (error)
                console.log(error.valueOf);
            else {
                objActiveBillRunLineChartConfig.data = json["Items"];
                
                fnVisualizeLineChart2(objActiveBillRunLineChartConfig);
            }
        });


        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() +"&operation=activebillrunsummary&intervalid=" + activeBillRunInterval, function (error, json) {
            if (error)
                console.log(error.valueOf);
            else {
                
                var activebillrunsummary = json["Items"];
                if (activebillrunsummary[0] != null) {
                    var successful = activebillrunsummary[0]["eop_succeeded_adapter_count"];
                    var failed = activebillrunsummary[0]["eop_failed_adapter_count"];
                    var waiting = activebillrunsummary[0]["eop_nyr_adapter_count"];
                    var ready = activebillrunsummary[0]["eop_rtr_adapter_count"];
                    var variance = activebillrunsummary[0]["variance"];
                    var earliesteta = activebillrunsummary[0]["earliest_eta"];
                 
                   
                 }

                  if(failed == 0){
 
                        d3.select("#tdFailedAdapters").attr("class","clszerovalue");
                     }
                    else{
                         d3.select("#tdFailedAdapters").attr("class","clshasvalue");
                    }

                     d3.select("#<%=txtFailedAdapters.ClientID%>").text(failed);
                      d3.select("#<%=txtSuccessful.ClientID%>").text(successful);
                      d3.select("#<%=txtWaiting.ClientID%>").text(waiting);
                      d3.select("#<%=txtReady.ClientID%>").text(ready);
                      d3.select("#<%=txtVariance.ClientID%>").text(variance);
                      d3.select("#<%=txtEarliestETA.ClientID%>").text(earliesteta);

                      d3.select("#<%=txtFailedAdapters.ClientID%>").style("cursor","pointer");
                      d3.select("#<%=txtFailedAdapters.ClientID%>").on("click",function(){window.location="/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/IntervalManagement.asp?ID=" + activeBillRunInterval;});
                  

            }
        });


        var legenddata = [
          {
            "x_axis": 40,
            "y_axis": 10,
            "color": "#FFC000",
            "text": "3 Month Average"
          },
          {
            "x_axis": 40,
            "y_axis": 20,
             "color": "#148622",
            "text": "Current Run"
          }
            ]

         
        CreateLegend(legenddata,d3.select("#svgActiveBillRunLegend"));

    }


     function makePricingEnginePart() {
        var ndx;
        var all;
		var dateDimension;
        var maxDate = new Date();
        var minDate = new Date();
		var realMaxDate;
		maxDate.setMonth(maxDate.getMonth() - 10);
		minDate.setMonth(minDate.getYear() + 10);
		d3.json("/MetraNet/AjaxServices/PricingEngineDashboardService.aspx?_=" + new Date().getTime(), function (error, json) {
            if (error) console.log("Error:" + error.valueOf());
            else {
            json.Items.forEach(function (d) {
                d.pipe_q = +d.pipe_q;
                d.msgq_q = +d.msgq_q;
                d.scheduler_q = +d.scheduler_q;
                d.pipe_backlog = +d.pipe_backlog;
                d.pipe = +d.pipe;
                d.dd = dateFormat.parse(d.date);
				if (d.dd > maxDate) maxDate = d.dd;
				if (d.dd < minDate) minDate = d.dd;
            });
			maxDate = new Date(maxDate);
			realMaxDate = new Date(maxDate);
			maxDate.setSeconds(maxDate.getSeconds() + 200);
            ndx = crossfilter(json.Items);
            all = ndx.groupAll();
            dateDimension = ndx.dimension(function(d){return d.dd;});
            var pipeQGroup = dateDimension.group().reduceSum(dc.pluck('pipe_q'));
            var msgqQGroup = dateDimension.group().reduceSum(dc.pluck('msgq_q'));
            var schedulerQGroup = dateDimension.group().reduceSum(dc.pluck('scheduler_q'));
			var colors = d3.scale.ordinal().domain([0,1,2]).range(['#00B0F0','#0070C0','#148622']);
            var composite1 = dc.compositeChart("#divPricingQueues");
            composite1
                    .margins({top: 5, right: 5, bottom: 75, left: 5})
					.height(255)
					.width(410)
                    .x(d3.time.scale().domain([minDate, maxDate]))
                    .elasticY(true)
                    .transitionDuration(750)
					.renderHorizontalGridLines(true)
                    .legend(dc.legend().x(15).y(200).itemHeight(13).gap(5))
                    .brushOn(false)
 					.title("Pipeline Queue", function(d){ return numberFormat(d.value) + " messages waiting to be assigned"; })
					.title("RAMP Queue", function(d){ return numberFormat(d.value) + " messages waiting in RabbitMQ"; })
					.title("Scheduler Queue", function(d){ return numberFormat(d.value) + " tasks waiting to be processed"; })
                   .compose([
                        dc.lineChart(composite1)
                                .dimension(dateDimension)
                                .group(pipeQGroup, "Pipeline Queue")
                                .colors(colors(0))
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return numberFormat(d.value) + " messages waiting to be assigned"; })
                        ,
                        dc.lineChart(composite1)
                                .dimension(dateDimension)
                                .group(msgqQGroup, "RAMP Queue")
                                .colors(colors(1))
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return numberFormat(d.value) + " messages waiting in RabbitMQ"; })
                        ,
                        dc.lineChart(composite1)
                                .dimension(dateDimension)
                                .group(schedulerQGroup, "Scheduler Queue")
                                .colors(colors(2))
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return numberFormat(d.value) + " tasks waiting to be processed"; })
                    ]);
            composite1.xAxis().tickSize(0,0).tickFormat("");
            composite1.yAxis().tickSize(0,0).tickFormat("");
			
            var pipeBacklogGroup = dateDimension.group().reduceSum(dc.pluck('pipe_backlog'));
            var pipeGroup = dateDimension.group().reduceSum(dc.pluck('pipe'));
            var msgqGroup = dateDimension.group().reduceSum(dc.pluck('msgq'));
            var rampBacklogGroup = dateDimension.group().reduceSum(dc.pluck('ramp_backlog'));
            var rampGroup = dateDimension.group().reduceSum(dc.pluck('ramp'));
            var composite2 = dc.compositeChart("#divPricingBacklog");
			colors = d3.scale.ordinal().domain([0,1,2,3,4]).range(['#00B0F0','#0070C0','#148622','#FFC000','#7F7F7F']);
            composite2
                    .margins({top: 5, right: 5, bottom: 75, left: 5})
					.height(255)
					.width(410)
                    .x(d3.time.scale().domain([minDate, maxDate]))
                    .elasticY(true)
                    .transitionDuration(750)
                    .legend(dc.legend().x(45).y(200).itemHeight(13).gap(5))
                    .brushOn(false)
					.renderHorizontalGridLines(true)
					.title("Pipeline Wait Duration", function(d){ return numberFormat(d.value) + " seconds waiting to be assigned"; })
					.title("Pipeline Processing Duration", function(d){ return numberFormat(d.value) + " seconds processing in the pipeline"; })
                    .compose([
                        dc.lineChart(composite2)
                                .dimension(dateDimension)
                                .group(pipeBacklogGroup, "Pipeline Wait Duration")
                                .colors(colors(0))
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return numberFormat(d.value) + " seconds waiting to be assigned"; })
                        ,
                        dc.lineChart(composite2)
                                .dimension(dateDimension)
                                .group(pipeGroup, "Pipeline Processing Duration")
                                .colors(colors(1))
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return numberFormat(d.value) + " seconds processing in the pipeline"; })
                    ])
			;
            composite2.xAxis().tickSize(0,0).tickFormat("");
            composite2.yAxis().tickSize(0,0).tickFormat("");
			
			dc.renderAll();
			
            setInterval(function() {
		d3.json("/MetraNet/AjaxServices/PricingEngineDashboardService.aspx?_=" + new Date().getTime(), function (error, json) {
            if (error) console.log("Error:" + error.valueOf());
            else {
            json.Items.forEach(function (d) {
                d.pipe_q = +d.pipe_q;
                d.msgq_q = +d.msgq_q;
                d.scheduler_q = +d.scheduler_q;
                d.pipe_backlog = +d.pipe_backlog;
                d.pipe = +d.pipe;
                d.dd = dateFormat.parse(d.date);
				if (d.dd > realMaxDate) realMaxDate = d.dd;
				if (d.dd < minDate) minDate = d.dd;
            });
			ndx.add(json.Items);
			if (((realMaxDate.getTime() - minDate.getTime() )/1000) > 200)
			{
			var otherDate = new Date(maxDate);
			otherDate.setSeconds(otherDate.getSeconds() - 200);
			dateDimension.filterRange([minDate,otherDate]);
			ndx.remove();
			dateDimension.filterAll();
			minDate = otherDate;
			maxDate = realMaxDate;
			}
			composite1.x(d3.time.scale().domain([minDate, maxDate]));
			composite2.x(d3.time.scale().domain([minDate, maxDate]));
			dc.renderAll();
			}});
            }, 10000);
			}
        });

	}


    function makeBillCloseSynopsisPart(){

        var colordata = {
            "Fixed":"#1F497D",
            "Open":"#148622",
            "Under Investigation":"#0070C0",
            "Unguided":"#7F7F7F"
        };
        
   
        var billCloseInterval = d3.select("#<%=ddBillCloses.ClientID %>").node().value;


        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() +"&operation=billclosedetails&intervalid=" + billCloseInterval, function (error, json) {
            if (error)
                console.log(error.valueOf);
            else {
                
            json.Items.forEach(function (d) {
                d.count = +d.count;
            });
            var chart = dc.barChart("#divBillCloseSynopsis");
            var ndx = crossfilter(json.Items);
            var all = ndx.groupAll();
            var statusDimension = ndx.dimension(function(d){return d.status;});
            var countGroup = statusDimension.group().reduceSum(dc.pluck('count'));
            chart
                    .margins({top: 10, right: 10, bottom: 100, left: 60})
					.height(230)
                    .dimension(statusDimension)
					.transitionDuration(0)
                    .group(countGroup)
                    .xAxisPadding(15)
                    .gap(3)
                    .x(d3.scale.ordinal().domain(["Open", "Under Investigation", "Fixed", "Unguided"]))
					.xUnits(dc.units.ordinal)
                    .centerBar(false)
                    .brushOn(false)
					.renderHorizontalGridLines(true)
                    .title(function(d){ return d.key + ": " + numberFormat(d.value);} )
//                    .legend(dc.legend().x(40).y(100).itemHeight(13).gap(5))
					.colors(d3.scale.ordinal().domain([0,1,2,3,4]).range(['#00B0F0','#0070C0','#148622','#FFC000','#7F7F7F']))
                    .renderlet(function (chart) {
                        // rotate x-axis ticks
                        chart.selectAll("g.x text")
                                .style("text-anchor", "start")
                                .attr('dx', '.3em')
                                .attr('dy', '-.05em')
                                .attr('transform', "rotate(45)");
                        ;
                    })
            ;
            chart.yAxis().tickSize(0,0).tickFormat("");
            chart.xAxis().outerTickSize(0);
            dc.renderAll();
            }
        });


       //alert(billCloseInterval);

        d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() +"&operation=billclosesummary&intervalid=" + billCloseInterval, function (error, json) {
            if (error)
                console.log(error.valueOf);
            else {
                var billCloseSummary = json["Items"];
               
                if (billCloseSummary[0] != null) {
                    var type = billCloseSummary[0]["type"];
                    var billgroups = billCloseSummary[0]["billgroups"];
                    var start = billCloseSummary[0]["start"];
                    var end = billCloseSummary[0]["end"];
                    var daysuntilrun = billCloseSummary[0]["days_until_run"];
                  
                 
                   if(daysuntilrun == 0){
                        d3.select("#tdBillCloseSynopisDaysUntilRun").attr("class","clszerovalue");
                     }
                    else{
                         d3.select("#tdBillCloseSynopisDaysUntilRun").attr("class","clshasvalue");
                    }

                      d3.select("#<%=txtBillCloseSynopisType.ClientID%>").text(type);
                      d3.select("#<%=txtBillCloseSynopisBillGroups.ClientID%>").text(billgroups);
                      d3.select("#<%=txtBillCloseSynopisStart.ClientID%>").text(start);
                      d3.select("#<%=txtBillCloseSynopisEnd.ClientID%>").text(end);
                      d3.select("#<%=txtBillCloseSynopisDaysUntilRun.ClientID%>").text(daysuntilrun); 
                      d3.select("#<%=txtBillCloseSynopisDaysUntilRun.ClientID%>").style("cursor","pointer");
                      d3.select("#<%=txtBillCloseSynopisDaysUntilRun.ClientID%>").on("click",function(){window.location="/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/IntervalManagement.asp?ID=" + billCloseInterval;});
                                                

                }
            }
        });

    
        var legenddata = [
          {
            "x_axis": -100,
            "y_axis": 10,
            "color": "#1F497D",
            "text": "Fixed"
          },
          {
            "x_axis": -100,
            "y_axis": 20,
             "color": "#148622",
            "text": "Open"
          },
          {
            "x_axis": -100,
            "y_axis": 30,
            "color": "#0070C0",
            "text": "Under Investigation"
          },
          {
            "x_axis": -100,
            "y_axis": 40,
            "color": "#7F7F7F",
            "text": "Unguided"
          }
            ];

         
        CreateLegend(legenddata,d3.select("#svgBillCloseSynopsisLegend"));

   }

    function makePuppetNodePart(){
         var colordata = {
            "Unresponsive":d3.rgb(0,176,240),
            "Failed":d3.rgb(0,112,192),
            "Changed":d3.rgb(31,73,125),
            "Unchanged":d3.rgb(20,134,34),
            "Pending":d3.rgb(256,192,0)
        };
        
        var data = [
               {
                "name": "Unchanged",
                "value": 10
              },
              {
                "name": "Unresponsive",
                "value": 5
              },
              {
                "name": "Failed",
                "value": 6
              },
              {
                "name": "Pending",
                "value": 2
              },
             {
                "name": "Changed",
                "value": 10
              }
             
        ]

          /*var objPuppetBarChartConfig = {
            width: 201,
            height: 125,
            margin: { left: 20, top: 10, right: 10, bottom: 10 },
            xAxis: {"Label":"Nodes", "Column":"name"},
            yAxis: {"Label":"Type","Column":"value"},
            parentElementId: "#divPuppetNodes",
            elementId: "#svgPuppetNodes",
            chartTitle: "Puppet Status",
            data:data,
            colordata:colordata
        };

        fnVisualizeBarChart(  objPuppetBarChartConfig); */



        data.forEach(function (d) {
                d.value = +d.value;
            });
            var chart = dc.barChart("#divPuppetNodes");
            var ndx = crossfilter(data);
            var all = ndx.groupAll();
            var nameDimension = ndx.dimension(function(d){ return d["name"];});
                  
            var valueGroup = nameDimension.group().reduceSum(dc.pluck('value'));

            var colors = d3.scale.ordinal().domain(["Unchanged", "Unresponsive", "Failed", "Pending","Changed"]).range(['#00B0F0','#0070C0','#148622','#FFC000','#7F7F7F']);
                   
            chart
                    .height(125)
                    .margins({top: 10, right: 10, bottom: 50, left: 10})
                    .dimension(nameDimension)
					.transitionDuration(0)
                    .group(valueGroup)
                    .gap(3)
                    .xAxisPadding(20)
                    .x(d3.scale.ordinal().domain(["Unchanged", "Unresponsive", "Failed", "Pending","Changed"]))
					.xUnits(dc.units.ordinal)
                    .centerBar(false)
					.renderHorizontalGridLines(true)
                    .brushOn(false)
                    .title(function(d){ return d.key + ": " + numberFormat(d.value);} )
                   // .legend(dc.legend().x(40).y(100).itemHeight(13).gap(5))
					.renderlet(function (chart) {
                        // rotate x-axis ticks
                        chart.selectAll("g.x text")
                                .style("text-anchor", "start")
                                .attr('dx', '.3em')
                                .attr('dy', '-.05em')
                                .attr('transform', "rotate(45)");
                        ;

                        chart.selectAll("rect.bar").attr("fill", function(d){
                             return colordata[d.x];
                        });
                    });

             chart.yAxis().tickSize(0,0).tickFormat("");
             chart.xAxis().outerTickSize(0);
             
             dc.renderAll(valueGroup);

    }

    </script>
    <script type="text/javascript">
        var gridster;

        $(function () {

            gridster = $(".gridster ul").gridster({
                widget_base_dimensions: [100, 25],
                widget_margins: [5, 5],
                helper: 'clone',
                resize: { enabled: false },
				autogrow_cols: true,
				min_rows: 30,
            }).data('gridster');
        });
    </script>
</asp:Content>

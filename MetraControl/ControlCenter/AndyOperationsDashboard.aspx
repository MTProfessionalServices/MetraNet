<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="OperationsDashboard.aspx.cs" Inherits="OperationsDashboard" Title="Operations Dashboard" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 
   <script type="text/javascript" src="js/SampleData.js"></script>
   <script type="text/javascript" src="js/D3Visualize.js"></script>
 
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

</style>
               
<MT:MTTitle ID="MTTitle1" Text="Operations Dashboard" runat="server" meta:resourcekey="MTTitle1Resource1" />
<br />
    
 <table>
    <tr>
    <td class="x-table-layout-cell" colspan="3" >
             <MT:MTPanel ID="pnlFailedTransactionsQueue" runat="server" Text="Failed Transactions Queue">
                   <table>
                        <tr >
                            <td><svg id="svg30DayAging"></svg></td>
                            <td><svg id="svgTotalTransactions"></svg></td>
                            <td>
                                <table>
                                    <tr><td align="center"><MT:MTLabel ID="lblOverXDays" runat="server" /></td></tr>
                                    <tr><td style="border-style: solid; border-width: medium; border-color: inherit; font-size: 20px; font-weight: bold; 
                                            color: #FF0000;" width="100%" height="50px"  valign="middle" align="center"> 499 </td></tr>
                                </table>
                             </td>
                       </tr>
                   </table>
             </MT:MTPanel>
         </td>
    </tr>
    <tr>
        <td colspan="3">
             <MT:MTPanel ID="pnlBatchUsage" runat="server" Text="Usage Data Records">
              <div id="divBatchUsage" >
                   <table>
                        <tr >
                            <td><svg id="svg30DayBatches"></svg></td>
                            <td><svg id="svg30DayUDRs"></svg></td>
                            <td>
                                <table>
                                    <tr><td align="center"><MT:MTLabel ID="lblLastBatch" runat="server" /></td></tr>
                                    <tr><td style="border-style: solid; border-width: medium; border-color: inherit; font-size: 20px; font-weight: bold; color: #FF0000;" width="100%" height="50px"  valign="middle" align="center"> 
                                    <MT:MTLabel ID="txtLastBatch" runat="server" /></td></tr>
                                </table>
                             </td>
                       </tr>
                   </table>
                </div>

             </MT:MTPanel>
        </td>
    </tr>
    <tr>
        <td colspan="3">
             <MT:MTPanel ID="pnlPricingEngine" runat="server" Text="Pricing Engine (Real-Time and Batch)">
              <div id="divPricingEngine" >
                   <table>
                        <tr >
                            <td><svg id="svgPricingQueues"></svg></td>
                            <td><svg id="svgPricingBacklog"></svg></td>
                            <td><svg id="svgPricingTPS"></svg></td>
                       </tr>
                   </table>
                </div>

             </MT:MTPanel>
        </td>
    </tr>
    <tr>
        <td colspan="3">
             <MT:MTPanel ID="pnlActiveBillRun" runat="server" Text="Active Bill Run">

             <div id="divActiveBillRun" >
                   <table>
                        <tr >
                           <td>
                                <table>
                                    <tr><td align="center"><MT:MTLabel ID="lblFailedAdapters" runat="server" /></td></tr>
                                    <tr><td style="border-style: solid; border-width: medium; border-color: inherit; font-size: 20px; font-weight: bold; color: #FF0000;" width="100%" height="50px"  valign="middle" align="center"> 
                                    <MT:MTLabel ID="txtFailedAdapters" runat="server" /></td></tr>
                                </table>
                             </td>
                              <td>
                      
                              </td>
                            <td><svg id="svgActiveBillRun"></svg></td>
                    
                       </tr>
                   </table>
                </div>
             </MT:MTPanel>
        </td>
    </tr>
    <tr>
        <td>
             <MT:MTPanel ID="pnlPendingBillClose" runat="server" Text="Pending Bill Close">
             </MT:MTPanel>
         </td>
          <td>
             <MT:MTPanel ID="pnlBillCloseSynopsis" runat="server" Text="Bill Close Synopsis">
             </MT:MTPanel>
         </td>
     </tr>
     <tr>
        <td>
         <MT:MTPanel ID="pnlFailedAdapters" runat="server" Text="Failed Adapters">
            <MT:MTFilterGrid ID="grdFailedAdapters" 
                runat="Server" ExtensionName="SystemConfig" 
                TemplateFileName="Dashboard.FailedAdapters.xml" >
            </MT:MTFilterGrid>
        </MT:MTPanel>
        </td>
        <td>
        <MT:MTPanel ID="pnlRunningAdapters" runat="server" Text="Running Adapters">
                
        </MT:MTPanel>
        </td>
        <td>
        <MT:MTPanel ID="pnlPuppetNodes" runat="server" Text="Puppet Nodes">
            <div id="divPuppetNodes">
            </div>
        </MT:MTPanel>
        </td>
    </tr>
  </table>

    


<script type="text/javascript">

    Ext.onReady(function () {

        //Failed transaction area
        makeFailedTransactionsQueuePart();
        //Usage Data Area
        makeBatchUsagePart();
        makeActiveBillRunsPart();
        //makePendingBillClosePart();
        //makeBillCloseSynopsisPart();
        //makePuppetNodePart();
		makePricingEnginePart();

    });



    function makeFailedTransactionsQueuePart() {
        var obj30DayAgingLineChartConfig = {
            width: 300,
            height: 150,
            margin: { left: 20, top: 20, right: 20, bottom: 20 },
			data: thirtyDayAgingData.slice(),
            yAxisLabel: "Count",
            xAxisLabel: "Days",
            xAxisColumn: "Day",
            //ignoreColumns: ["Open"],
            parentElementId: "#divFailedTransactionQueue",
            elementId: "#svg30DayAging",
            chartTitle: "30 Day Aging"
        };

/*        d3.json("js/SampleData.js", function (error, json) {
            if (error) alert(error);
            obj30DayAgingLineChartConfig.data = json;
            fnVisualizeLineChart(obj30DayAgingLineChartConfig);
        });
*/

        var objTotalTransactionsPieChartConfig = {
            width: 300,
            height: 200,
            margin: { left: 20, top: 20, right: 20, bottom: 20 },
            data: totalTransactionData.slice(),
            segment: "Total",
            datafield: "Count",
            parentElementId: "#divFailedTransactionQueue",
            elementId: "#svgTotalTransactions",
            chartTitle: "Total"
        };


        fnVisualizePieChart(objTotalTransactionsPieChartConfig);
    }

    function makeBatchUsagePart() {
        var objBatchUsgaeLineChartConfig = {
            width: 250,
            height: 150,
            margin: { left: 20, top: 20, right: 20, bottom: 20 },
            data: thirtyDayBatchUsageData.slice(),
            yAxisLabel: "Count",
            xAxisLabel: "Days",
            xAxisColumn: "Day",
            ignoreColumns: ["UDRCount"],
            parentElementId: "#divBatchUsage",
            elementId: "#svg30DayBatches",
            chartTitle: "Number of Batches(last 30 days)"
        };


        new fnVisualizeLineChart(objBatchUsgaeLineChartConfig);

        objBatchUsgaeLineChartConfig.elementId = "#svg30DayUDRs";
        objBatchUsgaeLineChartConfig.chartTitle = "Number of UDRs(last 30 days)";
        objBatchUsgaeLineChartConfig.ignoreColumns = ["BatchCount"];

        new fnVisualizeLineChart(objBatchUsgaeLineChartConfig);

        
    }


    function makeActiveBillRunsPart() {
        var objActiveBillRunLineChartConfig = {
            width: 250,
            height: 150,
            margin: { left: 20, top: 20, right: 20, bottom: 20 },
            data: activeBillRunComparisonData.slice(),
            yAxisLabel: "Time",
            xAxisLabel: "Adapter",
            xAxisColumn: "ID",
            parentElementId: "#divActiveBillRun",
            elementId: "#svgActiveBillRun",
            chartTitle: ""
        };


        new fnVisualizeLineChart(objActiveBillRunLineChartConfig);


        
    }

    function makePricingEnginePart() {
        var objPricingQueueLineChartConfig = {
            width: 234,
            height: 150,
            margin: { left: 10, top: 20, right: 10, bottom: 20 },
            data: thirtyDayBatchUsageData.slice(),
            yAxisLabel: "Count",
//            xAxisLabel: "Days",
            xAxisColumn: "x",
            ignoreColumns: ["BatchCount"],
            parentElementId: "#divPricingEngine",
            elementId: "#svgPricingQueues",
            chartTitle: "Pricing Queues"
        };

        var objPricingBacklogLineChartConfig = {
            width: 234,
            height: 150,
            margin: { left: 10, top: 20, right: 10, bottom: 20 },
            data: thirtyDayBatchUsageData.slice(),
            yAxisLabel: "Count",
//            xAxisLabel: "Days",
            xAxisColumn: "x",
            ignoreColumns: ["BatchCount"],
            parentElementId: "#divPricingEngine",
            elementId: "#svgPricingBacklog",
            chartTitle: "Pricing Backlog"
        };

        var objPricingTPSLineChartConfig = {
            width: 234,
            height: 150,
            margin: { left: 10, top: 20, right: 10, bottom: 20 },
            data: thirtyDayBatchUsageData.slice(),
            yAxisLabel: "TPS",
//            xAxisLabel: "Days",
            xAxisColumn: "x",
            ignoreColumns: ["BatchCount"],
            parentElementId: "#divPricingEngine",
            elementId: "#svgPricingTPS",
            chartTitle: "Pricing Speed"
        };
		var objPricingQueueLineChart;
		var objPricingBacklogLineChart;
		var objPricingTPSLineChart;
		d3.json("/MetraNet/AjaxServices/PricingEngineDashboardService.aspx?_=" + new Date().getTime(), function (error, json) {
            if (error) alert(error);
			else {
				objPricingQueueLineChartConfig.data = json.queues;
				objPricingBacklogLineChartConfig.data = json.backlog;
				objPricingTPSLineChartConfig.data = json.tps;
				objPricingQueueLineChart = new fnVisualizeLineChart(objPricingQueueLineChartConfig);
				objPricingBacklogLineChart = new fnVisualizeLineChart(objPricingBacklogLineChartConfig);
				objPricingTPSLineChart = new fnVisualizeLineChart(objPricingTPSLineChartConfig);
				objPricingQueueLineChart.xAxis.ticks(5);
				objPricingBacklogLineChart.xAxis.ticks(5);
				objPricingTPSLineChart.xAxis.ticks(5);
			}
        });
		
		setInterval(function () {
		d3.json("/MetraNet/AjaxServices/PricingEngineDashboardService.aspx?_=" + new Date().getTime(), function (error, json) {
            if (error) alert(error);
			else {
				if (objPricingQueueLineChart.data.length >= 30) objPricingQueueLineChart.data.shift();
				objPricingQueueLineChart.data.push(json.queues[0]);
				if (objPricingBacklogLineChart.data.length >= 30) objPricingBacklogLineChart.data.shift();
				objPricingBacklogLineChart.data.push(json.backlog[0]);
				if (objPricingTPSLineChart.data.length >= 30) objPricingTPSLineChart.data.shift();
				objPricingTPSLineChart.data.push(json.tps[0]);

				objPricingQueueLineChart.updateData();
				objPricingBacklogLineChart.updateData();
				objPricingTPSLineChart.updateData();
			}
        });
		}, 5000);
	}

     function makeAjaxRequest(action, licenseaccountid, ownerid,effectivedate,errorText)
    {
        var parameters = { 
          action: action, 
          ids: licenseaccountid,
          ownerid: ownerid,
          effectivedate: effectivedate
        };

        // make the call back to the server
        Ext.Ajax.request({
                disableCaching: True,
                url: '/MetraNet/AjaxServices/AssignUnassignLicenses.aspx',
                params: parameters,
                scope: this,
                callback: function(options, success, response) {
                    if (success) {
                       
                           hideMe();
                           
                       
                    }
                    else
                    {
                        Ext.UI.SystemError(errorText);
                    }
                }
        });
    }
  

</script>


</asp:Content>





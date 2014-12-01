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
    <link rel="stylesheet" type="text/css" href="/Res/Styles/dashboard.css">
    <link rel="stylesheet" type="text/css" href="Styles/OperationsDashboard.css">


    <div class="CaptionBar" style="color: #ddd;font-size: 150%;">
    <asp:Label ID="Label1" runat="server" meta:resourcekey="MTTitle1Resource1">Operations Dashboard</asp:Label>
  </div>    
  <br />
  <div class="gridster" width="100%" height="100%">
	<ul width="100%" height="100%" id="gridsterul" style="width:100%; text-align:left;">
            <li data-row="1" data-col="1" data-sizex="4" data-sizey="9" width="100%">
                <MT:MTPanel ID="pnlFailedTransactionsQueue" runat="server" meta:resourcekey="pnlFailedTransactionsQueueResource"
                    Width="430" Height="325" Text="Failed Transactions Queue" Collapsible="True">
                
                       <div id="div30DayAging" class="base-bottom">
                          <div id="div30DayAgingInfo" class="corner-bottom">
                             <MT:MTLabel ID="lblOverXDays" runat="server" CssClass="label" />
                             <MT:MTLabel ID="txtOverXDays" runat="server"/>  
                          </div>
                          <!--other stuff inside base-->
                      </div>
                  
                </MT:MTPanel>
            </li>
            <li data-row="1" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlBatchUsage" runat="server" meta:resourcekey="pnlBatchUsageResource"
                   Text="Usage Data Records" Width="430" Height="325">
                   <div id="divBatchUsage" class="base-bottom">
                          <div id="divLastBatch" class="corner-bottom">
                             <MT:MTLabel ID="lblLastBatch" runat="server" CssClass="label" />
                              <MT:MTLabel ID="txtLastBatch" runat="server" />
                           </div>
                          <!--other stuff inside base-->
                      </div>
                  
                </MT:MTPanel>
            </li>
            <li data-row="10" data-col="1" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlPricingQueue" runat="server" Text="Pricing Queue" meta:resourcekey="pnlPricingQueue"
                    Width="430" Height="325">
					<div id="divPricingQueues">
					</div>
                </MT:MTPanel>
            </li>
            <li data-row="10" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlPricingBacklog" runat="server" Text="Pricing Engine (Real-Time and Batch)" meta:resourcekey="pnlPricingBacklog"
                    Width="430" Height="325">
                    <div id="divPricingBacklog">
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="19" data-col="1" data-sizex="8" data-sizey="9">
                <MT:MTPanel ID="pnlActiveBillRun" runat="server" meta:resourcekey="pnlActiveBillRun"
                    Text="Active Bill Run" Width="870" Height="325">
                     <div>
                        <MT:MTDropDown ID="ddActiveBillRun" runat="server" AllowBlank="False" HideLabel="True"
                            Listeners="{'select' : { fn: this.makeActiveBillRunsPart, scope: this }}" ReadOnly="False">
                        </MT:MTDropDown>
                    </div>
                    <div id="divActiveBillRun">
                        <table>
                            <tr>
                                <td width="30%">
                                    <table>
                                        <tr>
                                            <td>
                                                <table style="border-collapse:collapse;border:none">
                                                    <tr>
                                                        <td align="center" class="tbllabel" >
                                                            <MT:MTLabel ID="lblFailedAdapters" runat="server" Text="Failed Adapters"/>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td id="tdFailedAdapters" class="tblclshasvalue" width="75px" height="50px" valign="middle"
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
                                            <td colspan="2" style="text-align: left">
                                                <MT:MTLabel ID="txtVariance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" style="text-align: left">
                                                <MT:MTLabel ID="txtEarliestETA" runat="server" /><br/><br/>
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
                <MT:MTPanel ID="pnlPendingBillClose" runat="server" Text="Pending Bill Close" meta:resourcekey="pnlPendingBillClose"
                Width="430" Height="325">
                    <div height="100%" style="height: 248px">
                        <MT:MTFilterGrid ID="grdPendingBillClose" runat="Server" ExtensionName="SystemConfig"
                            TemplateFileName="Dashboard.PendingBillCloses.xml" Width="100%" Height="100%">
                        </MT:MTFilterGrid>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="28" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlBillCloseSynopsis" runat="server" Text="Bill Close Synopsis" meta:resourcekey="pnlBillCloseSynopsisResource" Width="430">
                    <div style="width: 399px; height: 27px">
                        <MT:MTDropDown ID="ddBillCloses" runat="server" AllowBlank="False" HideLabel="True"
                            Listeners="{'select' : { fn: this.makeBillCloseSynopsisPart, scope: this }}" ReadOnly="False">
                        </MT:MTDropDown>
                    </div>
                    <div style="width: 100%; height:230px">
                        <table style="width: 100%; height: 100%">
                            <tr>
                                <td width="30%" style="vertical-align:top">
                                    <table style="border-collapse:collapse;border:none">
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                       <%-- <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisType" runat="server" meta:resourcekey="lblBillCloseSynopisTypeResource" Text="Type:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtBillCloseSynopisType" runat="server" />
                                            </td>
                                        </tr>--%>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisBillGroups" runat="server" meta:resourcekey="lblBillCloseSynopisBillGroupsResource" Text="Bill Groups:" Width="80" />
                                            </td>
                                            <td style="vertical-align: bottom">
                                                <MT:MTLabel ID="txtBillCloseSynopisBillGroups" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisStart" runat="server" meta:resourcekey="lblBillCloseSynopisStartResource" Text="Start:" />
                                            </td>
                                            <td>
                                                <MT:MTLabel ID="txtBillCloseSynopisStart" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                <MT:MTLabel ID="lblBillCloseSynopisEnd" runat="server" meta:resourcekey="lblBillCloseSynopisEndResource" Text="End:" />
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
                                            <td colspan="2" valign="middle" align="center" class="tbllabel">
                                                <MT:MTLabel ID="lblBillCloseSynopisDaysUntilRun" runat="server" meta:resourcekey="lblBillCloseSynopisDaysUntilRunResource" Text="Days Until Run" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="50px" valign="middle" align="center" colspan="2" class="tblclshasvalue">
                                                <MT:MTLabel ID="txtBillCloseSynopisDaysUntilRun" runat="server" Text="1" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="70%" style="vertical-align:top">
                                    <svg height="100%" id="divBillCloseSynopsis"></svg>
                                </td>
                            </tr>
                        </table>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="37" data-col="1" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlFailedAdapters" runat="server" Text="Failed Adapters" meta:resourcekey="pnlFailedAdapters"
                Width="320" Height="325">
                    <div height="100%" style="height: 248px">
                        <MT:MTFilterGrid ID="grdFailedAdapters" runat="Server" ExtensionName="SystemConfig"
                            TemplateFileName="Dashboard.FailedAdapters.xml">
                        </MT:MTFilterGrid>
                    </div>
                </MT:MTPanel>
            </li>
            <li data-row="37" data-col="5" data-sizex="4" data-sizey="9">
                <MT:MTPanel ID="pnlRunningAdapters" runat="server" Text="Running Adapters" meta:resourcekey="pnlRunningAdapters"
                Width="320" Height="325">
                    <div height="100%" style="height: 248px">
                        <MT:MTFilterGrid ID="grdRunningAdapters" runat="Server" ExtensionName="SystemConfig"
                            TemplateFileName="Dashboard.RunningAdapters.xml">
                        </MT:MTFilterGrid>
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
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlFailedAdapters').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(7), 3, 9); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlRunningAdapters').on('collapse', function (e) { gridster.resize_widget(gridster.$widgets.eq(8), 3, 1); });
            Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_pnlRunningAdapters').on('expand', function (e) { gridster.resize_widget(gridster.$widgets.eq(8), 3, 9); });
            
        });
    </script>
    <script type="text/javascript">

        var dayFormat = d3.time.format("%A, %B %e");
        var dateFormat = d3.time.format("<%=DateFormatJs%>");
        var numberFormat = d3.format(",");
        var currencyFormat = d3.format("$,.0f");
        var percentageFormat = d3.format(".1%");

	Ext.onReady(function () {

        //d3.select("#<%=ddBillCloses.ClientID %>").on("change", makeBillCloseSynopsisPart);
       
        //Failed transaction area
        makeFailedTransactionsQueuePart();
        //Usage Data Area
        makeBatchUsagePart();
        makeActiveBillRunsPart();
        makePendingBillClosePart();
        makeBillCloseSynopsisPart();
		    makePricingEnginePart();

    });

    function makePendingBillClosePart() {
    }
    
    function makeFailedTransactionsQueuePart() {
        var chart = dc.barChart("#div30DayAging","30DayAging");
           
        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=ft30dayaging&curTime=" + new Date().getTime(), function (error, data) {
            if (error) console.log("Error:" + error);
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

             chart
                    .margins({top: 5, right: 5, bottom: 40, left: 5})
					          .height(255)
				            .width(410)
                    .x(d3.scale.linear().domain([-30,1]))
                    .elasticY(true)
                    .transitionDuration(0)
                    .legend(dc.legend().x(15).y(225).itemHeight(13).gap(5))
					          .renderHorizontalGridLines(true)
                    .brushOn(false)
                    .dimension(dateDimension)
					          .group(openGroup, "<%=OpenWord%>")
                    .stack(uiGroup, "<%=UnderInvestigationWord%>")
                    .title("<%=OpenWord%>", function(d){ return -d.key + " <%=DaysBackText%>: " + numberFormat(d.value) + " <%=OpenWord%>";})
                    .title("<%=UnderInvestigationWord%>", function(d){ return -d.key + " <%=DaysBackText%>: " + numberFormat(d.value) + " <%=UnderInvestigationWord%>";})
					          .renderlet(function (_chart) {
						          function setStyle(selection, keyName) {
							          selection.style("fill", function (d) {
								          if (d[keyName] == "<%=OpenWord%>")
								              return "#0070C0";
								          else if (d[keyName] == "<%=UnderInvestigationWord%>")
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
					          .renderHorizontalGridLines(true);
            
            chart.xAxis().tickSize(0,0).tickFormat("");
            chart.yAxis().tickSize(0,0).tickFormat("");
            chart.render();
						
			      dc.renderAll("30DayAging");
			  }
			});

/*
        //Pie Chart
        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() + "&operation=ftgettotal", function (error, json) {
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

        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=ftoverxdays&threshold=<%=failedUdrCleanupThreshold%>&curTime=" + new Date().getTime(), function (error, json) {
            if (error) console.log("Error:" + error);
            else {
                var overXDaysData = json["Items"];
                if (overXDaysData[0]["count_over_set_days"] != null) {
                  var value = overXDaysData[0]["count_over_set_days"];
                  var valueClass = "clshasvalue";

                  if (value == 0)
                    valueClass = "clszerovalue";
                  
                  
                   
                  var txtOverXDays = d3.select("#<%=txtOverXDays.ClientID%>");
                  

                  txtOverXDays.text(value)
                            .style("cursor","pointer")
                            .attr("class",valueClass)
                            .on("click",function(){window.location="/MetraNet/MetraControl/FailedTransactions/FailedTransactionsView.aspx?Filter_FailedTransactionList=N";});

                }
            }
        });
    }

    function makeBatchUsagePart() {
        var maxDate = new Date();
        var minDate = new Date();
        minDate.setDate(maxDate.getDate() - 30);
        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=batchusage30day&curTime=" + new Date().getTime(), function (error, data) {
            if (error) console.log("Error:" + error);
            else {
            data.Items.forEach(function (d) {
                d.udr_count = +d.udr_count;
                d.batch_count = +d.batch_count;
                d.day_no = +d.day_no;
                if (d.calendardate.search(".m.") != -1) {
                  d.calendardate = d.calendardate.split('.').join("").toUpperCase();
                }
                d.dd = dateFormat.parse(d.calendardate);
            });
            
            var ndx = crossfilter(data.Items);
            var all = ndx.groupAll();
            var dateDimension = ndx.dimension(dc.pluck('dd'));
            var batchGroup = dateDimension.group().reduceSum(dc.pluck('batch_count'));
            var udrGroup = dateDimension.group().reduceSum(dc.pluck('udr_count'));
            var options = { weekday: 'long', month: 'long', day: 'numeric' };

            var composite = dc.compositeChart("#divBatchUsage");
            composite
                    .margins({top: 5, right: 5, bottom: 40, left: 5})
                    .height(255)
                    .width(410)
                    .x(d3.time.scale().domain([minDate, maxDate.setDate(maxDate.getDate()+1)]))
                    .elasticY(true)
                    .transitionDuration(0)
                    .legend(dc.legend().x(15).y(225).itemHeight(13).gap(5))
                    .renderHorizontalGridLines(true)
                    .brushOn(false)
                    .title("<%=UDRsWord%>", function(d){return d.key.toLocaleString(CURRENT_LOCALE, options) + ": " + FormatNumber(d.value) + " <%=UDRsWord%>";})
                    .title("<%=BatchesWord%>", function(d){return d.key.toLocaleString(CURRENT_LOCALE, options) + ": " + FormatNumber(d.value) + " <%=BatchesWord%>";})
                    .compose([
                        dc.lineChart(composite)
                                .dimension(dateDimension)
                                .group(udrGroup, "<%=UDRsWord%>")
                                //.colors('#0070C0')
                                .renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
                                .title(function(d){return d.key.toLocaleString(CURRENT_LOCALE, options) + ": " + FormatNumber(d.value) + " <%=UDRsWord%>";})
                        ,
                        dc.lineChart(composite)
                                .dimension(dateDimension)
                                .group(batchGroup, "<%=BatchesWord%>")
                                .colors('#148622')
                                .renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
                                .title(function(d){return d.key.toLocaleString(CURRENT_LOCALE, options) + ": " + FormatNumber(d.value) + " <%=BatchesWord%>";})
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
        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=getlastbatch&curTime=" + new Date().getTime(), function (error, json) {
            if (error) console.log("Error:" + error);
            else {
                var lastBatchInfo = json["Items"];
                if (lastBatchInfo[0] != null) {
                    var timediff = lastBatchInfo[0]["time diff"];
                    var lastbatchdatetime = lastBatchInfo[0]["datetime"];
                    var lastbatchid = lastBatchInfo[0]["batchid"];
                  
                     var valueClass = "clshasvalue";


                  if (timediff <= <%=udrBatchFrequencyThreshold%>) {

                    valueClass = "clszerovalue";

                  }

                  var txtLastBatch = d3.select("#<%=txtLastBatch.ClientID%>");
                  

                  txtLastBatch.text(RenderDate(lastbatchdatetime, DATE_TIME_RENDERER))
                            .style("cursor","pointer")
                            .attr("class",valueClass)
                            .on("click",function(){window.location="/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/BatchManagement.ViewEdit.asp?ID=" + lastbatchid;});
             
                }
            }
        });

    }


    function makeActiveBillRunsPart() {
      var objActiveBillRunLineChartConfig = {
          width: 450,
          height: 200,
          margin: { left: 40, top: 20, right: 20, bottom: 20 },
          yAxis: {"Label":"<%=DurationWord%>","IgnoreColumns": ["adapter"]},
          xAxis: {"Label":"<%=AdapterWord%>","Column":"rownumber"},
          parentElementId: "#divActiveBillRun",
          elementId: "#svgActiveBillRun",
          chartTitle: "<%=CurrentVs3MonthAverageText%>",
          colordata:{
              "duration":"#148622",
              "average":"#FFC000"
          }
      };
      var activeBillRunInterval = d3.select("#<%=ddActiveBillRun.ClientID %>").node().value;
      var ajaxReqStr = "/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=activebillrun&intervalid=" + activeBillRunInterval + "&curTime=" + new Date().getTime();

      d3.json(ajaxReqStr, function (error, json) {
          if (error)
              console.log(error);
          else {
              objActiveBillRunLineChartConfig.data = json["Items"];
              fnVisualizeLineChart2(objActiveBillRunLineChartConfig);
          }
      });
      d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=activebillrunsummary&intervalid=" + activeBillRunInterval + "&curTime=" + new Date().getTime(), function (error, json) {
      if (error) {
        console.log(error);
      } else {
        var activebillrunsummary = json["Items"];
        var total, successful, failed, waiting, ready, variance, earliesteta, etaoffset, remaining;
        if (activebillrunsummary[0] != null) {
          total = activebillrunsummary[0]["eop_adapter_count"];
          successful = activebillrunsummary[0]["eop_succeeded_adapter_count"];
          failed = activebillrunsummary[0]["eop_failed_adapter_count"];
          waiting = activebillrunsummary[0]["eop_nyr_adapter_count"];
          ready = activebillrunsummary[0]["eop_rtr_adapter_count"];
          variance = activebillrunsummary[0]["varianceAsString"];
          earliesteta = activebillrunsummary[0]["earliest_eta"];
          etaoffset = activebillrunsummary[0]["eta_offset"];
        }

        if (failed == 0) {
          d3.select("#tdFailedAdapters").attr("class", "tblclszerovalue");
        } else {
          d3.select("#tdFailedAdapters").attr("class", "tblclshasvalue");
        }

        d3.select("#<%=txtFailedAdapters.ClientID%>").text(failed);
        d3.select("#<%=txtSuccessful.ClientID%>").text(successful);
        d3.select("#<%=txtWaiting.ClientID%>").text(waiting);
        d3.select("#<%=txtReady.ClientID%>").text(ready);

        var varianceAsFloat = parseFloat(variance);
        var textVariance = "";
        if (!isNaN(varianceAsFloat)) {
          if (Math.abs(varianceAsFloat) <= .5) textVariance = '<%=GetLocalResourceObject("TEXT_VARIANCE_SAME_MESSAGE")%>';
          else if (varianceAsFloat > 0) textVariance = String.format('<%=GetLocalResourceObject("TEXT_VARIANCE_SLOWER_MESSAGE")%>', Math.abs(varianceAsFloat).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 }));
          else if (varianceAsFloat < 0) textVariance = String.format('<%=GetLocalResourceObject("TEXT_VARIANCE_FASTER_MESSAGE")%>', Math.abs(varianceAsFloat).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 }));
        }
        d3.select("#<%=txtVariance.ClientID%>").text(textVariance);

        var textETA = "";
        remaining = total - successful;
        if (!isNaN(remaining)) {
          textETA = String.format('<%=GetLocalResourceObject("TEXT_EARLIEST_ETA")%>', remaining , etaoffset, earliesteta);
        }
        d3.select("#<%=txtEarliestETA.ClientID%>").text(textETA);
        d3.select("#<%=txtFailedAdapters.ClientID%>").style("cursor", "pointer");
        d3.select("#<%=txtFailedAdapters.ClientID%>").on("click", function() { window.location = "/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/IntervalManagement.asp?ID=" + activeBillRunInterval; });
      }
    });

    var legenddata = [
      {
        "x_axis": 40,
        "y_axis": 10,
        "color": "#FFC000",
            "text": "<%=ThreeMonthAverageText%>"
      },
      {
        "x_axis": 40,
        "y_axis": 20,
          "color": "#148622",
            "text": "<%=CurrentRunText%>"
      }
    ];

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
		d3.json("/MetraNet/AjaxServices/PricingEngineDashboardService.aspx?curTime=" + new Date().getTime(), function (error, json) {
            if (error) console.log("Error:" + error);
            else {
            json.Items.forEach(function (d) {
                d.pipe_q = +d.pipe_q;
                d.msgq_q = +d.msgq_q;
                d.scheduler_q = +d.scheduler_q;
                d.pipe_backlog = +d.pipe_backlog;
                d.pipe = +d.pipe;
                if (d.date.search(".m.") != -1) {
                  d.date = d.date.split('.').join("").toUpperCase();
                }
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
            var composite1 = dc.compositeChart("#divPricingQueues");
            composite1
                    .margins({top: 5, right: 5, bottom: 64, left: 5})
					.height(255)
					.width(410)
                    .x(d3.time.scale().domain([minDate, maxDate]))
                    .elasticY(true)
                    .transitionDuration(750)
					.renderHorizontalGridLines(true)
                    .legend(dc.legend().x(15).y(200).itemHeight(13).gap(5))
                    .brushOn(false)
 					.title("<%=pipelineQueueText%>", function(d){ return FormatNumber(d.value) + " " + "<%=pipelineQueueToolTipText%>"; })
					.title("<%=rampQueueText%>", function(d){ return FormatNumber(d.value) + " " + "<%=rampQueueToolTipText%>"; })
					.title("<%=schedulerQueueText%>", function(d){ return FormatNumber(d.value) + " " + "<%=schedulerQueueToolTipText%>"; })
                   .compose([
                        dc.lineChart(composite1)
                                .dimension(dateDimension)
                                .group(pipeQGroup, "<%=pipelineQueueText%>")
                                .colors('deepskyblue')
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return FormatNumber(d.value) + " " + "<%=pipelineQueueToolTipText%>"; })
                        ,
                        dc.lineChart(composite1)
                                .dimension(dateDimension)
                                .group(msgqQGroup, "<%=rampQueueText%>")
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return FormatNumber(d.value) + " " + "<%=rampQueueToolTipText%>"; })
                        ,
                        dc.lineChart(composite1)
                                .dimension(dateDimension)
                                .group(schedulerQGroup, "<%=schedulerQueueText%>")
                                .colors('#148622')
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return FormatNumber(d.value) + " " + "<%=schedulerQueueToolTipText%>"; })
                    ]);
            composite1.xAxis().tickSize(0,0).tickFormat("");
            composite1.yAxis().tickSize(0,0).tickFormat("");
			
            var pipeBacklogGroup = dateDimension.group().reduceSum(dc.pluck('pipe_backlog'));
            var pipeGroup = dateDimension.group().reduceSum(dc.pluck('pipe'));
            var msgqGroup = dateDimension.group().reduceSum(dc.pluck('msgq'));
            var rampBacklogGroup = dateDimension.group().reduceSum(dc.pluck('ramp_backlog'));
            var rampGroup = dateDimension.group().reduceSum(dc.pluck('ramp'));
            var composite2 = dc.compositeChart("#divPricingBacklog");
            composite2
                    .margins({top: 5, right: 5, bottom: 64, left: 5})
					.height(255)
					.width(410)
                    .x(d3.time.scale().domain([minDate, maxDate]))
                    .elasticY(true)
                    .transitionDuration(750)
                    .legend(dc.legend().x(15).y(200).itemHeight(13).gap(5))
                    .brushOn(false)
					.renderHorizontalGridLines(true)
					.title("<%=pipelineWaitDurationText%>", function(d){ return FormatNumber(d.value) + " " + "<%=pipelineWaitDurationToolTipText%>"; })
          .title("<%=pipelineProcessingDurationText%>", function(d){ return FormatNumber(d.value) + " " + "<%=pipelineProcessingDurationToolTipText%>"; })   
                    .compose([
                        dc.lineChart(composite2)
                                .dimension(dateDimension)
                                .group(pipeBacklogGroup, "<%=pipelineWaitDurationText%>")
                                .colors('deepskyblue')
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return FormatNumber(d.value) + " " + "<%=pipelineWaitDurationToolTipText%>"; })
                        ,
                        dc.lineChart(composite2)
                                .dimension(dateDimension)
                                .group(pipeGroup, "<%=pipelineProcessingDurationText%>")
								.renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
								.title(function(d){ return FormatNumber(d.value) + " " + "<%=pipelineProcessingDurationToolTipText%>"; })
                    ])
			;

            composite2.xAxis().tickSize(0,0).tickFormat("");
            composite2.yAxis().tickSize(0,0).tickFormat("");
			
			dc.renderAll();
			
            setInterval(function() {
		d3.json("/MetraNet/AjaxServices/PricingEngineDashboardService.aspx?curTime=" + new Date().getTime(), function (error, json) {
            if (error) console.log("Error:" + error);
            else {
            json.Items.forEach(function (d) {
                d.pipe_q = +d.pipe_q;
                d.msgq_q = +d.msgq_q;
                d.scheduler_q = +d.scheduler_q;
                d.pipe_backlog = +d.pipe_backlog;
                d.pipe = +d.pipe;
                if (d.date.search(".m.") != -1) {
                  d.date = d.date.split('.').join("").toUpperCase();
                }
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


    function makeBillCloseSynopsisPart  () {
     
        var billCloseInterval = d3.select("#<%=ddBillCloses.ClientID %>").node().value;

        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=billclosedetails&intervalid=" + billCloseInterval + "&curTime=" + new Date().getTime(), function (error, json) {
            if (error)
                console.log(error);
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
              .margins({top: 10, right: 10, bottom: 75, left: 40})
			        .width(310)
			        .height(220)
              .dimension(statusDimension)
			        .transitionDuration(0)
              .group(countGroup)
  //          .xAxisPadding(15)
              .gap(17)
              .x(d3.scale.ordinal().domain(["Open", "Under Investigation", "Fixed", "Unguided"]))
			        .xUnits(dc.units.ordinal)
              .centerBar(false)
              .brushOn(false)
			        .renderHorizontalGridLines(true)
              .title(function(d){ return LocalizeTickText(d.key) + ": " + FormatNumber(d.value);} )
              .renderlet(function(chartRen) {
                          var colors =d3.scale.ordinal().domain(["Open", "Under Investigation", "Fixed", "Unguided"])
                                            .range(['deepskyblue','#0070C0','#148622','#FFC000']);
                          chart.selectAll('rect.bar').each(function(d) {
                            d3.select(this).attr("style", "fill: " + colors(d.x));
                          });

                          // rotate x-axis ticks
                          chartRen.selectAll("g.x text")
                            .style("text-anchor", "start")
                            .attr('dx', '.1em')
                            .attr('dy', '.5em')
                            .attr('transform', "rotate(45)");
              })
            ;
            chart.yAxis().tickSize(0).tickFormat(function(v) { return (v == Math.round(v)) ? v : ""; });
            chart.xAxis().outerTickSize(0);
            chart.xAxis().tickFormat(function(x) {
               return LocalizeTickText(x);
            });            
            dc.renderAll();
          }
        });


       //alert(billCloseInterval);

        d3.json("/MetraNet/MetraControl/ControlCenter/AjaxServices/VisualizeService.aspx?operation=billclosesummary&intervalid=" + billCloseInterval + "&curTime=" + new Date().getTime(), function (error, json) {
            if (error)
                console.log(error);
            else {
                var billCloseSummary = json["Items"];
               
                if (billCloseSummary[0] != null) {
                  //var type = billCloseSummary[0]["type"];
                    var billgroups = billCloseSummary[0]["billgroups"];
                    var start = billCloseSummary[0]["start"];
                    var end = billCloseSummary[0]["end"];
                    var daysuntilrun = billCloseSummary[0]["days_until_run"];
                  
                 
                   if(daysuntilrun == 0){
                        d3.select("#tdBillCloseSynopisDaysUntilRun").attr("class","tblclszerovalue");
                     }
                    else{
                         d3.select("#tdBillCloseSynopisDaysUntilRun").attr("class","tblclshasvalue");
                    }

                 <%--   d3.select("#<%=txtBillCloseSynopisType.ClientID%>").text(LocalizeTypeText(type));--%>
                    d3.select("#<%=txtBillCloseSynopisBillGroups.ClientID%>").text(billgroups);
                    d3.select("#<%=txtBillCloseSynopisStart.ClientID%>").text(RenderDate(start, DATE_FORMAT));
                    d3.select("#<%=txtBillCloseSynopisEnd.ClientID%>").text(RenderDate(end, DATE_FORMAT));
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
            "text": "<%=FixedWord%>"
          },
          {
            "x_axis": -100,
            "y_axis": 20,
             "color": "#148622",
            "text": "<%=OpenWord%>"
          },
          {
            "x_axis": -100,
            "y_axis": 30,
            "color": "#0070C0",
            "text": "<%=UnderInvestigationWord%>"
          },
          {
            "x_axis": -100,
            "y_axis": 40,
            "color": "#7F7F7F",
            "text": "<%=UnguidedWord%>"
          }
            ];

         
        CreateLegend(legenddata,d3.select("#svgBillCloseSynopsisLegend"));

   }

   function LocalizeTickText(text) {
      var localizedTickText = '';
      if (text == 'Open')
        localizedTickText = '<%=OpenWord%>';
      else if (text == 'Under Investigation')
        localizedTickText = '<%=UnderInvestigationWord%>';
      else if (text == 'Fixed')
        localizedTickText = '<%=FixedWord%>';
      else if (text == 'Unguided')
        localizedTickText = '<%=UnguidedWord%>';
      return localizedTickText;
   }
   
  <%-- function LocalizeTypeText(text) {
     var localizedTypeText = '';
     if (text == 'M5')
       localizedTypeText = '<%=TypeM5Text%>';
     else if (text == 'M12')
       localizedTypeText = '<%=TypeM12Text%>';
     else if (text == 'M19')
       localizedTypeText = '<%=TypeM19Text%>';
      else if (text == 'M26')
        localizedTypeText = '<%=TypeM26Text%>';
     else if (text == 'EOM')
        localizedTypeText = '<%=TypeEOMText%>';
     return localizedTypeText;

   }   --%> 
   
   function FormatNumber(d) {
    return parseFloat(d).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: 2, minimumFractionDigits: 0 });
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
            }).data('gridster').disable();
        });
    </script>
</asp:Content>

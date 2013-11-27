<%@ Page Language="C#" AutoEventWireup="true" Inherits="Mobile_HistoryChart" CodeFile="HistoryChart.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Usage History</title>
    
    <script type="text/javascript" src="jqPlot/jquery-1.3.2.min.js"></script>
    <script type="text/javascript" src="jqPlot/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="jqplot/plugins/jqplot.dateAxisRenderer.min.js"></script>
    <script type="text/javascript" src="jqPlot/plugins/jqplot.barRenderer.min.js"></script>
    <link rel="stylesheet" type="text/css" href="jqPlot/jquery.jqplot.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="jqPlot" id="chart1" style="height:320px; width:320px;"></div>
        <script type="text/javascript">
            line1 = [<%= ChartData %>];
            plot10 = $.jqplot('chart1', [line1], {
                title: 'Usage History Per Billing Period',
                gridPadding: { right: 35 },
                axes: {
                    xaxis: {
                        renderer: $.jqplot.DateAxisRenderer,
                        tickOptions: { formatString: '%b %#d, %y' },
                        tickInterval: '1 month'
                    },
                    yaxis: {
                      tickOptions:{formatString:'$%.2f'} 
                    }
                },
                series: [{ lineWidth: 4, markerOptions: { style: 'square'}}]
            });
        </script>    
    </form>
</body>
</html>

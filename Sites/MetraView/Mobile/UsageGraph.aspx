<%@ Page Language="C#" AutoEventWireup="true" Inherits="AjaxServices_UsageGraph" CodeFile="UsageGraph.aspx.cs" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Usage Details</title>
    
    <script type="text/javascript" src="jqPlot/jquery-1.3.2.min.js"></script>
    <script type="text/javascript" src="jqPlot/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="jqPlot/plugins/jqplot.pieRenderer.min.js"></script>
    <link rel="stylesheet" type="text/css" href="jqPlot/jquery.jqplot.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="jqPlot" id="chart1" style="height:320px; width:320px;"></div>
        <script type="text/javascript">
            line1 = [<%= ChartData %>];
            plot1 = $.jqplot('chart1', [line1], {
              title: 'Usage By Department',
              seriesDefaults: { renderer: $.jqplot.PieRenderer, rendererOptions: { sliceMargin: 8} },
              legend: { show: true }
            });
        </script>    
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" Inherits="AjaxServices_ProductGraph" CodeFile="ProductGraph.aspx.cs" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Usage Details</title>
    
    <script type="text/javascript" src="jqPlot/jquery-1.3.2.min.js"></script>
    <script type="text/javascript" src="jqPlot/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="jqPlot/plugins/jqplot.canvasTextRenderer.min.js"></script>
    <script type="text/javascript" src="jqPlot/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
    <script type="text/javascript" src="jqPlot/plugins/jqplot.categoryAxisRenderer.min.js"></script>
    <script type="text/javascript" src="jqPlot/plugins/jqplot.barRenderer.min.js"></script>
    <link rel="stylesheet" type="text/css" href="jqPlot/jquery.jqplot.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="jqPlot" id="chart1" style="height:320px; width:320px;"></div>
        <script type="text/javascript">
            line1 = [ <%= ChartData %> ];
            plot1 = $.jqplot('chart1', [line1], {
                legend:{show:false, location:'ne', xoffset:55},
                title:'Products',
                seriesDefaults:{
                    renderer:$.jqplot.BarRenderer, 
                    rendererOptions:{barPadding: 8, barMargin: 20}
                },
               axesDefaults: {
                      tickRenderer: $.jqplot.CanvasAxisTickRenderer ,
                      tickOptions: {
                        angle: -30,
                        fontSize: '10pt'
                      }
                  },
                axes:{
                    xaxis:{
                        renderer:$.jqplot.CategoryAxisRenderer, 
                        ticks:[ <%= ChartLabels %> ]
                    }, 
                    yaxis:{
                        min:0,
                        tickOptions:{formatString:'$%.2f'} 
                    }
                }
            });
        </script>    
    </form>
</body>
</html>

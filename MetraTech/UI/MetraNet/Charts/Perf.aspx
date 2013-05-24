<%@ Page Title="Home Page" Language="C#"  AutoEventWireup="true" Inherits="Perf" CodeFile="Perf.aspx.cs" %>
<html>
  <head>
    <title>High Resolution Timings</title>
    <script type="text/javascript" src="/Res/jqPlot/jquery-1.4.2.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasTextRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.categoryAxisRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.barRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.cursor.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.highlighter.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasTextRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.dateAxisRenderer.min.js"></script>
    <!--[if IE]><script type="text/javascript" src="/Res/jqPlot/excanvas.min.js"></script><![endif]-->
    <link rel="stylesheet" type="text/css" href="/Res/jqPlot/jquery.jqplot.css" />
  </head>
  <body>
    <h2>
        High Resolution Timings
    </h2>
    <div class="jqPlot" id="chart2" style="height:600px; width:1050px;"></div>

     <script type="text/javascript">
       <%= GetChartData() %>
       plot4 = $.jqplot('chart2', [<%= GetChartDataVariables() %>], {
         legend: { show: true, location: 'ne' },
         title: 'Timings',
         grid: { background: '#f3f3f3', gridLineColor: '#accf9b' },
         series: [
          <%= GetLabels() %>
        ],
        axesDefaults: {
          tickRenderer: $.jqplot.CanvasAxisTickRenderer ,
          tickOptions: {
            angle: -45,
            fontSize: '8pt'
          }
        },
        axes:{
            xaxis:{
                renderer:$.jqplot.DateAxisRenderer, 
                tickOptions:{formatString:'%m/%#d/%y %H:%M:%S'}
            }, 
            yaxis:{
                min:0
            }
        },
        cursor:{tooltipLocation:'sw', zoom:true, showTooltip:false} 

        });
        </script>   
         
        <h2>Raw Data</h2>
        <textarea rows="5" cols="100"><%=RawData %></textarea>
        <br />
        <%= DataLinks %>

</body>
</html>


<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_ProductUsageGraph" CodeFile="ProductUsageGraph.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" VaryByCustom="username" shared="true" %>

    <script type="text/javascript" src="/Res/jqPlot/jquery.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasTextRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.categoryAxisRenderer.min.js"></script>
    <script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.barRenderer.min.js"></script>
    <!--[if IE]><script type="text/javascript" src="/Res/jqPlot/excanvas.min.js"></script><![endif]-->
    <link rel="stylesheet" type="text/css" href="/Res/jqPlot/jquery.jqplot.css" />

        <script type="text/javascript">
            line2 = [ <%= ChartData %> ];
            if(line2.length > 0)
            {
              document.write('<div class="jqPlot" id="chart2" style="height:250px; width:265px;"></div>');
              plot2 = $.jqplot('chart2', [line2], {
                  legend:{show:false, location:'ne', xoffset:55},
                  seriesDefaults:{
                      renderer:$.jqplot.BarRenderer, 
                      rendererOptions:{barPadding: 8, barMargin: 20}
                  },
                 axesDefaults: {
                        tickRenderer: $.jqplot.CanvasAxisTickRenderer,
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
                          tickOptions:{formatString:GRAPH_CURRENCY_FORMAT} 
                      }
                  }
              });
              document.write('<%= GetGraphText() %>');
            }
            else
            {
              document.write('<br /><%=Resources.Resource.TEXT_NO_TRANSACTIONS_FOUND.Replace("'", "\\'") %>');
            }
        </script>    
    

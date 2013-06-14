<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="History" CodeFile="History.aspx.cs" Culture="auto" UICulture="auto"
  Title="<%$Resources:Resource,TEXT_TITLE%>"  %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<h1><asp:Localize meta:resourcekey="BillingHistory" runat="server">Billing History</asp:Localize></h1>

<script type="text/javascript" src="/Res/jqPlot/jquery.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/jquery.jqplot.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.dateAxisRenderer.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasTextRenderer.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.highlighter.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.cursor.min.js"></script>
<!--[if IE]><script type="text/javascript" src="/Res/jqPlot/excanvas.min.js"></script><![endif]-->
<link rel="stylesheet" type="text/css" href="/Res/jqPlot/jquery.jqplot.css" />

<style type="text/css">
  .jqplot-point-label 
  {
    font-size:1em;
  }
  
  table.jqplot-cursor-tooltip {
      font-size: 1em;
  }

  .jqplot-cursor-tooltip {
      font-size: 1em;
  }

  .jqplot-highlighter-tooltip {
      font-size: 1em;
  }  
</style>

<div id="noUsage" style="display:none;"><%=Resources.Resource.TEXT_NO_TRANSACTIONS_FOUND.Replace("'", "\\'")%></div>
<div class="jqPlot" id="chart1" style="height:500px; width:500px;"></div>

<script type="text/javascript">
 
 jQuery(document).ready(function($){

    line1 = [<%= ChartData %>];
    xticks = [<%= XTicks %>];

    if(line1.length > 1)
    {
      plot1 = $.jqplot('chart1', [line1], {
            grid: { background: '#f3f3f3', gridLineColor: '#accf9b' },
            axes:{
                xaxis:{ 
                    renderer:$.jqplot.DateAxisRenderer,
                    rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer}, 
                    ticks: xticks,
                    tickOptions:{
                        formatString: GRAPH_DATE_FORMAT,
                        fontSize:'10pt', 
                        fontFamily:'Tahoma', 
                        angle:-45
                    }
                },
                yaxis:{
                    min:<%=GetYMin()%>,
                    tickOptions:{
                        formatString: GRAPH_CURRENCY_FORMAT,
                        fontSize:'10pt', 
                        fontFamily:'Tahoma'
                    }
                }
            },
            highlighter:{ 
              show:true, 
              sizeAdjust:7.5, 
              formatString:'%s: %s' 
            },
            cursor: {show: false}
      });    
    }
    else
    {
      $('#noUsage').show();
    }

    function getColumnLocation(plot,gridpos,length)
    {
        // Get the width of the graph area minus the space taken up with axises.
        var insidewidth = plot.grid._width;
        var colwidth = insidewidth / length;
        var column = parseInt(gridpos.x / colwidth);
        return column;
    }

    $('#chart1').bind('jqplotClick', 
        function (ev, gridpos, datapos, neighbor, plot) {
			    if(plot.targetId == "#chart1") {
			      
				    var column = getColumnLocation(plot,gridpos,line1.length);
            document.location.href = "bill.aspx?interval=" + plot.data[0][parseInt(column)][2] + "&invoiceno=" + plot.data[0][parseInt(column)][3];
			    }
        }
    );

  });
</script>    

</asp:Content>
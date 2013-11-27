<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_UsageGraph" CodeFile="UsageGraph.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" VaryByCustom="username" shared="true" %>
<script type="text/javascript" src="/Res/jqPlot/jquery.min.js"></script>
<script type="text/javascript" src="/Res/jqPlot/jquery.jqplot.js"></script>
<script type="text/javascript" src="/Res/jqPlot/plugins/jqplot.pieRenderer.min.js"></script>
<!--[if IE]><script type="text/javascript" src="/Res/jqPlot/excanvas.min.js"></script><![endif]-->
<link rel="stylesheet" type="text/css" href="/Res/jqPlot/jquery.jqplot.css" />

<script type="text/javascript">
      line1 = [<%= ChartData %>];
      if(line1.length > 0)
      {
        document.write('<div class="jqPlot" id="chart1" style="height:250px; width:290px;"></div>');
      
        plot1 = $.jqplot('chart1', [line1], {
          grid: {
              drawBorder: false, 
              drawGridlines: false,
              background: '#ffffff',
              shadow:false
          },
          seriesDefaults:{
              renderer:$.jqplot.PieRenderer,
              rendererOptions: {
                  sliceMargin: 1, 
                  padding: 10
              }
          },
          legend:{
            show:true, 
            location: 'sw',
            fontSize:'8pt', 
            fontFamily:'Tahoma',
            xoffset:-80
          }
        }); 

        document.write('<%= GetGraphText() %>');
      }
      else
      {
        document.write('<br /><%=Resources.Resource.TEXT_NO_TRANSACTIONS_FOUND.Replace("'", "\\'")%>');
      }
</script>    


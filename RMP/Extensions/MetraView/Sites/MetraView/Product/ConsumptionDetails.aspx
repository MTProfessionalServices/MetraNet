<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/DetailsPageExt.master" AutoEventWireup="true" CodeFile="ConsumptionDetails.aspx.cs" Inherits="MetraView.Product.ConsumptionDetails" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <style type=text/css> 
        /* style rows on mouseover */
        .x-grid3-row-over .x-grid3-cell-inner {
            font-weight: bold;
        }
    </style> 
 

    <script>
      var store;
      var myData = <%= GetJsonData() %>

      Ext.onReady(function () {
        Ext.QuickTips.init();

        // Custom function used to render quantity
        function quantityRenderer(val) {
          if (val > myData.IncludedQuantity) {
            return '<span style="color:red;">' + val + '</span>';
          } else {
            return '<span style="color:black;">' + val + '</span>';
          }
          return val;
        }

        // Custom rendering function for running total
        var total = 0;
        function runningTotalRenderer(value, meta, record, rowIndex, colIndex, store)
        {
          total = total + record.data.Quantity;
          return Ext.util.Format.number(total, "0.000000");
        }

        // create the data store
        store = new Ext.data.ArrayStore({
        sortInfo: {
            field: 'Date',
            direction: 'ASC' // or 'DESC' (case sensitive for local sorting)
        },
          fields: [
           { name: 'Date', type: 'date', mapping: 'Date', dateFormat: DATE_LONG_FORMAT},
           { name: 'DayOfWeek', type: 'string', mapping: 'DayOfWeek'},
           { name: 'Quantity', type: 'float', mapping: 'Quantity' }
        ]
        });

        // Load the data into the store
        store.loadData(myData.Days);

        // create the Grid
        var grid = new Ext.grid.GridPanel({
          store: store,
          columns: [
            {
              header: 'Date',
              width: 95,
              sortable: true,
              renderer: Ext.util.Format.dateRenderer('m/d/Y'),
              dataIndex: 'Date'
            },
            {
              header: 'Day Of Week',
              width: 95,
              sortable: true,
              dataIndex: 'DayOfWeek'
            },
            {
              header: 'Consumed',
              width: 95,
              sortable: true,
              renderer: quantityRenderer,
              dataIndex: 'Quantity'
            }
            /*,
            {
              header: 'Total Consumed',
              width: 100,
              sortable: true,
              renderer: runningTotalRenderer,
              dataIndex: 'runningTotal'
            }*/
        ],
          stripeRows: true,
          height: 600,
          width: 300,
          title: 'Daily Consumption Details',
        });

        // render the grid to the specified div in the page
        grid.render('grid1');

    $.jqplot.config.enablePlugins = true;

          var xLabels = new Array();
          var consumed = new Array();
          var average = new Array();
          var runningTotal = new Array();
          var included = new Array();
          var total = 0;
          var avg = 0;
          var min = null;
          var max = null;
          var monday = 0;
          var tuesday = 0;
          var wednesday = 0;
          var thursday = 0;
          var friday = 0;
          var saturday = 0;
          var sunday = 0;
          var mondayLength = 0;
          var tuesdayLength = 0;
          var wednesdayLength = 0;
          var thursdayLength = 0;
          var fridayLength = 0;
          var saturdayLength = 0;
          var sundayLength = 0;

          for (var i = 0; i < store.data.length; i++) {
            xLabels.push([i, Ext.util.Format.date(store.data.items[i].get('Date'), 'Y-m-d')]);
            consumed.push(store.data.items[i].get('Quantity'));
            avg += store.data.items[i].get('Quantity');
            total += store.data.items[i].get('Quantity');
            runningTotal.push(total);

            if(min == null)
             min = store.data.items[i].get('Quantity');
            
            if(min > store.data.items[i].get('Quantity'))
             min = store.data.items[i].get('Quantity');

            if(max == null)
             max = store.data.items[i].get('Quantity');
            
            if(max < store.data.items[i].get('Quantity'))
             max = store.data.items[i].get('Quantity');

            if(store.data.items[i].get('DayOfWeek') == "Monday")
            { 
              monday += store.data.items[i].get('Quantity');
              mondayLength++;
            }
            if(store.data.items[i].get('DayOfWeek') == "Tuesday")
            { 
              tuesday += store.data.items[i].get('Quantity');
              tuesdayLength++;
            }
            if(store.data.items[i].get('DayOfWeek') == "Wednesday")
            { 
              wednesday += store.data.items[i].get('Quantity');
              wednesdayLength++;
            }
            if(store.data.items[i].get('DayOfWeek') == "Thursday")
            { 
              thursday += store.data.items[i].get('Quantity');
              thursdayLength++;
            }
            if(store.data.items[i].get('DayOfWeek') == "Friday")
            { 
              friday += store.data.items[i].get('Quantity');
              fridayLength++;
            }
            if(store.data.items[i].get('DayOfWeek') == "Saturday")
            { 
              saturday += store.data.items[i].get('Quantity');
              saturdayLength++;
            }
            if(store.data.items[i].get('DayOfWeek') == "Sunday")
            { 
              sunday += store.data.items[i].get('Quantity');
              sundayLength++;
            }
          }
          
          avg = avg / store.data.length;
          
          monday = monday / mondayLength;
          tuesday = tuesday / tuesdayLength;          
          wednesday = wednesday / wednesdayLength;          
          thursday = thursday / thursdayLength;          
          friday = friday / fridayLength;          
          saturday = saturday / saturdayLength;          
          sunday = sunday / sundayLength;

          var avgNode = Ext.get("average");
          if(avgNode != null)
            avgNode.dom.innerHTML = Ext.util.Format.number(avg, "0.000000");

          var maximumNode = Ext.get("maximum");
          if(maximumNode != null)
            maximumNode.dom.innerHTML = Ext.util.Format.number(max, "0.000000");

          var minimumNode = Ext.get("minimum");
          if(minimumNode != null)
            minimumNode.dom.innerHTML = Ext.util.Format.number(min, "0.000000");

          for(i=0; i < store.data.length; i++)
          { 
            average.push(avg);
            included.push(myData.IncludedQuantity);
          }

          // Graph 1
          plot1 = $.jqplot('graph1', [consumed, average], {
              legend:{show:true}, 
              title:'Daily Consumption',
              grid: {background:'#f3f3f3', gridLineColor:'#accf9b'},
              highlighter:{ 
                show:true, 
                sizeAdjust:7.5, 
                formatString:'%s: %s' 
              },
              cursor: {show: false},
              seriesDefaults: {showMarker:false},
              series:[
                  {label:'Consumed', markerOptions:{style:'square'}}, 
                  {label:'Average'}
              ],
              axes:{
                xaxis:{
                    renderer:$.jqplot.DateAxisRenderer,
                    rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer},
                    ticks:xLabels,
                    tickOptions:{formatString: GRAPH_DATE_FORMAT,showGridline: false, showLabel: false, angle: -90}
                }, 
                yaxis:{tickOptions:{showGridline: true, formatString:'%.6f'}}
              }
          });

         
          // Graph 2
          plot2 = $.jqplot('graph2', [runningTotal, included], {
              legend:{show:true}, 
              title:'Running Total Consumption',
              grid: {background:'#f3f3f3', gridLineColor:'#accf9b'},
              highlighter:{ 
                show:false, 
                sizeAdjust:7.5, 
                formatString:'%s: %s' 
              },
              cursor: {show: false},
              seriesDefaults: {showMarker:false},
              series:[
                  {label:'Consumed', markerOptions:{style:'square'}}, 
                  {label:'Included'}
              ],
              axes:{
                xaxis:{
                    renderer:$.jqplot.DateAxisRenderer,
                    rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer},
                    ticks:xLabels,
                    tickOptions:{formatString: GRAPH_DATE_FORMAT, showGridline: false, showLabel: false, angle: -90}
                }, 
                yaxis:{tickOptions:{showGridline: true, formatString:'%.6f'}}
              }
          });
          
          // Graph 3
          lineMon = [monday];
          lineTues = [tuesday];
          lineWed = [wednesday];
          lineThurs = [thursday];
          lineFri = [friday];
          lineSat = [saturday];
          lineSun = [sunday];
          plot3 = $.jqplot('graph3', [lineMon, lineTues, lineWed, lineThurs, lineFri, lineSat, lineSun], {
              legend:{show:true, location:'ne'},
              title:'Average Consumption by Day',
              highlighter:{ 
                show:false, 
                sizeAdjust:7.5, 
                formatString:'%s: %s' 
              },
              cursor: {show: false},
              series:[
                  {label:'Monday', renderer:$.jqplot.BarRenderer}, 
                  {label:'Tuesday', renderer:$.jqplot.BarRenderer}, 
                  {label:'Wednesday', renderer:$.jqplot.BarRenderer}, 
                  {label:'Thursday', renderer:$.jqplot.BarRenderer}, 
                  {label:'Friday', renderer:$.jqplot.BarRenderer}, 
                  {label:'Saturday', renderer:$.jqplot.BarRenderer}, 
                  {label:'Sunday', renderer:$.jqplot.BarRenderer}
              ],
              axes:{
                  xaxis:{
                    renderer:$.jqplot.CategoryAxisRenderer,
                    tickOptions:{showLabel: false}
                  }
              }
          });

          
      });    

    </script> 

    <h1>Daily Consumption</h1> 
    
    <div class="left" style="padding:10px;">
      <div id="grid1"></div> 
      <table>
        <tr><td>Minimum:</td><td align="right"><span id="minimum"></span></td></tr>
        <tr><td>Maximum:</td><td align="right"><span id="maximum"></span></td></tr>
        <tr><td>Average:</td><td align="right"><span id="average"></span></td></tr>
      </table>
    </div>
    <div class="left" style="padding:10px;border-left: solid 1px silver;width: 350px; height 600px;">
      <div class="jqPlot" id="graph1" style="height:250px; width:350px;"></div> 
      <div class="jqPlot"  id="graph2" style="height:250px; width:350px;"></div>
      <div class="jqPlot"  id="graph3" style="height:250px; width:350px;"></div>
    </div>


</asp:Content>
